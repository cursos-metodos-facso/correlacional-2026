# Ejercicio de inferencia

A Ud. se le ha solicitado estimar el promedio de ingresos en la población, así como también si existen diferencias de ingresos entre quienes han completado la educación superior en institutos técnico-profesionales y en quienes lo han hecho en instituciones universitarias. Para ello se le han propocionado los siguientes datos de la encuesta:
  
  - Datos: Encuesta de Ingresos, muestra aleatoria N=1.000 casos
  - Promedio salarios: 900.000, desviación estándar 200.000
  - Salario promedio técnico-profesional: 850.000, desviación estandar 100.000
  - Salario promedio universitario: 1.000.000, desviación estándar 150.000
  
Además de esto, se le han proporcionado los siguientes valores de inferencia estadística:
  
  - valor crítico z para el promedio con un $\alpha$ de 5% (0,05)= 1,96
  - valor crítico t para diferencia de medias con  un $\alpha$ de 5% (0,05) y grados de libertad 998 (N-2)= 1,96
  

## A. Estimación del promedio de salarios (de la población)

- Tengo que el promedio de salarios de la muestra es: 900.000
- Promedio de salarios de la población: $X$

### Test de hipótesis a realizar  

¿Qué tipo de aproximación de test de hipótesis corresponde en este caso? Recordemos las dos aproximaciones principales para test de hipótesis: a) contraste con valor crítico, y b) generación de intervalo de confianza. En general se pueden aplicar siempre las dos, pero su pertinencia es distinta según lo que se esté estimando:
  
- en este caso (estimación del promedio) se podría realizar la alternativa de contraste con valor crítico, que nos permitiría rechazar (o no) la hipótesis nula de que el promedio es cero en la población. 

- ya que la alternativa anterior no es muy informativa en este caso, en la estimación puntual de parámetros (como el promedio) se prefiere utilizar un rango de probabilidad, expresado en un intervalo de confianza.

Por lo tanto, en este caso lo que es más pertinente es la alternativa b: estimación de un intervalo de confianza

### Construcción de intervalo y 5 pasos de la inferencia

Los 5 pasos de la inferencia en esta caso son los siguientes:

