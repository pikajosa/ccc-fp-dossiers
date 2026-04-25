# Contexto del proyecto · Dossieres FP CCC
*Versión 3 · 25 de abril de 2026 · cierre de sesión previo a migración a repo*

---

## 0. CIERRE DE ESTA SESIÓN

Esta versión del md cierra el ciclo de trabajo en chats y prepara la migración a repositorio + Claude Code (CLI o VS Code). Los dos dossieres activos (TCAE v8.2 y AFI v1.2) quedan estables, validados y con todos los bugs reportados resueltos. Lecciones, decisiones arquitectónicas pendientes y plan de migración están al final del documento.

---

## 1. PROPÓSITO Y VISIÓN

Sistema reutilizable de **dossieres HTML print-ready** para los 34 grados de Formación Profesional de CCC (Centro de Enseñanza Carrera Comercial). Cada dossier se imprime desde Chrome a PDF y se usa como material comercial/informativo para alumnos potenciales.

**Principio arquitectónico fundamental:** un único HTML madre contiene toda la estructura (CSS + HTML + render JS). Para generar un grado nuevo se **clona el archivo** y solo se modifica el bloque `CONFIG` del principio del `<script>`. El resto del archivo no se toca. Cualquier cambio estructural obliga a aplicarlo a todos los archivos de grado existentes simultáneamente.

**Usuaria:** Rosa. Perfil producto + marketing con instinto visual fuerte. Trabaja desde móvil con pantallazos. Valida iterativamente en Chrome. Confirma cambios arquitectónicos con "avanti". Detecta regresiones rápidamente y exige coherencia.

---

## 2. ESTADO ACTUAL DE ARCHIVOS

### Archivos de grado

| Archivo | Grado | Estado |
|---|---|---|
| `dossier_TCAE_v7_9.html` | TCAE online | Legacy. No tocar. |
| `dossier_TCAE_v8_0.html` | TCAE online | Congelado. Referencia con sello + badge INCLUIDO + cartela paquete P3. |
| `dossier_TCAE_v8_1.html` | TCAE online | Congelado. Arquitectura opcionales N escalable. |
| `dossier_TCAE_v8_2.html` | TCAE online | **Activo y estable.** Logo en opcionales + fix impresión + textos coherentes. |
| `dossier_AFI_v1_0.html` | AFI presencial | Roto (clone con `imgs_ccc` perdido). No usar. |
| `dossier_AFI_v1_1.html` | AFI presencial | Congelado. Clone reparado, primer estado funcional. |
| `dossier_AFI_v1_2.html` | AFI presencial | **Activo y estable.** Textos AFI sin hardcodes TCAE + logos opcionales + fix impresión. |

### Documentos maestros (en proyecto)

- `Guia_produccion_fotografica_CCC_FP_v3.docx` — para agencia. Necesita pasar a v4.
- `Checklist_interno_logos_activos_CCC_FP_v3.docx` — uso interno CCC. Necesita pasar a v4.
- `Guía_de_estilo___1_.docx`
- `instrucciones_dossier_v7.docx`

---

## 3. ARQUITECTURA TÉCNICA

### 3.1. Estructura de un archivo

Cada dossier tiene 3 bloques `<script>`:
- **Script 1:** CONFIG + datos externos (librerías QRCode, etc.). Líneas ~22 a ~600.
- **Script 2:** Estilos generados dinámicamente.
- **Script 3:** IIFE de render (lee CONFIG → puebla DOM).

Para manipulación programática con Python:
```python
import re
scripts = list(re.finditer(r'<script[^>]*>(.*?)</script>', html, re.DOTALL))
config_script = scripts[0]   # índice 0 = CONFIG
render_script = scripts[2]   # índice 2 = render IIFE
```

### 3.2. Convenciones de imágenes (estado actual, pre-migración)

**Regla actual:**
- **Imágenes de grado** → rutas relativas `fotos/*.jpg` en `CONFIG.imgs`. NUNCA base64.
- **Activos comunes CCC** (logos CCC/MIN/CAM/FE/diploma/Microsoft/AWS, QRs) → base64 en `CONFIG.imgs_ccc` y `CONFIG.qr_curso` / `CONFIG.qr_general`.

