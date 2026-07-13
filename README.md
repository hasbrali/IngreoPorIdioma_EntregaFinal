# README — Análisis de la Brecha de Ingresos por Idioma Materno utilizando datos de la ENAHO

## Autor: Raphael Esteba

## Curso: Taller de Procesamiento de Datos

## Encuesta: Encuesta Nacional de Hogares (ENAHO), Instituto Nacional de Estadística e Informática (INEI), 2024 (versión anual)

## Módulos utilizados: 
* Módulo 300 (Educación)
* Módulo 400 (Salud)
* Módulo 500 (Empleo e ingresos)
* Módulo de Pobreza y de Ingresos de Jefes de Familia (Sumaria)

## Unidad de análisis: Jefes de familia (jefaturas de hogar) mayores de 14 años con ingresos positivos

## Descripción del proyecto
Este repositorio incluye el código y el flujo de trabajo completo del proyecto **"Análisis de la Brecha de Ingresos por Idioma Materno utilizando datos de la ENAHO"**, elaborado para el curso de Taller de Procesamiento de Datos de la PUCP. 

Se utilizan datos oficiales de la Encuesta Nacional de Hogares (ENAHO) de 2024 trabajados íntegramente en R. La consistencia y reproducibilidad de todas las librerías del entorno de paquetes privados se controla rigurosamente utilizando el sistema de gestión de dependencias `renv`.

El análisis explora la relación entre las brechas socioeconómicas y las siguientes dimensiones:
* **Demográficas**: Estructura de parentesco (jefes), edad, sexo biológico y adscripción según lengua materna.
* **Capital Humano y Economica**: Ingresos Brutos por hogar, máximo nivel educativo alcanzado y sector institucional de empleo.

