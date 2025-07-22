section .data
    ; Mensagens do menu
    menu db 10, '=== Menu de Operações de Arquivos/Diretórios ===', 10
         db '1. Criar arquivo', 10
         db '2. Remover arquivo', 10
         db '3. Copiar arquivo', 10
         db '4. Mover arquivo', 10
         db '5. Criar diretório', 10
         db '6. Remover diretório', 10
         db '7. Listar conteúdo do diretório', 10
         db '8. Alterar permissões de arquivo', 10
         db '0. Sair', 10
         db 'Escolha uma opção: ', 0
    menu_len equ $-menu

    ; Prompts e mensagens
    path1_prompt db 'Digite o caminho (origem): ', 0
    path1_prompt_len equ $-path1_prompt
    
    path2_prompt db 'Digite o caminho (destino): ', 0
    path2_prompt_len equ $-path2_prompt
    
    perm_prompt db 'Digite as permissões (em octal, ex: 755): ', 0
    perm_prompt_len equ $-perm_prompt
    
    success_msg db 'Operação realizada com sucesso!', 10, 0
    success_msg_len equ $-success_msg
    
    fail_msg db 'Falha na operação!', 10, 0
    fail_msg_len equ $-fail_msg
    
    newline db 10, 0
    
    ; Mensagens de erro específicas
    err_invalid_option db 'Opção inválida! Tente novamente.', 10, 0
    err_invalid_option_len equ $-err_invalid_option
    
    err_path_too_long db 'Erro: Caminho muito longo (max 255 caracteres).', 10, 0
    err_path_too_long_len equ $-err_path_too_long
    
    err_invalid_perm db 'Erro: Permissões inválidas. Use formato octal (ex: 755).', 10, 0
    err_invalid_perm_len equ $-err_invalid_perm
    
    ; Mensagens para listagem de diretório
    dir_header db 10, 'Conteúdo do diretório:', 10, '---------------------', 10, 0
    dir_header_len equ $-dir_header
    
    dir_footer db '---------------------', 10, 0
    dir_footer_len equ $-dir_footer

section .bss
    option resb 2
    path1 resb 256
    path2 resb 256
    perms resb 5
    buffer resb 1024
    dir_ent resb 1024  ; Buffer para entradas de diretório

section .text
    global _start

_start:
    ; Limpar buffers
    call clear_buffers

menu_loop:
    ; Mostrar menu
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, menu
    mov rdx, menu_len
    syscall

    ; Ler opção
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, option
    mov rdx, 2
    syscall

    ; Processar opção
    cmp byte [option], '1'
    je create_file
    cmp byte [option], '2'
    je remove_file
    cmp byte [option], '3'
    je copy_file
    cmp byte [option], '4'
    je move_file
    cmp byte [option], '5'
    je create_dir
    cmp byte [option], '6'
    je remove_dir
    cmp byte [option], '7'
    je list_dir
    cmp byte [option], '8'
    je change_perms
    cmp byte [option], '0'
    je exit_program

    ; Opção inválida
    mov rax, 1
    mov rdi, 1
    mov rsi, err_invalid_option
    mov rdx, err_invalid_option_len
    syscall
    jmp menu_loop

create_file:
    call get_path1
    jc menu_loop        ; Se houve erro ao obter path
    
    ; Syscall creat (path, mode)
    mov rax, 85         ; sys_creat
    mov rdi, path1
    mov rsi, 0644o      ; Permissões -rw-r--r--
    syscall
    call check_success
    jmp menu_loop

remove_file:
    call get_path1
    jc menu_loop
    
    ; Syscall unlink (path)
    mov rax, 87         ; sys_unlink
    mov rdi, path1
    syscall
    call check_success
    jmp menu_loop

