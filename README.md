# Estadística Correlacional 2026

Este es el repositorio en donde se aloja la página web del curso electivo "Estadística Correlacional: Inferencia, asociación y reporte", impartido en la Facultad de Ciencias Sociales durante el segundo semestre del 2026.

La página fue construida totalmente en Quarto.

> [!IMPORTANT]  
> Acceso a la página:

[https://correlacional.metodos-facso.org/](https://correlacional.metodos-facso.org/)


## Versiones anteriores del curso  

- [2025](https://correlacional.netlify.app/)

- [2024](https://2024--correlacional.netlify.app/)

- [2023](https://2023--correlacional.netlify.app/)


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
# Optimización de HTML publicados

Después de un renderizado exitoso de Quarto, ejecutar desde la raíz del repositorio:

```powershell
python scripts/optimize_embedded_css.py
```

El script extrae dos bloques CSS grandes e idénticos de nueve páginas publicadas y los comparte en `docs/optimized-assets/`. No ejecuta R, no modifica los QMD y puede ejecutarse de nuevo sin cambiar el resultado. Para probar solamente una página, usar `--pilot`.

Este paso permanece como comando explícito. No se configuró `project.post-render` porque un renderizado completo puede reejecutar código R de los prácticos y esa integración aún no se ha validado.

