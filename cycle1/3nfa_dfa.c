#include <stdio.h>
#include <stdlib.h>
#define MAX 20
struct node1 {
int nst[MAX];
};
int transition[MAX][MAX][MAX];
int transitionCount[MAX][MAX];
int set[MAX], nostate, noalpha, notransition, nofinal, start, complete = -1;
int finalstate[MAX];
char alphabet[MAX];
struct node1 hash[MAX];
int findalpha(char c) {
for (int i = 0; i < noalpha; i++) {
if (alphabet[i] == c)
return i;
}
return 999;
}
int compare(struct node1 a, struct node1 b) {
for (int i = 1; i <= nostate; i++) {
if (a.nst[i] != b.nst[i])
return 0;
}
return 1;
}
int insertdfastate(struct node1 newstate) {
for (int i = 0; i <= complete; i++) {
if (compare(hash[i], newstate))
return 0;
}
complete++;
hash[complete] = newstate;
return 1;
}
void printnewstate(struct node1 state) {
int first = 1;
printf("{");
for (int j = 1; j <= nostate; j++) {
if (state.nst[j] != 0) {
if (!first) printf(",");
printf("q%d", state.nst[j]);
first = 0;
}
}
printf("}");
}
void findfinalstate() {
printf("Final States of DFA: ");
int found = 0;
for (int i = 0; i <= complete; i++) {
for (int j = 1; j <= nostate; j++) {
for (int k = 0; k < nofinal; k++) {
if (hash[i].nst[j] == finalstate[k]) {
printnewstate(hash[i]);
printf(" ");
found = 1;
j = nostate; // break outer loop
break;
}
}
}
}
if (!found) printf("None");
printf("\n");
}
void insert(int from, char symbol, int to) {
int index = findalpha(symbol);
if (index == 999) {
printf("Invalid input symbol: %c\n", symbol);
exit(1);
}
int count = transitionCount[from][index];
transition[from][index][count] = to;
transitionCount[from][index]++;
}
int main() {
int i, j, k, m;
struct node1 newstate = {0}, tmpstate = {0};
printf("NOTE: Use 'e' for epsilon and place it last if present.\n");
printf("\nEnter number of alphabets: ");
scanf("%d", &noalpha);
getchar();
printf("Enter the alphabets one per line:\n");
for (i = 0; i < noalpha; i++) {
alphabet[i] = getchar();
getchar();
}
printf("Enter number of states: ");
scanf("%d", &nostate);
printf("Enter start state (e.g., 1): ");
scanf("%d", &start);
printf("Enter number of final states: ");
scanf("%d", &nofinal);
printf("Enter final states:\n");
for (i = 0; i < nofinal; i++) {
scanf("%d", &finalstate[i]);
}
printf("Enter number of transitions: ");
scanf("%d", &notransition);
printf("Enter transitions in format: from_state alphabet to_state\n");
for (i = 0; i < notransition; i++) {
int from, to;
char symbol;
scanf("%d %c %d", &from, &symbol, &to);
insert(from, symbol, to);
}
for (i = 0; i < MAX; i++)
for (j = 0; j < MAX; j++)
hash[i].nst[j] = 0;
printf("\nEquivalent DFA Construction\n");
printf("-----------------------------\n");
newstate.nst[start] = start;
insertdfastate(newstate);
i = -1;
while (i != complete) {
i++;
newstate = hash[i];
for (k = 0; k < noalpha; k++) {
for (j = 1; j <= nostate; j++) set[j] = 0;
int count = 0;
for (j = 1; j <= nostate; j++) {
int src = newstate.nst[j];
if (src != 0) {
for (int d = 0; d < transitionCount[src][k]; d++) {
int dst = transition[src][k][d];
if (set[dst] == 0) {
set[dst] = dst;
count++;
}
}
}
}
for (m = 1; m <= nostate; m++)
tmpstate.nst[m] = set[m];
printf("d(");
printnewstate(newstate);
printf(", %c) = ", alphabet[k]);
if (count != 0) {
insertdfastate(tmpstate);
printnewstate(tmpstate);
} else {
printf("NULL");
}
printf("\n");
}
}
printf("\nDFA States:\n");
for (i = 0; i <= complete; i++) {
printf("State %d: ", i);
printnewstate(hash[i]);
printf("\n");
}
printf("\nDFA Alphabet Set: ");
for (i = 0; i < noalpha; i++)
printf("%c ", alphabet[i]);
printf("\n");
printf("Start State of DFA: ");
printnewstate(hash[0]);
printf("\n");
findfinalstate();
printf("\nConversion Complete.\n");
return 0;
}
