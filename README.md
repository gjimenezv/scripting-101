# scripting-101

This repository contains the code required for the IRSI certification scripting project.

## Setup

### Install

Set up a Python virtual environment to isolate the required dependencies.

**Linux/macOS**
```bash
sudo apt install python3-venv
```

**Windows**  
Download and install Python from [python.org](https://www.python.org/downloads/windows/).

### Create Virtual Environment

Create a virtual environment for the project dependencies.

**Linux/macOS**
```bash
python3 -m venv venv
```

**Windows**
```bash
python -m venv venv
```

### Activate the Environment

**Linux/macOS**
```bash
source venv/bin/activate
```

**Windows**
```bash
venv\Scripts\activate
```

### Install Dependencies

Install the required Python packages:

```bash
pip install -r requirements.txt
```

Install the `pdflatex` dependencies:

```bash
sudo apt install texlive-latex-base texlive-latex-extra -y
```

## How to Run

1. **Generate Purchases CSV:**  
    Run `generador_compras.py` to create a new file in `bills/[date].csv` containing 1 to 10 randomly generated bills using the Faker package.
    ```bash
    python generador_compras.py
    ```

2. **Set Script Permissions:**  
    Grant execution permissions to the shell script (run this only once).
    ```bash
    sudo chmod u+x generador_facturas.sh
    ```

3. **Generate Invoices:**  
    Run `generador_facturas.sh` to generate a `templates/[id_transaccion].tex` file for each bill (row) in the CSV file `bills/[date].csv`, using `template.tex` as a base and replacing the relevant values. This script also generates a log file for each bill inside the `logs` folder, as well as a PDF for each bill inside the `pdf` folder. Additionally, the script creates a `cron/pendientes_envio.csv` file containing the PDF file and corresponding email address, which is used by another script (run as a cron job) to send an email with the PDF attached.

    ```bash
    ./generador_facturas.sh
    ```

4. **Run an SMTP server locally**  
    Run the MailHog image locally on port 1025 (Docker installation required):  
    ```bash
    sudo docker run -d -p 1025:1025 -p 8025:8025 mailhog/mailhog
    ```
    You can access the MailHog web interface at http://localhost:8025 to view sent emails.
    You can also enable Jim, MailHog’s built-in filtering tool, to reject specific senders and recipients.
   
5. **Send invoices**  
    ```bash
    python enviador.py
    ```
    Run `enviador.py` to read email addresses and PDF attachments from cron/pendientes_envio.csv.
    The script will process each row and send an email with the corresponding attachment.
    It will generate a log file in `logs/log_envios.csv` to track whether the email was sent successfully or not.
    You can review the sent emails in the MailHog web interface.



