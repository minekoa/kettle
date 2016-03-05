-module(parser_tests).
-include_lib("eunit/include/eunit.hrl").

devlist_test () ->
    %% 1| device robot;
    %% 2| device sensor;
    %% 3| ;
    Tokens = [{device,1},{ident,1,"robot"},{';',1},
              {device,2},{ident,2,"sensor"},{';',2},
             {';',3}],
    Tree   = {program, {devlist, [{device,1,"robot"},
                                  {device,2,"sensor"}]},
              [{statement,3,none}]},
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).

vardec_test () ->
    %% 1| var foo = 42;
    %% 2| var bar = "hello world!";
    %% 3| var buz = hoge;
    Tokens = [{var,1},{ident,1,"foo"},{'=',1},{integer,1,"42"},{';',1},
              {var,2},{ident,2,"bar"},{'=',2},{string ,2,"\"hello world!\""},{';',2},
              {var,3},{ident,3,"buz"},{'=',3},{ident  ,3,"hoge"},{';',3}],
    Tree   = {program, {devlist, []},
              [{vardec,1, {ident,1,"foo"},{integer,1,"42"}},
               {vardec,2, {ident,2,"bar"},{string ,2,"\"hello world!\""}},
               {vardec,3, {ident,3,"buz"},{lvalue ,3,"hoge"}}]},
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).

numcalc_test () ->
    %% 1| 1 + 2 *
    %% 2| -3
    %% 3| / (4 - 5)
    %% 4| ;
    Tokens = [{integer,1,"1"},{'+',1},{integer,1,"2"},{'*',1},
              {'-',2},{integer,2,"3"},
              {'/',3},{'(',3},{integer,3,"4"},{'-',3},{integer,3,"5"},{')',3},
              {';',4}],
    % (+1 (/ (* 2 -3) (- 4 5)))
    Tree    = {program, {devlist,[]},
               [{statement,4,
                 {'+',1,
                      {integer,1,"1"},
                      {'/',3,
                           {'*',1,
                                {integer,1,"2"},
                                {'-1*',2,{integer,2,"3"}}},
                           {'-',3,
                            {integer,3,"4"},{integer,3,"5"}}}}}]},
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).

skip_test () ->
    %% 1| device robot;
    %% 2|
    %% 3| skip
    %% 4| ;
    Tokens = [{device,1},{ident,1,"robot"},{';',1},
              {'skip',3},
              {';',4}],
    Tree   = {program, {devlist,[{device,1, "robot"}]},
              [{skip, 3}]},
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).
    
if_e_then_b_else_b_test () ->
    %% 1| if foo == 42
    %% 2| then {
    %% 3|     message = "This is the Ultimete answer of Life, the Universe, and Everything!";
    %% 4| }
    %% 5| else {
    %% 6|     message = "???";
    %% 7| }
    Tokens = [ {'if',1}, {ident,1,"foo"}, {'==',1}, {integer,1,"42"},
               {'then',2}, {'{', 2},
               {ident,3,"message"}, {'=',3}, {string,3,"\"This is the Ultimete answer of Life, the Universe, and Everything!\""}, {';',3},
               {'}',4},
               {'else',5}, {'{',5},
               {ident,6,"message"}, {'=',6}, {string,6,"\"???\""},{';',6},
               {'}',7} ],

    Criterion = {'==',1, {lvalue,1,"foo"}, {integer,1,"42"}},
    ThenBlk   = {block, [{assign, 3,
                          {ident ,3,"message"},
                          {string,3,"\"This is the Ultimete answer of Life, the Universe, and Everything!\""}}]},
    ElseBlk   = {block, [{assign, 6,
                          {ident ,6,"message"},
                          {string,6,"\"???\""}}]},
    Tree   = {program, {devlist,[]},
              [{if_then_else,1, Criterion, ThenBlk, ElseBlk}]},

    %% {ok, {program, DevList, [{if_then_else,_,E1,B2,B3}]}} = kettparser:parse(Tokens),
    %% EC = Criterion, ?debugVal(E1), ?debugVal(EC),
    %% TB = ThenBlk  , ?debugVal(B2), ?debugVal(TB),
    %% EB = ElseBlk  , ?debugVal(B3), ?debugVal(EB),
    %% ok.
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).
    
