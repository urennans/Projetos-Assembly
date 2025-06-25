#!/bin/bash

if [ -z "$1" ]; then
  echo "Uso: ./build.sh caminho/para/arquivo_sem_extensao"
  exit 1
fi

arquivo="$1"
nome=$(basename "$arquivo")

nasm -f elf32 "$arquivo.asm" -o "$arquivo.o" || { echo "Erro ao montar"; exit 1; }
ld -m elf_i386 -s -o "$arquivo.out" "$arquivo.o" || { echo "Erro ao linkar"; exit 1; }

echo -e "\n✅ Executando $arquivo.out...\n"
"./$arquivo.out"

echo -e "\n🧹 Limpando arquivos temporários..."
rm "$arquivo.o"
rm "$arquivo.out"

echo -e "\n🏁 Script concluído com sucesso."
