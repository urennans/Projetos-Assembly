section .data
    prompt1      db "Digite o primeiro número float: ", 0
    prompt2      db "Digite o segundo número float: ", 0
    prompt3      db "Digite o terceiro número float: ", 0
    result_a     db "a) Raiz quadrada do maior número: %f", 10, 0
    result_b     db "b) Arredondamento do menor número: %f", 10, 0
    result_c     db "c) Valor absoluto do restante em hexadecimal: 0x%08x", 10, 0
    scan_format  db "%f", 0
    debug_msg    db "Valor armazenado: %f", 10, 0

section .bss
    num1         resd 1
    num2         resd 1
    num3         resd 1
    maior        resd 1
    menor        resd 1
    resto        resd 1
    int_result   resd 1

section .text
    global main
    extern printf, scanf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32     ; Alinhar a pilha
    
    ; Inicializar FPU
    finit
    
    ; Ler os 3 números float
    call read_numbers
    
    ; Encontrar maior, menor e resto
    call find_min_max
    
    ; Calcular e mostrar resultados
    call calculate_results
    
    ; Sair com código 0
    xor eax, eax
    leave
    ret

read_numbers:
    push rbp
    mov rbp, rsp
    
    ; Primeiro número
    mov rdi, prompt1
    xor eax, eax
    call printf

    mov rdi, scan_format
    mov rsi, num1
    xor eax, eax
    call scanf
    
    ; Debug: mostrar valor lido
    mov rdi, debug_msg
    movss xmm0, [num1]
    cvtss2sd xmm0, xmm0
    mov rax, 1
    call printf

    ; Segundo número
    mov rdi, prompt2
    xor eax, eax
    call printf

    mov rdi, scan_format
    mov rsi, num2
    xor eax, eax
    call scanf
    
    ; Debug: mostrar valor lido
    mov rdi, debug_msg
    movss xmm0, [num2]
    cvtss2sd xmm0, xmm0
    mov rax, 1
    call printf

    ; Terceiro número
    mov rdi, prompt3
    xor eax, eax
    call printf

    mov rdi, scan_format
    mov rsi, num3
    xor eax, eax
    call scanf
    
    ; Debug: mostrar valor lido
    mov rdi, debug_msg
    movss xmm0, [num3]
    cvtss2sd xmm0, xmm0
    mov rax, 1
    call printf

    leave
    ret

find_min_max:
    push rbp
    mov rbp, rsp
    
    ; Inicializar maior e menor com num1
    mov eax, [num1]
    mov [maior], eax
    mov [menor], eax
    
    ; Comparar num2 com maior
    fld dword [num2]
    fld dword [maior]
    fcomip st1
    fstp st0
    jb .num2_maior
    jmp .check_num2_menor

.num2_maior:
    mov eax, [num2]
    mov [maior], eax

.check_num2_menor:
    ; Comparar num2 com menor
    fld dword [num2]
    fld dword [menor]
    fcomip st1
    fstp st0
    ja .num2_menor
    jmp .check_num3

.num2_menor:
    mov eax, [num2]
    mov [menor], eax

.check_num3:
    ; Comparar num3 com maior
    fld dword [num3]
    fld dword [maior]
    fcomip st1
    fstp st0
    jb .num3_maior
    jmp .check_num3_menor

.num3_maior:
    mov eax, [num3]
    mov [maior], eax

.check_num3_menor:
    ; Comparar num3 com menor
    fld dword [num3]
    fld dword [menor]
    fcomip st1
    fstp st0
    ja .num3_menor
    jmp .find_resto

.num3_menor:
    mov eax, [num3]
    mov [menor], eax

.find_resto:
    ; Determinar qual número é o "resto"
    mov eax, [num1]
    cmp eax, [maior]
    je .check_num1_menor
    cmp eax, [menor]
    je .check_num1_menor
    mov [resto], eax
    jmp .end

.check_num1_menor:
    mov eax, [num2]
    cmp eax, [maior]
    je .check_num2_resto
    cmp eax, [menor]
    je .check_num2_resto
    mov [resto], eax
    jmp .end

.check_num2_resto:
    mov eax, [num3]
    mov [resto], eax

.end:
    leave
    ret

calculate_results:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; a) Raiz quadrada do maior
    fld dword [maior]
    fsqrt
    fstp qword [rsp+16]
    
    mov rdi, result_a
    mov rax, 1
    movsd xmm0, [rsp+16]
    call printf
    
    ; b) Arredondamento do menor
    fld dword [menor]
    frndint
    fstp qword [rsp+8]
    
    mov rdi, result_b
    mov rax, 1
    movsd xmm0, [rsp+8]
    call printf
    
    ; c) Valor absoluto do resto em hex
    fld dword [resto]
    fabs
    fst dword [resto]     ; Armazenar valor absoluto
    mov eax, [resto]      ; Pegar representação binária IEEE 754
    mov [int_result], eax
    
    mov rdi, result_c
    mov esi, [int_result]
    xor eax, eax
    call printf
    
    leave
    ret