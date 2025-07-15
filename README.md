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
    python3 generador_compras.py
    ```

2. **Set Script Permissions:**  
    Grant execution permissions to the shell script (run this only once).
    ```bash
    sudo chmod u+x generador_facturas.sh
    ```

3. **Generate Invoices:**  
    Run `generador_facturas.sh` to generate a `templates/[id_transaccion].tex` file for each bill (row) in the CSV file `bills/[date].csv`, using `template.tex` as a base and replacing the relevant values. This script also generates a log file for each bill inside the `logs` folder, as well as a PDF for each bill inside the `pdf` folder.

    ```bash
    ./generador_facturas.sh
    ```
