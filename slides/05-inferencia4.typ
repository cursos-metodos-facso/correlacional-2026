// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black or heading-decoration == "underline"
           or heading-background-color != none) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#show: doc => article(
  pagenumbering: "1",
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= 
<section>

#block[
#block[

#align(right)[#box(image("img/logo-correlacional-transp.png", width: 100.0%))]
]
#block[
]
#block[
#set text(size: 18.75pt); 

=== #text(size: 2em , fill: white)[Estadística Correlacional]
<estadística-correlacional>
#block[
]
#text(size: 1.5em , fill: rgb("#dfc117"))[Inferencia, asociación, y reporte]

#text(size: 1em , fill: white)[Juan Carlos Castillo] \
#text(size: 1em , fill: white)[Sociología FACSO - UChile] \
#text(size: 1em , fill: white)[2do Sem 2026]

#link("https://correlacional.metodos-facso.org")[correlacional.metodos-facso.org]

#text(size: 1.3em , fill: white)[#strong[Inferencia 4];:]

#text(fill: rgb("#dfc117"))[Tipos de error, prueba t e hipótesis direccionales]

]
]
= #text(fill: rgb("#dfc117"))[¿Qué hemos visto hasta ahora?]
<qué-hemos-visto-hasta-ahora>
== 
<section-1>
#align(center)[#box(image("img/temas-inferencias.png", width: 100.0%))]
== ¿Qué puedo decir de la población a partir de mi muestra?
<qué-puedo-decir-de-la-población-a-partir-de-mi-muestra>
PROBABILIDADES … de un rango de valores

#block[
#block[
=== ¿Cómo llego al rango de valores probables de un parámetro poblacional obtenido a partir de #strong[una muestra];?
<cómo-llego-al-rango-de-valores-probables-de-un-parámetro-poblacional-obtenido-a-partir-de-una-muestra>
]
#block[
#align(center)[#box(image("img/inference1.png", width: 80.0%))]
]
]
== Probabilidades
<probabilidades>
#block[
#block[
- Podemos calcular probabilidades basados en una distribución teórica de ocurrencia de eventos.

- Ej: En teoría, la probabilidad de que salga sello al tirar una moneda es 50%

- Mientras más repetimos el evento, más se van a acercar los resultados (distribución empírica) a la probabilidad del evento (distribución teórica)

]
#block[
#box(image("05-inferencia4_files/figure-typst/unnamed-chunk-1-1.svg"))

]
]
== Curva normal
<curva-normal>
#block[
#block[
- Hay una serie de eventos que en términos teóricos y empíricos tienen una distribución particular en torno al valor central -\> #strong[normal]

- La #text(fill: rgb("#c0392b"))[curva normal] es una distribución teórica que nos permite tener un estándar con el cual comparar distribuciones empíricas

]
#block[

#align(center)[#box(image("img/norm2.png", width: 100.0%))]
]
]
== Teorema central del límite y error estándar
<teorema-central-del-límite-y-error-estándar>
#block[
#block[
- si pudiera calcular un estadístico en muchas muestras distintas (ej: promedio) este se distribuiría de manera normal

- el #strong[error estándar] es la formula que nos permite obtener el valor de la desviación estándar de los promedios con una sola muestra

]
#block[

$ sigma_(macron(X)) = s / sqrt(N) $

]
]
== Puntajes Z
<puntajes-z>
#block[
#block[
- el puntaje Z es una medida de distancias del promedio en una distribución normal, que tiene promedio 0 y desviación estándar 1

- Z expresa cualquier puntaje en desviaciones estándar desde el promedio (de la curva normal)

- Z permite además obtener el valor del percentil de cada puntaje

]
#block[
$ z = frac(x - mu, sigma) $

#align(center)[#box(image("https://correlacional.netlify.app/slides/03-inferencia2_files/figure-html/unnamed-chunk-16-1.png", width: 90.0%))]
]
]
== Intervalos de confianza \[para el promedio\]
<intervalos-de-confianza-para-el-promedio>
#block[
#block[
- rango de probabilidad del valor de un parámetro en la población