**Decisión arquitectónica acordada en esta sesión, pendiente de implementar tras la migración a repo:**
- Pool único de fotos: una sola carpeta con todas las fotos de los 34 grados, nombradas `{CODIGO_GRADO}_{slot}.jpg` (ej. `TCAE_p1_portada.jpg`, `AFI_p1_portada.jpg`). El CONFIG construye la ruta automáticamente con un `imgs_prefix`.
- Catálogo central de logos: archivo `LOGOS_CATALOG` en el HTML base con todos los logos disponibles (`ucam.png`, `microsoft.png`, `gesden.png`...). Cada grado selecciona por clave (`logo: "ucam"`) sin duplicar archivos.
- Mantener `imgs_ccc` (base64) solo para activos institucionales invariables (CCC, Ministerio, Consejería, Fondos Europeos, diploma).

Ver §11 para el plan de implementación.

### 3.3. Funciones de render de imágenes

- `renderImgOrPh(id, src, alt)` → contenedores fluidos (hero, grid, etc).
- `renderBgImg(id, src, alt)` → wrappers de altura fija (apaisadas inferiores).
- **Overlay gradient** `.img-overlay-bottom` (izquierda→derecha, oscuro→transparente) → centralizado en ambas funciones, se aplica automáticamente.

### 3.4. Orden y visibilidad de páginas

Control en `CONFIG.pages`: array inclusivo. Solo se muestran las páginas cuyo id aparece en el array. El orden del array determina el orden de impresión.

Ejemplo TCAE v8.2:
```js
pages: ['p1','p2','p3','p4','p5','p6','p6_2','p6b','p7','p7d','p7c','p7b','p8','p9b','p10b','p9','p11']
```

Ejemplo AFI v1.2:
```js
pages: ['p1','p2','p3','p4','p5','p6','p6_2','p6b','p7','p7c','p7b','p7b2','p7b3','p8','p9b','p10b','p9','p11']
```

### 3.5. Mecanismo de visibilidad reforzado (post-fix de impresión)

El render aplica DOBLE mecanismo a las páginas no incluidas en `ACTIVE_PAGES`:
1. `el.style.display = 'none'` (oculta en navegador).
2. `el.classList.add('is-hidden')` (sirve de gancho CSS).

Y el bloque `@media print` tiene reglas explícitas con `!important` que fuerzan altura A4 exacta y ocultan páginas con `is-hidden` o con `display:none` inline. Sin esto, Chrome a veces imprime páginas fantasma que no se ven en pantalla.

### 3.6. Variables CSS críticas

- `--fs-body: 8.5pt`, `--fs-body-sm: 7.5pt`
- `--rojo: #CC0000`, `--negro: #000`, `--gris: #666`, `--bg-suave: #F6F6F6`, `--borde: #DDD`
- `--pw: 210mm`, `--ph: 297mm`
- Alturas típicas: `sales-foto-wrap: 69mm`, `paquete foto apaisada: 64mm`, `p7b foto apaisada: 76mm`.

### 3.7. Sistema de badge "INCLUIDO"

Clase `.badge-incluido`, posición `top:-3mm; left:5mm`, tipografía 6.5pt uppercase letter-spacing .12em, radio 2.5px, negro minimalista.

- Se aplica en P7/P7d/P7e via `renderVentajaCard` solo si `v.tipo !== 'optativo'`.
- Se aplica en los 3 bloques hardcoded de P7c.
- NO se aplica en páginas de opcionales (P7b/P7b2/P7b3).
- Padding de los contenedores aumentado arriba (6mm `.vc`, 7mm bloques P7c) para no colisionar con el badge.

---

## 4. SISTEMA DE OPCIONALES ESCALABLE

### 4.1. Filosofía

Cada grado puede tener de 0 a 3 especializaciones **opcionales** (no incluidas en la matrícula). Se renderizan en `p7b`, `p7b2`, `p7b3`. Activación por inclusión en `CONFIG.pages`.

### 4.2. Contrato del array `CONFIG.opcionales[]`

