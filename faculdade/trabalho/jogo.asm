section .data
    ;----Constates do Game----
    MAX_ROUNDS equ 10
    BOMB_SLOTS equ 5

    msg_round db "ROUND: ", 0
    msg_score db "SCORE: ", 0
    msg_bombs db "TARGETS: [ ", 0
    msg_end   db " ]", 0xA, 0

    score     db 0
    current_round db MAX_ROUNDS

section .bss
    bomv_targets resd BOMB_SLOTS

section .text
    global _start

_start:
    call init_game

.game_loop:
    ;1 exibe status do game
    call show_game_status

    ;2 gera novos alvos
    call generate_targets
    
    ;3 lógica de input

    ;4 Atualiza rodada
    dec dword [current_round]
    jnz.game_loop

    ;5 Game Over
    call show_final_score
    call exit_game

    ;Sub-rotinas
init_game:
    ;Inicializa o jogo
    mov dword [score], 0
    mov dword [current_round], MAX_ROUNDS
    ret

show_game_status:


generate_targets:
    pusha                       ;DUVIDA 1
    mov ecx, BOMB_SLOTS ;5 alvos
    mov edi bomb_targets    ;array
.loop:
    ;pega o timestamp
    mov eax, 13
    xor ebx, ebx
    int 0x80  ; syscall para obter o tempo
    
    ;formula para aleatoriedade
    xor edx, edx
    mov ebx, 100
    div ebx
    mov [edi], edx ; armazena o alvo no array

    add edi, 4 ; move para o próximo slot
    loop .loop

    popa                        ;DUVIDA 2
    ret
show_final_score:

exit_game:
    ; Finaliza o jogo
    mov eax, 1
    xor ebx, ebx
    int 0x80  ; syscall para sair