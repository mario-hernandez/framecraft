# CLAUDE.md - Instrucciones para Claude Code

## Descripcion del proyecto

FrameCraft es una herramienta para generar frames de App Store con textos hero y fondos de gradiente. Ofrece tanto GUI (SwiftUI) como servidor MCP para automatizacion con Claude Code.

## Comandos de desarrollo

```bash
# Compilar todo
swift build

# Compilar release
swift build -c release

# Ejecutar GUI
swift run FrameCraft

# Ejecutar servidor MCP (para pruebas manuales)
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | swift run framecraft-mcp

# Limpiar build
rm -rf .build
```

## Arquitectura

### FrameCraftCore (biblioteca compartida)
- `Models.swift` - GradientTemplate, DeviceSize, extension NSColor
- `FrameGenerator.swift` - Logica de renderizado Core Graphics
- Sin dependencia de SwiftUI

### FrameCraftCLI (servidor MCP)
- `main.swift` - Loop stdin/stdout
- `MCPServer.swift` - Handler JSON-RPC + tools
- `MCPProtocol.swift` - Tipos legacy (puede eliminarse)

### HeroGenerator (GUI macOS)
- `ContentView.swift` - HSplitView principal
- `AppState.swift` - Estado observable
- `ControlPanel.swift` - Panel de controles
- `FramePreview.swift` - Vista previa escalada
- `Models.swift` - Extensions SwiftUI

## Herramientas MCP

| Tool | Descripcion |
|------|-------------|
| `generate_frame` | Genera un frame individual |
| `list_templates` | Lista plantillas disponibles |
| `generate_batch` | Genera multiples frames |

## Plantillas disponibles

ocean, sunset, forest, midnight, berry, coral, mint, slate, dawn, sand

## Problemas conocidos

### Texto cortado en frames
El layout actual puede cortar subtitulos largos cuando:
- Hero text tiene multiples lineas
- Subtitle es largo
- Ambos juntos exceden 22% del alto

**Solucion pendiente**: Ajustar zona de texto o reducir screenshot.

## Tests MCP

```bash
# Probar initialize
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | .build/debug/framecraft-mcp

# Probar list_templates
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"list_templates","arguments":{}}}' | .build/debug/framecraft-mcp
```

## GitHub

- Repo: mario-hernandez/framecraft (privado)
- Branch: main
