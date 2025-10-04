%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int yylex(void);
struct quad {
    char op[8];
    char arg1[64];
    char arg2[64];
    char result[64];
} QUAD[256];

struct stack {
    int items[200];
    int top;
} stk;

int Index = 0;
int tIndex = 0;
int StNo, Ind, tInd;
extern int LineNo;

/* function prototypes used in actions */
void push(int data);
int pop();
void AddQuadruple(const char op[], const char arg1[], const char arg2[], char result[]);
void yyerror(const char *s);

%}

/* semantic value */
%union {
    char var[64];
}

%token <var> NUM VAR RELOP
%token MAIN IF ELSE WHILE TYPE
%type <var> EXPR ASSIGNMENT CONDITION

%left '-' '+'
%left '*' '/'

%%

PROGRAM : MAIN BLOCK
        ;

BLOCK : '{' CODE '}'
      ;

CODE : BLOCK
     | STATEMENT CODE
     | STATEMENT
     ;

STATEMENT : DESCT ';'
          | ASSIGNMENT ';'
          | CONDST
          | WHILEST
          ;

DESCT : TYPE VARLIST
      ;

VARLIST : VAR ',' VARLIST
        | VAR
        ;

ASSIGNMENT : VAR '=' EXPR
            {
                /* assignment quadruple: result is the variable on LHS */
                strcpy(QUAD[Index].op, "=");
                strcpy(QUAD[Index].arg1, $3);
                QUAD[Index].arg2[0] = '\0';
                strcpy(QUAD[Index].result, $1);
                /* $$ gets the result (LHS variable name) */
                strcpy($$, QUAD[Index].result);
                Index++;
            }
          ;

EXPR : EXPR '+' EXPR
        { AddQuadruple("+", $1, $3, $$); }
     | EXPR '-' EXPR
        { AddQuadruple("-", $1, $3, $$); }
     | EXPR '*' EXPR
        { AddQuadruple("*", $1, $3, $$); }
     | EXPR '/' EXPR
        { AddQuadruple("/", $1, $3, $$); }
     | '-' EXPR
        { AddQuadruple("UMIN", $2, "", $$); }
     | '(' EXPR ')'
        { strcpy($$, $2); }
     | VAR
        { strcpy($$, $1); }
     | NUM
        { strcpy($$, $1); }
     ;

CONDST : IFST
       | IFST ELSEST
       ;

IFST : IF '(' CONDITION ')' 
        {
            /* create a conditional check quad that jumps to FALSE (placeholder) */
            strcpy(QUAD[Index].op, "==");
            strcpy(QUAD[Index].arg1, $3);
            strcpy(QUAD[Index].arg2, "FALSE");
            /* result will store the target index later; put placeholder "-1" */
            strcpy(QUAD[Index].result, "-1");
            push(Index);
            Index++;
        }
       BLOCK
        {
            /* after block, create unconditional GOTO placeholder and push it */
            strcpy(QUAD[Index].op, "GOTO");
            QUAD[Index].arg1[0] = '\0';
            QUAD[Index].arg2[0] = '\0';
            strcpy(QUAD[Index].result, "-1");
            push(Index);
            Index++;
        }
     ;

ELSEST : ELSE 
            {
                tInd = pop();
                Ind = pop();
                /* push back else-target to be fixed later */
                push(tInd);
                /* set the earlier conditional's result to current Index (start of else) */
                sprintf(QUAD[Ind].result, "%d", Index);
            }
         BLOCK
            {
                Ind = pop();
                sprintf(QUAD[Ind].result, "%d", Index);
            }
        ;

CONDITION : VAR RELOP VAR
            {
                /* condition quad: op is the relational operator */
                AddQuadruple($2, $1, $3, $$);
                StNo = Index - 1;
            }
          | VAR
            { strcpy($$, $1); }
          | NUM
            { strcpy($$, $1); }
          ;

WHILEST : WHILELOOP
        ;

WHILELOOP : WHILE '(' CONDITION ')' 
              {
                  /* create comparison quad */
                  strcpy(QUAD[Index].op, "==");
                  strcpy(QUAD[Index].arg1, $3);
                  strcpy(QUAD[Index].arg2, "FALSE");
                  strcpy(QUAD[Index].result, "-1");
                  push(Index);    /* push the location of the conditional */
                  Index++;
              }
            BLOCK
              {
                  /* create GOTO placeholder back to condition start */
                  strcpy(QUAD[Index].op, "GOTO");
                  QUAD[Index].arg1[0] = '\0';
                  QUAD[Index].arg2[0] = '\0';
                  strcpy(QUAD[Index].result, "-1");
                  push(Index);
                  Index++;
              }
            {
                /* fix jumps: pop GOTO placeholder and conditional placeholder to set targets */
                int gotoIndex = pop();  /* GOTO placeholder index */
                int condIndex = pop();  /* conditional placeholder index */

                /* GOTO should jump back to start of loop (we'll set it to condIndex) */
                sprintf(QUAD[gotoIndex].result, "%d", condIndex);

                /* conditional should jump to next instruction after loop (current Index) */
                sprintf(QUAD[condIndex].result, "%d", Index);
            }
          ;

%%

/* Epilogue: C code for helper functions and main */

extern FILE *yyin;

void push(int data) {
    if (stk.top == 199) {
        fprintf(stderr, "Stack overflow\n");
        exit(1);
    }
    stk.items[++stk.top] = data;
}

int pop() {
    if (stk.top == -1) {
        fprintf(stderr, "Stack underflow\n");
        exit(1);
    }
    return stk.items[stk.top--];
}

void AddQuadruple(const char op[], const char arg1[], const char arg2[], char result[]) {
    strcpy(QUAD[Index].op, op);
    strcpy(QUAD[Index].arg1, arg1);
    strcpy(QUAD[Index].arg2, arg2);
    sprintf(QUAD[Index].result, "t%d", tIndex);
    /* return the temp name in result (semantic $$) */
    sprintf(result, "t%d", tIndex);
    tIndex++;
    Index++;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error on line no: %d -- %s\n", LineNo, s ? s : "");
}

int main(int argc, char *argv[]) {
    FILE *fp;
    int i;

    /* initialize stack */
    stk.top = -1;

    if (argc > 1) {
        fp = fopen(argv[1], "r");
        if (!fp) {
            printf("\nFile not found\n");
            return 1;
        }
        yyin = fp;
    }

    yyparse();

    printf("\n\n\t\t----------------------------\n");
    printf("\t\tPos\tOperator\tArg1\tArg2\tResult\n");
    printf("\t\t----------------------------\n");
    for (i = 0; i < Index; i++) {
        printf("\t\t%d\t\%s\t\t%s\t\t%s\t\%s\n", i, QUAD[i].op, QUAD[i].arg1, QUAD[i].arg2, QUAD[i].result);
    }
    printf("\t\t----------------------------\n\n");
    return 0;
}