copy_file:
    call get_path1
    jc menu_loop
    call get_path2
    jc menu_loop
    
    ; Abrir arquivo origem
    mov rax, 2          ; sys_open
    mov rdi, path1
    mov rsi, 0          ; O_RDONLY
    syscall
    cmp rax, 0
    jl .fail
    mov r8, rax         ; Salvar fd origem

    ; Criar arquivo destino
    mov rax, 85         ; sys_creat
    mov rdi, path2
    mov rsi, 0644o
    syscall
    cmp rax, 0
    jl .fail_close
    mov r9, rax         ; Salvar fd destino

.copy_loop:
    ; Ler do origem
    mov rax, 0          ; sys_read
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 1024
    syscall
    cmp rax, 0
    jle .close_all      ; Fim do arquivo ou erro

    ; Escrever no destino
    mov rdx, rax        ; bytes lidos
    mov rax, 1          ; sys_write
    mov rdi, r9
    mov rsi, buffer
    syscall
    cmp rax, rdx
    jne .close_all      ; Erro na escrita
    jmp .copy_loop

.close_all:
    ; Fechar arquivos
    mov rax, 3          ; sys_close
    mov rdi, r8
    syscall
    mov rax, 3
    mov rdi, r9
    syscall
    call check_success
    jmp menu_loop

.fail_close:
    mov rax, 3          ; sys_close
    mov rdi, r8
    syscall
.fail:
    call print_fail
    jmp menu_loop

move_file:
    call get_path1
    jc menu_loop
    call get_path2
    jc menu_loop
    
    ; Syscall rename (oldpath, newpath)
    mov rax, 82         ; sys_rename
    mov rdi, path1
    mov rsi, path2
    syscall
    call check_success
    jmp menu_loop

create_dir:
    call get_path1
    jc menu_loop
    
    ; Syscall mkdir (path, mode)
    mov rax, 83         ; sys_mkdir
    mov rdi, path1
    mov rsi, 0755o      ; Permissões drwxr-xr-x
    syscall
    call check_success
    jmp menu_loop

remove_dir:
    call get_path1
    jc menu_loop
    
    ; Syscall rmdir (path)
    mov rax, 84         ; sys_rmdir
    mov rdi, path1
    syscall
    call check_success
    jmp menu_loop

list_dir:
    call get_path1
    jc menu_loop
    
    ; Abrir diretório
    mov rax, 2          ; sys_open
    mov rdi, path1
    mov rsi, 0          ; O_RDONLY | O_DIRECTORY
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .fail
    mov r8, rax         ; Salvar fd do diretório

    ; Exibir cabeçalho
    mov rax, 1
    mov rdi, 1
    mov rsi, dir_header
    mov rdx, dir_header_len
    syscall

.read_loop:
    ; Ler entradas do diretório (sys_getdents)
    mov rax, 78         ; sys_getdents64
    mov rdi, r8
    mov rsi, dir_ent
    mov rdx, 1024
    syscall
    cmp rax, 0
    jle .close_dir      ; Fim do diretório ou erro

    ; Processar entradas (simplificado - em sistemas reais precisaria analisar a estrutura dirent)
    ; Aqui apenas imprimimos o buffer como string (para simplificação)
    mov rdx, rax        ; bytes lidos
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, dir_ent
    syscall
    jmp .read_loop

.close_dir:
    ; Fechar diretório
    mov rax, 3          ; sys_close
    mov rdi, r8
    syscall
    
    ; Exibir rodapé
    mov rax, 1
    mov rdi, 1
    mov rsi, dir_footer
    mov rdx, dir_footer_len
    syscall
    
    jmp menu_loop

.fail:
    call print_fail
    jmp menu_loop

change_perms:
    call get_path1
    jc menu_loop
    call get_perms
    jc menu_loop
    
    ; Converter permissões de string para octal
    call atooct
    jc .invalid_perm
    
    ; Syscall chmod (path, mode)
    mov rax, 90         ; sys_chmod
    mov rdi, path1
    mov rsi, rdx        ; Permissões
    syscall
    call check_success
    jmp menu_loop

