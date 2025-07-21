// soma_array.c
void soma_array(int *vetor1, int *vetor2, int *resultado, int tamanho) {
    for (int i = 0; i < tamanho; i++) {
        resultado[i] = vetor1[i] + vetor2[i];
    }
}