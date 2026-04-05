#include "erl_nif.h"

static ERL_NIF_TERM make_map(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    unsigned int klen, vlen;
    // [{K,V},...] would be cleaner but we're lazy, so it's two lists so they
    // can become two arrays and we can test the thing
    if(!enif_get_list_length(env, argv[0], &klen) ||
       !enif_get_list_length(env, argv[1], &vlen) ||
       klen != vlen) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM* keys = enif_alloc(klen * sizeof(ERL_NIF_TERM));
    ERL_NIF_TERM* vals = enif_alloc(vlen * sizeof(ERL_NIF_TERM));

    ERL_NIF_TERM head, rest;
    unsigned int i;

    i = 0;
    rest = argv[0];
    while(enif_get_list_cell(env, rest, &head, &rest)) {keys[i++] = head;}

    i = 0;
    rest = argv[1];
    while(enif_get_list_cell(env, rest, &head, &rest)) {vals[i++] = head;}

    ERL_NIF_TERM map;
    int ok = enif_make_map_from_arrays(env, keys, vals, klen, &map);

    enif_free(keys);
    enif_free(vals);

    if(ok) {
        return enif_make_tuple2(env, enif_make_atom(env, "ok"), map);
    } else {
        return enif_make_atom(env, "error");
    }
}

static ErlNifFunc nif_funcs[] = {
    {"make_map", 2, make_map}
};

ERL_NIF_INIT(map_test_nif, nif_funcs, NULL, NULL, NULL, NULL)
