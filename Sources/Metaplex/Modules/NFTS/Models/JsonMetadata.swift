//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 5/18/22.
//

import Foundation

public struct JsonMetadata: Decodable {
    let name: String?
    let symbol: String?
    let description: String?
    let seller_fee_basis_points: Double?
    let image: String?
    let external_url: String?
    let attributes: [JsonMetadataAttribute]?
    let properties: JsonMetadataProperties?
}

public struct JsonMetadataProperties: Decodable {
    let creators: [JsonMetadataCreator]?
    let files: [JsonMetadataFile]?
}

enum Value: Equatable {
    case number(Double)
    case string(String)
    case unkown
}

public struct JsonMetadataAttribute: Decodable {
    let display_type: String?
    let trait_type: String?
    let value: Value?
    
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
    let address: String?
    let share: Double?
}

public struct JsonMetadataFile: Decodable {
    let type: String
    let uri: String?
}
