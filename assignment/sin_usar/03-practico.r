# Código: Práctico 3 Estadística Correlacional 2024
# Fecha: 01-10-2024
# Autor: Equipo Docente

# 1. Cargar librerías -----------------------------------------------------

# install.packages("pacman")

pacman::p_load(tidyverse, # Manipulacion datos
               sjPlot, # Graficos
               rstatix, # Test estadísticos
               broom) # Tablas

options(scipen = 999) # para desactivar notacion cientifica
rm(list = ls()) # para limpiar el entorno de trabajo

# 2. Cargar datos ---------------------------------------------------------

# Cargar bbdd pública de ELSOC
load(url("https://dataverse.harvard.edu/api/access/datafile/6160180"))

# 3. Explorar datos -------------------------------------------------------

names(elsoc_2021) # Nombre de columnas
dim(elsoc_2021) # Dimensiones

# 4. Procesamiento ---------------------------------------------------------

# Procesemos la bbdd quedandonos solo con algunas variables de interés
proc_elsoc <- elsoc_2021 %>%
    dplyr::select(
        idencuesta,
        ing_per = m13, 
        ing_per_just = m15,
        edad = m0_edad, 
        mesfuerzo = c18_09, 
        mtalento = c18_10
    ) %>%  # seleccionamos
    dplyr::mutate(
        across(ing_per:mtalento, ~ if_else(. %in% c(-666, -777, -888, -999), NA, .)), # Recodificar a NA
        pmerit = (mesfuerzo + mtalento) / 2 # Crear nueva variable
    ) %>% # recodificamos y transformamos
    labelled::set_variable_labels(
        pmerit = "Promedio entre percepción de meritocracia por esfuerzo y talento"
    ) # etiquetamos

head(proc_elsoc)

# 5. Correlación de Pearson ----------------------------------------------

## ¿Cómo se relacionan los ingresos que las personas reciben con los ingresos que creen que deberían recibir?

## HA: A medida que aumentan los ingresos reales de las personas, también aumentan los ingresos que creen merecer.
## H0: No hay asociación entre ingresos reales y merecidos

cor(x = proc_elsoc$ing_per, 
    y = proc_elsoc$ing_per_just, 
    use = "complete.obs")

# 6. Tamaños de efecto ----------------------------------------------

## < ±0.1  	Muy pequeño 
## ±0.1–0.3 	Pequeño 
## ±0.3–0.5 	Moderado 
## >±0.5 	Grande 

## Interpretación:

# El coeficiente de correlación de Pearson entre los ingresos reales y los ingresos considerados justos 
# es positivo y moderado (r = 0.47) según Cohen (1988).

# 7. Diagramas de dispersión ----------------------------------------------

sjPlot::plot_scatter(data = proc_elsoc, 
                     x = ing_per,
                     y = ing_per_just)


# 8. Inferencia en correlación ----------------------------------------------

## HA: cor(ingresos,ingresos_justos) ≠ 0
## H0: cor(ingresos,ingresos_justos) = 0


cor_results <- cor.test(x = proc_elsoc$ing_per, 
                        y = proc_elsoc$ing_per_just,
                        method = "pearson",
                        use = "complete.obs") # Considerar solo datos completos (listwise)

cor_results

# tabla de calidad
stats.table <- tidy(cor_results)

stats.table %>%
    dplyr::mutate(
        estimate = round(estimate, 2),
        statistic = round(statistic, 2),
        ic_95 = paste0("[", round(conf.low, 2), ",", round(conf.high, 2), "]"),
        stars = gtools::stars.pval(p.value),
        p_value = case_when(
            p.value < 0.05 & p.value > 0.01 ~ "< 0.05",
            p.value < 0.01 & p.value > 0.001 ~ "< 0.01",
            p.value < 0.001 ~ "< 0.001",
            TRUE ~ ""
        ),
        p_value = paste0(p_value, stars)
    ) %>%
    dplyr::select(estimate, statistic, p_value, parameter, method, alternative, ic_95) %>%
    kableExtra::kable(
        col.names = c("Estimación", "t", "p-value", "df", "Método", "Alternativa", "95% IC"),
        booktabs = T
    ) %>%
    kableExtra::kable_styling(
        bootstrap_options = c("striped", "hover", "condensed", "responsive"),
        full_width = T,
        latex_options = "hold_position",
        position = "center"
    )

# 9. Coeficiente de determinación R2 ----------------------------------------------

coef_r <- cor_results$estimate

coef_r

coef_r^2

# 10. Limitaciones de la correlación de Pearson ----------------------------------------------

# a) Valores extremos

sjPlot::plot_scatter(data = proc_elsoc, 
                     x = ing_per, 
                     y = ing_per_just) +
    geom_text(aes(label = "← Ingresos = 750.000 e Ingresos justos = 50.000.000"),
                 x = 5500000, 
                 y = 50100000, 
                 size = 3, 
                 hjust = 1, 
                 color = "black"
                 )

# Encuentra el punto con el valor máximo de ing_per_just
max_ing_per_just <- proc_elsoc %>% 
    dplyr::filter(ing_per_just == max(ing_per_just, na.rm = T))

# Excluye este caso de proc_elsoc
proc_elsoc2 <- proc_elsoc %>% 
    dplyr::filter(!idencuesta %in% max_ing_per_just$idencuesta)

# Calcular coeficiente
cor(x = proc_elsoc2$ing_per, 
    y = proc_elsoc2$ing_per_just, 
    use = "complete.obs")

sjPlot::plot_scatter(data = proc_elsoc2, 
                     x = ing_per, 
                     y = ing_per_just)

# b) Distintas distribuciones

# Ver cuarteto de Anscombe