# Projetos em Assembly

Este repositório contém projetos em linguagem Assembly,

## Estrutura

projetos-assembly/
├── loops/ # Códigos de repetição em Assembly
├── scripts/ # Scripts úteis para build

## Como rodar

Use o `nasm` e o `ld` para compilar os arquivos:
nasm -f elf32 loops/loop.asm -o loop.o
ld -m elf_i386 loop.o -o loop
./loop