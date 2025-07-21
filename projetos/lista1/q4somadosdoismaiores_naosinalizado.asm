section .data
    num1 dd 25
    num2 dd 40
    num3 dd 15
    resultado_msg db "A soma dos dois maiores é: ", 0
    newline db 0xA

section .bss
    buffer resb 10

section .text
    global _start

_start:
    ; Carrega os três números
    mov eax, [num1]
    mov ebx, [num2]
    mov ecx, [num3]

    ; Encontra os dois maiores números
    call encontrar_dois_maiores

    ; Soma os dois maiores (que estão em eax e ebx)
    add eax, ebx

    ; Agora eax contém o resultado da soma
    call imprimir_numero

    ; Imprime nova linha
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Sai do programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

encontrar_dois_maiores:
    ; Compara num1 e num2
    cmp eax, ebx
    jge .compare_num3
    xchg eax, ebx     ; Troca se num2 > num1

.compare_num3:
    ; Agora eax tem o maior entre num1 e num2
    cmp eax, ecx
    jge .segundo_maior
    xchg eax, ecx     ; num3 é o maior, move para eax

.segundo_maior:
    ; Agora eax tem o maior absoluto
    ; Compara os outros dois para encontrar o segundo maior
    cmp ebx, ecx
    jge .fim
    mov ebx, ecx      ; ebx agora tem o segundo maior
.fim:
    ret

imprimir_numero:
    ; Imprime a mensagem de resultado
    push eax          ; Preserva o valor
    mov eax, 4
    mov ebx, 1
    mov ecx, resultado_msg
    mov edx, 26       ; Tamanho da mensagem
    int 0x80
    pop eax           ; Recupera o valor

    ; Converte o número em EAX para ASCII e imprime
    mov edi, buffer + 9
    mov byte [edi], 0
    mov ebx, 10

.converte:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .converte

    ; Imprime o número convertido
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buffer + 10
    sub edx, edi
    int 0x80
    ret