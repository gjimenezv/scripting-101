from faker import Faker
import random
import csv
from datetime import datetime
import time

fake = Faker('es_MX')

def generar_compras(num_transacciones=5):
    hoy = datetime.now().strftime('%Y%m%d')
    nombre_archivo = f'bills/{hoy}.csv'
    
    with open(nombre_archivo, 'w', newline='') as csvfile:
        campos = ['id_transaccion','nombre', 'ciudad', 'direccion', 'correo', 'telefono', 
                 'ip', 'cantidad', 'monto', 'modalidad_pago', 'estado_pago', 'timestamp']
        writer = csv.DictWriter(csvfile, fieldnames=campos)
        writer.writeheader()
        
        for _ in range(num_transacciones):
            dt = fake.date_time_this_year()
            numero_random =  int(time.mktime(dt.timetuple()))
            id_transaccion = hoy + "-" + str(numero_random)[-3:]
            if random.random() < 0.95:
                writer.writerow({
                    'id_transaccion': id_transaccion,
                    'nombre': fake.name(),
                    'ciudad': fake.city(),
                    'direccion': fake.address().replace('\n', '- ').replace(',', ' '),
                    'correo': fake.email(),
                    'telefono': fake.phone_number(),
                    'ip': fake.ipv4(),
                    "cantidad": fake.random_int(min=1, max=20),
                    'monto': round(random.uniform(100, 5000), 2),
                    'modalidad_pago': random.choice(['completo', 'fraccionado']),
                    'estado_pago': random.choice(['exitoso', 'fallido']),
                    'timestamp': datetime.now().isoformat()
                })
            else:
                # Generar registro con error
                writer.writerow({
                    'id_transaccion': id_transaccion,
                    'nombre': fake.name(),
                    'ciudad': '',  # Campo vacío a propósito
                    'direccion': fake.address().replace('\n', '- ').replace(',', ' '),
                    'correo': 'correo_invalido',
                    'telefono': 'abc123',  # Teléfono inválido
                    'ip': '256.300.1.1',  # IP inválida
                    "cantidad": 0,
                    'monto': 'mil pesos',  # Monto inválido
                    'modalidad_pago': 'invalido',
                    'estado_pago': 'desconocido',
                    'timestamp': 'fecha_invalida'
                })

if __name__ == '__main__':
    num_transacciones = random.randint(1, 10)
    generar_compras(num_transacciones)
