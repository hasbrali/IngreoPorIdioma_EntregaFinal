#=====================================================
#Proyecto: INGRESOS POR IDIOMA
#Autor: Raphael Esteba
#Fecha: 12-07-2026
#Script: Carga y unión de modulos ENAHO
#====================================================

#1.Carga de Librerias--------------------------------------------------------
library(rio)
library(tidyverse)
library(janitor)
library(readr)
renv::snapshot()


#2 Importacion de datos------------------------------------------------------
mod500  <- import("Datos/Crudos/enaho01a-2024-500.dta") 

mod400  <- import("Datos/Crudos/enaho01a-2024-400.dta") 

mod300  <-  import("Datos/Crudos/enaho01a-2024-300.dta") 

sumaria <- import("Datos/Crudos/sumaria-2024-12g.dta") 

#3. Union de bases y filtrado---------------------------------------------------------

keys = c("aÑo", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato", "codperso")

enaho_total <- mod500 %>%
  filter(p203 == 1) %>% 
  left_join(mod400, by = keys) %>%
  left_join(mod300, by = keys) %>%
  # Sumaria no tiene 'codperso', intersect() seleccionará automáticamente las 8 llaves del hogar
  left_join(sumaria, by = intersect(names(.), names(sumaria)))
#Verificacion de filas
nrow(enaho_total) == nrow(sumaria)

#4. Exportacion de base de datos creada-----------------------------------------
install.packages("arrow")
library(arrow)
renv::snapshot()
write_parquet(enaho_total, "Datos/procesados/enaho_total_2024_050726.parquet")
