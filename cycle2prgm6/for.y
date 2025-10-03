%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}
%token FOR LPAREN RPAREN SEMICOLON ASSIGN LT GT LE GE EQ INC DEC
%token ID NUMBER
%%
stmt : FOR LPAREN expr_opt SEMICOLON expr_opt SEMICOLON expr_opt RPAREN
 { printf("Valid FOR statement syntax\n"); }
 ;
expr_opt : /* empty */
 | expr
 ;
expr : ID ASSIGN expr
 | ID
 | NUMBER
 | expr LT expr
 | expr GT expr
 | expr LE expr
 | expr GE expr
 | expr EQ expr
 | ID INC
 | ID DEC
 ;
%%
void yyerror(const char *s) {
 fprintf(stderr, "Error: %s\n", s);
}
int main() {
 printf("Enter a FOR statement:\n");
 yyparse();
 return 0;
}