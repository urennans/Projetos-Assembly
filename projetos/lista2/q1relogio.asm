section .data
    format db "%d/%m/%Y %H:%M:%S", 0
    newline db 10

section .bss
    time_buffer resb 64

section .text
    global main
    extern time, localtime, strftime, printf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32        ; Espaço para alinhamento e parâmetros

    ; Obter tempo atual (time(0))
    xor edi, edi
    call time
    mov [rbp-8], rax   ; Guarda o timestamp

    ; Converter para estrutura tm (localtime(&timestamp))
    lea rdi, [rbp-8]
    call localtime
    mov [rbp-16], rax   ; Guarda o ponteiro para tm

    ; Formatar a string (strftime(buffer, size, format, tm))
    mov rdi, time_buffer
    mov rsi, 64
    mov rdx, format
    mov rcx, [rbp-16]
    call strftime

    ; Imprimir resultado (printf("%s\n", buffer))
    mov rdi, time_buffer
    call printf

    ; Adicionar nova linha
    mov rdi, newline
    call printf

    ; Sair
    xor eax, eax
    leave
    ret