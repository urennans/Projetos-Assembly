section .data
    prompt_a    db "Digite o coeficiente a: ", 0
    prompt_b    db "Digite o coeficiente b: ", 0
    prompt_c    db "Digite o coeficiente c: ", 0
    prompt_d    db "Digite o coeficiente d: ", 0
    prompt_e    db "Digite o coeficiente e: ", 0
    prompt_f    db "Digite o coeficiente f: ", 0
    prompt_x    db "Digite o valor de x: ", 0
    result_fmt  db "O resultado do polinomio é: %f", 10, 0
    scan_fmt    db "%lf", 0

section .bss
    a           resq 1
    b           resq 1
    c           resq 1
    d           resq 1
    e           resq 1
    f           resq 1
    x           resq 1
    result      resq 1

section .text
    global main
    extern printf, scanf

main:
    push rbp
    mov rbp, rsp
    
    ; Ler todos os coeficientes
    call read_coefficients
    
    ; Calcular o polinômio usando FPU
    call calculate_polynomial_fpu
    
    ; Mostrar resultado
    mov rdi, result_fmt
    mov rax, 1
    movq xmm0, [result]
    call printf
    
    pop rbp
    ret

read_coefficients:
    push rbp
    mov rbp, rsp
    
    ; Ler a
    mov rdi, prompt_a
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, a
    xor eax, eax
    call scanf
    
    ; Ler b
    mov rdi, prompt_b
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, b
    xor eax, eax
    call scanf
    
    ; Ler c
    mov rdi, prompt_c
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, c
    xor eax, eax
    call scanf
    
    ; Ler d
    mov rdi, prompt_d
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, d
    xor eax, eax
    call scanf
    
    ; Ler e
    mov rdi, prompt_e
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, e
    xor eax, eax
    call scanf
    
    ; Ler f
    mov rdi, prompt_f
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, f
    xor eax, eax
    call scanf
    
    ; Ler x
    mov rdi, prompt_x
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, x
    xor eax, eax
    call scanf
    
    pop rbp
    ret

calculate_polynomial_fpu:
    push rbp
    mov rbp, rsp
    
    finit
    
    ; Carregar x
    fld qword [x]
    
    ; Calcular x^5
    fld st0
    fmul st0, st0    ; x^2
    fld st0
    fmul st0, st2     ; x^3
    fld st0
    fmul st0, st3     ; x^4
    fld st0
    fmul st0, st4     ; x^5
    
    ; Multiplicar por a (ax^5)
    fmul qword [a]
    
    ; bx^4 (st4 contém x^4)
    fxch st4
    fmul qword [b]
    faddp st1, st0
    
    ; cx^3 (st3 contém x^3)
    fxch st3
    fmul qword [c]
    faddp st1, st0
    
    ; dx^2 (st2 contém x^2)
    fxch st2
    fmul qword [d]
    faddp st1, st0
    
    ; ex (st1 contém x)
    fxch st1
    fmul qword [e]
    faddp st1, st0
    
    ; +f
    fadd qword [f]
    
    ; Armazenar resultado
    fstp qword [result]
    
    pop rbp
    ret