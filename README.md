# CCC FP · Dossieres

Sistema reutilizable de dossieres HTML print-ready para los 34 grados de Formación Profesional de CCC. Cada dossier se imprime desde Chrome a PDF como material comercial.

## Estado actual del proyecto

| Archivo | Grado | Estado |
|---|---|---|
| `dossier_TCAE_v8_2.html` | TCAE · Cuidados Auxiliares de Enfermería · online | **Activo y estable** |
| `dossier_AFI_v1_2.html` | AFI · Administración y Finanzas · presencial Madrid | **Activo y estable** |

## Estructura del repo

```
.
├── README.md                              ← este archivo
├── CONTEXTO_DOSSIERES_CCC_v3.md           ← contexto completo del proyecto, leer ANTES de tocar nada
├── dossier_TCAE_v8_2.html
├── dossier_AFI_v1_2.html
├── fotos/                                 ← imágenes y logos (estado actual: todo junto)
├── docs/
│   └── PLAN_001_pool_fotos_logos.md       ← plan de la próxima tarea arquitectónica
└── scripts/
    └── validate.sh                        ← validación de sintaxis JS de los HTML
```

## Convenciones clave

**Imágenes de grado:** rutas relativas en `fotos/`, NUNCA base64.

**Activos comunes** (logos CCC, Ministerio, Consejería, Fondos Europeos, diploma, QRs): base64 en `CONFIG.imgs_ccc`.

**Validación obligatoria** antes de commit: `bash scripts/validate.sh`.

**Cualquier cambio arquitectónico** se aplica a TODOS los archivos de grado existentes simultáneamente.

## Cómo trabajar con Claude Code en este repo

1. Abrir el repo en VS Code.
2. Asegurar que la extensión de Claude Code está instalada y autenticada.
3. Abrir el panel de Claude Code y pegarle el mensaje que aparece en `docs/PRIMERA_SESION.md`.
4. Trabajar en branches: `git checkout -b feature/lo-que-sea`.
5. Validar con `bash scripts/validate.sh` antes de cada commit.

## Próxima tarea arquitectónica

Implementar el sistema de pool de fotos con prefijo de grado + catálogo central de logos. Plan detallado en [`docs/PLAN_001_pool_fotos_logos.md`](docs/PLAN_001_pool_fotos_logos.md).

## Versionado

El versionado de archivos (v8.2, v1.2…) **se va a abandonar** una vez migremos al repo: a partir de ahora la versión la marca el commit/tag de Git. Los nombres de archivo pasarán a ser `dossier_TCAE.html`, `dossier_AFI.html`, etc.

## Documentos maestros (a actualizar a v4 tras la próxima tarea)

- Guía de producción fotográfica · CCC FP — para agencia.
- Checklist interno de logos y activos · CCC FP — uso interno.

Ambos viven en Google Drive del equipo.
