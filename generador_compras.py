# Importar los paquetes
from faker import Faker
import random
import csv
from datetime import datetime
import os, traceback

# Instanciar la clase Faker
fake = Faker('es_MX')

# Funcion que se encarga de generar el objeto de datos
def generar_datos(cantidad=100):
    try:
        # Validar que la cantidad sea un entero positivo
        if not isinstance(cantidad, int) or cantidad <= 0:
            raise ValueError("La cantidad debe ser un número entero positivo.")
        
        # inicializamos la variable para almacenar los datos generados
        datos = []
        for _ in range(cantidad):
            registro = {
                'nombre': fake.name(),
                'ciudad': fake.city(),
                'direccion': fake.address().replace("\n", ", "),
                'correo': fake.email(),
                'telefono': fake.phone_number(),
                'ip': fake.ipv4(),
                'monto': f"$ {round(random.uniform(10, 1000), 2)}",
                'modalidad_pago': random.choice(['completo', 'fraccionado']),
                'estado_pago': random.choice(['exitoso', 'fallido']),
                'timestamp': fake.date_time_between(start_date='-1y', end_date='now').strftime('%Y-%m-%d %H:%M:%S')
            }
            datos.append(registro)

        return datos

    except Exception as e:
        print("Ocurrió un error al generar los datos:")
        traceback.print_exc()
        return []


def generar_compras(datos):
    # Verificar que hayan datos para crear y exportar el archivo csv
    if len(datos) < 1:
        raise ValueError("El argumento 'datos' debe contener datos")
    
    # Validar que exista la carpeta y crearla si no existe
    os.makedirs('./scripting-101/data', exist_ok=True)

    # Generar el nombre del archivo
    hoy = datetime.now().strftime('%Y%m%d')
    id = random.randint(100000, 999999)
    nombre_archivo = f'./scripting-101/data/compras_{id}_{hoy}.csv'

    try:
        with open(nombre_archivo, 'w', newline='') as csvfile:
            # Definimos campos especificos
            campos = ['nombre', 'ciudad', 'direccion', 'correo', 'telefono', 
                    'ip', 'monto', 'modalidad_pago', 'estado_pago', 'timestamp']
            
            # Inicializamos el objeto csv
            writer = csv.DictWriter(csvfile, fieldnames=campos)
            writer.writeheader()
            
            # Recorremos los datos
            for d in datos:
                # Si el valor random es menor
                if random.random() < 0.95:
                    # Generamos el registro correcto
                    writer.writerow({
                        'nombre': d['nombre'],
                        'ciudad': d['ciudad'],
                        'direccion': d['direccion'],
                        'correo': d['correo'],
                        'telefono': d['telefono'],
                        'ip': d['ip'],
                        'monto': d['monto'],
                        'modalidad_pago': d['modalidad_pago'],
                        'estado_pago': d['estado_pago'],
                        'timestamp': d['timestamp']
                    })
                else:
                    # Generar registro con error
                    writer.writerow({
                        'nombre': d['nombre'],
                        'ciudad': '',  # Campo vacío a propósito
                        'direccion': d['direccion'],
                        'correo': 'correo_invalido',
                        'telefono': 'abc123',  # Teléfono inválido
                        'ip': '256.300.1.1',  # IP inválida
                        'monto': 'mil pesos',  # Monto inválido
                        'modalidad_pago': 'invalido',
                        'estado_pago': 'desconocido',
                        'timestamp': 'fecha_invalida'
                    })
        
        print(f"Archivo guardado correctamente en: {nombre_archivo}")
        return
    except Exception as e:
        print(f"Ocurrió un error al guardar el archivo: {e}")
        traceback.print_exc()
        return

def main():
    # llamamos a la funcion que genera los datos, (por defecto genera 100 compras)
    datos = generar_datos()

    # llamamos a la funcion que genera ls compras
    generar_compras(datos)
    return 0


if __name__ == '__main__':
    main()
