#!/bin/bash

# Función para mostrar el uso del script
mostrar_uso() {
    echo "Uso: $0 -f file_txt"
    exit 1
}

# Verificar si no se proporcionó ningún argumento
#if [ $# -eq 0 ]; then
 #   mostrar_uso
#fi

# Procesar los argumentos
while getopts "f:" opt; do
    case $opt in
        f)
            file_txt=$OPTARG
            ;;
        *)
            mostrar_uso
            ;;
    esac
done


while read -r line_ 
do
	urll=$(echo $line_ | tr -d '\n')
	echo "Testing DOMAIN : $urll" 
	bash allurls_for_dom2.sh -d "$line_"
done < "$file_txt"


