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
library (usethis)
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
#MEMO 1 EXPLORACIÓN
"* Alineación con Diccionario Oficial ENAHO 2024: Se corrigió el mapeo de la variable lengua materna (p300a) para evitar sesgos analíticos anteriores, asignando con precisión el código 4 a Castellano, los códigos 1 y 2 a Quechua y Aymara, e integrando los códigos 3 junto a las desagregaciones de la Amazonía (10 al 15) como Otras Lenguas Nativas.
* Reestructuración del Capital Humano (Nivel Educativo): Se agrupo la variable nivel_edu vinculando de forma precisa primaria completa (código 4) e incompleta con el umbral base, secundaria completa e incompleta (5 y 6) en el rango medio, y consolidando la instrucción superior junto a los niveles de posgrado (7 al 11).
* Estandarización de Atributos: Se transformaron las variables categóricas a factores ordenados en R para optimizar las visualizaciones bivariadas, y se recodificó de manera binaria el sexo del jefe de hogar."

#3 Analisis exploratorio bivariado y univariado---------------------------------

#3.1 Idioma materno por ingreso--------------------------------------------------
bivariado_idioma_ingreso <- jefes_explora %>%
  group_by(idioma_factor) %>%
  summarise(
    Total_Jefes      = n(),
    Ingreso_Promedio = round(mean(ingreso_bruto, na.rm = TRUE), 2),
    Ingreso_Mediano  = round(median(ingreso_bruto, na.rm = TRUE), 2)
  )
write_csv(bivariado_idioma_ingreso, "outputs/Tabla_Bivariado_Idioma_Ingreso.csv")

#MEMO 2 EXPLORACIÓN
"* Evidencia del Sesgo Distribucional: Se calculó la asimetría en todas las categorías, demostrando una brecha persistente donde los ingresos promedio superan sustancialmente a las medianas debido a la concentración de valores extremadamente altos.
* Jerarquización de Ingresos: El reporte confirma que las jefaturas de hogar de habla castellana lideran los ingresos (promedio superior a 34,800 soles), seguidas por las poblaciones aymara y quechua, mientras que el grupo de otras lenguas nativas registra la situación económica más baja de la muestra.
* Consistencia Muestral: Se documentó la distribución del volumen de jefaturas por adscripción, registrando un volumen minoritario de casos no especificados (NA) que, sin embargo, replican comportamientos de altos ingresos."


#3.2 Gráfico Univariado---------------------------------------------------------
#Histograma de la variable continua ingreso bruto.
grafico_uni_ingreso <- ggplot(jefes_explora, aes(x = ingreso_bruto)) +
  geom_histogram(fill = "steelblue", color = "white", bins = 40) +
  scale_x_log10(labels = dollar_format(prefix = "S/. ")) +
  labs(
    title = "Distribución Univariada del Ingreso Bruto Mensual (Escala Log10)",
    subtitle = "Estructura de ingresos en Jefes de Familia (2024)",
    x = "Ingreso Disponible Mensual del Hogar (Soles)",
    y = "Frecuencia de Hogares"
  ) +
  theme_minimal()
ggsave("outputs/Grafico_Univariado_Ingreso.png", plot = grafico_uni_ingreso, width = 8, height = 5, bg = "white")

#MEMO 3 EXPLORACIÓN
"* Transformación de Escala: Se aplicó la función scale_x_log10 para corregir el severo sesgo a la derecha característico de las variables de ingresos, logrando una distribución que se aproxima visualmente a una curva normal (simétrica).
* Identificación de Concentraciones: El gráfico Grafico_Univariado_Ingreso evidencia que la mayor frecuencia de hogares se agrupa sólidamente en torno a los rangos intermedios de la distribución monetaria (cercanos al umbral de las decenas de miles).
* FormatO: Se parametrizó el etiquetado estético con símbolos de la moneda nacional (S/.) y se exportó la gráfica final dentro del directorio de outputs del proyecto."