```js
opcionales: [
  {
    titulo_h1:      "Especialización en",            // parte negra del h1
    titulo_h1_span: "Enfermería Geriátrica",         // parte roja (span)
    subtitulo:      "...",                           // 9.5pt bold
    intro:          "...",                           // sec-intro
    temario_titulo: "Contenido de la especialización",
    temario:        ["Item 1", "Item 2", ...],       // grid 2 columnas
    nota:           "Especialización <strong>opcional</strong>...",
    foto_slot:      "p7b_foto",                      // clave en CONFIG.imgs (foto apaisada)
    logo_slot:      "p7b_logo",                      // clave en CONFIG.imgs (logo partner) — NUEVO en v8.2
    logo_caption:   "Universidad acreditadora",      // texto bajo el logo (auto MAYÚSCULAS via CSS) — NUEVO en v8.2
    pre_foto:       "Texto previo a la foto."
  },
  /* máx. 3 objetos */
]
```

### 4.3. Render genérico

IIFE `OPCIONALES_PAGES = ['p7b','p7b2','p7b3']`. Por cada item del array:
- Si hay 1 solo opcional → sec-label: `"Formación opcional"`.
- Si hay >1 opcionales → sec-label: `"Opción 1 · Formación opcional"`, etc.
- Pinta todos los campos en elementos con id `<pageId>-<campo>`.
- `renderBgImg` para la foto apaisada inferior.
- Si `logo_slot` apunta a una imagen existente, muestra el logo en esquina superior derecha del título; si no, oculta el contenedor (`.is-hidden`).

### 4.4. Clases CSS

`.opcional-puente`, `.opcional-subtitulo`, `.opcional-temario` (con `.temario-titulo` y `.temario-grid`), `.opcional-nota` (con `.icono` y `.texto`).

**Logo de partner (NUEVO en v8.2):**
- `.opcional-title-row` envuelve el sec-h1 y el contenedor del logo.
- `.opcional-logo-wrap` contiene `.opcional-logo-box` (caja blanca con borde) + `.opcional-logo-caption`.
- Caption: `font-size: 6.5pt`, `letter-spacing: .1em`, MAYÚSCULAS, `max-width: 28mm`, `text-align: right`, `line-height: 1.3` (forzado a 2 líneas naturales).
- Logo: `max-width: 100%`, `max-height: 11mm`, `object-fit: contain`.

---

## 5. CARTELA PAQUETE FORMATIVO P3

Bloque resumen en P3 alimentado por `CONFIG.paquete`:

```js
paquete: {
  destacados: [
    { titulo: "FP Oficial TCAE",       subtitulo: "Título MEC · 1.400h" },
    { titulo: "Prácticas en empresa",  subtitulo: "440h · Red +10.500" }
  ],
  extras: [
    { titulo: "CFC", subtitulo: "+ 50 créditos" },
    ...
  ]
}
```

Foto apaisada P3 reducida a 64mm para dar sitio a la cartela.

---

## 6. CONTENIDOS ESPECÍFICOS

### 6.1. TCAE v8.2 — online (sanitario)

- Acrónimo `TCAE`, 1.400h · 1,5 años, FCT 440h, modalidad online.
- Ventajas P7: CFC (badge +50 créditos) + GESDEN (licencia software). P7d activa.
- Opcionales: 1 (Enfermería Geriátrica) sin logo de partner.
- Sector: sanitario.

### 6.2. AFI v1.2 — presencial Madrid (empresarial)

- Acrónimo `AFI`, 2.000h · 2 años, FCT 500h, modalidad presencial Madrid (Julián Camarillo — Albasanz 9 / San Sotero 3).
- Ventajas P7: Power BI + Excel Avanzado (1 sola cartela, logo Microsoft). P7d desactivada.
- Opcionales: 3 (Marketing Digital + SEO con logo GA4, TSU Economía UCAM con logo UCAM, TSU Marketing UCAM con logo UCAM).
- Sector: empresarial / administrativo.

---

## 7. CAMPOS CONFIGURABLES (refactor de hardcodes en esta sesión)

Textos que antes vivían hardcoded en el HTML, ahora son campos del CONFIG. Cada grado los define con su propia terminología:

