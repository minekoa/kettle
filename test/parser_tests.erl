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
    %% (+ 1
    %%    (/ (* 2 -3)
    %%       (- 4  5)))
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
              {'skip', 3},
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

if_e_then_s_else_s_test () ->
    %% 1| if foo == 42
    %% 2| then
    %% 3|     message = "This is the Ultimete answer of Life, the Universe, and Everything!";
    %% 4| else 
    %% 5|     message = "???";
    Tokens = [ {'if',1}, {ident,1,"foo"}, {'==',1}, {integer,1,"42"},
               {'then',2},
               {ident,3,"message"}, {'=',3}, {string,3,"\"This is the Ultimete answer of Life, the Universe, and Everything!\""}, {';',3},
               {'else',4},
               {ident,5,"message"}, {'=',5}, {string,5,"\"???\""},{';',5} ],

    Criterion = {'==',1, {lvalue,1,"foo"}, {integer,1,"42"}},
    ThenStm   = {assign, 3,
                         {ident ,3,"message"},
                         {string,3,"\"This is the Ultimete answer of Life, the Universe, and Everything!\""} },
    ElseStm   = {assign, 5,
                         {ident ,5,"message"},
                         {string,5,"\"???\""}},
    Tree   = {program, {devlist,[]},
              [{if_then_else,1, Criterion, ThenStm, ElseStm}]},

    %% {ok, {program, DevList, [{if_then_else,_,E1,B2,B3}]}} = kettparser:parse(Tokens),
    %% EC = Criterion, ?debugVal(E1), ?debugVal(EC),
    %% TB = ThenBlk  , ?debugVal(B2), ?debugVal(TB),
    %% EB = ElseBlk  , ?debugVal(B3), ?debugVal(EB),
    %% ok.
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).
    
while_e_do_b_test() ->
    %% 1| while t < 42
    %% 2| do {
    %% 3|     sleep(30);
    %% 4| }
    Tokens = [{'while',1}, {ident,1,"t"}, {'<',1}, {integer,1,"42"},
              {'do',2}, {'{',2},
              {ident,3,"sleep"}, {'(',3}, {integer,3,"30"}, {')',3}, {';',3},
              {'}',4} ],
    
    Criterion = {'<',1, {lvalue,1,"t"}, {integer,1,"42"}},
    DoBlk     = {block, [ {statement, 3, {fun_apply, 3, "sleep", [{integer,3,"30"}]}} ] },   
    Tree   = {program, {devlist,[]},
              [{while_do,1,Criterion, DoBlk}]},

    %% {ok, {program, DevList, [{while_do,_,Exp,Blk}]}} = kettparser:parse(Tokens),
    %% CEp = Criterion, ?debugVal(CEp), ?debugVal(Exp),    
    %% DBk = DoBlk    , ?debugVal(DBk), ?debugVal(Blk),    
    %% ok.
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).
               
while_e_do_s_test() ->
    %% 1| while t < 42
    %% 2| do
    %% 3|     sleep(30);
    Tokens = [{'while',1}, {ident,1,"t"}, {'<',1}, {integer,1,"42"},
              {'do',2},
              {ident,3,"sleep"}, {'(',3}, {integer,3,"30"}, {')',3}, {';',3}],
    
    Criterion = {'<',1, {lvalue,1,"t"}, {integer,1,"42"}},
    DoStm     = {statement, 3, {fun_apply, 3, "sleep", [{integer,3,"30"}]}},   
    Tree   = {program, {devlist,[]},
              [{while_do,1,Criterion, DoStm}]},

    %% {ok, {program, DevList, [{while_do,_,Exp,Blk}]}} = kettparser:parse(Tokens),
    %% CEp = Criterion, ?debugVal(CEp), ?debugVal(Exp),    
    %% DBk = DoBlk    , ?debugVal(DBk), ?debugVal(Blk),    
    %% ok.
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).

after_e_do_b_test() ->
    %% 1| after t > 42
    %% 2| do {
    %% 3|     sleep(30);
    %% 4| }
    Tokens = [{'after',1}, {ident,1,"t"}, {'>',1}, {integer,1,"42"},
              {'do',2}, {'{',2},
              {ident,3,"sleep"}, {'(',3}, {integer,3,"30"}, {')',3}, {';',3},
              {'}',4} ],
    
    Criterion = {'>',1, {lvalue,1,"t"}, {integer,1,"42"}},
    DoBlk     = {block, [ {statement, 3, {fun_apply, 3, "sleep", [{integer,3,"30"}]}} ] },   
    Tree   = {program, {devlist,[]},
              [{after_do,1,Criterion, DoBlk}]},

    %% {ok, {program, DevList, [{while_do,_,Exp,Blk}]}} = kettparser:parse(Tokens),
    %% CEp = Criterion, ?debugVal(CEp), ?debugVal(Exp),    
    %% DBk = DoBlk    , ?debugVal(DBk), ?debugVal(Blk),    
    %% ok.
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).
               