- Para construirlo, 4 pasos:

  1- establecer #strong[nivel de confianza] (convencionalmente 95%)

  2- definir #strong[puntaje Z] correspondiente a este intervalo (para 95% es 1.96)

]
#block[
3- multiplicar Z por el #strong[error estándar]

4- restar al promedio (límite inferior) y sumar (límite superior)

$ macron(X) plus.minus Z \* sigma / sqrt(N) $

]
]
== 
<section-2>
#align(center)[#box(image("img/herramientas.png", width: 90.0%))]
= #text(fill: white)[¿Qué es una hipótesis?]
<qué-es-una-hipótesis>
#block[
=== #text(fill: white)[¿Cuándo una hipótesis es #text(fill: rgb("#dfc117"))[verdadera]?]
<cuándo-una-hipótesis-es-verdadera>
]
== #text(fill: white)[Una #text(fill: rgb("#dfc117"))[hipótesis] es una aseveración o una predicción que se desprende de una teoría sobre una situación que ocurre en la población en estudio]
<una-hipótesis-es-una-aseveración-o-una-predicción-que-se-desprende-de-una-teoría-sobre-una-situación-que-ocurre-en-la-población-en-estudio>
== #text(fill: white)[¿Cuándo se puede verificar una hipótesis?]
<cuándo-se-puede-verificar-una-hipótesis>
#block[
=== #text(fill: white)[-\> #text(fill: rgb("#dfc117"))[NUNCA]]
<nunca>
]
#block[
=== #text(fill: white)[… pero, se puede #strong[#text(fill: rgb("#e8871a"))[falsar]];]
<pero-se-puede-falsar>
]
== Popper y la falsabilidad
<popper-y-la-falsabilidad>
#block[
#block[
#align(center)[#box(image("img/popper.jpg", width: 80.0%))]
]
#block[
#emph["el criterio de demarcación que hemos de adoptar no es el de la verificabilidad, sino el de la #text(fill: rgb("#c0392b"))[falsabilidad] de los sistemas. Dicho de otro modo: no exigiré que un sistema científico pueda ser seleccionado, de una vez para siempre, en un sentido positivo; pero sí que sea susceptible de selección en un sentido negativo por medio de contrastes o pruebas empíricas: ha de ser posible refutar por la experiencia un sistema científico empírico" (Popper, 1982, p.~40)]

]
]
== Contraste de hipótesis y falsación
<contraste-de-hipótesis-y-falsación>
#block[
#block[
#align(center)[#box(image("img/hipotesis.png", width: 100.0%))]
]
#block[
- El #strong[verificar] una hipótesis no hace que una teoría sea verdadera

- Se puede intentar refutar una teoría (#strong[falsarla];) mediante un contraejemplo o hipótesis contraria

- Si no es posible refutar la hipótesis contraria, entonces la teoría queda aceptada #strong[provisionalmente]

]
]
== Ejemplo
<ejemplo>
#block[
#block[
Teoría: todos los cuervos son negros

Hipótesis de verificación: hay cuervos negros

Hipótesis de falsación: hay cuervos blancos

]
#block[

#align(center)[#box(image("img/white-crow.png", width: 90.0%))]
]
]
== #text(fill: white)[Lógica de contraste de hipótesis]
<lógica-de-contraste-de-hipótesis>
#block[
#set text(fill: white); === #text(fill: rgb("#dfc117"))[Intentar falsar lo que es contrario a nuestra hipótesis original]
<intentar-falsar-lo-que-es-contrario-a-nuestra-hipótesis-original>
#block[
=== En estadística, esta "hipótesis contraria" se denomina la #text(fill: rgb("#dfc117"))[HIPÓTESIS NULA]
<en-estadística-esta-hipótesis-contraria-se-denomina-la-hipótesis-nula>
]
]
== #text(fill: white)[buscamos RECHAZAR LA HIPÓTESIS NULA]
<buscamos-rechazar-la-hipótesis-nula>
#block[
#set text(fill: white , size: 0.8em); si logramos rechazar la hipótesis nula (o sea, que lo contrario de nuestra teoría no es verdad), entonces encontramos evidencia a favor de nuestra teoría

