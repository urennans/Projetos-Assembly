section .data
    numero dd -1234567    ; Número sinalizado (teste com positivos/negativos)
    sinal db '-'          ; Armazena o sinal (será sobrescrito se positivo)
    newline db 0xA        ; Quebra de linha

section .bss
    buffer resb 11        ; Buffer para dígitos (10 dígitos + sinal)

section .text
    global _start

_start:
    mov eax, [numero]    ; Carrega o número
    call imprimir_sinalizado

    ; Quebra de linha
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Sai do programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

imprimir_sinalizado:
    test eax, eax
    jns .positivo

    ; Se negativo:
    neg eax              
    mov byte [sinal], '-' ; Define o sinal como '-'
    jmp .converte

.positivo:
    mov byte [sinal], '+' ; Opcional: pode remover para não mostrar '+'

.converte:
    mov edi, buffer + 10 ; Aponta para o final do buffer
    mov byte [edi], 0    ; Terminador nulo (opcional)

    mov ebx, 10

.dividir:
    dec edi
    xor edx, edx         
    div ebx              
    add dl, '0'          ; Converte resto para ASCII
    mov [edi], dl        ; Armazena no buffer
    test eax, eax        ; Verifica se EAX == 0
    jnz .dividir         

    ; Imprime o sinal (se negativo)
    cmp byte [sinal], '-'
    jne .imprime_numero
    mov eax, 4
    mov ebx, 1
    mov ecx, sinal
    mov edx, 1
    int 0x80

.imprime_numero:
    ; Imprime os dígitos
    mov eax, 4
    mov ebx, 1
    mov ecx, edi         ; Início do número no buffer
    mov edx, buffer + 11 ; Calcula tamanho
    sub edx, edi
    int 0x80
    ret