| Campo | Página | Notas |
|---|---|---|
| `p3_title` | P3 | "Tu camino para <span>X</span> empieza aquí" |
| `p3_bajada` | P3 | Texto bajo el título |
| `p3_pre_foto` | P3 | Caption sobre foto apaisada inferior |
| `p5_puente` | P5 | Texto entre stats y salidas |
| `p6b_title` | P6b | Título de prácticas FCT |
| `p6b_intro` | P6b | Intro |
| `p6b_actividades_titulo` | P6b | Título lista actividades |
| `p6b_actividades` | P6b | Array de strings (5 actividades típicas) |
| `p6b_frase_cierre` | P6b | Frase entrecomillada de cierre |
| `p6b_centros_titulo` | P6b | Título lista centros |
| `p6b_centros` | P6b | Array de strings (tipos de centro) |
| `p7c_subtitulo` | P7c | Sub bajo el sec-h1 |
| `p7c_intro` | P7c | Intro principal con referencia al grado (ya no hardcoded "TCAE") |
| `p9b_req_intro` | P9b | Intro requisitos (cambia entre Grado Medio y Grado Superior) |
| `p10b_hero_sub` | P10b | Sub del hero "Becas y ayudas" |
| `cta_h2` | P11 | Llamada principal del CTA |
| `cta_sub` | P11 | Texto bajo el CTA |

**Requisitos de acceso:** array `requisitos[]` debe contener los requisitos correctos según GM o GS. Los de Grado Medio (TCAE) son distintos a los de Grado Superior (AFI).

---

## 8. BUGS RESUELTOS EN ESTA SESIÓN

### 8.1. Hardcodes "TCAE/sanitario" en HTML
Identificados y movidos a CONFIG en P3, P5, P6b, P7c, P9b, P10b, P11. Defaults en render JS también limpiados (`p4_title`, `p2-prop-pre`, `p1_card_*`).

### 8.2. P1 desbordando al imprimir (página fantasma entre P1 y P2)
**Causa raíz:** `.page` solo tenía `min-height: 297mm` sin `max-height`. Al imprimir, cualquier diferencia mínima de renderizado (bordes, decimales, escalado de Chrome) hacía que la página creciera y se partiera en 2 hojas A4 físicas.

**Fix aplicado en `@media print`:**
```css
.page {
  height: var(--ph);
  min-height: var(--ph);
  max-height: var(--ph);
  overflow: hidden;
}
.page[style*="display:none"],
.page[style*="display: none"],
.page.is-hidden {
  display: none !important;
  height: 0 !important;
  /* + más resets */
}
```

Y en JS: las páginas ocultas reciben `class="is-hidden"` además del `style.display = 'none'` para que el selector CSS las atrape con seguridad.

### 8.3. Caption del logo en una sola línea
Forzado a 2 líneas con `max-width: 28mm` + `text-align: right`. Ahora "PREPARACIÓN CERTIFICACIÓN" y "UNIVERSIDAD ACREDITADORA" se parten en 2 líneas equilibradas.

### 8.4. `</div>` sobrante después de P1
Eliminado en TCAE v8.2 y AFI v1.2 (no era la causa del desbordamiento pero estaba mal igualmente).

---

## 9. FLUJO DE TRABAJO PARA CLONAR UN GRADO NUEVO (modelo actual)

1. **Input necesario:** PDF con datos del grado.
2. `cp dossier_TCAE_v8_2.html dossier_XXX_v1_0.html` (o desde AFI si es Grado Superior).
3. Actualizar sello de versión al principio del CONFIG.
4. Sustituir CONFIG completo (líneas 22-543 aprox) con los datos del nuevo grado.
5. **Preservar íntegramente** el bloque final del CONFIG: `qr_curso`, `qr_general`, `imgs_ccc: {...}` (son activos comunes base64).
6. Validar sintaxis JS con `node --check` de los 3 scripts.
7. Abrir en Chrome + DevTools, revisar cada página.
8. Iterar correcciones visuales.
9. Print to PDF.

---

## 10. HERRAMIENTAS Y COMANDOS

### Validación de sintaxis JS (obligatorio antes de entregar)

```bash
node -e "
const fs = require('fs');
const html = fs.readFileSync('/path/to/dossier.html', 'utf8');
const scripts = [...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/g)].map(m => m[1]);
scripts.forEach((s, i) => { try { new Function(s); console.log('Script '+(i+1)+': OK'); } catch(e) { console.log('Script '+(i+1)+' ERROR: '+e.message); } });
"
```

### Sustitución de CONFIG por línea exacta (Python)

El CONFIG empieza en la línea `const CONFIG = {` y termina en la primera `};` a nivel 0. Localizarlo por número de línea (la primera `};` al principio de línea después del inicio) y sustituir solo ese rango. **No usar regex `\n};\n`** porque aparece en muchos otros sitios del archivo.

