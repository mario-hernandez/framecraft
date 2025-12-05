# FrameCraft

Generador de frames para App Store con soporte MCP (Model Context Protocol).

## Descripcion

FrameCraft permite crear screenshots profesionales para App Store con:
- Fondos de gradiente personalizables
- Textos hero y subtitulos
- Multiples tamanos de dispositivo
- Integracion con Claude Code via MCP

## Arquitectura

```
FrameCraft/
├── Sources/
│   ├── FrameCraftCore/     # Biblioteca compartida
│   ├── FrameCraftCLI/      # Servidor MCP (stdio)
│   └── HeroGenerator/      # GUI macOS (SwiftUI)
└── Package.swift
```

## Productos

| Producto | Tipo | Uso |
|----------|------|-----|
| `FrameCraft` | GUI App | Interfaz grafica macOS |
| `framecraft-mcp` | CLI | Servidor MCP para automatizacion |
| `FrameCraftCore` | Library | Logica compartida |

## Compilacion

```bash
# Compilar todo
swift build

# Compilar release
swift build -c release

# Ejecutar GUI
swift run FrameCraft

# Ejecutar servidor MCP
swift run framecraft-mcp
```

## Uso con Claude Code

Agregar a `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "framecraft": {
      "command": "/path/to/framecraft-mcp",
      "args": []
    }
  }
}
```

## Herramientas MCP

### generate_frame
Genera un frame individual.

```json
{
  "screenshot_path": "/path/to/screenshot.png",
  "hero_text": "Texto principal",
  "subtitle": "Subtitulo opcional",
  "template": "ocean",
  "output_path": "/path/to/output.png"
}
```

### list_templates
Lista plantillas disponibles: ocean, sunset, forest, midnight, berry, coral, mint, slate, dawn, sand.

### generate_batch
Genera multiples frames de una vez.

## Plantillas de gradiente

| ID | Nombre | Colores |
|----|--------|---------|
| ocean | Ocean | #0F2027 -> #2C5364 |
| sunset | Sunset | #F37335 -> #FDC830 |
| forest | Forest | #134E5E -> #71B280 |
| midnight | Midnight | #232526 -> #414345 |
| berry | Berry | #8E2DE2 -> #4A00E0 |
| coral | Coral | #FF416C -> #FF4B2B |
| mint | Mint | #00B09B -> #96C93D |
| slate | Slate | #2C3E50 -> #4CA1AF |
| dawn | Dawn | #C33764 -> #1D2671 |
| sand | Sand | #C9B37E -> #9D8858 |

## Tamanos soportados

- iPhone 6.7" (1290 x 2796)
- iPhone 6.5" (1284 x 2778)
- iPhone 5.5" (1242 x 2208)
- iPad 12.9" (2048 x 2732)

## Requisitos

- macOS 14.0+
- Swift 5.9+

## Licencia

MIT
