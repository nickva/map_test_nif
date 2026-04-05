This is a silly NIF to show the map in creation in Erlang NIFs

```
% rebar3 shell
...
1> map_test_nif:dupbug().

Bug1: didn't fail on duplicates:
In:{[k0,k1,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,k0,
     k0,k0,k0,k0,k0,k0,k0,k0,k0,k0],
    [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,
     28,29,30,31,32,33,34]}
Out:#{k1 => 2,k0 => 34}

Bug2: after failing, returned map doesn't match erlang map
Nif map: #{k1 => 2,k0 => 34}
Erl map: #{k0 => 34,k1 => 2}
not_ok
```
