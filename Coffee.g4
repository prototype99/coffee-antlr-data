grammar Coffee;

/*
LEXER
*/

// comments

SINGLE_COMMENT : '//' .*? '\n' ->skip;
MULTI_COMMENT : '/*' .*? '*/' ->skip;

// reserved words

IMPORT : 'import';
VOID : 'void';
INT : 'int';
FLOAT : 'float';
BOOLEAN : 'bool';
BREAK : 'break';
CONTINUE : 'continue';
RETURN : 'return';
IF : 'if';
ELSE : 'else';
FOR : 'for';
IN : 'in';
WHILE : 'while';
TRUE : 'true';
FALSE : 'false';

// operators

ADD : '+';
SUB : '-';
DIV : '/';
MUL : '*';
EQ : '=';
NEQ : '!=';
DEQ : '==';
LTEQ : '<=';
GTEQ : '>=';
LT : '<';
GT : '>';
AND : '&&';
OR : '||';

// brackets

LSQUARE : '[';
RSQUARE : ']';
LCURLY : '{';
RCURLY : '}';
LROUND : '(';
RROUND : ')';

// identifier & components

fragment ALPHA : [_a-zA-Z];
fragment NUM : [0-9];
fragment ALPHA_NUM : ALPHA | NUM;
ID : ALPHA ALPHA_NUM*;

// numerical literals

INT_LIT : NUM+;
FLOAT_LIT : NUM+ DOT NUM* | NUM* DOT NUM+;

// valid char

fragment VALID_CHAR : ~['"\n\t\r\f] | '\\' ['"ntrf];
CHAR_LIT : SQUOTE VALID_CHAR SQUOTE;
STRING_LIT : DQUOTE VALID_CHAR* DQUOTE;

// misc

QUEST : '?';
DOT : '.';
COMMA : ',';
COLON : ':';
SEMI : ';';
DQUOTE : '"';
SQUOTE : '\'';
NOT : '!';
MOD : '%';

// whitespace

WS : [ \n\t\r\f] -> skip;

/*
parser
*/

program : (import_stmt | global_decl | method_decl | block)* EOF;

import_stmt : IMPORT ID (COMMA ID)* SEMI;

global_decl : var_decl;

var_decl : data_type var_assign (COMMA var_assign)* SEMI;

var_assign : var (EQ expr)?;

var : ID | ID LSQUARE INT_LIT RSQUARE;

data_type : INT | FLOAT | BOOLEAN;

method_decl : return_type ID LROUND (param (COMMA param)*)? RROUND (block | expr);

return_type : data_type | VOID;

param : data_type ID;

block : LCURLY (var_decl | block)* RCURLY
    | statement;

statement : method_call SEMI #eval
    | location assign_op expr SEMI #assign
    | IF LROUND expr RROUND block (ELSE block)? #if
    | FOR LROUND loop_var IN (ID | limit) RROUND block #for
    | WHILE LROUND expr RROUND block #while
    | RETURN expr? SEMI #return
    | BREAK SEMI #break
    | CONTINUE SEMI #continue
    | SEMI #pass;

loop_var : ID;

method_call : ID LROUND (expr (COMMA expr)*)? RROUND;

expr : LROUND expr RROUND
    | LROUND data_type RROUND expr
    | SUB expr
    | NOT expr
    | expr (MUL | DIV | MOD) expr
    | expr (ADD | SUB) expr
    | expr (GT | LT | GTEQ | LTEQ) expr
    | expr (DEQ | NEQ) expr
    | expr AND expr
    | expr OR expr
    | expr QUEST expr COLON expr
    | location
    | literal
    | method_call;

assign_op : EQ;

literal : INT_LIT | FLOAT_LIT | bool_lit | STRING_LIT | CHAR_LIT;

bool_lit : TRUE | FALSE;

location : ID | ID LSQUARE expr RSQUARE;

limit : LSQUARE low? COLON high? (COLON step)? RSQUARE;

low : expr;

high : expr;

step : expr;
