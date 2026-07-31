
pacman::p_load(haven, dplyr,sjmisc, stargazer)



casen2022 <- read_dta("/home/juank/Downloads/Base de datos Casen 2022 STATA.dta")
summary(casen2022$y0101) #pregunta ingreso principal: y0101	Asalariados principal - Sueldos y salarios monetario
summary(casen2022$sexo) # 1=hombre, 2=mujer

casen2020_inf <- casen2022 %>% select(y0101,sexo) 
casen2020_inf <-na.omit(casen2020_inf)
casen2020_inf <- casen2020_inf %>% rename("Salario"=y0101)

stargazer(as.data.frame(casen2020_inf), type = "text")

confint(casen2020_inf$Salario)
save(casen2020_inf, file = "casen2020_inf.Rdata")
rm(list = c('casen2022'))



