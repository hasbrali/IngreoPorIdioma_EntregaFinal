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
