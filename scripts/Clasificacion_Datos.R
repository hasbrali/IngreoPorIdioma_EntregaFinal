#=====================================================================================
#Proyecto: INGRESOS POR IDIOMA
#Autor: Raphael Esteba
#Fecha: 12-07-2026
#Script: CLASIFICACIÓN DE DATOS ENFOQUE: JEFES DE FAMILIA
#=====================
#1.Carga de Librerias-----------------------------------------------------------
library(tidyverse)
library(arrow)
# 1. Carga de datos y creación compacta de variables analíticas-------------------
jefes_analitica <- read_parquet("Datos/procesados/enaho_jefes_exploratoria.parquet") %>%
  mutate(
    d_lengua_indigena = ifelse(lengua_materna %in% c(1, 2, 3, 10:15), 1, 0), # 1 = Indígena, 0 = Castellano
    d_jefa_mujer       = ifelse(sexo == 2, 1, 0),                           # 1 = Mujer, 0 = Hombre
    d_educ_superior   = ifelse(nivel_edu %in% c(7:11), 1, 0),              # 1 = Superior, 0 = Secundaria o menos
    ln_ingreso_bruto  = log(ingreso_bruto)                                 # Logaritmo para normalizar distribución
  )

#MEMO 1 CLASIFICACIÓN
"* Construcción de Indicadores Binarios (Dummies): Se sintetizó la matriz de datos creando variables dicotómicas con valor numérico de uno o cero para aislar las dimensiones críticas de exclusión e inclusión: d_lengua_indigena para agrupar las identidades nativas, d_jefa_mujer para capturar brechas de género en las jefaturas, y d_educ_superior como umbral de acumulación de alto capital humano.
* Normalización de la Variable Dependiente: Se aplicó la transformación logarítmica (log) sobre la variable continua ingreso_bruto para mitigar el sesgo y la presencia de valores atípicos extremos, garantizando el cumplimiento de los supuestos estadísticos en estimaciones de regresión lineal."


# 2. Exportación de la base analítica final
write_parquet(jefes_analitica, "Datos/procesados/enaho_jefes_analitica.parquet")

# 3. Generación del reporte analítico automatizado (Metadatos)
reporte_variables <- tibble(
  Variable_Nueva       = c("d_lengua_indigena", "d_jefa_mujer", "d_educ_superior", "ln_ingreso_bruto"),
  Variable_Origen      = c("p300a (lengua_materna)", "p207 (sexo)", "p301a (nivel_edu)", "ingmo1hd (ingreso_bruto)"),
  Sustento_Sociologico = c(
    "Mide la adscripción a identidades lingüísticas históricamente discriminadas.",
    "Permite analizar la penalidad económica o vulnerabilidad en hogares con jefatura femenina.",
    "Captura el umbral de acumulación de capital humano altamente valorado en el mercado laboral.",
    "Normaliza la distribución del ingreso eliminando el sesgo por valores atípicos extremos."
  )
)
write_csv(reporte_variables, "outputs/Reporte_Nuevas_Variables_Analiticas.csv")

#MEMO 2 CLASIFICACIÓN
"* Documentación Transparente: Se construyó una estructura tabular compacta que vincula de manera explícita cada variable analítica transformada con su respectivo código o indicador de origen proveniente de las encuestas originales de la ENAHO.
* Justificación Teórica: El reporte indexa los argumentos metodológicos detrás de cada métrica, detallando la evaluación de la discriminación lingüística histórica, las penalidades económicas y vulnerabilidades asociadas a la jefatura de hogar femenina, los umbrales de acumulación de capital humano altamente valorados, y los requerimientos estadísticos de simetría distributiva.
* Reproducibilidad: Se automatizó el registro estadístico estructurándolo como un dataframe nativo para facilitar su posterior exportación a formatos planos, sirviendo para la auditoría del proyecto."

