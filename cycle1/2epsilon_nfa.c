#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX 20
#define SYMBOLS 10
int numStates, numSymbols;
char symbols[SYMBOLS];
int eTransition[MAX][MAX];
int transition[MAX][SYMBOLS][MAX];
int newTransition[MAX][SYMBOLS][MAX];
int eClosure[MAX][MAX];
int closureSize[MAX];
int getSymbolIndex(char ch) {
for (int i = 0; i < numSymbols; i++)
if (symbols[i] == ch)
return i;
return -1;
}
void dfs(int state, int closure[], int *size) {
if (closure[state]) return; // already visited
closure[state] = 1;
closureSize[state]++;
for (int i = 0; i < numStates; i++) {
if (eTransition[state][i]) {
dfs(i, closure, size);
}
}
}
void computeEClosures() {
for (int i = 0; i < numStates; i++) {
int closure[MAX] = {0};
closureSize[i] = 0;
dfs(i, closure, &closureSize[i]);
int k = 0;
for (int j = 0; j < numStates; j++) {
if (closure[j]) {
eClosure[i][k++] = j;
}
}
closureSize[i] = k;
}
}
void removeEpsilonTransitions() {
for (int state = 0; state < numStates; state++) {
for (int sym = 0; sym < numSymbols; sym++) {
int added[MAX] = {0}; // Keep track of added states to avoid duplicates
for (int i = 0; i < closureSize[state]; i++) {
int p = eClosure[state][i]; // State reachable from E-closure
for (int j = 0; j < numStates; j++) {
if (transition[p][sym][j] && !added[j]) {
for (int k = 0; k < closureSize[j]; k++) {
int q = eClosure[j][k];
newTransition[state][sym][q] = 1;
added[q] = 1;
}
}
}
}
}
}
}
void printTransitions(int t[MAX][SYMBOLS][MAX], char *title) {
printf("\n%s:\n", title);
for (int state = 0; state < numStates; state++) {
for (int sym = 0; sym < numSymbols; sym++) {
printf("q%d -- %c --> ", state, symbols[sym]);
int flag = 0;
for (int j = 0; j < numStates; j++) {
if (t[state][sym][j]) {
printf("q%d ", j);
flag = 1;
}
}
if (!flag) printf("NULL");
printf("\n");
}
}
}
int main() {
int numET;
printf("Enter number of states: ");
scanf("%d", &numStates);
printf("Enter number of input symbols (excluding E): ");
scanf("%d", &numSymbols);
printf("Enter the input symbols (e.g., a b): ");
for (int i = 0; i < numSymbols; i++)
scanf(" %c", &symbols[i]);
printf("Enter number of E-transitions: ");
scanf("%d", &numET);
printf("Enter E-transitions (from to):\n");
for (int i = 0; i < numET; i++) {
int from, to;
scanf("%d %d", &from, &to);
eTransition[from][to] = 1;
}
int numNT;
printf("Enter number of normal transitions: ");
scanf("%d", &numNT);
printf("Enter transitions (from symbol to):\n");
for (int i = 0; i < numNT; i++) {
int from, to;
char sym;
scanf("%d %c %d", &from, &sym, &to);
int idx = getSymbolIndex(sym);
if (idx == -1) {
printf("Invalid symbol!\n");
exit(1);
}
transition[from][idx][to] = 1;
}
computeEClosures();
removeEpsilonTransitions();
printTransitions(transition, "Original Transitions");
printTransitions(newTransition, "Transitions after Removing E");
return 0;
}