after_e_do_s_test() ->
    %% 1| after t > 42
    %% 2| do
    %% 3|     sleep(30);
    Tokens = [{'after',1}, {ident,1,"t"}, {'>',1}, {integer,1,"42"},
              {'do',2},
              {ident,3,"sleep"}, {'(',3}, {integer,3,"30"}, {')',3}, {';',3}],
    
    Criterion = {'>',1, {lvalue,1,"t"}, {integer,1,"42"}},
    DoStm     = {statement, 3, {fun_apply, 3, "sleep", [{integer,3,"30"}]}},   
    Tree   = {program, {devlist,[]},
              [{after_do,1,Criterion, DoStm}]},

    %% {ok, {program, DevList, [{while_do,_,Exp,Blk}]}} = kettparser:parse(Tokens),
    %% CEp = Criterion, ?debugVal(CEp), ?debugVal(Exp),    
    %% DBk = DoBlk    , ?debugVal(DBk), ?debugVal(Blk),    
    %% ok.
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).

wait_until_test() ->
    %% 1| wait 300
    %% 2| until foo <= 3 
    %% 3|    && bar >= 4 ;
    Tokens = [{'wait', 1}, {integer,1,"300"},
              {'until',2}, {ident,2,"foo"}, {'<=',2},{integer,2,"3"},
              {'&&',3}, {ident,3,"bar"}, {'>=',3}, {integer,3,"4"},{';',3}],
    Criterion = {'&&',3, {'<=',2, {lvalue,2,"foo"}, {integer,2,"3"}},
                         {'>=',3, {lvalue,3,"bar"}, {integer,3,"4"}}},
    Tree      = {program, {devlist,[]},
                 [{wait_until,1, {integer,1,"300"}, Criterion}]},
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).

parallel_b_test() ->                            
    %% 1| parallel {
    %% 2|     print("hogehoge");
    %% 3| }
    Tokens = [{'parallel',1}, {'{',1},
              {ident,2,"print"}, {'(',2}, {string,2,"\"hogehoge\""}, {')',2},{';',2},
              {'}',3}],
    ParaBlk ={block,[{statement,2,{fun_apply,2,"print",[{string,2,"\"hogehoge\""}]}}]},
    Tree   = {program, {devlist,[]},
              [{parallel,1, ParaBlk}]},
                
    %% {ok, {program, DevList, [{parallel,_,Blk}]}} = kettparser:parse(Tokens),
    %% ?debugVal(Blk), ?debugVal(ParaBlk),
    %% ok.
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).

parallel_s_test() ->                            
    %% 1| parallel
    %% 2|     print("hogehoge");
    Tokens = [{'parallel',1},
              {ident,2,"print"}, {'(',2}, {string,2,"\"hogehoge\""}, {')',2},{';',2}],
    ParaStm = {statement,2,{fun_apply,2,"print",[{string,2,"\"hogehoge\""}]}},
    Tree   = {program, {devlist,[]},
              [{parallel,1, ParaStm}]},
                
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).
    

funapply_test() ->
    %% 1| funcFoo( 42 );
    %% 2| funcBar( "see", you(next), time);
    %% 3| funcBuz( 1 + 2 );
    %% 4| exit();
    Tokens = [ {ident,1,"funcFoo"}, {'(',1}, {integer,1,"42"}, {')',1}, {';',1},
               {ident,2,"funcBar"}, {'(',2}, 
                     {string,2,"\"see\""}, {',',2}, 
                     {ident,2,"you"}, {'(',2}, {ident,2,"next"}, {')',2}, {',',2},
                     {ident,2,"time"}, {')',2}, {';',2},
               {ident,3,"funcBuz"}, {'(',3}, {'integer',3,"1"}, {'+',3}, {integer,3,"2"}, {')',3}, {';',3},
               {ident,4,"exit"}, {'(',4}, {')',4}, {';',4}],

    Stm1   = {statement, 1, {fun_apply,1, "funcFoo", [{integer,1,"42"}]}},
    Stm2   = {statement, 2, {fun_apply,2, "funcBar",
                             [ {string  ,2, "\"see\""},
                               {fun_apply,2, "you", [{lvalue,2,"next"}]},
                               {lvalue  ,2, "time"} ]}},
    Stm3   = {statement, 3, {fun_apply,3, "funcBuz",
                             [ {'+',3, {integer,3,"1"}, {integer,3,"2"}} ]}},
    Stm4   = {statement, 4, {fun_apply,4, "exit", []}},
    Tree   = {program, {devlist,[]}, [Stm1, Stm2, Stm3, Stm4]},

%    {ok, {program, DevList, [Sxx1, Sxx2, Sxx3, Sxx4]}} = kettparser:parse(Tokens),
%    ?debugVal(Stm1), ?debugVal(Sxx1),
%    ?debugVal(Stm2), ?debugVal(Sxx2),
%    ?debugVal(Stm3), ?debugVal(Sxx3),
%    ?debugVal(Stm4), ?debugVal(Sxx4),
%    Sxx1 = Stm1, Sxx2 = Stm2, Sxx3 = Stm3, Sxx4 = Stm4, ok.
    ?assertEqual( {ok, Tree}, kettparser:parse(Tokens)).


