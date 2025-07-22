section .data
    ; Mensagens
    msg_sucesso db 'Executando programa externo...', 0xA
    len_sucesso equ $ - msg_sucesso
    
    msg_erro db 'Falha ao executar o programa!', 0xA
    len_erro equ $ - msg_erro
    
    ; Programa a ser executado (caminho completo ou relativo)
    programa db './meu_programa', 0     ; Substitua pelo seu programa
    argumento db 'parametro1', 0       ; Argumento opcional
    
    ; Array de argumentos para execve (terminado com NULL)
    argv dq programa                   ; Nome do programa (64-bit pointer)
         dq argumento                  ; Argumento 1
         dq 0                          ; NULL terminator
    
    ; Variável de ambiente (pode ser vazia)
    envp dq 0                          ; NULL terminator

section .text
    global _start

_start:
    ; Mostrar mensagem de início
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_sucesso
    mov rdx, len_sucesso
    syscall

    ; Chamar execve
    mov rax, 59                 ; syscall execve (número 59 em x86-64)
    mov rdi, programa           ; caminho do programa
    mov rsi, argv               ; array de argumentos
    mov rdx, envp               ; variáveis de ambiente
    syscall

    ; Se execve retornar, houve erro
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_erro
    mov rdx, len_erro
    syscall

    ; Sair com erro
    mov rax, 60                 ; sys_exit
    mov rdi, 1                  ; status 1 (erro)
    syscall