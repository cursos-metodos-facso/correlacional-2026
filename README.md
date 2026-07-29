# Estadística Correlacional 2026

Este es el repositorio en donde se aloja la página web del curso electivo "Estadística Correlacional: Inferencia, asociación y reporte", impartido en la Facultad de Ciencias Sociales durante el segundo semestre del 2026.

La página fue construida totalmente en Quarto.

> [!IMPORTANT]  
> Acceso a la página:

[cienciasocialabierta.netlify.app](https://cursos-metodos-facso.github.io/cienciasocialabierta2026/docs/index.html)

## Auto-commit del .bib sincronizado con Zotero

Cuando `references/publications/posts/ciencia-abierta.bib` se actualiza localmente (por ejemplo via Better BibTeX), el siguiente script detecta la modificacion y hace `commit` + `push` automatico **solo cuando hay nuevas entradas** (lineas `@...` en el diff):

```bash
# Primera vez: dar permisos de ejecucion
chmod +x scripts/auto-commit-bib.sh

# Correr en terminal aparte (queda en primer plano bloqueando la terminal)
scripts/auto-commit-bib.sh

# O en segundo plano (log en bib-watcher.log)
nohup scripts/auto-commit-bib.sh > bib-watcher.log 2>&1 &
echo $! > bib-watcher.pid  # guarda el PID para poder detenerlo con: kill $(cat bib-watcher.pid)
```

**Requisitos:** `git` configurado con `user.name` / `user.email` y acceso de push a `origin/main`.