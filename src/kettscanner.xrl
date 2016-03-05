Definitions.

INT        = [0-9]+
WHITESPACE = [\s\t\n]
WORD       = [A-Za-z_][A-Za-z0-9_]*
STR        = \".*\" 
VAR        = var
IF         = if
THEN       = then
ELSE       = else
WHILE      = while
AFTER      = after
DO         = do
WAIT       = wait
UNTIL      = until
PARALLEL   = parallel
SKIP       = skip
DEVICE     = device

Rules.

{INT}\.{INT}     : {token, {float   , TokenLine, TokenChars}}.
{INT}            : {token, {integer , TokenLine, TokenChars}}.
{STR}            : {token, {string  , TokenLine, TokenChars}}.
{IF}             : {token, {'if'    , TokenLine}}.
{THEN}           : {token, {then    , TokenLine}}.
{ELSE}           : {token, {else    , TokenLine}}.
{WHILE}          : {token, {while   , TokenLine}}.
{AFTER}          : {token, {'after' , TokenLine}}.
{DO}             : {token, {do      , TokenLine}}.
{WAIT}           : {token, {wait    , TokenLine}}.
{UNTIL}          : {token, {until   , TokenLine}}.
{PARALLEL}       : {token, {parallel, TokenLine}}.
{SKIP}           : {token, {skip    , TokenLine}}.
{DEVICE}         : {token, {device  , TokenLine}}.
{VAR}            : {token, {var     , TokenLine}}.
{WORD}           : {token, {ident   , TokenLine, TokenChars}}.

\,               : {token, {','     , TokenLine}}.
\;               : {token, {';'     , TokenLine}}.
\{               : {token, {'{'     , TokenLine}}.
\}               : {token, {'}'     , TokenLine}}.
\(               : {token, {'('     , TokenLine}}.
\)               : {token, {')'     , TokenLine}}.
\>\=             : {token, {'>='    , TokenLine}}. 
\<\=             : {token, {'<='    , TokenLine}}. 
\|\|             : {token, {'||'    , TokenLine}}. 
\&\&             : {token, {'&&'    , TokenLine}}. 
\=\=             : {token, {'=='    , TokenLine}}. 
\!\=             : {token, {'!='    , TokenLine}}. 

\+               : {token, {'+'     , TokenLine}}. 
\-               : {token, {'-'     , TokenLine}}. 
\*               : {token, {'*'     , TokenLine}}. 
\/               : {token, {'/'     , TokenLine}}. 
\>               : {token, {'>'     , TokenLine}}. 
\<               : {token, {'<'     , TokenLine}}. 
\=               : {token, {'='     , TokenLine}}. 
{WHITESPACE}+    : skip_token.

Erlang code.
