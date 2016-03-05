-module(scanner_tests).
-include_lib("eunit/include/eunit.hrl").

devlist_test () ->
    %% 1| device robot;
    %% 2| device sensor;
    %% 3| ;
    String 
        =  "device robot;\n"
        ++ "device sensor;\n"
        ++ ";\n",
    Tokens = [{device,1},{ident,1,"robot"},{';',1},
              {device,2},{ident,2,"sensor"},{';',2},
             {';',3}],
    ?assertEqual( {ok, Tokens, 4}, kettscanner:string(String) ).

vardec_test () ->
    %% 1| var foo = 42;
    %% 2| var bar = "hello world!";
    %% 3| var buz = hoge;
    String 
        =  "var foo = 42;\n"
        ++ "var bar = \"hello world!\";\n"
        ++ "var buz = hoge;\n",
    Tokens = [{var,1},{ident,1,"foo"},{'=',1},{integer,1,"42"},{';',1},
              {var,2},{ident,2,"bar"},{'=',2},{string ,2,"\"hello world!\""},{';',2},
              {var,3},{ident,3,"buz"},{'=',3},{ident  ,3,"hoge"},{';',3}],
    ?assertEqual( {ok, Tokens, 4}, kettscanner:string(String) ).

numcalc_test () ->
    %% 1| 1 + 2 *
    %% 2| -3
    %% 3| / (4 - 5)
    %% 4| ;
    String 
        =  "1 + 2 *\n"
        ++ "-3\n"
        ++ "/ (4 - 5)\n"
        ++ ";\n",
    Tokens = [{integer,1,"1"},{'+',1},{integer,1,"2"},{'*',1},
              {'-',2},{integer,2,"3"},
              {'/',3},{'(',3},{integer,3,"4"},{'-',3},{integer,3,"5"},{')',3},
              {';',4}],
    ?assertEqual( {ok, Tokens, 5}, kettscanner:string(String) ).

skip_test () ->
    %% 1| device robot;
    %% 2|
    %% 3| skip
    %% 4| ;
    String 
        =  "device robot;\n"
        ++ "\n"
        ++ "skip\n;"
        ++ "\n",
    Tokens = [{device,1},{ident,1,"robot"},{';',1},
              {'skip', 3},
              {';',4}],
    ?assertEqual( {ok, Tokens, 5}, kettscanner:string(String) ).
    
if_e_then_b_else_b_test () ->
    %% 1| if foo == 42
    %% 2| then {
    %% 3|     message = "This is the Ultimete answer of Life, the Universe, and Everything!";
    %% 4| }
    %% 5| else {
    %% 6|     message = "???";
    %% 7| }
    String
        =  "if foo == 42\n"
        ++ "then {\n"
        ++ "    message = \"This is the Ultimete answer of Life, the Universe, and Everything!\";\n"
        ++ "}\n"
        ++ "else {\n"
        ++ "    message = \"???\";\n"
        ++ "}\n",
    Tokens = [ {'if',1}, {ident,1,"foo"}, {'==',1}, {integer,1,"42"},
               {'then',2}, {'{', 2},
               {ident,3,"message"}, {'=',3}, {string,3,"\"This is the Ultimete answer of Life, the Universe, and Everything!\""}, {';',3},
               {'}',4},
               {'else',5}, {'{',5},
               {ident,6,"message"}, {'=',6}, {string,6,"\"???\""},{';',6},
               {'}',7} ],
    ?assertEqual( {ok, Tokens, 8}, kettscanner:string(String) ).


if_e_then_s_else_s_test () ->
    %% 1| if foo == 42
    %% 2| then
    %% 3|     message = "This is the Ultimete answer of Life, the Universe, and Everything!";
    %% 4| else 
    %% 5|     message = "???";
    String
        =   "if foo == 42\n"
        ++  "then\n"
        ++  "    message = \"This is the Ultimete answer of Life, the Universe, and Everything!\";\n"
        ++  "else \n"
        ++  "    message = \"???\";\n",
    Tokens = [ {'if',1}, {ident,1,"foo"}, {'==',1}, {integer,1,"42"},
               {'then',2},
               {ident,3,"message"}, {'=',3}, {string,3,"\"This is the Ultimete answer of Life, the Universe, and Everything!\""}, {';',3},
               {'else',4},
               {ident,5,"message"}, {'=',5}, {string,5,"\"???\""},{';',5} ],
    ?assertEqual( {ok, Tokens, 6}, kettscanner:string(String) ).

    
while_e_do_b_test() ->
    %% 1| while t < 42
    %% 2| do {
    %% 3|     sleep(30);
    %% 4| }
    String
        =  "while t < 42\n"
        ++ "do {\n"
        ++ "    sleep(30);\n"
        ++ "}\n",
    Tokens = [{'while',1}, {ident,1,"t"}, {'<',1}, {integer,1,"42"},
              {'do',2}, {'{',2},
              {ident,3,"sleep"}, {'(',3}, {integer,3,"30"}, {')',3}, {';',3},
              {'}',4} ],
    ?assertEqual( {ok, Tokens, 5}, kettscanner:string(String) ).
               
