#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char result[20][20];
char copy[3];
char states[20][20];
void addState(char a[20], int i) {
strcpy(result[i], a);
}
void display(int n) {
int k = 0;
printf("\nEpsilon closure of %s = {", copy);
while (k < n) {
printf(" %s", result[k]);
k++;
}
printf(" }\n");
}
int main() {
FILE *INPUT;
INPUT = fopen("input.txt", "r");
char state1[20];
char input[20];
char state2[20];
char state[20];
int n;
printf("\nEnter The Number of States: ");
scanf("%d", &n);
printf("\nEnter The States: \n");
for (int k = 0; k < n; k++){
scanf("%s", states[k]);
}
for (int k = 0; k < n; k++) {
int i = 0;
strcpy(state, states[k]);
strcpy(copy, state);
addState(state, i++);
while (1) {
int end = fscanf(INPUT, "%s %s %s", state1, input, state2);
if (end == EOF) break;
if ((strcmp(state, state1) == 0) && (strcmp(input, "e") == 0)){
addState(state2, i++);
strcpy(state, state2);
}
}
display(i);
rewind(INPUT);
}
fclose(INPUT);
return 0;
}