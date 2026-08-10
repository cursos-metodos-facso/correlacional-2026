# Ejercicio práctico de trabajo autónomo
# Distribución Normal e Intervalos de Confianza

# 0. Cargue la base de datos real ---------------------------------------

if (!requireNamespace("HistData", quietly = TRUE)) install.packages("HistData") # Si no está instalado, instala el paquete
library(HistData)
data("Galton")

names(Galton) # revisar las variables disponibles: "parent" y "child"
altura <- Galton$child # creamos el vector con la variable de interés

# 1. Calcule y describa la distribución ----------------------------------

# Obtenga la media y desviación estándar de la estatura.
media <- mean(altura, na.rm = TRUE)
desv_estandar <- sd(altura, na.rm = TRUE)

cat("Media:", media, "\n")
cat("Desviación Estándar:", desv_estandar, "\n")

# Visualice la distribución en un histograma
hist(altura, main="Estatura de Hijos Adultos (Galton, 1886)", xlab="Estatura (pulgadas)", ylab="Frecuencia", col="cyan4", border="black")

# 2. Estandarice los datos (puntajes Z) -----------------------------------

# Transforme la variable a puntajes Z
z_scores_altura <- scale(altura)

# Muestre los primeros 10 valores (head()).
# Comparar valores originales y estandarizados
head(data.frame(Valor = altura, Z = z_scores_altura), 10)

# Muestre también los últimos 10 valores (tail()).
# Comparar valores originales y estandarizados
tail(data.frame(Valor = altura, Z = z_scores_altura), 10)

# ¿Cuál es el máximo puntaje Z y el mínimo puntaje Z? ¿A qué estatura corresponden?
max_z <- max(z_scores_altura, na.rm = TRUE)
min_z <- min(z_scores_altura, na.rm = TRUE)

max_z
min_z

# Verifique la media y desviación estándar
mean(z_scores_altura, na.rm = TRUE) # Debe ser (aprox.) 0
sd(z_scores_altura, na.rm = TRUE)    # Debe ser 1

# 3. Calcule el error estándar de la variable -----------------------------

n_altura <- length(altura)
ee_altura <- desv_estandar / sqrt(n_altura)

ee_altura

# 4. Calcule el intervalo de confianza para la media -----------------------

# Estime el IC para un 95% de confianza
# Estime el IC para un 99% de confianza. ¿Qué sucede con el ancho del intervalo?
Publish::ci.mean(altura, alpha = 0.05)
Publish::ci.mean(altura, alpha = 0.01)

# 5. Explore el efecto del tamaño muestral ---------------------------------

# Generemos 3 submuestras aleatorias con la función sample().
set.seed(123)
muestra_100 <- sample(altura, 100)
muestra_200 <- sample(altura, 200)
muestra_400 <- sample(altura, 400)

# Calcule el error estándar y el intervalo de confianza al 95% de cada muestra
# ¿Qué pasa con el error estándar y el intervalo de confianza a medida que aumenta el tamaño de la muestra?

### Errores muestrales
n_altura_100 <- length(muestra_100)
ee_altura_100 <- desv_estandar / sqrt(n_altura_100)

n_altura_200 <- length(muestra_200)
ee_altura_200 <- desv_estandar / sqrt(n_altura_200)

n_altura_400 <- length(muestra_400)
ee_altura_400 <- desv_estandar / sqrt(n_altura_400)

ee_altura_100
ee_altura_200
ee_altura_400

### Intervalos de confianza
Publish::ci.mean(muestra_100, alpha = 0.05)
Publish::ci.mean(muestra_200, alpha = 0.05)
Publish::ci.mean(muestra_400, alpha = 0.05)
