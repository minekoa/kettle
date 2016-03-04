-module(kettlint).
-export([from_string/1, from_file/1]).

from_string(String) ->
    {ok, Tokens, _} = kettscanner:string(String),
    {ok, Ast}       = kettparser:parse(Tokens),
    Ast.

from_file( FileName ) ->
    {ok, F } = file:read_file(FileName),
    from_string(binary_to_list(F)).