while_e_do_s_test() ->
    %% 1| while t < 42
    %% 2| do
    %% 3|     sleep(30);
    String
        = "while t < 42\n"
        ++ "do\n"
        ++ "    sleep(30);\n",
    Tokens = [{'while',1}, {ident,1,"t"}, {'<',1}, {integer,1,"42"},
              {'do',2},
              {ident,3,"sleep"}, {'(',3}, {integer,3,"30"}, {')',3}, {';',3}],
    ?assertEqual( {ok, Tokens, 4}, kettscanner:string(String) ).


after_e_do_b_test() ->
    %% 1| after t > 42
    %% 2| do {
    %% 3|     sleep(30);
    %% 4| }
    String
        =  "after t > 42\n"
        ++ "do {\n"
        ++ "    sleep(30);\n"
        ++ "}\n",
    Tokens = [{'after',1}, {ident,1,"t"}, {'>',1}, {integer,1,"42"},
              {'do',2}, {'{',2},
              {ident,3,"sleep"}, {'(',3}, {integer,3,"30"}, {')',3}, {';',3},
              {'}',4} ],
    ?assertEqual( {ok, Tokens, 5}, kettscanner:string(String) ).
               
after_e_do_s_test() ->
    %% 1| after t > 42
    %% 2| do
    %% 3|     sleep(30);
    String
        =  "after t > 42\n"
        ++ "do\n"
        ++ "    sleep(30);\n",
    Tokens = [{'after',1}, {ident,1,"t"}, {'>',1}, {integer,1,"42"},
              {'do',2},
              {ident,3,"sleep"}, {'(',3}, {integer,3,"30"}, {')',3}, {';',3}],
    ?assertEqual( {ok, Tokens, 4}, kettscanner:string(String) ).

wait_until_test() ->
    %% 1| wait 300
    %% 2| until foo <= 3 
    %% 3|    && bar >= 4 ;
    String
        =  "wait 300\n"
        ++ "until foo <= 3 \n"
        ++ "   && bar >= 4 ;\n",
    Tokens = [{'wait', 1}, {integer,1,"300"},
              {'until',2}, {ident,2,"foo"}, {'<=',2},{integer,2,"3"},
              {'&&',3}, {ident,3,"bar"}, {'>=',3}, {integer,3,"4"},{';',3}],
    ?assertEqual( {ok, Tokens, 4}, kettscanner:string(String) ).

parallel_b_test() ->                            
    %% 1| parallel {
    %% 2|     print("hogehoge");
    %% 3| }
    String
        =  "parallel {\n"
        ++ "    print(\"hogehoge\");\n"
        ++ "}\n",
    Tokens = [{'parallel',1}, {'{',1},
              {ident,2,"print"}, {'(',2}, {string,2,"\"hogehoge\""}, {')',2},{';',2},
              {'}',3}],
    ?assertEqual( {ok, Tokens, 4}, kettscanner:string(String) ).

parallel_s_test() ->                            
    %% 1| parallel
    %% 2|     print("hogehoge");
    String
        =  "parallel\n"
        ++ "    print(\"hogehoge\");\n",
    Tokens = [{'parallel',1},
              {ident,2,"print"}, {'(',2}, {string,2,"\"hogehoge\""}, {')',2},{';',2}],
    ?assertEqual( {ok, Tokens, 3}, kettscanner:string(String) ).

funapply_test() ->
    %% 1| funcFoo( 42 );
    %% 2| funcBar( "see", you(next), time);
    %% 3| funcBuz( 1 + 2 );
    %% 4| exit();
    String
        =  "funcFoo( 42 );\n"
        ++ "funcBar( \"see\", you(next), time);\n"
        ++ "funcBuz( 1 + 2 );\n"
        ++ "exit();\n",
    Tokens = [ {ident,1,"funcFoo"}, {'(',1}, {integer,1,"42"}, {')',1}, {';',1},
               {ident,2,"funcBar"}, {'(',2}, 
                     {string,2,"\"see\""}, {',',2}, 
                     {ident,2,"you"}, {'(',2}, {ident,2,"next"}, {')',2}, {',',2},
                     {ident,2,"time"}, {')',2}, {';',2},
               {ident,3,"funcBuz"}, {'(',3}, {'integer',3,"1"}, {'+',3}, {integer,3,"2"}, {')',3}, {';',3},
               {ident,4,"exit"}, {'(',4}, {')',4}, {';',4}],
    ?assertEqual( {ok, Tokens, 5}, kettscanner:string(String) ).


