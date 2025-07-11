from faker import Faker
import random
import csv
from datetime import datetime

fake = Faker('es_MX')

def generar_compras(num_transacciones=100):
    hoy = datetime.now().strftime('%Y%m%d')
    nombre_archivo = f'data/compras_{hoy}.csv'
    
    with open(nombre_archivo, 'w', newline='') as csvfile:
        campos = ['nombre', 'ciudad', 'direccion', 'correo', 'telefono', 
                 'ip', 'monto', 'modalidad_pago', 'estado_pago', 'timestamp']
        writer = csv.DictWriter(csvfile, fieldnames=campos)
        writer.writeheader()
        
        for _ in range(num_transacciones):
            if random.random() < 0.95:
                writer.writerow({
                    'nombre': fake.name(),
                    'ciudad': fake.city(),
                    'direccion': fake.address().replace('\n', ', '),
                    'correo': fake.email(),
                    'telefono': fake.phone_number(),
                    'ip': fake.ipv4(),
                    'monto': round(random.uniform(100, 5000), 2),
                    'modalidad_pago': random.choice(['completo', 'fraccionado']),
                    'estado_pago': random.choice(['exitoso', 'fallido']),
                    'timestamp': datetime.now().isoformat()
                })
            else:
                # Generar registro con error
                writer.writerow({
                    'nombre': fake.name(),
                    'ciudad': '',  # Campo vacío a propósito
                    'direccion': fake.address().replace('\n', ', '),
                    'correo': 'correo_invalido',
                    'telefono': 'abc123',  # Teléfono inválido
                    'ip': '256.300.1.1',  # IP inválida
                    'monto': 'mil pesos',  # Monto inválido
                    'modalidad_pago': 'invalido',
                    'estado_pago': 'desconocido',
                    'timestamp': 'fecha_invalida'
                })

if __name__ == '__main__':
    generar_compras()
