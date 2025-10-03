%{
 #include <stdio.h>
 extern int yylex();
 extern int yyerror(const char *);
 int valid = 1;
%}
%token digit letter
%%
start : letter s;
s : letter s
 | digit s
 | /* empty */
 ;
%%
int yyerror(const char *s) {
 printf("\nIt's not an identifier!\n");
 valid = 0;
 return 0;
}
int main() {
 printf("\nEnter a name to test if it's a valid identifier: ");
 yyparse();
 if (valid) {
 printf("\nIt is a valid identifier!\n");
 }
 return 0;
}