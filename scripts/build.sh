#!/bin/bash

if [ -z "$1" ]; then
  echo "Uso: ./scripts/build.sh caminho/para/arquivo (sem .asm)"
  echo "Exemplo: ./scripts/build.sh loops/dezena"
  exit 1
fi

arquivo="$1"
nome=$(basename "$arquivo")        # Só o nome do arquivo
dir=$(dirname "$arquivo")          # Só a pasta

asm="$arquivo.asm"
obj="$arquivo.o"
out="$arquivo.out"

# Compilar
nasm -f elf32 "$asm" -o "$obj" || { echo "❌ Erro ao montar $asm"; exit 1; }

# Linkar
ld -m elf_i386 -s -o "$out" "$obj" || { echo "❌ Erro ao linkar $obj"; exit 1; }

# Executar
echo -e "\n✅ Executando $out...\n"
"./$out"

# Limpeza
echo -e "\n🧹 Limpando arquivos temporários..."
rm "$obj"
rm "$out"

echo -e "\n🏁 Script concluído com sucesso."
