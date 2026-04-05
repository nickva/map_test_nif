-module(map_test_nif).

-export([
   make_map/2,
   dupbug/0
]).

-on_load(init/0).

init() ->
    PrivDir = code:priv_dir(map_test_nif),
    erlang:load_nif(filename:join(PrivDir, "map_test_nif"), 0).

% A thin layer on top of enif_make_map_from_arrays, take two separate lists for
% key and values. This is a quick and dirty thing for testing only
%
make_map(_Keys, _Vals) ->
    erlang:nif_error(not_loaded).

dupbug() ->
    % The important bit here is that we create enough entries to start with a
    % hashmap, but end with a flatmap after dedup (if everthing worked as
    % intended). Of course, if we got a proper duplicate rejection error we
    % wouldn't be in this predicament to start with.
    %
    % So the first bug is we don't get reject duplicate error back and second
    % bug is the map we get can be invalid - it won't match against a pure
    % Erlang created map with the exact same keys and values.
    %
    Keys = [k0, k1 | [k0 || _ <- lists:seq(1, 32)]],
    Vals = lists:seq(1, 34),

    NifRes = make_map(Keys, Vals),
    Erl = maps:from_list(lists:zip(Keys, Vals)),
    case NifRes of
        {ok, Nif} ->
            io:format("~nBug1: didn't fail on duplicates:~nIn:~p~nOut:~p~n", [{Keys, Vals}, Nif]),
            case Nif =:= Erl of
                true ->
                    ok;
                false ->
                    io:format("~nBug2: after failing, returned map doesn't match erlang map", []),
                    io:format("~nNif map: ~p~nErl map: ~p~n", [Nif, Erl]),
                    not_ok
            end;
        _ ->
             io:format("~nNo bugs. We got rejected duplicated, which is what the API promised us~n", [])
    end.
