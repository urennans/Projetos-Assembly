section .data
    ; Matriz 3x3 (exemplo)
    matriz dd 1, 2, 3
           dd 4, 5, 6
           dd 7, 8, 9
    
    ; Mensagens
    msg_det db "O determinante da matriz é: ", 0
    msg_len equ $ - msg_det - 1  ; Calcula o tamanho da mensagem automaticamente
    newline db 10

section .bss
    buffer resb 12      ; Buffer para conversão de números
    det resd 1

section .text
global _start

_start:
    ; Calcular o determinante usando a regra de Sarrus
    ; det = a(ei - fh) - b(di - fg) + c(dh - eg)
    
    ; Calcular a(ei - fh)
    mov eax, [matriz + 16]    ; e (linha 1, col 2)
    imul dword [matriz + 32]  ; *i (linha 2, col 2)
    mov ebx, eax
    
    mov eax, [matriz + 20]    ; f (linha 1, col 2)
    imul dword [matriz + 28]  ; *h (linha 2, col 1)
    sub ebx, eax              ; ebx = (ei - fh)
    
    mov eax, [matriz]         ; a (linha 0, col 0)
    imul ebx                  ; eax = a*(ei - fh)
    mov [det], eax
    
    ; Calcular -b(di - fg)
    mov eax, [matriz + 12]    ; d (linha 1, col 0)
    imul dword [matriz + 32]  ; *i (linha 2, col 2)
    mov ebx, eax
    
    mov eax, [matriz + 20]    ; f (linha 1, col 2)
    imul dword [matriz + 24]  ; *g (linha 2, col 0)
    sub ebx, eax              ; ebx = (di - fg)
    
    mov eax, [matriz + 4]     ; b (linha 0, col 1)
    imul ebx                  ; eax = b*(di - fg)
    sub [det], eax            ; subtrai (por causa do -b)
    
    ; Calcular c(dh - eg)
    mov eax, [matriz + 12]    ; d (linha 1, col 0)
    imul dword [matriz + 28]  ; *h (linha 2, col 1)
    mov ebx, eax
    
    mov eax, [matriz + 16]    ; e (linha 1, col 1)
    imul dword [matriz + 24]  ; *g (linha 2, col 0)
    sub ebx, eax              ; ebx = (dh - eg)
    
    mov eax, [matriz + 8]     ; c (linha 0, col 2)
    imul ebx                  ; eax = c*(dh - eg)
    add [det], eax
    
    ; Imprimir a mensagem
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, msg_det
    mov edx, msg_len
    int 0x80
    
    ; Converter o determinante para string e imprimir
    mov eax, [det]
    call print_number
    
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

; Função para imprimir um número inteiro (com sinal)
print_number:
    pusha
    mov edi, buffer + 11      ; Aponta para o final do buffer
    mov byte [edi], 0         ; Terminador nulo
    mov ebx, 10               ; Divisor
    
    ; Verifica se é negativo
    test eax, eax
    jns .positive
    neg eax
    push eax                  ; Salva o valor positivo
    
    ; Imprime o sinal negativo
    mov eax, 4
    mov ebx, 1
    mov ecx, minus
    mov edx, 1
    int 0x80
    
    pop eax                   ; Recupera o valor positivo
    mov ebx, 10
    
.positive:
    ; Converte dígitos
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .positive
    
    ; Imprime o número
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buffer + 12
    sub edx, edi
    int 0x80
    
    popa
    ret

section .data
minus db "-", 0