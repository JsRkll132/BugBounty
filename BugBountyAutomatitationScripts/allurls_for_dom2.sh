#!/bin/bash

# Función para mostrar el uso del script
mostrar_uso() {
    echo "Uso: $0 -d dominio"
    exit 1
}

# Verificar si no se proporcionó ningún argumento
if [ $# -eq 0 ]; then
    mostrar_uso
fi

# Procesar los argumentos
while getopts "d:" opt; do
    case $opt in
        d)
            dominio=$OPTARG
            ;;
        *)
            mostrar_uso
            ;;
    esac
done

# Verificar si el dominio no está vacío
if [ -z "$dominio" ]; then
    mostrar_uso
fi

# Crear una carpeta con el nombre del dominio
mkdir -p "$dominio"

# Crear el archivo filtered_dominio.txt
archivo="$dominio/filtered_${dominio}.txt"
touch "$archivo"

# Ejecutar katana y redirigir la salida al archivo
echo "Executing katana scanning : "
katana -u "https://$dominio/" -o "$archivo"


# Ejecutar waybackurls y añadir la salida al archivo
echo "Executing waybackurls scanning : "
waybackurls "$dominio" | tee -a "$archivo"

valid_urls="$dominio/validurls_${dominio}.txt"
touch "$valid_urls"
echo "Httpx valid urls scanning : " 
httpx-toolkit -l "$archivo" -mc 200,300,301,302  -o "$valid_urls"
#validacion de urls con parametros
valid_urls_with_params="$dominio/validurlswp_${dominio}.txt"
touch "$valid_urls_with_params"
grep '?' "$valid_urls" > "$valid_urls_with_params"

xss_output="$dominio/XssFinderReport_${dominio}.txt"
touch "$xss_output"
echo "--------------------------------------------------------"
echo "BUSCANDO VULN / CVE'S XSS" 
echo "--------------------------------------------------------"
while read -r line_ 
do
	urll=$(echo $line_ | tr -d '\n')
	echo "Testing url : $urll" | tee -a "$xss_output"
	python3 xsstrike.py -u $urll | tee -a "$xss_output"
done < "$valid_urls"

echo "Proceso completado. Resultados guardados en $archivo."
