# Pipeline de Inferencia Filogenética para SARS-CoV-2

Pipeline automatizado de alto rendimiento orquestado con Snakemake. Combina procesamiento de bajo nivel en Rust para el filtrado de secuencias, análisis vectorial en Python (NumPy/Biopython) para el control de calidad, e inferencia de Máxima Verosimilitud (C++). Todo el entorno de ejecución está garantizado y aislado mediante uv.

## Requisitos del Sistema (Dependencies)

> **Importante:** Este proyecto está diseñado exclusivamente para entornos **Linux (x86_64)**.

Para poder ejecutar el pipeline, es necesario contar con las siguientes dependencias instaladas en el sistema:

* **uv**: Gestor de paquetes ultrarrápido (sustituto de pip/venv).
* **mafft**: Herramienta de alineamiento múltiple (debe estar en el PATH del sistema).
* **NCBI Datasets CLI y unzip**: Requeridos únicamente si se va a ejecutar `download.sh`.

> **Nota Arquitectónica:** Para garantizar la portabilidad sin necesidad de compiladores locales, el filtro rápido de control de calidad (`sars_filter`) y el motor de inferencia filogenética (`iqtree3`) se proporcionan como binarios precompilados en la carpeta `bin/`.

## Fases del Pipeline (Arquitectura de Datos)

El flujo del grafo acíclico dirigido (DAG) de Snakemake se divide en:

* **Fase 1 (Bash)**: Descarga de secuencias de variantes (VOCs) desde NCBI.
* **Fase 2 (Rust)**: Filtrado O(n) por longitud de secuencia usando el binario nativo.
* **Fase 3 (MAFFT)**: Alineamiento múltiple paralelizado.
* **Fase 4 (Python/NumPy)**: Limpieza matricial de gaps y generación de histogramas de variabilidad posicional.
* **Fase 5 (IQ-TREE)**: Construcción del árbol filogenético (Maximum Likelihood) con selección automática de modelo evolutivo.

## Instrucciones de Ejecución (Reproducibilidad)

```bash
# 1. Clonar el repositorio
git clone https://github.com/gutierrels/sars-cov-2-phylogeny.git
cd sars-cov-2-phylogeny

# 2. Sincronizar el entorno de Python usando el uv.lock
uv sync

# 3. Dar permisos a los binarios locales
chmod +x bin/sars_filter bin/iqtree3

# 4. Ejecutar el orquestador (usando 16 hilos)
uv run snakemake -c 16
```

## Estructura de Resultados (Outputs)

Al finalizar, se generará una carpeta `results/` (ignorada en Git) que contendrá:

* `results/tree/sars_cov_2.treefile`: Árbol en formato Newick.
* `results/qc/variability_plot.pdf`: Histograma de mutaciones/gaps.
* `results/logs/`: Registros estándar y de error de cada regla.
