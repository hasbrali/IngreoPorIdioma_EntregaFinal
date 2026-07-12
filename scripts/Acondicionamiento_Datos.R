#=====================================================================================
#Proyecto: INGRESOS POR IDIOMA
#Autor: Raphael Esteba
#Fecha: 12-07-2026
#Script: ACONDICIONAMIENTO DE DATOS (ENFOQUE: JEFES DE FAMILIA)
#=====================

#1.Carga de Librerias-----------------------------------------------------------
library(tidyverse)
library(arrow)
library(janitor)
library(naniar)
renv::snapshot()

#2.Carga, selección y renombrado de variables de interés------------------------
gc()
# Cargamos la base integrada
base_unida <- read_parquet("Datos/procesados/enaho_total_2024_050726.parquet")

# Seleccionamos y renombramos de acuerdo al proyecto
base_acondicionada <- base_unida %>%
  select(
    # Keys
    aÑo,
    mes,
    conglome,
    vivienda,
    hogar,
    codperso,
    ubigeo,
    dominio,
    estrato,
    
    # Variables
    ingreso_bruto = ingmo1hd,      # Ingreso disponible mensual del hogar
    jefe_familia  = p203,          # Parentesco (Filtro Jefe = 1)
    edad          = p208a,         # Edad 
    sexo          = p207,          # Sexo
    lengua_materna = p300a,        # Lengua materna / Idioma
    nivel_edu     = p301a,         # Nivel educativo alcanzado
    sector_empleo = p510           # Sector de empleo institucional
  )
