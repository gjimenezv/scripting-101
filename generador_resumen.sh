#!/bin/bash

# Cambia al directorio del script
# Esto asegura que los archivos relativos se manejen correctamente
# y que el script se ejecute desde su propia ubicación al usar cron jobs
cd "$(dirname "$0")"

# Verificar si el archivo de bandera del paso previo existe
FLAG_PREV=".flag_enviador_ok"
FLAG_ME=".flag_generador_resumen_ok"
log_resumen=logs/resumen-envios.log

if [ ! -f "$FLAG_PREV" ]; then
    echo "No está listo enviador.py, saliendo."
    exit 0
fi

rm "$FLAG_PREV"

echo "Generando resumen..."
awk -F, '
BEGIN {
    total = 0
    exitosos = 0
    fallidos = 0
}
{
    total++
    if (tolower($3) ~ /exitoso/) exitosos++
    else fallidos++
}
END {
    print "Total de correos procesados:", total
    print "Total de correos exitosos:", exitosos
    print "Total de correos fallidos:", fallidos
}
' logs/log_envios.csv > $log_resumen
# Extraemos información adicional del log diario
FACTURAS_MONTO_TOTAL=$(grep "Monto total facturado" logs/log-diario.log | awk -F: '{print $2}' | xargs)
FACTURAS_PAGO_COMPLETO=$(grep "Facturas pagados en su totalidad" logs/log-diario.log | awk -F: '{print $2}' | xargs)
# Agregamos la información adicional al resumen
echo "Total vendido: ₡$FACTURAS_MONTO_TOTAL" >> $log_resumen
echo "Pedidos pagados en su totalidad: $FACTURAS_PAGO_COMPLETO" >> $log_resumen
echo "Resumen generado en $log_resumen"
touch "$FLAG_ME"