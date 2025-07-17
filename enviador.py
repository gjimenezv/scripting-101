import csv
import os
import re
import smtplib
from datetime import datetime
from email.message import EmailMessage

# Parametros de correo
SMTP_SERVER = "localhost"
SMTP_PORT = 1025
EMAIL_SENDER = "factura-electronica@solucionesficticias.com"

# Rutas de directorios
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Ruta del CSV
CSV_PATH = os.path.join(BASE_DIR, "cron", "pendientes_envio.csv")
# Ruta de los PDFs
PDF_DIR = os.path.join(BASE_DIR, "pdf")
# Ruta de los logs
LOGS_DIR = os.path.join(BASE_DIR, "logs")
# Resumento de envíos
LOG_ENVIO_CSV = os.path.join(LOGS_DIR, "log_envios.csv")

# Regex para validar correos
EMAIL_REGEX = re.compile(r"^[\w\.-]+@[\w\.-]+\.\w+$")

def registrar_log_envio(nombre_pdf, correo, estado):
    with open(LOG_ENVIO_CSV, "a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([nombre_pdf, correo, estado])


# Función para enviar el correo
def enviar_correo(destinatario, archivo_pdf):
    mensaje = EmailMessage()
    mensaje["Subject"] = "Soluciones Ficticias - Factura Electr´onica"
    mensaje["From"] = EMAIL_SENDER
    mensaje["To"] = destinatario
    mensaje.set_content("Adjunto encontrarás el documento solicitado.")

    with open(archivo_pdf, "rb") as f:
        contenido_pdf = f.read()
        mensaje.add_attachment(contenido_pdf, maintype="application", subtype="pdf", filename=os.path.basename(archivo_pdf))
    
    # aca usamos una version simplificada para enviar el correo con el servidor SMTP local
    # esto por cuestion de pruebas y tambien que los correos generados son ficticios normalmete fallarian
    with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.send_message(mensaje)
    
    # Normalmente se deberia usar ssl y un servidor SMTP seguro,como stmtp.gmail.com usando correo enviador y contraseña
    # contexto = ssl.create_default_context()
    # with smtplib.SMTP_SSL(SMTP_SERVER, SMTP_PORT, context=contexto) as server:
    #     server.login(EMAIL_SENDER, EMAIL_PASSWORD)
    #     server.send_message(mensaje)

# Función principal
def procesar_envios():
    pendientes = []
    exitosos = []

    with open(CSV_PATH, newline="", encoding="utf-8") as archivo_csv:
        lector = csv.reader(archivo_csv)
        for linea in lector:
            if len(linea) < 2:
                continue

            # Paths de archivos
            pdf, correo = linea[0].strip(), linea[1].strip()
            pdf_path = os.path.join(PDF_DIR, pdf)

            log_filename = f"send-{os.path.basename(pdf)}-attempt-1.log"
            log_path = os.path.join(LOGS_DIR, log_filename)

            if not EMAIL_REGEX.match(correo):
                with open(log_path, "w") as log:
                    log.write(f"Correo inválido: {correo}\n")
                pendientes.append(linea)
                continue

            try:
                if not os.path.isfile(pdf_path):
                    raise FileNotFoundError(f"No se encontró el archivo: {pdf_path}")
                enviar_correo(correo, pdf_path)
                with open(log_path, "w") as log:
                    log.write(f"Correo enviado exitosamente a {correo} con el archivo {pdf}\n")
                exitosos.append(linea)
                registrar_log_envio(pdf, correo, "exitoso")
            except Exception as e:
                with open(log_path, "w") as log:
                    log.write(f"Error enviando correo a {correo}: {str(e)}\n")
                pendientes.append(linea)
                registrar_log_envio(pdf, correo, "fallido")


    # Escribir las líneas no exitosas de nuevo en el CSV limpiando el contenido
    with open(CSV_PATH, "w", newline="", encoding="utf-8") as archivo_csv:
        escritor = csv.writer(archivo_csv)
        for linea in pendientes:
            escritor.writerow(linea)

if __name__ == "__main__":
    procesar_envios()
