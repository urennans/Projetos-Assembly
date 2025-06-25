section .data
	newline db 0xA

section .bss
	dezena resb 1
	unidade resb 1
section .text
	global _start

_start:
	mov eax, 90
	mov ebx, 10
	xor edx, edx
	div ebx        ;divide eax por ebx
	
	;resultado:
	;AL = quociente (dezena)
	;DL = resto (unidade)
	
	;converter dezena para ASCII e guardar
	add al, '0'
	mov [dezena], al
	
	;converte unidade para ASCII e guarda
	add dl, '0'
	mov [unidade], dl
	
	;escrever a dezena
	mov eax, 4
	mov ebx, 1
	mov ecx, dezena
	mov edx, 1
	int 0x80
	
	;escrever a unidade
	mov eax, 4
	mov ebx, 1
	mov ecx, unidade
	mov edx, 1
	int 0x80
	
	;quebra de linha
	mov eax, 4
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80
	
	;sair do programa
	mov eax, 1
	xor ebx, ebx
	int 0x80
