#!/bin/bash
python3 /home/asd/dev/scripting-101/enviador.py

if [ $? -eq 0 ]; then
    log_resumen=logs/resumen-envios.log
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
        echo "Enviando resumen a administrador..."
        python3 /home/asd/dev/scripting-101/enviador-resumen.py
        
        if [ $? -eq 0 ]; then
            echo "Resumen enviado correctamente"
        else
            echo "Error al enviar el resumen"
        fi
else
    echo "Error al ejecutar el script enviador.py"
fi