Buscamos #strong[no encontrar] cuervos blancos #box(image("img/white-crow.png", width: 10.0%))

]
== Hipótesis nula
<hipótesis-nula>
- Hipótesis se denota con la letra $H$

- La hipótesis nula se denota $H_0$ (hache cero)

- #strong[Cero] porque en general se refiere a que lo que señala la teoría no existe o #strong[es cero en la población]

\-\> más detalle de tipos de hipótesis prox. clase, ahora vamos a un #strong[ejemplo]

== #text(fill: white)[¿Existen diferencias salariales entre hombres y mujeres en Chile?]
<existen-diferencias-salariales-entre-hombres-y-mujeres-en-chile>
#block[
#set text(fill: white , size: 0.7em); #table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Hipótesis general], [Hipótesis estadística],),
  table.hline(),
  [Existen diferencias salariales entre hombres y mujeres], [Hipótesis #strong[alternativa];: Las diferencias son distintas de cero],
  [No existen diferencias salariales entre hombres y mujeres], [Hipótesis #strong[nula];: Las diferencias no son distintas de cero],
)
]
== Cuestionario CASEN
<cuestionario-casen>
#block[
#block[
#align(center)[#box(image("img/sueldo_casen.png", width: 85.0%))]
]
#block[
#align(center)[#box(image("img/sexo_casen.png", width: 100.0%))]
]
]
== Datos CASEN 2022
<datos-casen-2022>
#block[
#block[
#align(center)[#box(image("img/casen_download.png", width: 100.0%))]
]
#block[
Vamos a generar una submuestra de 350 casos de CASEN para ilustrar de mejor manera el sentido del test de hipótesis

#block[
```r
pacman::p_load(sjmisc, haven, dplyr, stargazer, interpretCI, kableExtra)
load("casen2022_inf2.Rdata")
options(scipen = 999) # para evitar notación en los ceros
set.seed(20) # para fijar el resultado aleatorio
casen_350 <- casen2022_inf %>% select(salario, sexo) %>% sample_n(350)
casen_350 <- na.omit(casen_350)
```

]
]
]
== Datos
<datos>
#block[
```r
stargazer(as.data.frame(casen_350), type = "text")
```

#block[
```

======================================================
Statistic  N     Mean      St. Dev.    Min      Max   
------------------------------------------------------
salario   343 634,402.300 459,180.200 30,000 2,900,000
sexo      343    1.402       0.491      1        2    
------------------------------------------------------
```

]
]
== 
<section-3>
```r
casen_350 %>% # se especifica la base de datos
  dplyr::group_by(sexo = sjlabelled::as_label(sexo)) %>% # se agrupan por la variable categórica y se usan sus etiquetas con as_label
  dplyr::summarise(Obs. = n(), Promedio = mean(salario, na.rm = TRUE), SD = sd(salario, na.rm = TRUE)) %>% # se agregan las operaciones a presentar en la tabla
  kable(format = "markdown") # se genera la tabla
```

#table(
  columns: 4,
  align: (left,right,right,right,),
  table.header([sexo], [Obs.], [Promedio], [SD],),
  table.hline(),
  [1. Hombre], [205], [654585.4], [468692.5],
  [2. Mujer], [138], [604420.3], [444666.0],
)
Diferencia salarial = 654.585-604.420=#strong[50.165]

