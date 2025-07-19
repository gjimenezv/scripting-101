#!/bin/bash

# Define las tareas cron
# Ejecuta generador_facturas.sh a las 9 pm todos los dias
# Ejecuta enviador.py a las 10 pm todos los dias
# Ejecuta generador_resumen.sh a las 10:30 pm todos los dias
# Ejecuta enviador-resumen.py a las 11:30 pm todos los dias
CRON_CONTENT="\
0 21 * * * /home/asd/dev/scripting-101/generador_facturas.sh >> /home/asd/dev/scripting-101/logs/cron.log 2>&1
0 22 * * * /home/asd/dev/scripting-101/venv/bin/python3 /home/asd/dev/scripting-101/enviador.py >> /home/asd/dev/scripting-101/logs/cron.log 2>&1
30 22 * * * /home/asd/dev/scripting-101/generador_resumen.sh >> /home/asd/dev/scripting-101/logs/cron.log 2>&1
0 23 * * * /home/asd/dev/scripting-101/venv/bin/python3 /home/asd/dev/scripting-101/enviador-resumen.py >> /home/asd/dev/scripting-101/logs/cron.log 2>&1
"

# Instala el nuevo crontab (reemplaza por completo las entradas anteriores)
echo "$CRON_CONTENT" | crontab -