1. Formular hipótesis ( 

Contrastamos la *hipótesis nula* (el promedio es igual a 0 en la población):
  
  $$H_{0}: \bar{X}_{salarios}= 0$$
  
  En referencia a la siguiente hipótesis alternativa:
  
  $$H_{a}: \bar{X}_{salarios} \neq 0$$

2.Obtener error estándar y estadístico de prueba empírico correspondiente (ej: Z o t)

El error estándar del promedio es: 
  
  $$\sigma_{\bar{X}}=\frac{s}{\sqrt{N}}$$


Reemplazando:

-  $$\sigma_{\bar{X}}=\frac{200}{\sqrt{N}}$$
  


3. Establecer la probabilidad de error α y valor crítico (teórico) de la prueba correspondiente

4. Cálculo de intervalo de confianza / contraste valores empírico/crítico

5. Interpretación








## 2. Estimación de diferencia de medias




# Generar base de datos


set.seed(123) # Fijar semilla para reproducibilidad
n <- 1000
datos <- data.frame(
  ingreso = runif(n, min = 100000, max = 5000000),
  sexo = sample(c("hombre", "mujer"), n, replace = TRUE)
)

# Función para graficar la distribución de las medias muestrales
graficar_muestras <- function(datos, tamaño_muestra, num_muestras) {
  medias <- numeric(num_muestras)
  
  for (i in 1:num_muestras) {
    muestra <- sample(datos$ingreso, tamaño_muestra, replace = TRUE)
    medias[i] <- mean(muestra)
  }
  
  # Graficar distribución de las medias muestrales
  hist(medias, probability = TRUE, main = paste("Distribución de medias muestrales\nMuestras extraídas:", num_muestras, "\nTamaño de muestra:", tamaño_muestra),
       xlab = "Media", ylab = "Densidad", col = "lightblue", border = "black")
  
  # Añadir curva normal teórica
  curve(dnorm(x, mean = mean(datos$ingreso), sd = sd(datos$ingreso)/sqrt(tamaño_muestra)),
        col = "red", lwd = 2, add = TRUE)
}

# Graficar distribuciones de manera separada
graficar_muestras(datos, tamaño_muestra = 100, num_muestras = 10)
graficar_muestras(datos, tamaño_muestra = 100, num_muestras = 50)
graficar_muestras(datos, tamaño_muestra = 100, num_muestras = 100)

----
# 2. Error estándar y teorema central del límite:
  
  
# Paso 1: Calcular promedio y desviación estándar de las medias muestrales de 100 muestras
set.seed(123)
num_muestras <- 100
tamaño_muestra <- 100
medias <- numeric(num_muestras)

for (i in 1:num_muestras) {
  muestra <- sample(datos$ingreso, tamaño_muestra, replace = TRUE)
  medias[i] <- mean(muestra)
}

# Calcular el promedio y la desviación estándar de las medias muestrales
promedio_medias <- mean(medias)
desviacion_medias <- sd(medias)

cat("Promedio de las medias muestrales (100 muestras):", promedio_medias, "\n")
cat("Desviación estándar de las medias muestrales (100 muestras):", desviacion_medias, "\n")

# Paso 2: Extraer una muestra de 100 casos y calcular su error estándar
muestra_aleatoria <- sample(datos$ingreso, tamaño_muestra, replace = TRUE)
promedio_muestra <- mean(muestra_aleatoria)
error_estandar_muestra <- sd(muestra_aleatoria) / sqrt(tamaño_muestra)

cat("Promedio de una muestra de 100 casos:", promedio_muestra, "\n")
cat("Error estándar de una muestra de 100 casos:", error_estandar_muestra, "\n")

# Paso 3: Comparación
cat("\nComparación:\n")
cat("Promedio de las medias muestrales vs. Promedio de una muestra aleatoria:", promedio_medias, "vs.", promedio_muestra, "\n")
cat("Desviación estándar de las medias muestrales vs. Error estándar de una muestra:", desviacion_medias, "vs.", error_estandar_muestra, "\n")

----
# Tabla comparativa: 

# Paso 1: Calcular promedio y desviación estándar de la población
promedio_poblacion <- mean(datos$ingreso)
desviacion_poblacion <- sd(datos$ingreso)

# Paso 2: Calcular promedio y desviación estándar de las 100 muestras
promedio_medias <- mean(medias)
desviacion_medias <- sd(medias)

# Paso 3: Calcular promedio y error estándar de una muestra aleatoria de 100 casos
promedio_muestra <- mean(muestra_aleatoria)
desviacion_muestra <- sd(muestra_aleatoria)
error_estandar_muestra <- desviacion_muestra / sqrt(tamaño_muestra)

# Crear tabla de comparación
tabla_comparacion <- data.frame(
  "Medida" = c("Promedio", "Desviación Estándar","Error Estándar"),
  "Población" = c(promedio_poblacion, desviacion_poblacion, NA),
  "100 Muestras" = c(promedio_medias, desviacion_medias, NA),
  "Muestra Aleatoria" = c(promedio_muestra, desviacion_muestra, error_estandar_muestra)
)

# Mostrar la tabla
print(tabla_comparacion)

----
# Comparación de intervalos de confianza
  
  
# Con muestras de 500 casos
  
  # Cargar librerías necesarias
  library(dplyr)

# Establecer la semilla para reproducibilidad
set.seed(123)

# Generar la base de datos con 1000 casos
n_total <- 1000
ingresos <- runif(n_total, 100000, 5000000)
sexo <- sample(c("hombre", "mujer"), n_total, replace = TRUE)

# Crear el data frame
datos <- data.frame(ingresos, sexo)

# Definir parámetros
tamaño_muestra <- 500
n_muestras <- 100
z_95 <- 1.96

# Extraer 100 muestras aleatorias de 500 casos
muestras <- replicate(n_muestras, sample(ingresos, tamaño_muestra, replace = FALSE), simplify = FALSE)

# Calcular promedios y desviaciones estándar de las 100 muestras
medias <- sapply(muestras, mean)
desviaciones <- sapply(muestras, sd)

# Calcular intervalos de confianza para cada muestra
ic_muestras <- lapply(muestras, function(muestra) {
  promedio <- mean(muestra)
  desviacion <- sd(muestra)
  error_estandar <- desviacion / sqrt(tamaño_muestra)
  c(
    promedio - z_95 * error_estandar,
    promedio + z_95 * error_estandar
  )
})

# Ordenar las muestras por promedio
orden_muestras <- order(medias)
muestras_ordenadas <- muestras[orden_muestras]

# Seleccionar las 5 muestras con menor promedio y las 5 muestras con mayor promedio
muestras_menor <- muestras_ordenadas[1:5]
muestras_mayor <- muestras_ordenadas[(length(medias)-4):length(medias)]

# Calcular intervalos de confianza para las 5 muestras con menor promedio
ic_muestras_menor <- lapply(muestras_menor, function(muestra) {
  promedio <- mean(muestra)
  desviacion <- sd(muestra)
  error_estandar <- desviacion / sqrt(tamaño_muestra)
  c(
    promedio - z_95 * error_estandar,
    promedio + z_95 * error_estandar
  )
})

# Calcular intervalos de confianza para las 5 muestras con mayor promedio
ic_muestras_mayor <- lapply(muestras_mayor, function(muestra) {
  promedio <- mean(muestra)
  desviacion <- sd(muestra)
  error_estandar <- desviacion / sqrt(tamaño_muestra)
  c(
    promedio - z_95 * error_estandar,
    promedio + z_95 * error_estandar
  )
})

# Calcular el promedio poblacional
promedio_poblacion <- mean(ingresos)

# Crear la tabla de comparación
tabla_comparacion_ic <- data.frame(
  "Muestra" = c("Promedio Poblacional", paste0("Muestra Menor ", 1:5), paste0("Muestra Mayor ", 1:5)),
  "Promedio" = c(promedio_poblacion, sapply(muestras_menor, mean), sapply(muestras_mayor, mean)),
  "Límite Inferior IC (95%)" = c(NA, sapply(ic_muestras_menor, `[`, 1), sapply(ic_muestras_mayor, `[`, 1)),
  "Límite Superior IC (95%)" = c(NA, sapply(ic_muestras_menor, `[`, 2), sapply(ic_muestras_mayor, `[`, 2))
)

# Mostrar la tabla
print(tabla_comparacion_ic)
  