//
//  GpaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/18/22.
//

import Foundation
import Solana

protocol GpaBuilder {
    var connection: Connection { get }
    var programId: PublicKey { get }
    var config: RequestConfiguration? { get }
}