```python
with open(path, 'r') as f:
    lines = f.readlines()
start = next(i for i, l in enumerate(lines) if 'const CONFIG = {' in l)
end = next(i for i, l in enumerate(lines[start+1:], start=start+1) if l.rstrip() == '};' and i < 600)
new_lines = lines[:start] + [new_config] + lines[end+1:]
```

### Print to PDF desde Chrome

Tamaño A4. Márgenes predeterminados. Gráficos de fondo: ACTIVADO. Escala 100%.

---

## 11. DECISIONES ARQUITECTÓNICAS PENDIENTES (post-migración a repo)

### 11.1. Pool único de fotos con prefijo de grado

**Propuesta de Rosa, aceptada:**
- Una sola carpeta `fotos/` con todos los grados.
- Nomenclatura: `{CODIGO_GRADO}_{slot}.jpg` (ej. `TCAE_p1_portada.jpg`, `AFI_p1_portada.jpg`).
- En CONFIG: campo nuevo `imgs_prefix: "AFI"` y rutas simplificadas a solo el slot (`p1_portada: "p1_portada.jpg"`).
- El render concatena: `fotos/${imgs_prefix}_${slot}`.

**Ventaja operativa:** la agencia entrega un único drop, no 34 carpetas.

### 11.2. Catálogo central de logos

**Propuesta de Rosa, aceptada:**
- Archivo único `LOGOS_CATALOG` en el HTML base (no se toca al clonar):
  ```js
  const LOGOS_CATALOG = {
    aws:        { src: "logos/aws.png",        caption_default: "" },
    cfc:        { src: "logos/cfc.png",        caption_default: "Acreditadora" },
    ga4:        { src: "logos/ga4.png",        caption_default: "Preparación certificación" },
    gesden:     { src: "logos/gesden.png",     caption_default: "Software incluido" },
    microsoft:  { src: "logos/microsoft.png",  caption_default: "" },
    ucam:       { src: "logos/ucam.png",       caption_default: "Universidad acreditadora" },
  };
  ```
- En CONFIG de cada grado, los logos se eligen por clave: `logo: "ucam"`.
- Caption override-able si hace falta: `logo: "ucam", logo_caption: "Acreditación oficial"`.

**Ventaja operativa:** un archivo por partner, no por ocurrencia. UCAM aparece en N grados con un solo archivo.

### 11.3. Activos comunes (base64) — sin cambios

Mantener `imgs_ccc` solo para activos institucionales invariables (CCC, Ministerio, Consejería, Fondos Europeos, diploma). NO mover partners variables ahí.

### 11.4. Documentos maestros que necesitan actualización (v3 → v4)

**`Guia_produccion_fotografica_CCC_FP_v3.docx` → v4:**
- Cambiar §2 Estructura de entrega: pool único en `fotos/` con prefijo de grado.
- Añadir §3 Inventario: 2 filas nuevas `p7b2_foto` y `p7b3_foto` (condicionales).
- Cambiar nomenclatura de archivos en §2 y §6: `TCAE_p1_portada.jpg` en lugar de `p1_portada.jpg`.
- Resumen ejecutivo: ajustar conteo de fotos opcionales (hasta 3 por grado en lugar de 1).

**`Checklist_interno_logos_activos_CCC_FP_v3.docx` → v4:**
- Sección nueva: catálogo central de logos con tabla de partners disponibles.
- Sección nueva: convención `logos/{partner}.png` (carpeta separada de `fotos/`).
- Familia de slots opcionales: `p7b_logo`, `p7b2_logo`, `p7b3_logo` con explicación del sistema de catálogo.
- Decisión sobre activos comunes: cuáles siguen en base64, cuáles van a `logos/`.

---

## 12. MIGRACIÓN A REPO + CLAUDE CODE

Esta es la última sesión que se hace en chats. Las próximas iteraciones se harán en repositorio (GitHub privado) trabajando con Claude Code (CLI o extensión VS Code).

### 12.1. Por qué migramos

- 34 grados es demasiado para gestionar en chats: cada chat se queda sin context window.
- Los cambios arquitectónicos deben aplicarse a N archivos en paralelo: necesitamos scripts.
- Las decisiones quedan en commits con su mensaje, no perdidas en transcripts.
- Múltiples personas (diseño, copy, producto) pueden colaborar en branches.