#3.3 Tabla de distribución de jefes por idioma materno--------------------------
univariado_idioma <- jefes_explora %>%
  count(idioma_factor, name = "frecuencia_absoluta") %>%
  mutate(porcentaje = round((frecuencia_absoluta / sum(frecuencia_absoluta)) * 100, 2))

write_csv(univariado_idioma, "outputs/Tabla_Univariado_Idioma.csv")

#MEMO 4 EXPLORACIÓN
"* Estructura Predominante: La tabla Tabla_Univariado_Idioma evidencia que la gran mayoría de las jefaturas de hogar tienen como lengua materna el Castellano (71.89%, superando las 24,000 jefaturas).
* Participación de Lenguas Indígenas: El Quechua se posiciona como la segunda categoría de mayor peso muestral con el 22.83% (7,672 jefes), seguida por el Aymara con el 3.36% (1,129 jefes) y el conjunto de Otras Lenguas Nativas con un 1.67% (560 jefes).
* Calidad y Consistencia: Se registra una mínima proporción marginal de valores no especificados o perdidos (NA = 0.25%, 83 observaciones), confirmando la solidez de la muestra para el análisis de brechas."


#3.4 Tabla de cruce de idioma con nivel educativo-----------------------------
bivariado_educ_idioma <- jefes_explora %>%
  tabyl(idioma_factor, educ_factor) %>%
  adorn_percentages("row") %>%
  adorn_pct_formatting(digits = 2) %>%
  adorn_ns()

write_csv(bivariado_educ_idioma, "outputs/Tabla_Bivariado_Cruce_Educacion.csv")

#MEMO 5 EXPLORACIÓN

"* Desigualdad Educativa Intergrupal: Se ejecutó una tabulación bidimensional cruzando identificación lingüística y educación acumulada, evidenciando que las jefaturas de hogar quechua, aymara y de otras lenguas nativas concentran su distribución en la categoría de Sin Educación o Primaria completa/incompleta.
* Brecha en Educación Superior: Los resultados demuestran una marcada asimetría en el acceso a instrucción técnica o universitaria, donde el grupo hispanohablante triplica la proporción de educación superior en comparación con las jefaturas quechuahablantes y duplica a las de habla aymara.
* Formateo Relativo: Se utilizaron las funciones de janitor para estimar porcentajes normalizados por fila (row percentages) conservando de forma adyacente las frecuencias absolutas de la muestra, exportando de manera automatizada el archivo Tabla_Bivariado_Cruce_Educacion."


# 3.5 Gráfico Bivariado: Barras de Ingreso Promedio según Idioma Materno
grafico_bi_barras <- ggplot(bivariado_idioma_ingreso, aes(x = idioma_factor, y = Ingreso_Promedio, fill = idioma_factor)) +
  geom_col(color = "black", width = 0.5, show.legend = FALSE) +
  geom_text(aes(label = paste("S/.", format(Ingreso_Promedio, big.mark=","))), vjust = -0.5, fontface = "bold") +
  labs(
    title = "Ingreso Promedio Mensual por Lengua Materna del Jefe de Familia",
    subtitle = "PC4: Brechas de ingresos según adscripción lingüística (2024)",
    x = "Lengua Materna",
    y = "Ingreso Promedio (Soles)",
    caption = "Fuente: ENAHO 2024 - Instituto Nacional de Estadística e Informática"
  ) +
  scale_y_continuous(labels = dollar_format(prefix = "S/. "), limits = c(0, max(bivariado_idioma_ingreso$Ingreso_Promedio) * 1.15)) +
  theme_minimal()

ggsave("outputs/Grafico_Bivariado_Barras.png", plot = grafico_bi_barras, width = 9, height = 6, bg = "white")

#MEMO 6 Exploración
"* Evidencia de Desigualdad: El gráfico Grafico_Bivariado_Barras muestra las marcadas brechas salariales en el Perú, posicionando a las jefaturas de habla castellana con los retornos promedio más altos (superando los 34,800 soles), seguidas por las poblaciones aymara y quechua, mientras que las otras lenguas nativas registran el menor promedio de ingresos"
