import Foundation

// MARK: - JSON-RPC Types

struct JSONRPCRequest: Codable {
    let jsonrpc: String
    let id: RequestId?
    let method: String
    let params: AnyCodable?

    init(jsonrpc: String = "2.0", id: RequestId? = nil, method: String, params: AnyCodable? = nil) {
        self.jsonrpc = jsonrpc
        self.id = id
        self.method = method
        self.params = params
    }
}

struct JSONRPCResponse: Codable {
    let jsonrpc: String
    let id: RequestId?
    let result: AnyCodable?
    let error: JSONRPCError?

    init(id: RequestId?, result: AnyCodable? = nil, error: JSONRPCError? = nil) {
        self.jsonrpc = "2.0"
        self.id = id
        self.result = result
        self.error = error
    }

    static func success(id: RequestId?, result: Any) -> JSONRPCResponse {
        JSONRPCResponse(id: id, result: AnyCodable(result))
    }

    static func error(id: RequestId?, code: Int, message: String) -> JSONRPCResponse {
        JSONRPCResponse(id: id, error: JSONRPCError(code: code, message: message))
    }
}

struct JSONRPCError: Codable {
    let code: Int
    let message: String
    let data: AnyCodable?

    init(code: Int, message: String, data: AnyCodable? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}

enum RequestId: Codable, Equatable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid request ID")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
}

// MARK: - AnyCodable for dynamic JSON

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported type")
            throw EncodingError.invalidValue(value, context)
        }
    }

    func asDictionary() -> [String: Any]? {
        value as? [String: Any]
    }

    func asString() -> String? {
        value as? String
    }

    func asArray() -> [Any]? {
        value as? [Any]
    }
}

// MARK: - MCP Types

struct MCPServerInfo: Codable {
    let name: String
    let version: String
}

struct MCPCapabilities: Codable {
    let tools: [String: AnyCodable]?

    init(tools: [String: Any]? = nil) {
        self.tools = tools?.mapValues { AnyCodable($0) }
    }
}

struct MCPInitializeResult: Codable {
    let protocolVersion: String
    let serverInfo: MCPServerInfo
    let capabilities: MCPCapabilities
}

struct MCPTool: Codable {
    let name: String
    let description: String
    let inputSchema: [String: AnyCodable]

    init(name: String, description: String, inputSchema: [String: Any]) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema.mapValues { AnyCodable($0) }
    }
}

struct MCPToolsListResult: Codable {
    let tools: [MCPTool]
}

struct MCPToolCallParams: Codable {
    let name: String
    let arguments: [String: AnyCodable]?
}

struct MCPToolResult: Codable {
    let content: [MCPContent]
    let isError: Bool?
}

struct MCPContent: Codable {
    let type: String
    let text: String
}
