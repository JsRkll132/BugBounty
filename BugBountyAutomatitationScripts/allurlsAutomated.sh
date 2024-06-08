#!/bin/bash

# Función para mostrar el uso del script
#mostrar_uso() {
 #   echo "Uso: $0 -f file_txt"
 #   exit 1
#}

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

# Verificar si el dominio no está vacío
##if [ -z "$file_txt" ]; then
#    mostrar_uso
##fi

# Ejecutar waybackurls y añadir la salida al archivo
#echo "Executing waybackurls scanning : "

#xss_output="$dominio/XssFinderReport_${dominio}.txt"
#touch "$xss_output"
#echo "--------------------------------------------------------"
#echo "BUSCANDO VULN / CVE'S XSS" 
#echo "--------------------------------------------------------"
while read -r line_ 
do
	urll=$(echo $line_ | tr -d '\n')
	echo "Testing DOMAIN : $urll" 
	bash allurls_for_dom.sh -d "$line_"
done < "$file_txt"


