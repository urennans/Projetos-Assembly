section .data
    num1    dd -15      ; Primeiro número (pode ser negativo)
    num2    dd 42       ; Segundo número
    num3    dd 30       ; Terceiro número
    msg     db "A soma dos dois maiores é: ", 0
    newline db 10       ; Caractere de nova linha

section .bss
    buffer  resb 12     ; Buffer para conversão numérica

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

    ; Imprime a mensagem
    mov ecx, msg
    call imprimir_string

    ; Converte e imprime o resultado
    call imprimir_numero

    ; Imprime nova linha
    mov ecx, newline
    call imprimir_string

    ; Sai do programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

encontrar_dois_maiores:
    ; Compara num1 (eax) e num2 (ebx)
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

imprimir_string:
    ; Calcula o tamanho da string
    mov edx, 0
.calcula_tamanho:
    cmp byte [ecx + edx], 0
    je .imprime
    inc edx
    jmp .calcula_tamanho
.imprime:
    mov eax, 4        ; sys_write
    mov ebx, 1        ; stdout
    int 0x80
    ret

imprimir_numero:
    ; Verifica se é negativo
    test eax, eax
    jns .positivo
    neg eax
    push eax
    mov ecx, '-'
    mov [buffer], ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    pop eax

.positivo:
    ; Converte número para string
    mov edi, buffer + 11
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
    mov ecx, edi
    mov edx, buffer + 12
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret