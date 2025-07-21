section .data
    prompt1 db "Digite o primeiro número: ", 0
    prompt2 db "Digite o segundo número: ", 0
    prompt3 db "Digite o terceiro número: ", 0
    format  db "A soma dos dois maiores números é: %d", 10, 0
    scanf_fmt db "%d", 0

section .bss
    num1 resd 1
    num2 resd 1
    num3 resd 1

section .text
    global main
    extern printf, scanf

main:
    push rbp
    mov rbp, rsp

    ; Lê o primeiro número
    mov rdi, prompt1
    xor eax, eax
    call printf
    mov rdi, scanf_fmt
    mov rsi, num1
    xor eax, eax
    call scanf

    ; Lê o segundo número
    mov rdi, prompt2
    xor eax, eax
    call printf
    mov rdi, scanf_fmt
    mov rsi, num2
    xor eax, eax
    call scanf

    ; Lê o terceiro número
    mov rdi, prompt3
    xor eax, eax
    call printf
    mov rdi, scanf_fmt
    mov rsi, num3
    xor eax, eax
    call scanf

    ; Lógica para encontrar os dois maiores
    mov eax, [num1]
    mov ebx, [num2]
    mov ecx, [num3]

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
    add eax, ebx

    ; Imprime resultado
    mov rdi, format
    mov esi, eax
    xor eax, eax
    call printf

    pop rbp
    xor eax, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