## 1. EXTRAER
* **Qué se hizo**: Se descargaron los módulos correspondientes a Educación (300), Salud (400), Empleo (500) y la Sumaria de hogar de la ENAHO 2024.
* **Decisiones y justificación**: Las fuentes se extrajeron en su formato propietario original .dta (Stata) para resguardar la metadata y las etiquetas de origen de las variables.
Los archivos se mantuvieron intactos y alojados en el directorio Datos/Crudos/ para asegurar el principio de inmutabilidad de las fuentes primarias.
* **Outputs**: Módulos originales almacenados en la carpeta Datos/Crudos/.
## 2. GESTIONAR
* **Qué se hizo**: Se inicializó un entorno de control mediante R Project (IngresoPorIdioma.Rproj) conectado con la plataforma remota de GitHub.
El control de la reproducibilidad de las librerías se aisló mediante renv.
* **Decisiones y justificación**: Para optimizar el rendimiento del almacenamiento y evitar bloqueos por tamaño excesivo de archivos en Git, se configuró el archivo .gitignore excluyendo los archivos de datos masivos .dta.
El procesamiento se agilizó utilizando la librería arrow para persistir las bases intermedias en formato binario eficiente .parquet.
* **Outputs**: Estructura de carpetas jerárquica, archivo de bloqueo renv.lock y exclusión de datos configurada en .gitignore
## 3. ACONDICIONAR
* **Qué se hizo**: Se ejecutó la unión relacional de los módulos mediante uniones externas izquierdas (left_join) utilizando un vector estricto de llaves de consistencia socio-temporal e identificación personal: aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato y codperso. Para el módulo de sumaria, la fusión se automatizó mediante la intersección de las 8 llaves correspondientes a nivel de hogar.
Posteriormente, se seleccionaron y renombraron las variables de interés mapeando los códigos nativos del INEI hacia la nomenclatura del proyecto: ingmo1hd como ingreso_bruto (ingreso disponible mensual), p203 como jefe_familia (parentesco), p208a como edad, p207 como sexo, p300a como lengua_materna, p301a como nivel_edu y p510 como sector_empleo (sector institucional).
* **Decisiones y justificación**: Se aplicó un filtro muestral estricto reteniendo solo a jefes de familia (p203 == 1), mayores de 14 años y con ingresos mensuales válidos mayores a cero.
Se implementó un diagnóstico de datos perdidos con la librería naniar que reveló que la variable sector_empleo concentraba la asimetría de omisiones mientras el resto presentaba consistencia plena.
* **Outputs**: Base maestra unificada en Datos/procesados/enaho_total_2024_050726.parquet, base filtrada limpia en Datos/procesados/enaho_jefes_acondicionada.parquet y el diagnóstico visual outputs/Grafico_NAs_Jefes.png.
## 4. EXPLORAR
* **Qué se hizo**: Se realizó un análisis exploratorio de datos (EDA) univariado y bivariado cruzando el idioma materno del jefe con el nivel de ingresos y el capital humano alcanzado.
* **Decisiones y justificación**: Se recodificaron las variables nativas a factores ordenados en R de acuerdo al diccionario oficial 2024, agrupando de forma estricta los códigos de lenguas de origen amazónico y nativo en una sola categoría analítica frente al castellano (4), quechua (1) y aymara (2).
Para el análisis del ingreso continuo se utilizó una transformación de escala logarítmica con el fin de corregir el severo sesgo hacia la derecha.
* **Outputs**: Base estructurada Datos/procesados/enaho_jefes_exploratoria.parquet y reportes en outputs/ (Tabla_Univariado_Idioma.csv, Tabla_Bivariado_Cruce_Educacion.csv, Tabla_Bivariado_Idioma_Ingreso.csv, el histograma Grafico_Univariado_Ingreso.png y el gráfico de barras bivariado Grafico_Bivariado_Barras.png).
* **Relevancia de los hallazgos y análisis de los outputs**
Los resultados obtenidos en los entornos de análisis revelan una profunda y persistente asimetría estructural en la distribución del ingreso y el capital humano en el Perú. La Tabla_Bivariado_Cruce_Educacion.csv evidencia una marcada brecha en el acceso a la instrucción superior, donde la población hispanohablante triplica la tasa de acceso técnico o universitario en comparación con las jefaturas quechuahablantes y aymaras, quienes concentran más del 47% y 58% de sus miembros en los niveles educativos base (Sin instrucción o Primaria).
Esta desigualdad en la acumulación de credenciales educativas se traduce directamente en penalidades económicas severas dentro del mercado laboral, tal como lo expone el Grafico_Bivariado_Barras.png, donde los hogares liderados por jefes con lenguas originarias nativas registran retornos promedio drásticamente inferiores frente a sus contrapartes criollo-mestizas occidentales.
La relevancia metodológica de estos outputs radica en su capacidad para operacionalizar y aportar evidencia cuantitativa robusta a las teorías contemporáneas de la estratificación social y la exclusión histórica en el contexto peruano. Al constatar que el ingreso promedio diverge sustancialmente de la mediana en todas las adscripciones lingüísticas (Tabla_Bivariado_Idioma_Ingreso.csv), se comprueba la existencia de una distribución altamente concentrada y desigual, la cual distorsionaría las proyecciones si no se aplicaran los controles rigurosos diseñados en la etapa analítica.
En consecuencia, la normalización logarítmica en el Grafico_Univariado_Ingreso.png y la indexación de metadatos teóricos en el Reporte_Nuevas_Variables_Analiticas.csv no es menor, sino un paso indispensable para aislar con precisión el impacto interseccional del género, la etnicidad y la educación en futuros modelos predictivos y de inferencia causal.
## 5. CLASIFICAR
* **Qué se hizo**: Se operacionalizaron variables analíticas avanzadas compactando la matriz de datos a través de transformaciones vectoriales directas con tidyverse.
* **Decisiones y justificación**: Se construyeron variables dummy binarias (1 o 0) para aislar dimensiones de exclusión estructural, género y capital humano: d_lengua_indigena (adscripciones nativas discriminadas históricamente), d_jefa_mujer (penalidad económica por jefatura femenina) y d_educ_superior (umbral de acumulación educativa valorada).
Se generó el logaritmo de los ingresos (ln_ingreso_bruto) para cumplir los supuestos de simetría estadística.
* **Outputs**: Base analítica indexada Datos/procesados/enaho_jefes_analitica.parquet y el reporte automatizado de metadatos conceptuales outputs/Reporte_Nuevas_Variables_Analiticas.csv.
## 6. DOCUMENTAR
* **Qué se hizo**: La documentación del proyecto se integró en este archivo README.md, el cual funciona como el informe oficial del proyecto de procesamiento de datos.
* **Decisiones y justificación**: Cada script de procesamiento de datos fue estructurado incluyendo cabeceras descriptivas con autoría, fechas y bloques funcionales comentados para permitir la auditoría externa del código.
Las justificaciones de las transformaciones y decisiones metodológicas se registraron tanto de forma integrada en el archivo de metadatos como a través del historial de cambios documentado en los commits de Git.Outputs: Scripts comentados y el presente archivo README.md del repositorio.

