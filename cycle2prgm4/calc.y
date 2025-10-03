%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}

/* Define semantic value type */
%union { int ival; }

/* Tokens with types */
%token <ival> NUMBER
%token PLUS MINUS MUL DIV
%token LPAREN RPAREN

/* Operator precedence */
%left PLUS MINUS
%left MUL DIV
%right UMINUS

%type <ival> expr

%%

input:
      /* empty */
    | input expr '\n'   { printf("= %d\n", $2); }
    | input expr ';'    { printf("= %d\n", $2); }
    | input expr        
    ;

expr:
      NUMBER            { $$ = $1; }
    | expr PLUS expr     { $$ = $1 + $3; }
    | expr MINUS expr    { $$ = $1 - $3; }
    | expr MUL expr      { $$ = $1 * $3; }
    | expr DIV expr      { 
                             if ($3 == 0) { 
                                 yyerror("Division by zero"); 
                                 $$ = 0; 
                             } else { 
                                 $$ = $1 / $3; 
                             } 
                         }
    | LPAREN expr RPAREN { $$ = $2; }
    | MINUS expr %prec UMINUS { $$ = -$2; }
    ;

%%

int main() {
    printf("Enter The Expression:\n");
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
