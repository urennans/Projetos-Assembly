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
    
    ; Calcular o polinômio usando SSE
    call calculate_polynomial_sse
    
    ; Mostrar resultado
    mov rdi, result_fmt
    mov rax, 1
    movsd xmm0, [result]
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

calculate_polynomial_sse:
    push rbp
    mov rbp, rsp
    
    ; Carregar x em xmm0
    movsd xmm0, [x]          ; xmm0 = x
    
    ; Calcular x^2
    movsd xmm1, xmm0         ; xmm1 = x
    mulsd xmm1, xmm0         ; xmm1 = x^2
    
    ; Calcular x^3
    movsd xmm2, xmm1         ; xmm2 = x^2
    mulsd xmm2, xmm0         ; xmm2 = x^3
    
    ; Calcular x^4
    movsd xmm3, xmm2         ; xmm3 = x^3
    mulsd xmm3, xmm0         ; xmm3 = x^4
    
    ; Calcular x^5
    movsd xmm4, xmm3         ; xmm4 = x^4
    mulsd xmm4, xmm0         ; xmm4 = x^5
    
    ; Multiplicar pelos coeficientes e acumular
    movsd xmm5, [a]          ; xmm5 = a
    mulsd xmm5, xmm4         ; xmm5 = a*x^5
    
    movsd xmm6, [b]          ; xmm6 = b
    mulsd xmm6, xmm3         ; xmm6 = b*x^4
    addsd xmm5, xmm6         ; acumula
    
    movsd xmm6, [c]          ; xmm6 = c
    mulsd xmm6, xmm2         ; xmm6 = c*x^3
    addsd xmm5, xmm6         ; acumula
    
    movsd xmm6, [d]          ; xmm6 = d
    mulsd xmm6, xmm1         ; xmm6 = d*x^2
    addsd xmm5, xmm6         ; acumula
    
    movsd xmm6, [e]          ; xmm6 = e
    mulsd xmm6, xmm0         ; xmm6 = e*x
    addsd xmm5, xmm6         ; acumula
    
    addsd xmm5, [f]          ; soma f
    
    ; Armazenar resultado
    movsd [result], xmm5
    
    pop rbp
    ret