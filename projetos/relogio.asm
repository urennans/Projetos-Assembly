section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    timezone_offset equ -3 * 3600
    colon db ":"
    clear db 30,"[H",27,"[J"
    clear_len equ $-clear
    buffer_default db " 00:00:00"  ; Inicializado com zeros

section .bss
    buffer resb 8

section .text
    global main

main:
    ; Inicializa buffer com zeros
    mov edi, buffer
    mov eax, '00:00:00'  ; Carrega o padrão completo de uma vez
    mov [edi], eax
    mov eax, 0           ; Limpa qualquer resto
    mov [edi+4], eax

infinite_loop:
    ; Limpa terminal
    mov eax, 4
    mov ebx, 1
    mov ecx, clear
    mov edx, clear_len
    int 0x80

    ; Obtém tempo atual
    mov eax, 13
    xor ebx, ebx
    int 0x80

    ; Ajusta fuso horário
    add eax, timezone_offset

    ; Calcula H/M/S
    xor edx, edx
    mov ebx, 3600
    div ebx
    mov edi, eax        ; horas
    
    ; Normaliza horas (0-23)
    cmp edi, 24
    jl .hora_ok
    sub edi, 24
.hora_ok:

    mov eax, edx        ; segundos restantes
    xor edx, edx
    mov ebx, 60
    div ebx
    mov esi, eax        ; minutos
    mov ecx, edx        ; segundos

    ; Formatação do buffer
    ; Horas
    mov eax, edi
    call convert_to_ascii
    mov [buffer], ah
    mov [buffer+1], al
    mov byte [buffer+2], ':'  ; Usa valor imediato

    ; Minutos
    mov eax, esi
    call convert_to_ascii
    mov [buffer+3], ah
    mov [buffer+4], al
    mov byte [buffer+5], ':'

    ; Segundos
    mov eax, ecx
    call convert_to_ascii
    mov [buffer+6], ah
    mov [buffer+7], al

    ; Escreve no terminal
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 8
    int 0x80

    ; Espera 1 segundo
    mov eax, 162
    push 0
    push 1
    mov ebx, esp
    xor ecx, ecx
    int 0x80
    add esp, 8

    jmp infinite_loop

convert_to_ascii:
    xor edx, edx
    mov ebx, 10
    div ebx
    add al, '0'
    add dl, '0'
    mov ah, al
    mov al, dl
    ret