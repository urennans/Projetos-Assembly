#include <stdio.h>
#define TAMANHO 10

extern void print_array_int(int *array, int tamanho); // Implementado em Assembly

void soma_array(int *vetor1, int *vetor2, int *resultado, int tamanho) {
    for (int i = 0; i < tamanho; i++) {
        resultado[i] = vetor1[i] + vetor2[i];
    }
}

int main() {
    int vetor1[TAMANHO] = {1,2,3,4,5,6,7,8,9,10};
    int vetor2[TAMANHO] = {10,20,30,40,50,60,70,80,90,100};
    int resultado[TAMANHO];

    soma_array(vetor1, vetor2, resultado, TAMANHO);
    print_array_int(resultado, TAMANHO);

    return 0;
}