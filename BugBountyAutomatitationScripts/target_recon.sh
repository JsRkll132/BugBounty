#!/bin/bash

# Inicializa la variable
PROGRAM_ROUTE=""

# Analiza los argumentos
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -p)
            PROGRAM_ROUTE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option, use : $1"
            exit 1
            ;;
    esac
done

# Verifica si el archivo 'domains.txt' existe
file_route="$PROGRAM_ROUTE/domains.txt"
alter_subdomains="$PROGRAM_ROUTE/alter_domains.txt"

if [ ! -f "$file_route" ]; then
    echo "Error: 'domains.txt' does not exist in '$PROGRAM_ROUTE'."
    exit 1
fi

# Comienza la ejecución secuencial de comandos
echo "Subfinder test...."
subfinder -dL "$file_route" -all -recursive -o "$PROGRAM_ROUTE/subdomains.txt"
if [ $? -ne 0 ]; then
    echo "Error executing Subfinder"
    exit 1
fi

# Añadir dominios alternativos si existe el archivo 'alter_domains.txt'
if [ -f "$alter_subdomains" ]; then
    echo "Adding alter domains..."
    cat "$alter_subdomains" | anew "$PROGRAM_ROUTE/subdomains.txt"
    if [ $? -ne 0 ]; then
        echo "Error adding alter domains"
        exit 1
    fi
fi

# Buscar subdominios vivos
echo "Searching for alive subdomains..."
cat "$PROGRAM_ROUTE/subdomains.txt" | httpx-toolkit -l "$PROGRAM_ROUTE/subdomains.txt" -ports 443,80,8080,8000,8888 -threads 200 > "$PROGRAM_ROUTE/subdomains_alive.txt"
if [ $? -ne 0 ]; then
    echo "Error finding alive subdomains"
    exit 1
fi

# Buscar puertos abiertos
echo "Searching for open ports..."
naabu -list "$PROGRAM_ROUTE/subdomains.txt" -c 50 -nmap-cli 'nmap -sV -SC' -o "$PROGRAM_ROUTE/naabu-full.txt"
if [ $? -ne 0 ]; then
    echo "Error executing Naabu"
    exit 1
fi

# Buscar URLs en subdominios vivos
echo "Searching for URLs in alive subdomains..."
cat "$PROGRAM_ROUTE/subdomains_alive.txt" | gau > "$PROGRAM_ROUTE/params.txt"
if [ $? -ne 0 ]; then
    echo "Error gathering URLs"
    exit 1
fi

# Filtrar URLs
echo "Filtering URLs..."
cat "$PROGRAM_ROUTE/params.txt" | uro -o "$PROGRAM_ROUTE/filterparam.txt"
if [ $? -ne 0 ]; then
    echo "Error filtering URLs"
    exit 1
fi

# Filtrar URLs con parámetros "?="
echo "Filtering URLs with params '?='..."
grep -Ei "=" "$PROGRAM_ROUTE/filterparam.txt" > "$PROGRAM_ROUTE/withparams.txt"
if [ $? -ne 0 ]; then
    echo "Error filtering URLs with params"
    exit 1
fi

echo "Script completed successfully!"
