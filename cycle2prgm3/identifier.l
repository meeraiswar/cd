%{
 #include "y.tab.h"
%}
%%
[a-zA-Z_][a-zA-Z_0-9]* return letter; // Identifiers starting with a letter or underscore
[0-9] return digit; // Single digits
. return yytext[0]; // Any other character
\n return 0; // End of input
%%
int yywrap() {
 return 1;
}