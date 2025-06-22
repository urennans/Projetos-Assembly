section .data
	mensagem db "Renan é brabo!", 0xA
	tam equ $ - mensagem

section .bss
	contador resb 1

section .text
	global _start
	
_start:
	mov byte [contador], 20

loop_inicio:
	mov eax, 4
	mov ebx, 1
	mov ecx, mensagem
	mov edx, tam
	int 0x80
	
	dec byte [contador]
	
	cmp byte [contador], 0
	jne loop_inicio
	
	; sai do programa
	
	mov eax, 1
	xor ebx, ebx
	int 0x80
