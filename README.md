# CCC FP · Dossieres

Sistema reutilizable de dossieres HTML print-ready para los 34 grados de Formación Profesional de CCC. Cada dossier se imprime desde Chrome a PDF como material comercial.

## Estado actual del proyecto

| Archivo | Grado | Versión | Estado |
|---|---|---|---|
| `dossier_TCAE_v8_3_p2.html` | TCAE · Cuidados Auxiliares de Enfermería · online | Motor AFI + aligerado | **Activo · usar este** |
| `dossier_AFI_v1_3_p2.html` | AFI · Administración y Finanzas · presencial Madrid | Aligerado | **Activo · usar este** |
| `dossier_TCAE_v8_2.html` | TCAE · original pre-aligerado | Referencia histórica | Archivo, no editar |
| `dossier_AFI_v1_2.html` | AFI · original pre-aligerado | Referencia histórica + motor de referencia | Archivo, no editar |

## Estructura del repo

```
.
├── README.md                              ← este archivo
├── CONTEXTO_DOSSIERES_CCC_v3.md           ← contexto completo del proyecto, leer ANTES de tocar nada
├── dossier_TCAE_v8_3_p2.html             ← TCAE activo
├── dossier_TCAE_v8_2.html                ← TCAE original (referencia histórica)
├── dossier_AFI_v1_3_p2.html              ← AFI activo
├── dossier_AFI_v1_2.html                 ← AFI original (referencia histórica + motor canónico)
├── fotos/                                ← fotos de grado con prefijo (TCAE_*, AFI_*, ...)
├── logos/
│   ├── comunes/                          ← activos comunes a los 34 grados (17 archivos)
│   └── [partners por grado]              ← logos de certificadoras, software, etc.
├── docs/
│   └── PLAN_001_pool_fotos_logos.md      ← plan de la próxima tarea arquitectónica
└── scripts/
    └── validate.sh                       ← validación de sintaxis JS de los HTML
```

## Arquitectura del HTML

Cada dossier es un único archivo HTML autosuficiente con 3 bloques `<script>` en orden fijo:

```
script[0] → const CONFIG = { ... }   único por grado — aquí vive todo el copy y las rutas de fotos
script[1] → CSS embebido             común a todos los grados (byte-idéntico entre TCAE y AFI)
script[2] → Render IIFE              motor de renderizado común (AFI es la versión canónica)
```

El HTML estático (fuera de scripts) también es común. Solo `script[0]` cambia entre grados.

## Convenciones clave

**Fotos de grado:** rutas relativas en `fotos/` con prefijo del grado (`TCAE_portada.jpg`, `AFI_hero.jpg`...). NUNCA base64.

**Activos comunes** (logos CCC, Ministerio, Consejería, Fondos Europeos, diploma, Microsoft, AWS, fotos campus CCC): rutas relativas en `logos/comunes/`. NUNCA base64. Los 17 archivos actuales son la referencia de verdad — cualquier activo nuevo que sea común a todos los grados va aquí.

**QR:** base64 en `CONFIG.imgs_ccc.qr_curso` y `CONFIG.imgs_ccc.qr_general`. Son los únicos base64 que se mantienen intencionadamente — funcionan offline y se generan una sola vez.

**Logos de partners por grado** (certificadoras, software específico): en `logos/` con prefijo de grado o nombre del partner. Rutas relativas en `CONFIG.ventajas[].logo.src`.

**Validación obligatoria** antes de commit: `bash scripts/validate.sh`.

**Cualquier cambio en el motor** (script[1] CSS o script[2] render) se aplica a TODOS los dossieres activos simultáneamente.

## Motor canónico

`dossier_AFI_v1_2.html` es el motor de referencia. Su `script[2]` es un superset estricto del TCAE original — añade configurabilidad a P3, P5, P6b, P7c, P9b y P10b sin romper nada. Su CSS es byte-idéntico al de TCAE. Cualquier nuevo grado parte de este motor.

Los 15 campos que AFI añade sobre el motor TCAE original y que deben estar en el CONFIG de cada grado:
`p3_title`, `p3_bajada`, `p3_pre_foto`, `p5_puente`, `p6b_title`, `p6b_intro`, `p6b_actividades_titulo`, `p6b_actividades`, `p6b_frase_cierre`, `p6b_centros_titulo`, `p6b_centros`, `p7c_subtitulo`, `p7c_intro`, `p9b_req_intro`, `p10b_hero_sub`.

## Cómo crear un nuevo dossier

1. Copiar `dossier_AFI_v1_3_p2.html` como base (motor canónico + ya aligerado).
2. Sustituir `script[0]` (CONFIG) por el del nuevo grado.
3. Ajustar `<title>`.
4. Añadir los 15 campos del motor AFI al CONFIG con el copy del nuevo grado.
5. Verificar que las fotos del grado están en `fotos/` con el prefijo correcto.
6. Validar con `bash scripts/validate.sh`.
7. Abrir en Chrome y revisar todas las páginas.
8. Commit y push.

Ver el prompt detallado de este proceso en `docs/prompt_aligerado_grado_FP.md`.

## Hoja de ruta del build system

El sistema actual (un HTML por grado) es la solución correcta mientras el motor esté en evolución. Cuando haya 5-6 grados validados y el motor sea estable, tiene sentido automatizar la generación con un build script que componga:

```
config_GRADO.js  +  motor_comun.html  →  dossier_GRADO.html
```

No automatizar antes — el motor todavía puede cambiar y regenerar 34 archivos a mano sería costoso. La arquitectura actual lo permite sin fricción.

## Versionado

A partir de ahora la versión la marca el commit/tag de Git. Los nombres de archivo actuales (`v8_3_p2`, `v1_3_p2`) son transitorios — en cuanto el motor sea estable los archivos pasarán a llamarse `dossier_TCAE.html`, `dossier_AFI.html`, etc.

## Cómo trabajar con Claude en este repo

1. Abrir el repo en VS Code.
2. Pasar a Claude el contexto `CONTEXTO_DOSSIERES_CCC_v3.md` al inicio de cada sesión.
3. Para tareas de aligerado de nuevos grados, usar el prompt en `docs/prompt_aligerado_grado_FP.md`.
4. Trabajar en branches para cambios arquitectónicos: `git checkout -b feature/lo-que-sea`.
5. Validar con `bash scripts/validate.sh` antes de cada commit.

## Documentos maestros

- Guía de producción fotográfica · CCC FP — para agencia fotográfica.
- Checklist interno de logos y activos · CCC FP — uso interno.
- Guía de estilo · CCC FP — sistema visual.

Todos viven en Google Drive del equipo. Pendiente actualizar a v4 cuando el sistema de pool de fotos esté implementado.
