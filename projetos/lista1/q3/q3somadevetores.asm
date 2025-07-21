; q3somadevetores.asm
section .note.GNU-stack noalloc noexec nowrite progbits  ; Remove warning

section .data
    vetor1 dd 1,2,3,4,5,6,7,8,9,10
    vetor2 dd 10,20,30,40,50,60,70,80,90,100
    resultado times 10 dd 0
    TAMANHO equ 10
    format db "%d ", 0

section .text
    extern soma_array
    extern printf
    global main        ; Alterado para main

main:
    push ebp          ; Prólogo padrão do C
    mov ebp, esp

    ; Chama soma_array
    push TAMANHO
    push resultado
    push vetor2
    push vetor1
    call soma_array
    add esp, 16

    ; Imprime resultados
    mov ecx, 0
print_loop:
    mov eax, [resultado + ecx*4]
    push ecx
    push eax
    push format
    call printf
    add esp, 8
    pop ecx
    inc ecx
    cmp ecx, TAMANHO
    jl print_loop

    ; Retorna 0
    xor eax, eax
    pop ebp           ; Epílogo padrão do C
    ret