section .data
    ; Matriz A 3x3
    matrizA dd 1, 2, 3
            dd 4, 5, 6
            dd 7, 8, 9
    
    ; Matriz B 3x3
    matrizB dd 9, 8, 7
            dd 6, 5, 4
            dd 3, 2, 1
    
    ; Matriz resultado
    matrizR dd 0, 0, 0
            dd 0, 0, 0
            dd 0, 0, 0
    
    msg db "Matriz Resultado:", 10, 0
    linha db "[ %d %d %d ]", 10, 0

section .text
    global main
    extern printf

main:
    push ebp
    mov ebp, esp
    
    ; Inicializar índices
    xor esi, esi        ; i = 0 (linha)

loop_i:
    cmp esi, 3
    jge imprimir
    
    xor edi, edi        ; j = 0 (coluna)

loop_j:
    cmp edi, 3
    jge next_i
    
    ; Calcular endereço de matrizR[i][j]
    mov eax, esi
    mov ebx, 12         ; 3 elementos * 4 bytes
    mul ebx
    lea ebx, [matrizR + eax]
    mov dword [ebx + edi*4], 0  ; Zerar o elemento
    
    xor ecx, ecx        ; k = 0

loop_k:
    cmp ecx, 3
    jge next_j
    
    ; Calcular A[i][k]
    mov eax, esi
    mov edx, 12
    mul edx
    lea edx, [matrizA + eax]
    mov eax, [edx + ecx*4]  ; EAX = A[i][k]
    
    ; Calcular B[k][j] - CORREÇÃO AQUI
    mov ebx, ecx        ; k
    imul ebx, 12        ; 3 elementos * 4 bytes
    lea edx, [matrizB + ebx]
    mov ebx, [edx + edi*4]  ; EBX = B[k][j]
    
    ; Multiplicar e somar ao resultado
    imul eax, ebx
    
    ; Atualizar matrizR[i][j]
    mov edx, esi
    imul edx, 12
    lea edx, [matrizR + edx]
    add [edx + edi*4], eax
    
    inc ecx
    jmp loop_k

next_j:
    inc edi
    jmp loop_j

next_i:
    inc esi
    jmp loop_i

imprimir:
    ; Imprimir mensagem
    push msg
    call printf
    add esp, 4
    
    ; Imprimir matriz resultado
    xor esi, esi        ; i = 0

print_loop:
    cmp esi, 3
    jge fim
    
    ; Calcular endereço da linha
    mov eax, esi
    mov ebx, 12
    mul ebx
    lea eax, [matrizR + eax]
    
    ; Imprimir linha
    push dword [eax+8]  ; matrizR[i][2]
    push dword [eax+4]  ; matrizR[i][1]
    push dword [eax]    ; matrizR[i][0]
    push linha
    call printf
    add esp, 16         ; Limpar stack
    
    inc esi
    jmp print_loop

fim:
    ; Sair
    mov esp, ebp
    pop ebp
    ret