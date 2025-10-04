%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ---------- AST STRUCT ---------- */
typedef struct AST {
    char *nodeType;
    int value;
    struct AST *left, *right;
} AST;

/* ---------- FUNCTION PROTOTYPES ---------- */
int yylex(void);
int yyerror(const char *s);

/* AST helpers */
AST* makeNode(char *type, AST *l, AST *r);
AST* makeNum(int val);
void printAST(AST *root, int lvl);
int evalAST(AST *root);
%}

/* ---------- UNION ---------- */
%union {
    int num;
    struct AST* node;
}

/* ---------- TOKENS & TYPES ---------- */
%token <num> NUMBER
%type <node> expr
%left '+' '-'
%left '*' '/'
%left UMINUS
%%

start:
    expr {
        printf("\nAST:\n");
        printAST($1,0);
        printf("\nResult: %d\n", evalAST($1));
    }
;

expr:
      expr '+' expr   { $$ = makeNode("+",$1,$3); }
    | expr '-' expr   { $$ = makeNode("-",$1,$3); }
    | expr '*' expr   { $$ = makeNode("*",$1,$3); }
    | expr '/' expr   { $$ = makeNode("/",$1,$3); }
    | '-' expr %prec UMINUS { $$ = makeNode("NEG",$2,NULL); }
    | '(' expr ')'    { $$ = $2; }
    | NUMBER          { $$ = makeNum($1); }
;
%%

/* ---------- FUNCTIONS ---------- */
AST* makeNode(char *type, AST *l, AST *r) {
    AST *n = malloc(sizeof(AST));
    n->nodeType = strdup(type);
    n->value = 0;
    n->left = l; n->right = r;
    return n;
}

AST* makeNum(int val) {
    AST *n = malloc(sizeof(AST));
    n->nodeType = strdup("NUM");
    n->value = val;
    n->left = n->right = NULL;
    return n;
}

void printAST(AST *root, int lvl) {
    if(!root) return;
    for(int i=0;i<lvl;i++) printf("  ");
    if(strcmp(root->nodeType,"NUM")==0)
        printf("NUM(%d)\n", root->value);
    else
        printf("%s\n", root->nodeType);
    printAST(root->left,lvl+1);
    printAST(root->right,lvl+1);
}

int evalAST(AST *root) {
    if(!root) return 0;
    if(strcmp(root->nodeType,"NUM")==0) return root->value;
    if(strcmp(root->nodeType,"+")==0) return evalAST(root->left)+evalAST(root->right);
    if(strcmp(root->nodeType,"-")==0) return evalAST(root->left)-evalAST(root->right);
    if(strcmp(root->nodeType,"*")==0) return evalAST(root->left)*evalAST(root->right);
    if(strcmp(root->nodeType,"/")==0) return evalAST(root->left)/evalAST(root->right);
    if(strcmp(root->nodeType,"NEG")==0) return -evalAST(root->left);
    return 0;
}

int yyerror(const char *s) {
    printf("Error: %s\n", s);
    return 0;
}

int main() {
    printf("Enter arithmetic expression:\n");
    yyparse();
    return 0;
}
