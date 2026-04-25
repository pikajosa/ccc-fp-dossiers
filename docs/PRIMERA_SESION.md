# Primera sesión con Claude Code · CCC FP Dossieres

Cuando abras la extensión de Claude Code en VS Code por primera vez en este repo, **pega exactamente el mensaje que está más abajo** como tu primera intervención. Está pensado para que Claude se oriente solo, sin que tengas que explicar nada.

---

## Mensaje para pegar (copia desde la línea de abajo hasta el final)

```
Hola. Bienvenido al repo `ccc-fp-dossiers`. Vas a trabajar conmigo (Rosa) en este proyecto.

Antes de hacer nada, lee en este orden:

1. `README.md` — visión general del repo.
2. `CONTEXTO_DOSSIERES_CCC_v3.md` — contexto técnico completo (es largo, léelo entero).
3. `docs/PLAN_001_pool_fotos_logos.md` — plan detallado de la próxima tarea.

Después, explora la estructura del repo con `ls -la` en la raíz y un `ls fotos/` para ver el estado actual de imágenes (todo está mezclado: fotos de grado y logos juntos en `fotos/`).

Una vez tengas el contexto cargado, NO empieces a tocar código. En su lugar:

a) Confirma que has entendido el estado actual: qué archivos hay, qué versiones están activas, qué fix ya está aplicado y qué queda pendiente.
b) Inventaríame qué tengo realmente en `fotos/` ahora mismo, separando lo que parece foto (p1_portada, p2_hero, etc.) de lo que parece logo (cfc, gesden, microsoft, ucam, ga4, etc.). Si encuentras nombres que no encajan en ninguna categoría, lístalos aparte.
c) Propón el orden de las primeras 3 fases del PLAN_001 con una estimación realista de cambios por fase y los riesgos que veas.
d) NO ejecutes ninguna fase hasta que yo te diga "avanti" explícitamente.

Reglas que no negocio:

- Validación obligatoria con `bash scripts/validate.sh` después de cada cambio.
- Un commit por fase, mensajes claros (formato convencional `feat:`, `fix:`, `chore:`, `docs:`).
- No mezclar refactor con cambios de contenido en el mismo commit.
- Si una fase del plan resulta más grande de lo previsto, pararse y consultarme antes de seguir.
- Si detectas algo que mejora la arquitectura pero no está en el plan, NO lo implementes: anótamelo y decidimos después.

Empieza.
```

---

## Tras esa primera respuesta de Claude

Lo que Claude te va a contestar es:

1. Un resumen de lo que ha entendido del proyecto.
2. Un inventario real de lo que hay en `fotos/`.
3. Una propuesta de orden de fases del plan.

Tú lees, valoras, y respondes con uno de:

- **"Avanti, empieza por la Fase 0"** → Claude ejecuta la Fase 0 entera, hace commit, te enseña el diff y espera.
- **"Antes de empezar, ajustemos X"** → conversación normal de ajuste hasta que estéis alineados.

A partir de ahí, el flujo es: una fase, validación, commit, siguiente fase.

---

## Cosas que conviene saber sobre la extensión de Claude Code en VS Code

**Permisos de ejecución.** La primera vez que Claude te pida ejecutar un comando (`bash`, `git`, `node`...) saldrá un diálogo pidiendo confirmación. Puedes aprobar comandos puntuales o aprobar patrones (`bash *`, `git *`) para no tener que confirmar cada vez. Para esta primera sesión, te recomiendo aprobar puntualmente los primeros 3-4 comandos para acostumbrarte, y luego aprobar el patrón general.

**Edición de archivos.** Claude te va a proponer ediciones que aparecen como diffs en el panel. Las aceptas (o rechazas) con un clic. No tienes que copiar/pegar nada manualmente.

**Contexto del archivo abierto.** El archivo que tengas abierto en VS Code tiene prioridad para Claude. Si quieres que se centre en `dossier_AFI_v1_2.html`, ábrelo en el editor antes de hablarle.

**Si te pierdes.** Puedes parar a Claude en cualquier momento y preguntar: "Recuérdame en qué fase estamos y qué falta". Claude no tiene memoria persistente entre sesiones de VS Code, pero el repo + el plan + los commits le permiten reconstruir el estado en segundos.

---

## Si la cosa se va de madre

Si en cualquier momento Claude empieza a hacer cambios que no esperas:

1. **Stop.** Dile "Para. Vamos a revisar."
2. **Revierte si es necesario:** `git checkout .` para descartar cambios sin commitear, o `git reset --hard HEAD~1` para deshacer el último commit.
3. **Reinicia con un mensaje claro:** "Volvamos al plan original. La próxima fase es X."

El repo + Git son tu red de seguridad. No tengas miedo de ir agresivo con `git reset` si algo se descarrila.
