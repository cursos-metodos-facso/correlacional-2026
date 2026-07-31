# Definimos los promedios posibles (1.5, 2, 2.5, ..., 5.5, 6)
promedios_posibles <- seq(1, 6, by = 0.5)

# Calculamos la distribución de probabilidad teórica para cada promedio
# Las probabilidades corresponden a los valores de promedios específicos
probabilidades_teoricas <- c(1/36, 2/36, 3/36, 4/36, 5/36, 6/36, 5/36, 4/36, 3/36, 2/36, 1/36)

# Graficamos la distribución de probabilidad teórica
barplot(probabilidades_teoricas, 
        names.arg = promedios_posibles,
        main = "Distribución de Probabilidad Teórica del Promedio de Dos Dados",
        xlab = "Promedio de los Dados",
        ylab = "Probabilidad Teórica",
        col = "orange")

teoric = recordPlot()
teoric

# Repeticiones

# Establecemos la semilla para reproducibilidad
set.seed(123)

# Simulamos 100 repeticiones de dos dados
dados1 <- sample(1:6, 100, replace = TRUE)
dados2 <- sample(1:6, 100, replace = TRUE)

# Calculamos el promedio de los resultados de ambos dados
promedio_dados <- (dados1 + dados2) / 2

# Calculamos las frecuencias de cada promedio posible
frecuencias_empiricas <- table(promedio_dados)

# Convertimos las frecuencias a probabilidades
probabilidades_empiricas <- frecuencias_empiricas / sum(frecuencias_empiricas)

# Graficamos las frecuencias de probabilidad empíricas
barplot(probabilidades_empiricas, 
        main = "Frecuencia de Probabilidad del Promedio de Dos Dados (100 repeticiones)",
        xlab = "Promedio de los Dados",
        ylab = "Frecuencia de Probabilidad",
        col = rgb(0.1, 0.5, 0.8, 0.6), # Azul con transparencia
        ylim = c(0, max(probabilidades_empiricas, probabilidades_teoricas) * 1.2))

# Superponemos las barras de la distribución teórica
barplot(probabilidades_teoricas, 
        names.arg = promedios_posibles,
        col = rgb(0.8, 0.2, 0.2, 0.5), # Rojo con transparencia
        add = TRUE)

# Se agrega al gráfico existente
legend("topright", legend = c("Empírica", "Teórica"), 
               fill = c(rgb(0.1, 0.5, 0.8, 0.6), rgb(0.8, 0.2, 0.2, 0.5)),
               border = "white"))

rep100 =recordPlot()        


# Rep 500
# Establecemos la semilla para reproducibilidad
set.seed(123)

# Simulamos 100 repeticiones de dos dados
dados1 <- sample(1:6, 500, replace = TRUE)
dados2 <- sample(1:6, 500, replace = TRUE)

# Calculamos el promedio de los resultados de ambos dados
promedio_dados <- (dados1 + dados2) / 2

# Calculamos las frecuencias de cada promedio posible
frecuencias_empiricas <- table(promedio_dados)

# Convertimos las frecuencias a probabilidades
probabilidades_empiricas <- frecuencias_empiricas / sum(frecuencias_empiricas)

# Graficamos las frecuencias de probabilidad empíricas
barplot(probabilidades_empiricas, 
        main = "Frecuencia de Probabilidad del Promedio de Dos Dados (500 repeticiones)",
        xlab = "Promedio de los Dados",
        ylab = "Frecuencia de Probabilidad",
        col = rgb(0.1, 0.5, 0.8, 0.6), # Azul con transparencia
        ylim = c(0, max(probabilidades_empiricas, probabilidades_teoricas) * 1.2))

# Superponemos las barras de la distribución teórica
barplot(probabilidades_teoricas, 
        names.arg = promedios_posibles,
        col = rgb(0.8, 0.2, 0.2, 0.5), # Rojo con transparencia
        add = TRUE)

# Se agrega al gráfico existente
legend("topright", legend = c("Empírica", "Teórica"), 
       fill = c(rgb(0.1, 0.5, 0.8, 0.6), rgb(0.8, 0.2, 0.2, 0.5)),
       border = "white"))

rep500 =recordPlot()        

# rep1500

# Establecemos la semilla para reproducibilidad
set.seed(123)

# Simulamos 100 repeticiones de dos dados
dados1 <- sample(1:6, 1500, replace = TRUE)
dados2 <- sample(1:6, 1500, replace = TRUE)

# Calculamos el promedio de los resultados de ambos dados
promedio_dados <- (dados1 + dados2) / 2

# Calculamos las frecuencias de cada promedio posible
frecuencias_empiricas <- table(promedio_dados)

# Convertimos las frecuencias a probabilidades
probabilidades_empiricas <- frecuencias_empiricas / sum(frecuencias_empiricas)

# Graficamos las frecuencias de probabilidad empíricas
barplot(probabilidades_empiricas, 
        main = "Frecuencia de Probabilidad del Promedio de Dos Dados (1500 repeticiones)",
        xlab = "Promedio de los Dados",
        ylab = "Frecuencia de Probabilidad",
        col = rgb(0.1, 0.5, 0.8, 0.6), # Azul con transparencia
        ylim = c(0, max(probabilidades_empiricas, probabilidades_teoricas) * 1.2))

# Superponemos las barras de la distribución teórica
barplot(probabilidades_teoricas, 
        names.arg = promedios_posibles,
        col = rgb(0.8, 0.2, 0.2, 0.5), # Rojo con transparencia
        add = TRUE)

# Se agrega al gráfico existente
legend("topright", legend = c("Empírica", "Teórica"), 
       fill = c(rgb(0.1, 0.5, 0.8, 0.6), rgb(0.8, 0.2, 0.2, 0.5)),
       border = "white"))

rep1500 =recordPlot()        

# rep 5000

# Establecemos la semilla para reproducibilidad
set.seed(123)

# Simulamos 100 repeticiones de dos dados
dados1 <- sample(1:6, 5000, replace = TRUE)
dados2 <- sample(1:6, 5000, replace = TRUE)

# Calculamos el promedio de los resultados de ambos dados
promedio_dados <- (dados1 + dados2) / 2

# Calculamos las frecuencias de cada promedio posible
frecuencias_empiricas <- table(promedio_dados)

# Convertimos las frecuencias a probabilidades
probabilidades_empiricas <- frecuencias_empiricas / sum(frecuencias_empiricas)

# Graficamos las frecuencias de probabilidad empíricas
barplot(probabilidades_empiricas, 
        main = "Frecuencia de Probabilidad del Promedio de Dos Dados (5000 repeticiones)",
        xlab = "Promedio de los Dados",
        ylab = "Frecuencia de Probabilidad",
        col = rgb(0.1, 0.5, 0.8, 0.6), # Azul con transparencia
        ylim = c(0, max(probabilidades_empiricas, probabilidades_teoricas) * 1.2))

# Superponemos las barras de la distribución teórica
barplot(probabilidades_teoricas, 
        names.arg = promedios_posibles,
        col = rgb(0.8, 0.2, 0.2, 0.5), # Rojo con transparencia
        add = TRUE)

# Se agrega al gráfico existente
legend("topright", legend = c("Empírica", "Teórica"), 
       fill = c(rgb(0.1, 0.5, 0.8, 0.6), rgb(0.8, 0.2, 0.2, 0.5)),
       border = "white"))

rep5000 =recordPlot()        





