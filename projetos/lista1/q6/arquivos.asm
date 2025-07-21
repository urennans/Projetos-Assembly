section .data
    filename db "./numeros.txt", 0
    format   db "A soma dos dois maiores é: %d", 10, 0
    error1   db "Erro: Arquivo não encontrado ou sem permissão", 10, 0
    error2   db "Erro: O arquivo deve conter 3 números inteiros", 10, 0
    mode     db "r", 0             ; Modo de abertura para leitura
    buffer   times 32 db 0         ; Buffer maior para segurança

section .bss
    nums     resd 3
    fd       resq 1

section .text
    global main
    extern printf, fopen, fclose, fgets, atoi, exit

main:
    push rbp
    mov rbp, rsp
    push r12                      ; Preserva R12 (ABI requer preservação)

    ; Abre arquivo
    mov rdi, filename
    mov rsi, mode                 ; Modo "r" para leitura
    call fopen
    test rax, rax
    jz .file_error
    mov [fd], rax

    ; Lê os números
    xor r12, r12                  ; Contador
    lea rbx, [nums]               ; Endereço do array

.read_loop:
    ; Lê uma linha
    mov rdi, buffer
    mov rsi, 32                   ; Tamanho do buffer
    mov rdx, [fd]
    call fgets
    test rax, rax                 ; Verifica EOF
    jz .check_count

    ; Converte para inteiro
    mov rdi, buffer
    call atoi
    mov [rbx + r12*4], eax        ; Armazena no array
    inc r12
    cmp r12, 3
    jl .read_loop

.check_count:
    ; Fecha arquivo
    mov rdi, [fd]
    call fclose

    ; Verifica se leu 3 números
    cmp r12, 3
    jne .count_error

    ; ----- Lógica de comparação -----
    mov eax, [nums]
    mov ebx, [nums+4]
    mov ecx, [nums+8]

    ; Ordena os 3 números (eax >= ebx >= ecx)
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
    add eax, ebx                  ; Soma os dois maiores

    ; Imprime resultado
    mov rdi, format
    mov esi, eax
    xor eax, eax
    call printf

    ; Sai com sucesso
    mov rax, 60
    xor rdi, rdi
    syscall

.file_error:
    mov rdi, error1
    xor eax, eax
    call printf
    mov rax, 60
    mov rdi, 1
    syscall

.count_error:
    mov rdi, error2
    xor eax, eax
    call printf
    mov rax, 60
    mov rdi, 1
    syscall
    
    
    
section .note.GNU-stack noalloc noexec nowrite progbits
