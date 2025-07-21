section .data
    prompt db "Digite uma expressão matemática (+, -, *, /, ()): ", 0
    result db "Resultado: %d", 10, 0
    input times 256 db 0       ; Buffer para entrada do usuário
    error_msg db "Erro na expressão!", 10, 0

section .text
    global main
    extern printf, scanf, malloc, free

main:
    ; Alocar espaço para a pilha de avaliação
    mov rdi, 256
    call malloc
    mov r12, rax               ; r12 = ponteiro para a pilha
    mov r13, rax               ; r13 = topo da pilha

    ; Pedir entrada do usuário
    mov rdi, prompt
    xor rax, rax
    call printf

    ; Ler expressão do usuário
    mov rdi, input
    mov rsi, 255               ; Máximo de 255 caracteres
    mov rdx, [rel stdin]
    call fgets

    ; Avaliar a expressão
    mov rdi, input
    mov rsi, r12
    call evaluate_expression

    ; Verificar se há resultado na pilha
    cmp r13, r12
    jne .valid_result

    ; Se não, erro
    mov rdi, error_msg
    xor rax, rax
    call printf
    jmp .exit

.valid_result:
    ; Imprimir resultado
    mov rdi, result
    mov esi, [r12]
    xor rax, rax
    call printf

.exit:
    ; Liberar memória e sair
    mov rdi, r12
    call free
    xor rax, rax
    ret

; Função para avaliar expressão
; rdi = ponteiro para string
; rsi = ponteiro para pilha
evaluate_expression:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov r12, rdi               ; r12 = string de entrada
    mov r13, rsi               ; r13 = base da pilha
    lea rbx, [rsi + 256]       ; rbx = topo da pilha

    xor rcx, rcx               ; Contador de parênteses

.eval_loop:
    movzx eax, byte [r12]
    test al, al
    jz .eval_done

    ; Ignorar espaços
    cmp al, ' '
    je .next_char

    ; Verificar dígito
    cmp al, '0'
    jb .not_digit
    cmp al, '9'
    ja .not_digit

    ; Processar número
    call parse_number
    push rax
    jmp .next_char

.not_digit:
    ; Verificar operador ou parêntese
    cmp al, '('
    je .open_paren
    cmp al, ')'
    je .close_paren
    cmp al, '+'
    je .add_op
    cmp al, '-'
    je .sub_op
    cmp al, '*'
    je .mul_op
    cmp al, '/'
    je .div_op

    ; Caractere inválido
    jmp .eval_error

.open_paren:
    inc rcx
    push '('
    jmp .next_char

.close_paren:
    dec rcx
    js .eval_error             ; Parêntese fechado sem aberto

    ; Avaliar até encontrar '('
.close_loop:
    pop rdx
    cmp dl, '('
    je .next_char

    pop rsi
    pop rdi
    call do_operation
    push rax
    jmp .close_loop

.add_op:
    push '+'
    jmp .next_char

.sub_op:
    push '-'
    jmp .next_char

.mul_op:
    push '*'
    jmp .next_char

.div_op:
    push '/'
    jmp .next_char

.next_char:
    inc r12
    jmp .eval_loop

.eval_done:
    ; Verificar parênteses balanceados
    test rcx, rcx
    jnz .eval_error

    ; Avaliar operações restantes
.eval_remaining:
    cmp rsp, rbp
    je .eval_success

    pop rdx
    pop rsi
    pop rdi
    call do_operation
    push rax
    jmp .eval_remaining

.eval_success:
    pop rax                    ; Resultado final
    mov [r13], eax             ; Armazenar na base da pilha
    jmp .eval_exit

.eval_error:
    mov qword [r13], 0         ; Limpar resultado
    mov rdi, error_msg
    xor rax, rax
    call printf

.eval_exit:
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

; Função para parsear número
; r12 = ponteiro para string
; Retorna número em rax
parse_number:
    xor eax, eax
    xor ecx, ecx

.parse_loop:
    movzx edx, byte [r12]
    sub edx, '0'
    cmp edx, 9
    ja .parse_done

    imul eax, 10
    add eax, edx
    inc r12
    jmp .parse_loop

.parse_done:
    dec r12                   ; Ajustar ponteiro
    ret

; Função para executar operação
; rdi = operando esquerdo
; rsi = operando direito
; dl = operador
; Retorna resultado em rax
do_operation:
    cmp dl, '+'
    je .do_add
    cmp dl, '-'
    je .do_sub
    cmp dl, '*'
    je .do_mul
    cmp dl, '/'
    je .do_div

    xor eax, eax              ; Operador inválido
    ret

.do_add:
    add edi, esi
    mov eax, edi
    ret

.do_sub:
    sub edi, esi
    mov eax, edi
    ret

.do_mul:
    imul edi, esi
    mov eax, edi
    ret

.do_div:
    xor edx, edx
    mov eax, edi
    idiv esi
    ret

section .bss
    ; Nada adicional necessário