import os
import smtplib
from email.message import EmailMessage
import sys

# Parametros de correo
SMTP_SERVER = "localhost"
SMTP_PORT = 1025
EMAIL_SENDER = "resumen-sistema@solucionesficticias.com"

# Rutas de directorios
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Ruta de los logs
LOGS_DIR = os.path.join(BASE_DIR, "logs")
# Resumento de envíos
LOG_RESUMEN = os.path.join(LOGS_DIR, "resumen-envios.log")
CRON_LOG = os.path.join(LOGS_DIR, "cron.log")

FLAG_PREV = os.path.join(BASE_DIR, ".flag_generador_resumen_ok")
FLAG_ME = os.path.join(BASE_DIR, ".flag_enviador_resumen_ok")

# Función para enviar el correo
def enviar_correo(destinatario, archivo_log):
    mensaje = EmailMessage()
    mensaje["Subject"] = "Soluciones Ficticias - Resumen de envíos"
    mensaje["From"] = EMAIL_SENDER
    mensaje["To"] = destinatario
    
    # Agregar el resumen de envíos al cuerpo del mensaje
    with open(archivo_log, "rb") as f:
        contenido_log = f.read()
        mensaje.set_content("Resumen de envíos del sistema de facturación electrónica de Soluciones Ficticias\n" + contenido_log.decode('utf-8'))
    
    if os.path.exists(CRON_LOG):
    # Adjuntar el archivo de log del cron
        with open(CRON_LOG, "rb") as l:
            contenido_log = l.read()
            mensaje.add_attachment(contenido_log, maintype="application", subtype="txt", filename=os.path.basename(CRON_LOG))
    
    # aca usamos una version simplificada para enviar el correo con el servidor SMTP local
    # esto por cuestion de pruebas y tambien que los correos generados son ficticios normalmete fallarian
    with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.send_message(mensaje)
    
    # Normalmente se deberia usar ssl y un servidor SMTP seguro,como stmtp.gmail.com usando correo enviador y contraseña
    # contexto = ssl.create_default_context()
    # with smtplib.SMTP_SSL(SMTP_SERVER, SMTP_PORT, context=contexto) as server:
    #     server.login(EMAIL_SENDER, EMAIL_PASSWORD)
    #     server.send_message(mensaje)

if __name__ == "__main__":
    if not os.path.exists(FLAG_PREV):
        print("generador_resumen.sh no terminó o no se ejecutó aún. Saliendo.")
        sys.exit(0)

    # Remover el archivo de bandera del paso anterior
    os.remove(FLAG_PREV)
    print("Enviando resumen de envíos...")
    # Enviar el resumen por correo
    enviar_correo('admin@solucionesficticias.com', LOG_RESUMEN)
    print("Resumen enviado correctamente.")
    # Crear el archivo de bandera para indicar que este paso se completó correctamente
    open(FLAG_ME, 'w').close()
