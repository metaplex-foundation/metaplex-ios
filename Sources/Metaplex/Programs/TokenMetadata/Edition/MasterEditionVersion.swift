//
//  MasterEditionVersion.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation

public enum MasterEditionVersion: Codable {
    case masterEditionV1(MasterEditionV1)
    case masterEditionV2(MasterEditionV2)
}
