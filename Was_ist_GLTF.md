# 🧠 Was ist GLTF

GLTF (GL Transmission Format) ist ein modernes 3D-Dateiformat, das Second Life verwendet, um realistische Materialien und Texturen auf Prims darzustellen. In der Linden Scripting Language (LSL) kannst du GLTF-Materialien direkt per Skript setzen – mit erweiterten Eigenschaften wie Transparenz, Normalmaps, Metallglanz und Emission.

GLTF-Materialparameter sind sogenannte **Overrides**: Sie überschreiben die Standardmaterialien (Blinn-Phong). Wenn du einen Parameter auf einen leeren String (`""`) setzt, wird der entsprechende Override **gelöscht**.

---

## 🔧 GLTF-Materialparameter im Detail

### 1. `PRIM_GLTF_BASE_COLOR`

```lsl
[PRIM_GLTF_BASE_COLOR, face, texture, repeats, offsets, rotation_in_radians, linear_color, alpha, gltf_alpha_mode, alpha_mask_cutoff, double_sided]
```

- **face**: Flächennummer (z. B. 0)
- **texture**: UUID der Textur oder leer (`""`) zum Entfernen
- **repeats**: Vektor `<x, y, 0.0>` für Texturwiederholungen
- **offsets**: Vektor `<x, y, 0.0>` für Verschiebung
- **rotation_in_radians**: Drehung der Textur (z. B. `PI/2`)
- **linear_color**: RGB-Farbwert im linearen Farbraum (z. B. `<1.0, 0.5, 0.0>`)
- **alpha**: Transparenzwert (0.0 = durchsichtig, 1.0 = undurchsichtig)
- **gltf_alpha_mode**:
  - `0` = OPAQUE: ignoriert Alpha
  - `1` = BLEND: Alpha-Blending (kann zu Sortierproblemen führen)
  - `2` = MASK: Alpha-Maskierung mit Schwellenwert
- **alpha_mask_cutoff**: Schwellenwert für Maskierung (z. B. `0.5`)
- **double_sided**: `TRUE` oder `FALSE` – ob beide Seiten sichtbar sind

---

### 2. `PRIM_GLTF_NORMAL`

```lsl
[PRIM_GLTF_NORMAL, face, texture, repeats, offsets, rotation_in_radians]
```

- Fügt eine **Normalmap** hinzu, die Oberflächenstruktur simuliert.
- Alle Parameter sind wie bei `PRIM_GLTF_BASE_COLOR`.
- Die Textur muss eine gültige Normalmap sein.
- Ein leerer String entfernt die Normalmap.

---

### 3. `PRIM_GLTF_METALLIC_ROUGHNESS`

```lsl
[PRIM_GLTF_METALLIC_ROUGHNESS, face, texture, repeats, offsets, rotation_in_radians, metallic_factor, roughness_factor]
```

- **metallic_factor**: Wert zwischen `0.0` (nicht metallisch) und `1.0` (voll metallisch)
- **roughness_factor**: Wert zwischen `0.0` (glatt/glänzend) und `1.0` (rau/matt)
- Optional kann eine Textur verwendet werden, die beide Kanäle kombiniert.
- Ein leerer String entfernt die Textur.

---

### 4. `PRIM_GLTF_EMISSIVE`

```lsl
[PRIM_GLTF_EMISSIVE, face, texture, repeats, offsets, rotation_in_radians, linear_emissive_tint]
```

- Erzeugt einen **Leuchteffekt**, unabhängig von Lichtquellen.
- **linear_emissive_tint**: RGB-Farbwert im linearen Farbraum
- Ein leerer String entfernt die Emissive-Map.

---

## 🎯 GLTF Texture Scale – Texturskalierung

Die Skalierung von GLTF-Texturen wird über den Parameter `repeats` gesteuert:

```lsl
repeats = <x, y, 0.0>
```

- **x** = horizontale Skalierung (U-Achse)
- **y** = vertikale Skalierung (V-Achse)

### Skalierungsverhalten:

| Wert                | Wirkung auf die Textur                         |
|---------------------|------------------------------------------------|
| `<1.0, 1.0, 0.0>`   | Standardgröße der Textur                       |
| `<2.0, 2.0, 0.0>`   | Textur wird **kleiner** und **häufiger gekachelt** |
| `<0.5, 0.5, 0.0>`   | Textur wird **größer** und **weniger gekachelt** |
| `<-1.0, 1.0, 0.0>`  | Textur wird **horizontal gespiegelt**         |
| `<1.0, -1.0, 0.0>`  | Textur wird **vertikal gespiegelt**           |

Zusätzlich kannst du:

- **`offsets`** verwenden, um die Textur zu verschieben
- **`rotation_in_radians`** nutzen, um die Textur zu drehen (z. B. `PI` = 180°)

> 📌 GLTF verwendet das **Vulkan-Koordinatensystem**, bei dem die **Y-Achse invertiert** ist. Das bedeutet: Texturen können „auf dem Kopf“ erscheinen, wenn du sie wie gewohnt aus OpenGL exportierst.

---
