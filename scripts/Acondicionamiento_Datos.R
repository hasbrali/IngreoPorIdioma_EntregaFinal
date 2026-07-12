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

#3. Diagnóstico y Reporte de Datos Perdidos (NAs)-------------------------------

#Reporte Gráfico de NAs
grafico_nas_jefes <- gg_miss_var(base_acondicionada, show_pct = TRUE) +
  labs(
    title = "Porcentaje de Valores Perdidos (NAs) por Variable",
    subtitle = "Diagnóstico analítico con variables renombradas (2024)",
    y = "% de Datos Perdidos",
    x = "Variables del Proyecto"
  ) +
  theme_minimal()
# Guardamos el gráfico
ggsave("outputs/Grafico_NAs_Jefes.png", plot = grafico_nas_jefes, 
       width = 8, height = 6, bg = "white")

#4. Filtrado Muestral Estricto y Exportación Final------------------------------
#Conservamos solo jefes de hogar (código 1), mayores de 14 años y con ingresos mayores a cero.
jefes_filtrada <- base_acondicionada %>%
  filter(jefe_familia == 1, !is.na(ingreso_bruto), ingreso_bruto > 0, edad >= 14)

write_parquet(jefes_filtrada, "Datos/procesados/enaho_jefes_acondicionada.parquet")
