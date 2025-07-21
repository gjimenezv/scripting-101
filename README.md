# Scripting-101

This repository contains the code required for the IRSI certification scripting project. The system automates the generation, processing, and distribution of invoices through a complete pipeline.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Automated Workflow](#automated-workflow)
- [Manual Execution](#manual-execution)

## Prerequisites

- Python 3.6 or higher
- Docker (for local SMTP server)
- LaTeX distribution (for PDF generation)

## Installation

### 1. Set Up Python Virtual Environment

**Linux/macOS:**
```bash
sudo apt install python3-venv
```

**Windows:**
Download and install Python from [python.org](https://www.python.org/downloads/windows/).

### 2. Create and Activate Virtual Environment

**Create virtual environment:**

*Linux/macOS:*
```bash
python3 -m venv venv
```

*Windows:*
```bash
python -m venv venv
```

**Activate virtual environment:**

*Linux/macOS:*
```bash
source venv/bin/activate
```

*Windows:*
```bash
venv\Scripts\activate
```

### 3. Install Dependencies

**Install Python packages:**
```bash
pip install -r requirements.txt
```

**Install LaTeX dependencies (Linux/macOS):**
```bash
sudo apt install texlive-latex-base texlive-latex-extra -y
```

## Project Structure

```
scripting-101/
├── bills/                    # Generated CSV files with purchase data
├── templates/                # LaTeX templates for invoices
├── pdf/                      # Generated PDF invoices
├── logs/                     # Log files and processing records
├── cron/                     # Files for automated processing
├── generador_compras.py      # Purchase data generator
├── generador_facturas.sh     # Invoice generation script
├── enviador.py              # Email sender script
├── enviador-resumen.py      # Summary email sender
├── generador_resumen.sh     # Summary generation script
├── cron_job.sh              # Automated workflow script
└── requirements.txt         # Python dependencies
```

## Usage

### Automated Workflow

The entire invoice processing pipeline can be automated using the cron job script:

```bash
./cron_job.sh
```

This single command executes all processing steps automatically.

### Manual Execution

For step-by-step manual execution or testing individual components:

#### Step 1: Generate Purchase Data
```bash
python generador_compras.py
```
Creates a CSV file in `bills/[date].csv` containing 1-10 randomly generated bills using the Faker package.

#### Step 2: Set Script Permissions (One-time setup)
```bash
sudo chmod u+x generador_facturas.sh
```

#### Step 3: Generate Invoices
```bash
./generador_facturas.sh
```
This script:
- Generates `templates/[id_transaccion].tex` files for each bill using `plantilla_factura.tex` as a template
- Creates log files in the `logs` folder for each processed bill
- Generates PDF files in the `pdf` folder
- Creates `cron/pendientes_envio.csv` with email addresses and corresponding PDF files for delivery

#### Step 4: Start Local SMTP Server
```bash
sudo docker run -d -p 1025:1025 -p 8025:8025 mailhog/mailhog
```
- Access the MailHog web interface at http://localhost:8025 to view sent emails
- Optional: Enable Jim (MailHog's filtering tool) to reject specific senders and recipients

#### Step 5: Send Invoices
```bash
python enviador.py
```
- Reads email addresses and PDF attachments from `cron/pendientes_envio.csv`
- Sends emails with corresponding PDF attachments
- Generates `logs/log_envios.csv` to track delivery status
- Review sent emails in the MailHog web interface

#### Step 6: Generate Invoice Summary
```bash
./generador_resumen.sh
```
Creates a comprehensive summary of all processed invoices and saves it to `logs/resumen-envios.log`.

#### Step 7: Send Summary to Administrator
```bash
python enviador-resumen.py
```
- Sends the contents of `logs/resumen-envios.log` as the email body
- Attaches `cron.log` to the administrative email

#### Step 8: Create Temporary User Accounts (Windows PowerShell)
```powershell
.\usuarios.ps1
```
This PowerShell script automates the creation of temporary user accounts:
- Reads employee data from `staff/empleados.csv`
- Generates secure random passwords for each user
- Creates local Windows user accounts with appropriate group assignments
- Sets account expiration dates based on employment duration
- Generates comprehensive logs in `logs/usuarios_[date].log`
- Assigns users to "Administradores" or "Usuarios" groups based on their position

**Prerequisites for Windows script:**
- Windows PowerShell with administrator privileges
- Employee data file: `staff/empleados.csv` with columns: Nombre, Apellido, Puesto, Departamento, FechaInicio, FechaFin
- Script must be run with elevated permissions to create local user accounts

**CSV Format Example:**
```csv
Nombre,Apellido,Puesto,Departamento,FechaInicio,FechaFin
Juan,Pérez,Supervisor,Ventas,2025-01-15,2025-06-15
María,García,Empleado,Soporte,2025-02-01,2025-07-31
```

## Notes

- Ensure all dependencies are properly installed before running the scripts
- The system uses MailHog for local email testing - check the web interface to verify email delivery
- Log files are generated throughout the process for monitoring and troubleshooting
- The automated workflow handles all steps sequentially, making it ideal for scheduled execution
- The Windows PowerShell script (usuarios.ps1) requires administrator privileges and should be run separately on Windows systems