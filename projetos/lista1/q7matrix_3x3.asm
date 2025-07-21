section .data
    ; Matriz 3x3 (exemplo)
    matriz dd 1, 2, 3
           dd 4, 5, 6
           dd 7, 8, 9
    
    ; Mensagens
    msg_det db "O determinante da matriz é: ", 0
    newline db 10, 0
    minus db "-", 0

section .bss
    char resb 1
    det resd 1
    temp resd 1

section .text
global _start

_start:
    ; Calcular o determinante usando a regra de Sarrus
    ; det = a(ei - fh) - b(di - fg) + c(dh - eg)
    
    ; Calcular a(ei - fh)
    mov eax, [matriz + 16]    ; e
    imul dword [matriz + 32]  ; *i
    mov [temp], eax
    
    mov eax, [matriz + 20]    ; f
    imul dword [matriz + 28]  ; *h
    sub [temp], eax
    
    mov eax, [matriz + 0]     ; a
    imul dword [temp]         ; * (ei - fh)
    mov [det], eax
    
    ; Calcular -b(di - fg)
    mov eax, [matriz + 12]    ; d
    imul dword [matriz + 32]  ; *i
    mov [temp], eax
    
    mov eax, [matriz + 20]    ; f
    imul dword [matriz + 24]  ; *g
    sub [temp], eax
    
    mov eax, [matriz + 4]     ; b
    imul dword [temp]         ; * (di - fg)
    sub [det], eax            ; subtrai (por causa do -b)
    
    ; Calcular c(dh - eg)
    mov eax, [matriz + 12]    ; d
    imul dword [matriz + 28]  ; *h
    mov [temp], eax
    
    mov eax, [matriz + 16]    ; e
    imul dword [matriz + 24]  ; *g
    sub [temp], eax
    
    mov eax, [matriz + 8]     ; c
    imul dword [temp]         ; * (dh - eg)
    add [det], eax
    
    ; Imprimir a mensagem
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, msg_det
    mov edx, 26
    int 0x80
    
    ; Converter o determinante para string e imprimir
    mov eax, [det]
    call print_int
    
    ; Imprimir nova linha
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Sair do programa
    mov eax, 1                ; sys_exit
    xor ebx, ebx              ; status 0
    int 0x80

; Função para imprimir um inteiro sinalizado
print_int:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Verificar se é negativo
    test eax, eax
    jns .positive
    neg eax
    push eax
    
    ; Imprimir sinal negativo
    mov eax, 4
    mov ebx, 1
    mov ecx, minus
    mov edx, 1
    int 0x80
    
    pop eax
    
.positive:
    ; Converter para string
    mov ebx, 10
    xor ecx, ecx
    
.convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    inc ecx
    test eax, eax
    jnz .convert_loop
    
    ; Imprimir dígitos
.print_loop:
    pop eax
    mov [char], al
    mov eax, 4
    mov ebx, 1
    mov ecx, char
    mov edx, 1
    int 0x80
    loop .print_loop
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret