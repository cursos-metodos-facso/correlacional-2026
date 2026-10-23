# Simulación de datos Prueba 2
# Variables: izq_der (1-10), edad (18-90), sexo (0 = Hombre, 1 = Mujer)
# Pregunta 2 (chi2): clase (1 = Baja, 2 = Media, 3 = Alta)
# Dos versiones (A y B) con semillas distintas, según RUT par/impar

simular_base <- function(seed, n = 500) {
  set.seed(seed)

  sexo <- rbinom(n, 1, 0.52)
  edad <- round(pmin(pmax(rnorm(n, 46, 16), 18), 90))

  # Orientación política: más a la derecha con la edad (moderada),
  # levemente más a la izquierda en mujeres (débil)
  latente <- 0.35 * as.numeric(scale(edad)) -
    0.12 * as.numeric(scale(sexo)) +
    rnorm(n, 0, 0.9)
  izq_der <- round(pmin(pmax(5.5 + 2.2 * latente, 1), 10))
  sexo_completo <- sexo

  # Casos perdidos con distinta frecuencia por variable
  izq_der[sample(n, 80)] <- NA # no se ubica en la escala (~16%)
  edad[sample(n, 25)]    <- NA # ~5%
  sexo[sample(n, 6)]     <- NA # ~1%

  # Clase social (se genera al final para no alterar las variables anteriores):
  # mujeres con mayor probabilidad de clase baja
  p_hombre <- c(0.30, 0.50, 0.20)
  p_mujer  <- c(0.43, 0.45, 0.12)
  clase <- sapply(sexo_completo, function(x)
    sample(1:3, 1, prob = if (x == 1) p_mujer else p_hombre))
  clase[sample(n, 12)] <- NA # ~2%

  data.frame(id = 1:n, izq_der, edad, sexo, clase)
}

# Guarda las dos bases
semillas <- c(A = 0, B = 6)
for (v in names(semillas)) {
  write.csv(simular_base(semillas[[v]]),
            sprintf("files/pruebas/prueba2/base_%s.csv", v),
            row.names = FALSE)
}