.invalid_perm:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_invalid_perm
    mov rdx, err_invalid_perm_len
    syscall
    jmp menu_loop

exit_program:
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; ==============================================
; Funções auxiliares melhoradas
; ==============================================

get_path1:
    ; Exibir prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, path1_prompt
    mov rdx, path1_prompt_len
    syscall

    ; Ler caminho
    mov rax, 0
    mov rdi, 0
    mov rsi, path1
    mov rdx, 256
    syscall
    
    ; Verificar se ultrapassou o tamanho máximo
    cmp rax, 255
    jg .path_too_long
    
    ; Remover newline do final
    mov rdi, path1
    call strip_newline
    clc                 ; Clear carry flag - indica sucesso
    ret

.path_too_long:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_path_too_long
    mov rdx, err_path_too_long_len
    syscall
    stc                 ; Set carry flag - indica erro
    ret

get_path2:
    ; Exibir prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, path2_prompt
    mov rdx, path2_prompt_len
    syscall

    ; Ler caminho
    mov rax, 0
    mov rdi, 0
    mov rsi, path2
    mov rdx, 256
    syscall
    
    ; Verificar se ultrapassou o tamanho máximo
    cmp rax, 255
    jg .path_too_long
    
    ; Remover newline do final
    mov rdi, path2
    call strip_newline
    clc
    ret

.path_too_long:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_path_too_long
    mov rdx, err_path_too_long_len
    syscall
    stc
    ret

get_perms:
    ; Exibir prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, perm_prompt
    mov rdx, perm_prompt_len
    syscall

    ; Ler permissões
    mov rax, 0
    mov rdi, 0
    mov rsi, perms
    mov rdx, 5
    syscall
    
    ; Remover newline do final
    mov rdi, perms
    call strip_newline
    
    ; Verificar se é um número octal válido (0-7)
    mov rsi, perms
.check_digit:
    movzx rax, byte [rsi]
    cmp al, 0
    je .valid
    cmp al, '0'
    jl .invalid
    cmp al, '7'
    jg .invalid
    inc rsi
    jmp .check_digit

.valid:
    clc
    ret

.invalid:
    stc
    ret

strip_newline:
    ; Remove newline do final da string em RDI
    mov al, byte [rdi]
    inc rdi
    cmp al, 0
    jne strip_newline
    dec rdi
    cmp byte [rdi], 10
    jne .done
    mov byte [rdi], 0
.done:
    ret

atooct:
    ; Converte string octal em perms para valor em RDX
    ; Retorna com carry set se erro
    xor rdx, rdx
    mov rsi, perms
.next_digit:
    movzx rax, byte [rsi]
    cmp al, 0
    je .done
    sub al, '0'
    js .error           ; Se menor que '0'
    cmp al, 7
    ja .error           ; Se maior que 7
    shl rdx, 3
    add rdx, rax
    inc rsi
    jmp .next_digit
.done:
    clc
    ret
.error:
    stc
    ret

check_success:
    cmp rax, 0
    jl print_fail
    jmp print_success

print_success:
    mov rax, 1
    mov rdi, 1
    mov rsi, success_msg
    mov rdx, success_msg_len
    syscall
    ret

print_fail:
    mov rax, 1
    mov rdi, 1
    mov rsi, fail_msg
    mov rdx, fail_msg_len
    syscall
    ret

clear_buffers:
    ; Limpa os buffers de entrada
    mov rdi, path1
    mov rcx, 256
    xor al, al
    rep stosb

    mov rdi, path2
    mov rcx, 256
    xor al, al
    rep stosb

    mov rdi, perms
    mov rcx, 5
    xor al, al
    rep stosb
    
    mov rdi, buffer
    mov rcx, 1024
    xor al, al
    rep stosb
    
    mov rdi, dir_ent
    mov rcx, 1024
    xor al, al
    rep stosb
    ret