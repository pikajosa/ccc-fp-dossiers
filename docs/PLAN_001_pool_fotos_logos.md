# Plan 001 · Pool de fotos con prefijo + catálogo central de logos

**Objetivo:** simplificar la operativa de gestión de imágenes de los 34 grados FP, separando responsabilidades (fotos = agencia, logos = CCC) y eliminando duplicación.

**Estado:** decidido por Rosa. Pendiente de implementar.

**Archivos afectados:** `dossier_TCAE_v8_2.html`, `dossier_AFI_v1_2.html`. Cualquier grado nuevo nacerá ya con este sistema.

---

## Resultado esperado

Tras esta tarea, la estructura de imágenes del repo quedará así:

```
fotos/
  TCAE_p1_portada.jpg
  TCAE_p2_hero.jpg
  TCAE_p7_sales1_foto.webp
  ...
  AFI_p1_portada.jpg
  AFI_p2_hero.jpg
  AFI_p7_sales1_foto.jpg
  ...

logos/
  cfc.png
  gesden.png
  microsoft.png
  ucam.png
  ga4.png
  aws.png
  ...
```

Y los CONFIG de cada grado:

```js
// TCAE
imgs_prefix: "TCAE",
imgs: {
  p1_portada: ["p1_portada.jpg"],
  p2_hero:    "p2_hero.jpg",
  // (sin prefijo aquí; el render lo añade)
}
```

```js
// AFI
imgs_prefix: "AFI",
imgs: {
  p1_portada: ["p1_portada.jpg"],
  p2_hero:    "p2_hero.jpg",
}
```

Y el catálogo de logos vivirá en el HTML base (idéntico en TCAE y AFI):

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

Selección en CONFIG por clave:

```js
// AFI
opcionales: [
  { titulo_h1: "Posicionamiento Web", titulo_h1_span: "y Marketing Digital", logo: "ga4", ... },
  { titulo_h1: "TSU en", titulo_h1_span: "Economía",  logo: "ucam", ... },
  { titulo_h1: "TSU en", titulo_h1_span: "Marketing", logo: "ucam", ... }
]
```

Caption override-able:

```js
{ logo: "ucam", logo_caption: "Acreditación oficial" }   // sobreescribe el default del catálogo
```

---

## División por fases (un commit por fase)

### Fase 0 · Reorganización del repo

- [ ] Crear carpeta `logos/` en raíz.
- [ ] Mover los archivos de logos actuales (los que están dentro de `fotos/`) a `logos/`. Renombrarlos con identidad clara: `cfc.png`, `gesden.png`, `microsoft.png`, `ucam.png`, `ga4.png`, `aws.png` (los que existan en este momento).
- [ ] Renombrar las fotos de grado de `fotos/p1_portada.jpg` a `fotos/TCAE_p1_portada.jpg` y `fotos/AFI_p1_portada.jpg`. Si ahora hay duplicados con el mismo nombre, esto los desambigua.
- [ ] Commit: `chore: reorganizar fotos/ con prefijo de grado y crear logos/`.

### Fase 1 · Render adaptado al prefijo

- [ ] En el render IIFE de ambos HTML, modificar `renderImgOrPh` y `renderBgImg` para que, si `C.imgs_prefix` existe y la ruta NO empieza con `fotos/`, `logos/` ni `data:`, prependen `fotos/${prefix}_`.
- [ ] Mantener compatibilidad: si la ruta ya viene con `fotos/...` explícita, no la toca (rampa de migración suave).
- [ ] Commit: `feat: render soporta imgs_prefix para construir rutas`.

### Fase 2 · CONFIG de los 2 grados con prefijo

- [ ] En TCAE y AFI: añadir `imgs_prefix: "TCAE"` / `"AFI"` al CONFIG.
- [ ] Simplificar las rutas de `imgs.*`: quitar el `fotos/` y el resto del path, dejar solo el filename.
- [ ] Validar con `bash scripts/validate.sh`.
- [ ] Abrir ambos HTML en navegador, verificar que las imágenes cargan correctamente.
- [ ] Commit: `feat: TCAE y AFI usan imgs_prefix para sus fotos`.

### Fase 3 · Catálogo central de logos (HTML base)

