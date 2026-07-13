#================================================================================
#Proyecto: INGRESOS POR IDIOMA
#Autor: Raphael Esteba
#Fecha: 12-07-2026
#Script: EXPLORACIÓN DE DATOS ENFOQUE: JEFES DE FAMILIA
#================================================================================
#1.Carga de Librerias y Base de Datos-----------------------------------------------------------
library(tidyverse)
library(arrow)
library(scales)
#Base acondicionada
jefes_acondicionada <- read_parquet("Datos/procesados/enaho_jefes_acondicionada.parquet")

#2. Recodificación Metodológica--------------------------------------------------

#Creación de códigos numéricos a etiquetas---------------------------------------

jefes_explora <- jefes_acondicionada %>%
  mutate(
    # Lengua Materna (p300a) - Ajuste estricto al diccionario oficial 2024
    idioma_factor = case_when(
      lengua_materna == 1 ~ "Quechua",
      lengua_materna == 2 ~ "Aymara",
      lengua_materna == 4 ~ "Castellano",
      lengua_materna %in% c(3, 10, 11, 12, 13, 14, 15) ~ "Otras Lenguas Nativas",
      TRUE ~ "Otros/No especificado"
    ),
    idioma_factor = factor(idioma_factor, levels = c("Castellano", "Quechua", "Aymara", "Otras Lenguas Nativas")),
    
    # Nivel Educativo (p301a) - Ajuste estricto a la codificación del módulo 300
    educ_factor = case_when(
      nivel_edu %in% c(1, 2, 3, 4) ~ "Sin Educ / Primaria", # Incluye primaria completa (4)
      nivel_edu %in% c(5, 6)       ~ "Secundaria",           # Secundaria incompleta (5) y completa (6)
      nivel_edu %in% c(7, 8, 9, 10, 11) ~ "Superior (Tec/Univ)", # Superiores y posgrados (7 al 11)
      TRUE ~ "No especificado"
    ),
    educ_factor = factor(educ_factor, levels = c("Sin Educ / Primaria", "Secundaria", "Superior (Tec/Univ)")),
    
    # Sexo (p207)
    sexo_factor = case_when(
      sexo == 1 ~ "Hombre",
      sexo == 2 ~ "Mujer",
      TRUE ~ NA_character_
    )
  )


