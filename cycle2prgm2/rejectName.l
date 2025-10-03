%{
#include <stdio.h>
%}
%%
.*meer.* { printf("Rejected: contains 'meer'\n"); }
.* { printf("Accepted: %s\n", yytext); }
%%
int yywrap() {
 return 1;
}
int main() {
 yylex();
 return 0;
}