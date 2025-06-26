# 🕒 Relógio em Assembly (x86)

Um projeto desafiador desenvolvido em Assembly x86 que exibe o horário atual no fuso horário de Brasília, atualizando a cada segundo.

## ✨ Funcionalidades

- Exibe horário local (UTC-3) formatado (HH:MM:SS)
- Atualização dinâmica a cada segundo
- Ajuste preciso do fuso horário
- Uso eficiente de syscalls para interação com o sistema

## ⚙️ Tecnologias e Conceitos
- Linguagem Assembly x86
- Syscalls Linux (`time`, `nanosleep`)
- Manipulação de tempo Unix Epoch
- Cálculos de conversão de tempo
- Operações aritméticas em baixo nível

## 📦 Pré-requisitos
- NASM (Netwide Assembler)
- GCC (GNU Compiler Collection)
- Sistema compatível com arquitetura x86 (32 bits)

## 🚀 Compilação e Execução
```bash
nasm -f elf32 relogio.asm -o relogio.o
gcc -m32 -no-pie relogio.o -o relogio
./relogio

🔍 Detalhes de Implementação
⏱️ Ajuste de Fuso Horário
O sistema retorna o tempo em segundos desde 1º de janeiro de 1970 (Unix Epoch). Para converter para o horário de Brasília (UTC-3), utilizamos:

asm
timezone_offset equ -3 * 3600  ; 3 horas em segundos
⏳ Syscall Nanosleep
Utilizamos a syscall nanosleep (162) para controlar a atualização do relógio:

asm
mov eax, 162          ; syscall nanosleep
mov ebx, time_struct  ; estrutura de tempo
mov ecx, 0            ; NULL para tempo restante
int 0x80

🔢 Cálculos de Tempo
O processo de conversão envolve:

Obter timestamp atual

Aplicar offset do fuso horário

Calcular horas, minutos e segundos

Ajustar para formato legível

🎛️ Desafios Enfrentados
Precisão nos cálculos aritméticos

Conversão correta de Unix Time para formato legível

Sincronização precisa das atualizações

Manipulação de registradores para operações temporais

📚 Aprendizados
Trabalho direto com syscalls do Linux

Manipulação avançada de tempo em baixo nível

Controle preciso de execução com nanosleep

Otimização de código Assembly