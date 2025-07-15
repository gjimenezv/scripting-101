#!/bin/bash

# Archivos y directorios
TEMPLATE="templates/template.tex"
OUTPUT_DIR="templates"
HOY=$(date +%Y%m%d)
CSV="bills/${HOY}.csv"
# Procesar cada línea del CSV (excepto la primera)
# Crear directorios si no existen
PDF_DIR="pdf"
LOGS_DIR="logs"
mkdir -p "$PDF_DIR" "$LOGS_DIR"

# Verificar si existe el archivo CSV
if [ ! -f "$CSV" ]; then
    echo "No existe el archivo $CSV"
    exit 1
fi

echo "Procesando archivo: $CSV"

tail -n +2 "$CSV" | while read line; do

    # Usar awk para separar las columnas
    id_transaccion=$(echo "$line" | awk -F',' '{print $1}')
    nombre=$(echo "$line" | awk -F',' '{print $2}')
    ciudad=$(echo "$line" | awk -F',' '{print $3}')
    direccion=$(echo "$line" | awk -F',' '{print $4}')
    correo=$(echo "$line" | awk -F',' '{print $5}')
    telefono=$(echo "$line" | awk -F',' '{print $6}')
    ip=$(echo "$line" | awk -F',' '{print $7}')
    cantidad=$(echo "$line" | awk -F',' '{print $8}')
    monto=$(echo "$line" | awk -F',' '{print $9}')
    modalidad_pago=$(echo "$line" | awk -F',' '{print $10}')
    estado_pago=$(echo "$line" | awk -F',' '{print $11}')
    timestamp=$(echo "$line" | awk -F',' '{print $12}')

    # Limpiar comillas de los campos
    id_transaccion=$(echo "$id_transaccion" | sed 's/^"//;s/"$//')
    nombre=$(echo "$nombre" | sed 's/^"//;s/"$//')
    ciudad=$(echo "$ciudad" | sed 's/^"//;s/"$//')
    direccion=$(echo "$direccion" | sed 's/^"//;s/"$//')
    correo=$(echo "$correo" | sed 's/^"//;s/"$//')
    telefono=$(echo "$telefono" | sed 's/^"//;s/"$//')
    ip=$(echo "$ip" | sed 's/^"//;s/"$//')
    monto=$(echo "$monto" | sed 's/^"//;s/"$//')
    cantidad=$(echo "$cantidad" | sed 's/^"//;s/"$//')
    modalidad_pago=$(echo "$modalidad_pago" | sed 's/^"//;s/"$//')
    estado_pago=$(echo "$estado_pago" | sed 's/^"//;s/"$//')

    # Para timestamp convertimos a fecha legible
    fecha_limpia=$(echo "$timestamp" | sed 's/T/ /' | sed 's/\..*//')
    timestamp=$(echo "$fecha_limpia" | sed 's/^"//;s/"$//')

    # Verificar que el ID no esté vacío
    if [ -z "$id_transaccion" ]; then
        echo "Error: ID de transacción vacío"
        continue
    fi

    echo "Procesando: $id_transaccion"

    # Crear el archivo .tex copiando el template
    TEX="$OUTPUT_DIR/$id_transaccion.tex"
    cp "$TEMPLATE" "$TEX"

    # Reemplazar cada campo en el archivo
    sed -i "s|{id_transaccion}|$id_transaccion|g" "$TEX"
    sed -i "s|{nombre}|$nombre|g" "$TEX"
    sed -i "s|{ciudad}|$ciudad|g" "$TEX"
    sed -i "s|{direccion}|$direccion|g" "$TEX"
    sed -i "s|{correo}|$correo|g" "$TEX"
    sed -i "s|{telefono}|$telefono|g" "$TEX"
    sed -i "s|{ip}|$ip|g" "$TEX"
    sed -i "s|{cantidad}|$cantidad|g" "$TEX"
    sed -i "s|{monto}|$monto|g" "$TEX"
    sed -i "s|{estado_pago}|$estado_pago|g" "$TEX"
    sed -i "s|{timestamp}|$timestamp|g" "$TEX"

    # Campos especiales
    # Para modalidad_pago también usamos {pago}
    sed -i "s|{pago}|$modalidad_pago|g" "$TEX"
    sed -i "s|{fecha_emision}|$fecha_limpia|g" "$TEX"

    # Agregar observaciones por defecto
    sed -i "s|{observaciones}|Factura generada automáticamente|g" "$TEX"

    echo "Archivo generado: $TEX"

    # Generar PDF con pdflatex (salida en PDF_DIR, logs en LOGS_DIR)
    PDF_FILE="$PDF_DIR/$id_transaccion.pdf"
    LOG_FILE="$LOGS_DIR/$id_transaccion.log"
    # Cambiar a LOGS_DIR para ejecutar pdflatex y evitar logs en PDF_DIR
    pdflatex -output-directory="$PDF_DIR" "$TEX" >"$LOG_FILE" 2>&1
    # Eliminar el archivo .log generado por pdflatex en PDF_DIR
    rm -f "$PDF_DIR/$id_transaccion.log"
    rm -f "$PDF_DIR/$id_transaccion.aux"
    rm -f "$PDF_DIR/$id_transaccion.out"
    if [ $? -eq 0 ]; then
        echo "PDF generado: $PDF_FILE"
        echo "Log: $LOG_FILE"
    else
        echo "Error al generar PDF para $TEX. Ver $LOG_FILE"
    fi
done

echo "Proceso completado"