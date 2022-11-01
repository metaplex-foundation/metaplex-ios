//
//  GpaBuildersTests.swift
//  
//
//  Created by Arturo Jamaica on 4/22/22.
//

import Foundation
import XCTest
import Solana
@testable import Metaplex

final class GpaBuildersTests: XCTestCase {
    func testDataSizeSerialization() {
        let requestDataSize = RequestDataSizeFilter(dataSize: 66)
        XCTAssertEqual(requestDataSize.jsonString, "66")
    }
}

extension Encodable {
    var jsonString: String? {
        guard let data = try? JSONEncoder().encode(self) else {return nil}
        return String(data: data, encoding: .utf8)
    }
}
