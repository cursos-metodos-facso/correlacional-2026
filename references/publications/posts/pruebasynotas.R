# Pruebas y notas

Sobre los archivos: correr

source("content/publication/bibtex_2academic_plus.R")

- bibtex2academic.R es el básico y que aparece en el blog, así que dejarlo
- bibtex2academic2.R básico + renderiza también carpeta de presentaciones y la pone acá en esta misma carpeta
- bibtex2academic_plus.R : agrega opciones adicionales (con la condición de cortar/pegar info extra en el extra field de Zotero...), y también tiene a las tesis.
- bibtex2academic_plus0.R : como la anterior sin las tesis


Pendientes:

- featured image: hay un script en el blogdown de PRICE de Julio que propone una solución para presentaciones, pero usando el extra field que impide utilizar este espacio para otras cosas (creo). Posible solución: usar el field de Zotero "Call number", que en realidad no sirve de mucho y aquí adaptar código de PRICE para que se libere el extra field.

- solucion para extra fields del YAML: dejar sin la línea final del YAML en script (último +++), y partir el campo Extra en Zotero con eso. Desventaja:
  - hay que agregar +++ a todos los extra, a menos que con un script se pueda hacer condicional (por ejemplo, que si hay 2 +++ seguidos, se elimine 1)
  - funciona, pero permite agregar solo 1 extra field del YAML, porque al correr la función si se pone el segundo extra field en la línea inmediatamente posterior asume una línea, pero si se salta un espacio entre ambas incluye una línea vacía entre ambas, y entonces arroja error (no puede haber líneas vacías en YAML, al menos en este sistema hugo-rmarkdown) :( . Solución: ??. Se prueba con distintos caracteres para generar el espacio desde Extra (|, \, \n ... no los reconoce ) Al parecer el problema está en como se traduce el campo extra con readBib. Tal vez, agregar un caracter especial (|) y reemplazarlo luego con un salto de línea en el archivo.bib, antes de llamarlo con el script.
- lo anterior se soluciona agregando opciones en extra field, ver blog.

pacman::p_load(RefManageR, dplyr, stringr, anytime, tidyr, stringi)
mypubs   <- ReadBib("content/publication/academic-presentations.bib", check = "warn", .Encoding = "UTF-8") %>%
  as.data.frame()

# the "extra" Zotero field is in the "annotation" column

print(mypubs$month[23])
print(gsub("images", "\nimages",mypubs$month[23] ) )

mypubs$month <- mypubs$month %>% replace_na('jan')
