#include <stdio.h>

int main(int argc, char *argv[]) {
    printf("Eu sou o programa externo!\n");
    if(argc > 1) {
        printf("Recebi o parametro: %s\n", argv[1]);
    }
    return 0;
}