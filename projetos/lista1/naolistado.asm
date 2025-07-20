;Crie uma função assembly que imprima na tela um número inteiro não sinalizado, 
;definido na seção data, independente da quantidade de dígitos.
section .data
    numero dd 1234567    ; Teste com qualquer número aqui!
    newline db 0xA

section .bss
    buffer resb 10       ; Buffer para armazenar todos os dígitos

section .text
    global _start

_start:
    mov eax, [numero]   ; Carrega o número a ser impresso
    call imprimir_numero ; Chama a função que imprime

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

imprimir_numero:
    mov edi, buffer + 9  ; Aponta para o final do buffer
    mov byte [edi], 0    ; Terminador nulo (opcional para strings)

    mov ebx, 10          ; Divisor (base decimal)

.converte:
    dec edi              ; Move para a posição anterior no buffer
    xor edx, edx         ; Limpa EDX para a divisão
    div ebx             ; Divide EDX:EAX por 10
    add dl, '0'         ; Converte resto para ASCII
    mov [edi], dl       ; Armazena no buffer
    test eax, eax       ; Verifica se EAX == 0
    jnz .converte       ; Se não zero, continua convertendo

    ; Agora, imprime o número
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, edi        ; Início do número no buffer
    mov edx, buffer + 10 ; Calcula tamanho
    sub edx, edi        ; EDX = tamanho do número
    int 0x80

    ret