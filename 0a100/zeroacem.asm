section .data
	newline db 0xA
section .bss
	buffer resb 2
section .text
	global_start

_start:
	mov ecx, 0
	
loop_numeros:
	mov eax, ecx	;copia o conteudo do contador
	mov ebx, 10	;aqui é o numerom que vai dividir
	xor edx, edx	;zerando edx
	div ebx		;dividindo o numero

;converter dezena para ASCII
	add al, '0'
	mov [buffer], al

;converter unidade para ASCII
	add dl, '0'
	mov [buffer+1], dl
	
