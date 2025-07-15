#!/bin/bash

# Archivos y directorios
TEMPLATE="templates/template.tex"
OUTPUT_DIR="templates"
PDF_DIR="pdf"
LOGS_DIR="logs"
CRON_DIR="cron"
HOY=$(date +%Y%m%d)
CSV="bills/${HOY}.csv"
# Archivo de pendientes de envío en carpeta cron
PENDIENTES_FILE="$CRON_DIR/pendientes_envio.csv"
# Limpiar o crear el archivo pendientes_envio.csv al inicio
echo -n > "$PENDIENTES_FILE"

# Log diario5
LOG_DIA="$LOGS_DIR/log-diario-${HOY}.log"
FACTURAS_OK=0
FACTURAS_ERR=0

# Verificar si existe el archivo CSV
if [ ! -f "$CSV" ]; then
    echo "No existe el archivo $CSV"
    exit 1
fi

echo "Procesando archivo: $CSV"

while read line; do

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
        echo "Error: ID de transacción vacío" | tee -a "$LOG_DIA"
        FACTURAS_ERR=$((FACTURAS_ERR+1))
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

    PDF_FILE="$PDF_DIR/$id_transaccion.pdf"
    LOG_FILE="$LOGS_DIR/$id_transaccion.log"
    
    # Generar PDF en la carpeta correspondiente (sin log individual)
    pdflatex -output-directory="$PDF_DIR" "$TEX" >"$LOG_FILE" 2>&1
    # Ejecutar de nuevo para generar numero de paginas 
    pdflatex -output-directory="$PDF_DIR" "$TEX" >"$LOG_FILE" 2>&1
    
    # Limpiar archivos temporales
    rm -f "$PDF_DIR/$id_transaccion.log"
    rm -f "$PDF_DIR/$id_transaccion.aux"
    rm -f "$PDF_DIR/$id_transaccion.out"

    if [ $? -eq 0 ]; then
        echo "------------------------------" >> "$LOG_DIA"
        echo "ID: $id_transaccion" >> "$LOG_DIA"
        echo "PDF generado: $PDF_FILE" >> "$LOG_DIA"
        echo "Log: $LOG_FILE" >> "$LOG_DIA"
        FACTURAS_OK=$((FACTURAS_OK+1))
        # Agregar a pendientes_envio.csv: [id].pdf,[correo] en carpeta cron
        echo "${id_transaccion}.pdf,${correo}" >> "$PENDIENTES_FILE"
    else
        echo "Error al generar PDF para $TEX." | tee -a "$LOG_DIA"
        FACTURAS_ERR=$((FACTURAS_ERR+1))
    fi
done < <(tail -n +2 "$CSV")

echo "Proceso completado"

# Resumir resultados al final del log diario
echo "      " >> "$LOG_DIA"
echo "-----------RESUMEN------------" >> "$LOG_DIA"
echo "Facturas generadas exitosamente: $FACTURAS_OK" >> "$LOG_DIA"
echo "Facturas con error: $FACTURAS_ERR" >> "$LOG_DIA"
echo "-----------RESUMEN------------" >> "$LOG_DIA"

echo "Facturas generadas exitosamente: $FACTURAS_OK"
echo "Facturas con error: $FACTURAS_ERR"