== #text(fill: white)[#text(fill: rgb("#dfc117"))[Procedimiento: 5 pasos de la inferencia] (ajustados de Ritchey)]
<procedimiento-5-pasos-de-la-inferencia-ajustados-de-ritchey>
#block[
#set text(fill: white); + Formular hipótesis ( $H_0$ y $H_A$)

+ Obtener error estándar y estadístico de prueba empírico correspondiente (ej: Z o t)

+ Establecer la probabilidad de error $alpha$ (usualmente 0.05) y obtener valor crítico (teórico) de la prueba correspondiente

+ Cálculo de intervalo de confianza / contraste valores empírico/crítico

+ Interpretación

]
== 1. Formular hipótesis
<formular-hipótesis>
Contrastamos la #emph[hipótesis nula] (no hay diferencias de promedios entre grupos):

$ H_0 : macron(X)_(h o m b r e s) - macron(X)_(m u j e r e s) = 0 $

En referencia a la siguiente hipótesis alternativa:

$ H_a : macron(X)_(h o m b r e s) - macron(X)_(m u j e r e s) eq.not 0 $

== 
<section-4>
#block[
=== (2. Error estándar y estadístico de prueba)
<error-estándar-y-estadístico-de-prueba>
- #text(fill: rgb("#ffe08a"))[(Una nota preliminar)] En general, existen 2 formas de realizar el contraste de hipótesis:

  - intervalo de confianza, asociado al error estándar

  - contraste con valor crítico, asociado al estadístico de prueba

- Ambos entregan información consistente y complementaria

- En esta clase vamos a estimar solo el intervalo, la próxima veremos el contraste con valor crítico, que el caso de diferencia de medias corresponde a la prueba $t$ de student.

]
== 2. Error estándar (y estadístico de prueba)
<error-estándar-y-estadístico-de-prueba-1>
- Cada estadístico tiene su propia fórmula de error estándar

- En el caso de la #strong[diferencia de medias] (en este caso, de hombres y mujeres), el error estándar es:

$ S E = sqrt(sigma_(d i f f) / n_a + sigma_(d i f f) / n_b) $

Donde

$ sigma_(d i f f) = frac(sigma_a^2 (n_a - 1) + sigma_b^2 (n_b - 1), n_a + n_b - 2) $

- como se puede apreciar, es una extensión del error estándar del promedio pero para dos grupos distintos

== 
<section-5>
Cálculo de la desviación estándar de las diferencias de promedios:

$ sigma_(d i f f) & = frac(468692^2 (205 - 1) + 444666^2 (138 - 1), 205 + 138 - 2)\
\
 & = frac(44813126936256 + 27088715663172, 341)\
\
 & = 210855843400 $

== 
<section-6>
Y entonces el error estándar de la diferencia de medias:

$ S E & = sqrt(sigma_(d i f f) / n_a + sigma_(d i f f) / n_b)\
\
 & = sqrt(210855843400 / 205 + 210855843400 / 138)\
\
 & = 50561 $

== 3. Establecer probabilidad de error
<establecer-probabilidad-de-error>
- asumimos que existe una probabilidad de error al rechazar $H_0$, para lo cual fijamos un límite convencional -\> usualmente un 5%

- ¿error #strong[de qué];? -\> de rechazar $H_0$ cuando esta existe en la población.

- Esto se conoce como la #strong[probabilidad de error Tipo I o $alpha$ (alfa)]

== Hipótesis nula ( $H_0$) y tipos de error
<hipótesis-nula-h_0-y-tipos-de-error>
#align(center)[#box(image("img/errortypes.png", width: 100.0%))]
== En nuestro ejemplo:
<en-nuestro-ejemplo>
$ H_0 : macron(X)_(s u e l d o med m u j e r e s) - macron(X)_(s u e l d o med h o m b r e s) = 0 $

- Si #strong[hay] diferencias de sueldo en la población y rechazamos $H_0$: decisión correcta

- Si #strong[no hay] diferencias de sueldo en la población y rechazamos $H_0$: Error tipo I

