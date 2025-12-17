import Foundation
import FrameCraftCore

// MARK: - MCP Server

class MCPServer {
    private let generator = FrameGenerator()

    init() {}

    // MARK: - Tool Definitions

    private var toolsJSON: [[String: Any]] {
        [
            [
                "name": "generate_frame",
                "description": "Generate an App Store screenshot frame with hero text and gradient background. Returns the path to the generated file.",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "screenshot_path": [
                            "type": "string",
                            "description": "Absolute path to the screenshot PNG/JPG file"
                        ],
                        "hero_text": [
                            "type": "string",
                            "description": "Main headline text displayed above the screenshot"
                        ],
                        "subtitle": [
                            "type": "string",
                            "description": "Optional subtitle text below the hero text"
                        ],
                        "template": [
                            "type": "string",
                            "enum": GradientTemplate.allTemplates.map { $0.id },
                            "description": "Gradient template ID: ocean, sunset, forest, midnight, berry, coral, mint, slate, dawn, sand"
                        ],
                        "device": [
                            "type": "string",
                            "enum": DeviceSize.allSizes.map { $0.id },
                            "default": "iphone_6.7",
                            "description": "Device size: iphone_6.7, iphone_6.5, iphone_5.5, ipad_12.9, ipad_13, macbook_pro_16"
                        ],
                        "output_path": [
                            "type": "string",
                            "description": "Output path for the generated frame (must end in .png)"
                        ]
                    ],
                    "required": ["screenshot_path", "hero_text", "template", "output_path"]
                ]
            ],
            [
                "name": "list_templates",
                "description": "List all available gradient templates with their colors",
                "inputSchema": [
                    "type": "object",
                    "properties": [:] as [String: Any],
                    "required": [] as [String]
                ]
            ],
            [
                "name": "list_devices",
                "description": "List all available device sizes for frame generation",
                "inputSchema": [
                    "type": "object",
                    "properties": [:] as [String: Any],
                    "required": [] as [String]
                ]
            ],
            [
                "name": "generate_batch",
                "description": "Generate multiple frames at once. Each frame requires screenshot_path, hero_text, template, and output_path.",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "frames": [
                            "type": "array",
                            "description": "Array of frames to generate",
                            "items": [
                                "type": "object",
                                "properties": [
                                    "screenshot_path": ["type": "string"],
                                    "hero_text": ["type": "string"],
                                    "subtitle": ["type": "string"],
                                    "template": ["type": "string"],
                                    "output_path": ["type": "string"]
                                ],
                                "required": ["screenshot_path", "hero_text", "template", "output_path"]
                            ]
                        ],
                        "device": [
                            "type": "string",
                            "default": "iphone_6.7",
                            "description": "Device size for all frames"
                        ]
                    ],
                    "required": ["frames"]
                ]
            ]
        ]
    }

    // MARK: - Handle Request

    func handleRequest(_ data: Data) -> Data? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let method = json["method"] as? String else {
                return errorResponse(id: nil, code: -32600, message: "Invalid request")
            }

            let id = json["id"]
            let params = json["params"] as? [String: Any]

            let result = processMethod(method: method, params: params, id: id)
            return result
        } catch {
            return errorResponse(id: nil, code: -32700, message: "Parse error: \(error.localizedDescription)")
        }
    }

    private func processMethod(method: String, params: [String: Any]?, id: Any?) -> Data? {
        switch method {

        case "initialize":
            let result: [String: Any] = [
                "protocolVersion": "2024-11-05",
                "serverInfo": [
                    "name": "framecraft-mcp",
                    "version": "1.1.0"
                ],
                "capabilities": [
                    "tools": [:]
                ]
            ]
            return successResponse(id: id, result: result)

        case "notifications/initialized":
            return successResponse(id: id, result: ["ok": true])

        case "tools/list":
            let result: [String: Any] = [
                "tools": toolsJSON
            ]
            return successResponse(id: id, result: result)

        case "tools/call":
            return handleToolCall(params: params, id: id)

        default:
            return errorResponse(id: id, code: -32601, message: "Method not found: \(method)")
        }
    }

    // MARK: - Tool Calls

    private func handleToolCall(params: [String: Any]?, id: Any?) -> Data? {
        guard let params = params,
              let toolName = params["name"] as? String else {
            return errorResponse(id: id, code: -32602, message: "Invalid params: missing tool name")
        }

        let arguments = (params["arguments"] as? [String: Any]) ?? [:]

        do {
            var resultText: String

            switch toolName {
            case "generate_frame":
                resultText = try handleGenerateFrame(arguments)

            case "list_templates":
                resultText = handleListTemplates()

            case "list_devices":
                resultText = handleListDevices()

            case "generate_batch":
                resultText = try handleGenerateBatch(arguments)

            default:
                return errorResponse(id: id, code: -32602, message: "Unknown tool: \(toolName)")
            }

            let result: [String: Any] = [
                "content": [
                    ["type": "text", "text": resultText]
                ]
            ]
            return successResponse(id: id, result: result)

        } catch {
            let result: [String: Any] = [
                "content": [
                    ["type": "text", "text": "Error: \(error.localizedDescription)"]
                ],
                "isError": true
            ]
            return successResponse(id: id, result: result)
        }
    }

    // MARK: - Tool Implementations

    private func handleGenerateFrame(_ args: [String: Any]) throws -> String {
        guard let screenshotPath = args["screenshot_path"] as? String else {
            throw FrameGeneratorError.screenshotNotFound("missing screenshot_path")
        }
        guard let heroText = args["hero_text"] as? String else {
            throw FrameGeneratorError.renderingFailed
        }
        guard let template = args["template"] as? String else {
            throw FrameGeneratorError.templateNotFound("missing template")
        }
        guard let outputPath = args["output_path"] as? String else {
            throw FrameGeneratorError.saveFailed("missing output_path")
        }

        let subtitle = args["subtitle"] as? String
        let device = (args["device"] as? String) ?? "iphone_6.7"

        try generator.generateFrame(
            screenshotPath: screenshotPath,
            heroText: heroText,
            subtitle: subtitle,
            templateId: template,
            deviceId: device,
            outputPath: outputPath
        )

        return "Frame generated successfully at: \(outputPath)"
    }

    private func handleListTemplates() -> String {
        let templates = generator.listTemplates()
        let lines = templates.map { t in
            "- \(t["id"] ?? ""): \(t["name"] ?? "") (\(t["topColor"] ?? "") → \(t["bottomColor"] ?? ""))"
        }
        return "Available templates:\n\(lines.joined(separator: "\n"))"
    }

    private func handleListDevices() -> String {
        let lines = DeviceSize.allSizes.map { d in
            "- \(d.id): \(d.name)"
        }
        return "Available devices:\n\(lines.joined(separator: "\n"))"
    }

    private func handleGenerateBatch(_ args: [String: Any]) throws -> String {
        guard let framesArray = args["frames"] as? [[String: Any]] else {
            throw FrameGeneratorError.renderingFailed
        }

        let device = (args["device"] as? String) ?? "iphone_6.7"

        var frames: [[String: String]] = []
        for frame in framesArray {
            var f: [String: String] = [:]
            if let v = frame["screenshot_path"] as? String { f["screenshot_path"] = v }
            if let v = frame["hero_text"] as? String { f["hero_text"] = v }
            if let v = frame["subtitle"] as? String { f["subtitle"] = v }
            if let v = frame["template"] as? String { f["template"] = v }
            if let v = frame["output_path"] as? String { f["output_path"] = v }
            frames.append(f)
        }

        let outputPaths = try generator.generateBatch(frames: frames, deviceId: device)

        return "Generated \(outputPaths.count) frames:\n\(outputPaths.joined(separator: "\n"))"
    }

    // MARK: - Response Helpers

    private func successResponse(id: Any?, result: Any) -> Data? {
        var response: [String: Any] = [
            "jsonrpc": "2.0",
            "result": result
        ]
        if let id = id {
            response["id"] = id
        }
        return try? JSONSerialization.data(withJSONObject: response)
    }

    private func errorResponse(id: Any?, code: Int, message: String) -> Data? {
        var response: [String: Any] = [
            "jsonrpc": "2.0",
            "error": [
                "code": code,
                "message": message
            ]
        ]
        if let id = id {
            response["id"] = id
        }
        return try? JSONSerialization.data(withJSONObject: response)
    }
}
