#=====================================================
#Proyecto: INGRESOS POR IDIOMA
#Autor: Raphael Esteba
#Fecha: 12-07-2026
#====================================================

#Creación de Carpetas------------------

dir.create("Datos")
dir.create("Datos/Crudos")
dir.create("Datos/procesados")
dir.create("outputs")
dir.create("docs")
dir.create("scripts")


#Enlace con Git y Github
usethis::use_git_config(
  user.name = "Hasbrali",
  user.email = "esteba.raphael@pucp.edu.pe"
)

usethis::use_git()
gitcreds::gitcreds_set()
usethis::use_github()
