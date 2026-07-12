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
