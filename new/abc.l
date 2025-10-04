%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
%}

/* ---------- PATTERNS ---------- */
%%
[0-9]+      { yylval.num = atoi(yytext); return NUMBER; }
[ \t]     ;   /* ignore whitespace */
.           return yytext[0];
\n          { return 0; } 
%%

int yywrap() { return 1; }
