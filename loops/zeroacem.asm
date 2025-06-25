section .data
    newline db 0xA       ; caractere de nova linha

section .bss
    buffer resb 2        ; buffer para os 2 dígitos

section .text
    global _start

_start:
    mov esi, 0           ; contador (0 a 99) em ESI (registrador seguro)

print_loop:
    ; ---- Divide o número em dezena/unidade ----
    mov eax, esi         ; número atual
    mov ebx, 10          ; divisor
    xor edx, edx         ; limpa EDX para a divisão
    div ebx              ; EAX = dezena, EDX = unidade

    ; ---- Converte para ASCII ----
    add al, '0'          ; dezena para ASCII
    mov [buffer], al     ; armazena no buffer
    add dl, '0'          ; unidade para ASCII
    mov [buffer+1], dl   ; armazena no buffer

    ; ---- Escreve os 2 dígitos ----
    mov eax, 4           ; sys_write
    mov ebx, 1           ; stdout
    mov ecx, buffer      ; ponteiro pro buffer
    mov edx, 2           ; 2 caracteres
    int 0x80

    ; ---- Escreve nova linha ----
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; ---- Incrementa e verifica se chegou em 100 ----
    inc esi
    cmp esi, 100
    jl print_loop        ; repete se < 100

    ; ---- Sai do programa ----
    mov eax, 1           ; sys_exit
    xor ebx, ebx         ; status 0
    int 0x80