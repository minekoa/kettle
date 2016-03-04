Nonterminals
program devlist dev stmlist stm exp stmblock explist uminus.

Terminals
device ident skip 
integer float string 
';' '{' '}' '(' ')' ','
'if' 'then' 'else'
'while' 'after' 'do'
'wait' 'until' 'parallel' 'var'
'+' '-' '*' '/' '>' '<' '>=' '<='
'=' '||' '&&' '==' '!='
.

Right 100 '='.
Left  200 '||'.
Left  300 '&&'.
Left  400 '==' '!='.
Left  500 '<=' '>=' '<' '>'.
Left  600 '+' '-'.
Left  700 '*' '/'.
Unary 800 uminus.


Rootsymbol program.

program -> devlist stmlist   : {program, {devlist, '$1'}, '$2'}.
program -> stmlist           : {program, {devlist, []}  , '$1'}.

devlist -> dev devlist       : ['$1'] ++ '$2'.
devlist -> dev               : ['$1'].

dev -> device ident ';'      : {device, line_of('$1'), value_of('$2')}.

stmlist -> stm                                   : ['$1'].
stmlist -> stmlist stm                           : '$1' ++ ['$2'].

stm -> ';'                                       : {statement   , line_of('$1'), none}.
stm -> exp ';'                                   : {statement   , line_of('$2'), '$1'}.
stm -> 'skip' ';'                                : {skip        , line_of('$1')}.
stm -> ident '=' exp ';'                         : {assign      , line_of('$2'), '$1', '$3'}.
stm -> 'if' exp 'then' stmblock 'else' stmblock  : {if_then_else, line_of('$1'), '$2', '$4', '$6'}.
stm -> 'while' exp 'do' stmblock                 : {while_do    , line_of('$1'), '$2', '$4'}.
stm -> 'after' exp 'do' stmblock                 : {after_do    , line_of('$1'), '$2', '$4'}.
stm -> 'wait' exp 'until' exp ';'                : {wait_until  , line_of('$1'), '$2', '$4'}.
stm -> 'parallel' stmblock                       : {parallel    , line_of('$1'), '$2'}.
stm -> 'var' ident '=' exp ';'                   : {vardec      , line_of('$1'), '$2', '$4'}.
     
stmblock -> stm                                  : '$1'.
stmblock -> '{' stmlist '}'                      : {block, '$2'}.
stmblock -> '{' '}'                              : {block, []}.

exp -> integer               : {integer  , line_of('$1'), value_of('$1')}.
exp -> float                 : {float    , line_of('$1'), value_of('$1')}.
exp -> string                : {string   , line_of('$1'), value_of('$1')}.
exp -> ident                 : {lvalue   , line_of('$1'), value_of('$1')}. 
exp -> ident '(' explist ')' : {fun_apply, line_of('$1'), value_of('$1'), '$3'}.
exp -> ident '(' ')'         : {fun_apply, line_of('$1'), value_of('$1'), []}.
exp -> exp '+' exp           : {'+'      , line_of('$2'), '$1', '$3'}.
exp -> exp '-' exp           : {'-'      , line_of('$2'), '$1', '$3'}.
exp -> exp '*' exp           : {'*'      , line_of('$2'), '$1', '$3'}.
exp -> exp '/' exp           : {'/'      , line_of('$2'), '$1', '$3'}.
exp -> exp '>' exp           : {'>'      , line_of('$2'), '$1', '$3'}.
exp -> exp '<' exp           : {'<'      , line_of('$2'), '$1', '$3'}.
exp -> exp '>=' exp          : {'>='     , line_of('$2'), '$1', '$3'}.
exp -> exp '<=' exp          : {'<='     , line_of('$2'), '$1', '$3'}.
exp -> exp '==' exp          : {'=='     , line_of('$2'), '$1', '$3'}.
exp -> exp '!=' exp          : {'!='     , line_of('$2'), '$1', '$3'}.    
exp -> exp '&&' exp          : {'&&'     , line_of('$2'), '$1', '$3'}.
exp -> exp '||' exp          : {'||'     , line_of('$2'), '$1', '$3'}.
exp -> '(' exp ')'           : '$2'.
exp -> uminus                : '$1'.
    
uminus -> '-' exp            : {'-1*'  , line_of('$1'), '$2'}.
     
explist -> exp              : ['$1'].
explist -> explist ',' exp  : '$1' ++ ['$3'].
    
Erlang code.

line_of(Token) ->
    element(2, Token).

value_of(Token) ->
    element(3, Token).
   
    
    
     
