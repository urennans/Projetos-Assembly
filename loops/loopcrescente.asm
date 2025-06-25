section .data
	newline db 0xA
	FIM db "FIM!", 0xA
	FIMlen equ $ - FIM
section .bss
	numero resb 1
section .text
	global _start
_start:
	mov byte [numero], '0'
	
loop_numerico:
	;escreve o número atual
	mov eax, 4
	mov ebx, 1
	mov ecx, numero
	mov edx, 1
	int 0x80
	
	;escreve a quebra de linha
	mov eax, 4
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80

	;incrementa o valor do numero
	inc byte [numero]
	
	;compara se ja chegou no ASCII de '9' +1
	cmp byte [numero], '9'+1
	jne loop_numerico
	
	;exibe o FIM
	mov eax, 4
	mov ebx, 1
	mov ecx, FIM
	mov edx, FIMlen
	int 0x80
	
	;sair do programa
	mov eax, 1
	xor ebx, ebx
	int 0x80