### 12.2. Estructura recomendada del repo

```
ccc-fp-dossiers/
├── grados/
│   ├── dossier_TCAE.html
│   ├── dossier_AFI.html
│   └── ...
├── assets/
│   ├── fotos/         (pool único, todas las fotos con prefijo)
│   │   ├── TCAE_p1_portada.jpg
│   │   ├── AFI_p1_portada.jpg
│   │   └── ...
│   ├── logos/         (catálogo de partners)
│   │   ├── ucam.png
│   │   ├── microsoft.png
│   │   └── ...
│   └── shared/        (base, comunes, no tocar)
├── docs/
│   ├── CONTEXTO.md                       (este archivo, sin sección 12)
│   ├── guia_produccion_fotografica.md    (v4 markdown)
│   ├── checklist_logos.md                (v4 markdown)
│   ├── decisiones_arquitectonicas.md
│   └── flujo_clone_grado.md
├── scripts/
│   ├── validate.sh                       (node --check de los 3 scripts)
│   ├── clone_grado.sh                    (asistente de creación)
│   └── generate_pdfs.sh                  (puppeteer/playwright para PDFs masivos)
└── README.md
```

### 12.3. Primeros pasos en el repo

1. Crear repo privado en GitHub.
2. Subir el estado actual: TCAE v8.2 (renombrado a `dossier_TCAE.html`) + AFI v1.2 (renombrado a `dossier_AFI.html`).
3. Convertir los 2 docx maestros a markdown y meterlos en `docs/`.
4. Instalar Claude Code.
5. **Primera tarea con Claude Code:** implementar la separación `fotos/` + `logos/` con catálogo central (decisiones 11.1 y 11.2). Es el primer cambio arquitectónico y aprovechar la potencia del repo desde el principio.
6. **Segunda tarea:** actualizar los documentos maestros a v4 reflejando los cambios.
7. **Tercera tarea en adelante:** clonar el tercer grado FP, ya en el sistema definitivo.

### 12.4. Mensaje-tipo para arrancar la primera sesión Claude Code

> Bienvenido al repo `ccc-fp-dossiers`. Lee `docs/CONTEXTO.md` antes de hacer nada. Estamos en el momento del proyecto descrito en §11: dos grados estables (TCAE v8.2 y AFI v1.2) y vamos a implementar la separación `fotos/` + `logos/` con catálogo central. Empieza por proponerme un plan detallado de cambios antes de tocar código. Trabaja con commits granulares y valida con `scripts/validate.sh` después de cada cambio.

---

## 13. REGLAS PARA CLAUDE EN FUTURAS SESIONES

1. **Trabajar siempre sobre los 2 archivos activos a la vez** (TCAE + AFI) si el cambio es arquitectónico.
2. **Validar con `node --check`** antes de entregar. Los 3 scripts deben pasar.
3. **Nunca perder el bloque `imgs_ccc`** al sustituir CONFIG.
4. **Iteraciones pequeñas** con validación visual de Rosa.
5. **No improvisar contenido del grado.** Pedir el PDF/datos si faltan.
6. **Respetar la división estilística:** rojo CCC + negro + gris, tipografía pt, medidas mm.
7. **Entregar siempre con `present_files`** los HTML modificados + este md si se ha actualizado.
8. **Actualizar este md** si el cambio afecta a arquitectura o reglas.
9. **No añadir features sin que Rosa diga "avanti".**

---

## 14. HISTORIAL DE VERSIONES ARQUITECTÓNICAS

- **v7.9 TCAE:** base legacy con paquete formativo.
- **v8.0 TCAE:** sello + badge INCLUIDO + cartela paquete P3 (congelada).
- **v8.1 TCAE:** arquitectura opcionales N escalable (CONFIG.opcionales[]).
- **v8.2 TCAE:** logo en opcionales + fix impresión + textos coherentes hardcoded → CONFIG.
- **v1.0 AFI:** primer clone (ROTO, imgs_ccc perdido).
- **v1.1 AFI:** clone reparado, primer estado funcional.
- **v1.2 AFI:** textos AFI sin hardcodes TCAE + 3 opcionales con logos UCAM + GA4 + fix impresión.

---

*Fin del documento. Esta es la última versión del md gestionada en chats. La próxima evolución se hará en repositorio.*
