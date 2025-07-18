#!/bin/bash
python3 /home/asd/dev/scripting-101/enviador.py

if [ $? -eq 0 ]; then
    echo "enviador.py script terminó correctamente"
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
            print "Exitosos:", exitosos
            print "Fallidos:", fallidos
        }
        ' logs/log_envios.csv > logs/resumen_envios.log
    # pick up the summary from logs/log-diario.log using grep add it to logs/resumen_envios.log
        FACTURAS_MONTO_TOTAL=$(grep "Monto total facturado" logs/log-diario.log | awk -F: '{print $2}' | xargs)
        FACTURAS_PAGO_COMPLETO=$(grep "Facturas pagados en su totalidad" logs/log-diario.log | awk -F: '{print $2}' | xargs)

        echo "Total vendido: $FACTURAS_MONTO_TOTAL" >> logs/resumen_envios.log
        echo "Pedidos pagados en su totalidad: $FACTURAS_PAGO_COMPLETO" >> logs/resumen_envios.log

    # ▪Total vendido
    # ▪Cuantos pedidos fueron pagados en su totalidad
else
    echo "Error al ejecutar el script enviador.py"
fi
