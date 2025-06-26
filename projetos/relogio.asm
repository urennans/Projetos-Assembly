section .note.GNU-stack noalloc noexec nowrite progbits
section .data
    timezone_offset equ -3 * 3600  ; Fuso de Brasília (-3h)
    colon db ":"                   ; Separador
    clear db 27,"[H",27,"[J"       ; Código para limpar terminal (ESC [ H ESC [ J)
    clear_len equ $-clear

section .bss
    buffer resb 8       ; "HH:MM:SS"

section .text
    global main

main:
    infinite_loop:
        ; Limpa o terminal (opcional)
        mov eax, 4
        mov ebx, 1
        mov ecx, clear
        mov edx, clear_len
        int 0x80

        ; Obtém timestamp
        mov eax, 13     ; syscall time()
        xor ebx, ebx
        int 0x80

        ; Ajusta fuso e calcula H/M/S (mesmo código anterior)
        add eax, timezone_offset
        xor edx, edx
        mov ebx, 3600
        div ebx
        mov edi, eax    ; horas
        mov eax, edx
        xor edx, edx
        mov ebx, 60
        div ebx
        mov esi, eax    ; minutos
        mov ecx, edx    ; segundos

        ; Converte e formata (mesmo código anterior)
        mov eax, edi
        call convert_to_ascii
        mov [buffer], ah
        mov [buffer+1], al
        mov al, [colon]
        mov [buffer+2], al
        mov eax, esi
        call convert_to_ascii
        mov [buffer+3], ah
        mov [buffer+4], al
        mov al, [colon]
        mov [buffer+5], al
        mov eax, ecx
        call convert_to_ascii
        mov [buffer+6], ah
        mov [buffer+7], al

        ; Escreve o horário
        mov eax, 4
        mov ebx, 1
        mov ecx, buffer
        mov edx, 8
        int 0x80

        ; Espera 1 segundo
        mov eax, 162     ; syscall nanosleep
        push 0           ; Parte fracionária (0)
        push 1           ; 1 segundo
        mov ebx, esp     ; Aponta para a struct timespec
        xor ecx, ecx     ; NULL (não precisa de remaning time)
        int 0x80
        add esp, 8       ; Limpa a stack

        ; Repete infinitamente
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