section .data
    format db "A soma dos dois maiores números é: %d", 10, 0
    usage  db "Uso: %s <num1> <num2> <num3>", 10, 0

section .text
    global main
    extern printf, atoi, exit

main:
    push rbp
    mov rbp, rsp

    ; Verifica número de argumentos (argc em edi)
    cmp edi, 4          ; 1 (nome do programa) + 3 números
    je .process_args
    
    ; Mostra mensagem de uso
    mov rdi, usage
    mov rsi, [rsi]      ; Nome do programa (argv[0])
    xor eax, eax
    call printf
    mov edi, 1
    call exit

.process_args:
    ; Converte argumentos para inteiros
    mov rbx, rsi        ; Preserva argv

    ; Primeiro número (argv[1])
    mov rdi, [rbx + 8]
    call atoi
    push rax            ; Salva num1

    ; Segundo número (argv[2])
    mov rdi, [rbx + 16]
    call atoi
    push rax            ; Salva num2

    ; Terceiro número (argv[3])
    mov rdi, [rbx + 24]
    call atoi
    push rax            ; Salva num3

    ; Recupera os números
    pop rcx             ; num3
    pop rbx             ; num2
    pop rax             ; num1

    ; Encontra os dois maiores
    cmp eax, ebx
    jge .cmp1
    xchg eax, ebx
.cmp1:
    cmp eax, ecx
    jge .cmp2
    xchg eax, ecx
.cmp2:
    cmp ebx, ecx
    jge .sum
    xchg ebx, ecx

.sum:
    add eax, ebx        ; Soma os dois maiores

    ; Imprime resultado
    mov rdi, format
    mov esi, eax
    xor eax, eax
    call printf

    pop rbp
    xor eax, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
