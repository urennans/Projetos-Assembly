section .data
    prompt db "Digite uma expressao matematica (+, -, *, /): ", 0
    result db "Resultado: %d", 10, 0
    input times 256 db 0
    error_msg db "Erro na expressao!", 10, 0

section .bss
    num1 resd 1
    num2 resd 1
    op resb 1

section .text
    global main
    extern printf, scanf, fgets, stdin

main:
    push ebp
    mov ebp, esp
    
    ; Pedir entrada do usuário
    push prompt
    call printf
    add esp, 4

    ; Ler expressão do usuário
    push dword [stdin]
    push 255
    push input
    call fgets
    add esp, 12

    ; Parsear a expressão
    mov esi, input
    
    ; Pular espaços iniciais
.skip_spaces1:
    movzx eax, byte [esi]
    cmp al, ' '
    jne .get_num1
    inc esi
    jmp .skip_spaces1

.get_num1:
    call parse_number
    mov [num1], eax
    
    ; Pular espaços após o primeiro número
.skip_spaces2:
    movzx eax, byte [esi]
    cmp al, ' '
    jne .get_op
    inc esi
    jmp .skip_spaces2

.get_op:
    mov al, [esi]
    mov [op], al
    inc esi
    
    ; Pular espaços após o operador
.skip_spaces3:
    movzx eax, byte [esi]
    cmp al, ' '
    jne .get_num2
    inc esi
    jmp .skip_spaces3

.get_num2:
    call parse_number
    mov [num2], eax

    ; Verificar se chegou ao final da string
    movzx eax, byte [esi]
    cmp al, 0
    je .calculate
    cmp al, 10     ; newline
    je .calculate
    
    jmp .error

.calculate:
    ; Realizar operação
    mov eax, [num1]
    mov ebx, [num2]
    mov cl, [op]
    
    cmp cl, '+'
    je .add
    cmp cl, '-'
    je .sub
    cmp cl, '*'
    je .mul
    cmp cl, '/'
    je .div
    
    jmp .error

.add:
    add eax, ebx
    jmp .show_result

.sub:
    sub eax, ebx
    jmp .show_result

.mul:
    imul eax, ebx
    jmp .show_result

.div:
    xor edx, edx
    idiv ebx
    jmp .show_result

.show_result:
    push eax
    push result
    call printf
    add esp, 8
    jmp .exit

.error:
    push error_msg
    call printf
    add esp, 4

.exit:
    mov esp, ebp
    pop ebp
    ret

; Função para parsear número
; esi = ponteiro para string (atualizado durante a execução)
; Retorna número em eax
parse_number:
    xor eax, eax
    xor ecx, ecx

.next_digit:
    movzx edx, byte [esi]
    test dl, dl
    jz .done
    cmp dl, 10     ; newline
    je .done
    cmp dl, ' '
    je .done
    cmp dl, '+'
    je .done
    cmp dl, '-'
    je .done
    cmp dl, '*'
    je .done
    cmp dl, '/'
    je .done
    
    sub edx, '0'
    cmp edx, 9
    ja .invalid
    
    imul eax, 10
    add eax, edx
    inc esi
    jmp .next_digit

.invalid:
    xor eax, eax
    ret

.done:
    ret