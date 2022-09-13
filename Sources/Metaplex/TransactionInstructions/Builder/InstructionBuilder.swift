//
//  InstructionBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation
import Solana

struct InstructionBuilder {
    let metaplex: Metaplex

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }
}
