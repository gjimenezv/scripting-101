#!/bin/bash

TEMPLATE="templates/template.tex"
OUTPUT_DIR="templates"
FACTURAS_DIR="facturas"

for CSV in "$FACTURAS_DIR"/*.csv; do
    BASENAME=$(basename "$CSV" .csv)
    TEX="$OUTPUT_DIR/$BASENAME.tex"
    cp "$TEMPLATE" "$TEX"

    # Leer encabezados y valores
    headers=$(head -n1 "$CSV")
    values=$(tail -n1 "$CSV")

    echo headers: $headers
    echo values: $values

    # Reemplazar los encabezados y valores en el archivo .tex
done
