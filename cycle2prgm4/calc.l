%{
#include "y.tab.h"   // tokens from YACC
#include <stdio.h>
#include <stdlib.h>
%}

%option noyywrap

%%

[0-9]+      { yylval.ival = atoi(yytext); return NUMBER; }  // numbers
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MUL; }
"/"         { return DIV; }
"("         { return LPAREN; }
")"         { return RPAREN; }
[ \t]+      ;  // ignore spaces/tabs
\n          { return '\n'; }
.           { return yytext[0]; }  // any other char

%%