- [ ] Definir `LOGOS_CATALOG` como `const` JS (fuera del CONFIG, en el script principal o al inicio del render IIFE).
- [ ] Añadir el catálogo a TCAE y AFI con las mismas entradas (es global, no por grado).
- [ ] Modificar el render de opcionales: si `op.logo` es un string corto (no path), buscar en `LOGOS_CATALOG[op.logo]` y resolver `src` y `caption_default`.
- [ ] Mantener compatibilidad con el sistema actual (`logo_slot` apuntando a `imgs.p7b_logo`) para que el cambio sea progresivo.
- [ ] Aplicar también al render de ventajas P7 (los logos `p7_logoX_Y` también pueden migrar a claves del catálogo).
- [ ] Commit: `feat: catálogo central de logos (LOGOS_CATALOG)`.

### Fase 4 · Migrar AFI a claves del catálogo

- [ ] En AFI CONFIG: cambiar `logo_slot: "p7b_logo"` por `logo: "ga4"` en el primer opcional.
- [ ] Cambiar `logo_slot: "p7b2_logo"` por `logo: "ucam"` en el segundo y tercer opcional.
- [ ] Eliminar las entradas `p7b_logo`, `p7b2_logo`, `p7b3_logo` de `imgs` (ya no hacen falta).
- [ ] En la ventaja única (Power BI + Excel), migrar `logos: [...]` a claves: `logos: ["microsoft"]`.
- [ ] Validar y abrir en navegador.
- [ ] Commit: `feat(afi): migrar logos a sistema de catálogo`.

### Fase 5 · Migrar TCAE a claves del catálogo

- [ ] Mismo proceso para TCAE: ventajas P7 (CFC, GESDEN) → claves `["cfc"]` y `["gesden"]`.
- [ ] El opcional Geriatría no tiene logo asignado actualmente; queda igual (sin `logo`).
- [ ] Validar y abrir en navegador.
- [ ] Commit: `feat(tcae): migrar logos a sistema de catálogo`.

### Fase 6 · Limpieza y documentación

- [ ] Eliminar del CONFIG todas las entradas de `imgs.p7_logoX_Y` que ya no se usan.
- [ ] Actualizar `CONTEXTO_DOSSIERES_CCC_v3.md` reflejando la implementación. Renombrar a v4 si los cambios lo justifican.
- [ ] Generar markdown actualizado de la guía de producción fotográfica (v4) con la convención `{CODIGO}_{slot}.jpg`.
- [ ] Generar markdown actualizado del checklist interno de logos (v4) con el catálogo y la nueva carpeta `logos/`.
- [ ] Commit: `docs: actualizar contexto y documentos maestros a v4`.

### Fase 7 · Renombrado final de archivos (opcional pero recomendado)

- [ ] Renombrar `dossier_TCAE_v8_2.html` → `dossier_TCAE.html`.
- [ ] Renombrar `dossier_AFI_v1_2.html` → `dossier_AFI.html`.
- [ ] Crear tag de Git `v1.0-pool-logos` para marcar el cierre de esta migración arquitectónica.
- [ ] Commit: `chore: renombrar archivos de grado sin sufijo de versión`.

---

## Criterios de aceptación

- [ ] Los dos HTML pasan `bash scripts/validate.sh` sin errores.
- [ ] Al abrir cada HTML en Chrome, todas las páginas se ven completas y las imágenes cargan.
- [ ] Al imprimir a PDF, no aparecen páginas fantasma ni desbordamientos.
- [ ] Cambiar `imgs_prefix` en un CONFIG basta para que el sistema lea otra serie de fotos sin tocar nada más.
- [ ] Añadir un logo nuevo al catálogo es operación de 1 línea + subir el archivo a `logos/`.
- [ ] Reutilizar un logo (ej. UCAM en 5 grados) no requiere duplicar archivos.

---

## Notas para Claude Code

- Trabajar fase a fase, commit a commit. NO acumular cambios entre fases.
- Si se detecta una mejora arquitectónica adicional durante el camino, NO implementar sin pedir confirmación a Rosa.
- Cualquier duda de criterio (¿qué caption por defecto poner para Microsoft? ¿la ventaja CFC también lleva logo de la entidad acreditadora?) preguntar a Rosa antes de decidir.
- Antes de empezar, listar el estado real de archivos en `fotos/` con `ls fotos/` para mapear qué hay actualmente y qué hay que renombrar.
