//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 5/18/22.
//

import Foundation

public struct JsonMetadata: Decodable {
    public let name: String?
    public let symbol: String?
    public let description: String?
    public let seller_fee_basis_points: Double?
    public let image: String?
    public let external_url: String?
    public let attributes: [JsonMetadataAttribute]?
    public let properties: JsonMetadataProperties?
}

public struct JsonMetadataProperties: Decodable {
    public let creators: [JsonMetadataCreator]?
    public let files: [JsonMetadataFile]?
}

enum Value: Equatable {
    case number(Double)
    case string(String)
    case unkown
}

public struct JsonMetadataAttribute: Decodable {
    public let display_type: String?
    public let trait_type: String?
    public let value: Value?
    
    private enum CodingKeys: String, CodingKey {
        case display_type
        case trait_type
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        display_type = try container.decodeIfPresent(String.self, forKey: .display_type)
        trait_type = try container.decodeIfPresent(String.self, forKey: .trait_type)
        if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = .string(stringValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: .value){
            value = .number(doubleValue)
        } else {
            value = .unkown
        }
    }
}

public struct JsonMetadataCreator: Decodable {
    public let address: String?
    public let share: Double?
}

public struct JsonMetadataFile: Decodable {
    public let type: String
    public let uri: String?
}