#block[
#block[
=== El Error Tipo I equivale a encontrar cosas en nuestra muestra que no existen en la población
<el-error-tipo-i-equivale-a-encontrar-cosas-en-nuestra-muestra-que-no-existen-en-la-población>
]
]
== Hipótesis nula y tipos de error
<hipótesis-nula-y-tipos-de-error>
#align(center)[#box(image("img/errors.jpg", width: 70.0%))]
== Hipótesis nula y tipos de error
<hipótesis-nula-y-tipos-de-error-1>

#block[
#block[
#block[
=== Error Tipo I
<error-tipo-i>
Encontrar algo que no existe en la población

]
]
#block[
#block[
=== Error Tipo II
<error-tipo-ii>
No encontrar algo que si existe en la población

]
]
]
== Hipótesis nula y $alpha$
<hipótesis-nula-y-alpha>
- Entonces, el $alpha$ es la probabilidad de error que fijamos para rechazar la hipótesis nula

- en lenguaje de prueba de hipótesis, es la probabilidad de rechazar la hipótesis nula cuando esta es verdadera

- o la probabilidad de encontrar diferencias entre grupos de la población cuando estas no existen

- o en simple, la probabilidad de que nos estemos equivocando

== Nivel de confianza y probabilidad de error $alpha$
<nivel-de-confianza-y-probabilidad-de-error-alpha>
- el nivel de confianza de una estimación se determina de manera #strong[convencional];, usualmente se acepta 95% o 99% de confianza

- un nivel de confianza se expresa en una probabilidad de error $alpha$ (#text(fill: rgb("#c0392b"))[alfa]), que es 1 - nivel de confianza

  - para un nivel de confianza de 95%, $alpha = 1 - 0.95 = 0.05$

  - para un nivel de confianza de 99%, $alpha = 1 - 0.99 = 0.01$

== 
<section-7>
#align(center)[#box(image("img/normal&alfa2.png", width: 90.0%))]
== 
<section-8>
#align(center)[#box(image("img/normal&alfa.png", width: 90.0%))]
== 
<section-9>
#block[
=== 4. Intervalo de confianza \[y contraste con valor crítico\]
<intervalo-de-confianza-y-contraste-con-valor-crítico>
- de la clase anterior con prueba Z sabemos que el valor crítico para un 95% de confianza es 1.96

- para diferencia de medias se utiliza prueba $t$, donde el valor crítico es variable según en tamaño muestral

- sin embargo, para muestras grandes, t=Z, y por lo tanto por ahora mantendremos los valores referenciales Z (de 1.96) hasta que profundicemos en t la próxima clase

]
== 4. Intervalo de confianza
<intervalo-de-confianza>
$ macron(x)_1 - macron(x)_2 & plus.minus t_(alpha \/ 2) \* S E_(macron(x_1) - macron(x_2))\
\
50165 & plus.minus 1.96 \* 50561\
\
50165 & plus.minus 99099.56\
\
C I \[ - 49287.48 & ; 149617.63 \] $

== Test de hipótesis de diferencias en R
<test-de-hipótesis-de-diferencias-en-r>
#block[
```r
t.test(salario ~ sexo, data = casen_350, var.equal = TRUE)
```

#block[
```

    Two Sample t-test

data:  salario by sexo
t = 0.99215, df = 341, p-value = 0.3218
alternative hypothesis: true difference in means between group 1 and group 2 is not equal to 0
95 percent confidence interval:
 -49287.48 149617.63
sample estimates:
mean in group 1 mean in group 2 
       654585.4        604420.3 
```

]
]
== tabla t test con `rempsyc`
<tabla-t-test-con-rempsyc>
```r
pacman::p_load(rempsyc, broom)
model <- t.test(salario ~ sexo, data = casen_350, var.equal = TRUE)
stats.table <- tidy(model, conf.int = TRUE)
nice_table(stats.table, broom = "t.test")
```