---


## Estructura del directorio
El espacio de trabajo se organiza formalmente a través de la siguiente estructura de carpetas:

```text
├── IngresoPorIdioma.Rproj            # Archivo de inicialización del entorno R Project
├── scripts/                          # Flujo secuencial indexado del procesamiento de datos
│   ├── Enlace_Carpetas.R             # Configuración inicial del entorno y directorios locales
│   ├── Carga_Union_Modulos.R         # Importación, estandarización de eñes y consolidación (Joins)
│   ├── Acondicionamiento_Datos.R     # Selección, filtro de muestra de jefes y diagnóstico de NAs
│   ├── Exploracion_Datos.R           # Inyección de factores de expansión, etiquetas y gráficas del EDA
│   └── Clasificacion_Datos.R         # Construcción indexada de variables dummies y escala logarítmica
├── Datos/
│   ├── Crudos/                       # Módulos originales de la ENAHO 2024 en formato .dta (Stata)
│   │   ├── enaho01a-2024-300.dta     # Módulo de Educación
│   │   ├── enaho01a-2024-400.dta     # Módulo de Salud
│   │   ├── enaho01a-2024-500.dta     # Módulo de Empleo
│   │   └── sumaria-2024-12g.dta      # Módulo de Pobreza e Ingresos
│   └── procesados/                   # Bases maestras integradas en formato eficiente .parquet
│       ├── enaho_total_2024_050726.parquet   # Base total unida producto de Carga_Union_Modulos.R
│       ├── enaho_jefes_acondicionada.parquet # Base filtrada post-diagnóstico (Acondicionamiento_Datos.R)
│       ├── enaho_jefes_exploratoria.parquet  # Base con factores y factores ordenados (Exploracion_Datos.R)
│       └── enaho_jefes_analitica.parquet     # Base analítica final con dummies y logaritmos (Clasificacion_Datos.R)
├── outputs/                          # Resultados, tablas y gráficos generados por los scripts
│   ├── Grafico_NAs_Jefes.png         # Reporte gráfico del porcentaje de valores perdidos
│   ├── Grafico_Univariado_Ingreso.png # Histograma de ingresos en escala Log10
│   ├── Grafico_Bivariado_Barras.png  # Gráfico de barras de ingreso promedio según idioma
│   ├── Tabla_Univariado_Idioma.csv   # Distribución de frecuencias absolutas y relativas por lengua materna
│   ├── Tabla_Bivariado_Cruce_Educacion.csv # Tabla de cruce de idioma con nivel educativo
│   ├── Tabla_Bivariado_Idioma_Ingreso.csv   # Estadísticos de ingresos promedio y mediano por idioma
│   └── Reporte_Nuevas_Variables_Analiticas.csv # Matriz de metadatos y sustento de dummificaciones
├── renv/                             # Carpeta aislada del entorno local de paquetes privados
├── renv.lock                         # Registro exacto ("cápsula del tiempo") de las versiones de las librerías
└── .gitignore                        # Configuración de exclusión para evitar subir las bases pesadas a GitHub