#[
#set par(justify: false)
#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
  stroke: none,
  table.header(
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[Method]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[Alternative]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[Mean 1]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[Mean 2]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(style: "italic", size: 12pt, fill: rgb("000000"), font: "Times New Roman")[M]#sub[#text(size: 7.2pt, fill: rgb("000000"), font: "Times New Roman")[1]]#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[ \- ]#text(style: "italic", size: 12pt, fill: rgb("000000"), font: "Times New Roman")[M]#sub[#text(size: 7.2pt, fill: rgb("000000"), font: "Times New Roman")[2]]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(style: "italic", size: 12pt, fill: rgb("000000"), font: "Times New Roman")[t]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(style: "italic", size: 12pt, fill: rgb("000000"), font: "Times New Roman")[df]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(style: "italic", size: 12pt, fill: rgb("000000"), font: "Times New Roman")[p]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: 0.5pt + rgb("000000"), bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[95% CI]],
  ),
  table.cell(align: left + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[Two Sample t\-test]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[two\.sided]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[654,585\.37]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[604,420\.29]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[50,165\.08]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[0\.99]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[341]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[\.322]],
  table.cell(align: center + horizon, inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: (top: none, bottom: 0.5pt + rgb("000000"), left: none, right: none))[#text(size: 12pt, fill: rgb("000000"), font: "Times New Roman")[\[\-49287\.48, 149617\.63\]]],
)
]
#block[
https:\/\/rempsyc.remi-theriault.com/articles/t-test

]
== 5. Interpretación
<interpretación>
Nuestro intervalo de confianza #strong[contiene el cero];, por lo que no se rechaza la hipótesis nula

#block[
#block[
Con un 95% de confianza (5% de probabilidad de error) no se encuentra evidencia de diferencias salariales entre hombres y mujeres.

Alternativamente: No existe evidencia que las diferencias salariales entre hombres y mujeres son distintas de cero, con un 5% de probabilidad de error

]
]
= #text(fill: rgb("#dfc117"))[Resumen]
<resumen>
#block[
#set text(fill: white , size: 0.85em); - hipótesis: aseveraciones sobre algo que ocurre en la población, usualmente asociaciones entre conceptos / variables

- las hipótesis se contrastan con un criterio de falsabilidad

- el contraste de hipótesis en estadística opera mediante el rechazo de la hipótesis nula (o de no diferencias), con una probabilidad de error $alpha$

- 5 pasos para contraste de hipótesis

]
== Próxima clase (miércoles): manos al código
<próxima-clase-miércoles-manos-al-código>
#block[
]
=== y próximo lunes
<y-próximo-lunes>
- Prueba $t$

- hipótesis direccionales (mayor o menor qué) o de una cola (one tail)

- inferencia para proporciones

== Recomendaciones
<recomendaciones>
#link("https://cienciassocialesfcpys.wordpress.com/wp-content/uploads/2016/03/5la-logica-de-las-ciencias-sociales-popper-adorno-dahrendorf-habermas.pdf")[#box(image("img/logicaccss.png", width: 30.0%))]

= 
<section-10>

#block[
#block[

#align(right)[#box(image("img/logo-correlacional-transp.png", width: 100.0%))]
]
#block[
]
#block[
#set text(size: 18.75pt); 

=== #text(size: 2em , fill: white)[Estadística Correlacional]
<estadística-correlacional-1>
#block[
]
#text(size: 1.5em , fill: rgb("#dfc117"))[Inferencia, asociación, y reporte]

#text(size: 1em , fill: white)[Juan Carlos Castillo] \
#text(size: 1em , fill: white)[Sociología FACSO - UChile] \
#text(size: 1em , fill: white)[2do Sem 2026]

#link("https://correlacional.metodos-facso.org")[correlacional.metodos-facso.org]

]
]


 
  
#set bibliography(style: "../files/bib/chicago-author-date.csl") 


#bibliography("../files/bib/references.bib")

