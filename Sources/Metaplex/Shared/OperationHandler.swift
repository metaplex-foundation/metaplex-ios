//
//  OperationHandler.swift
//  
//
//  Created by Arturo Jamaica on 4/11/22.
//

import Foundation

public enum OperationError: Error {
    case nilDataOnAccount
    case couldNotFindPDA
    case gmaBuilderError(Error)
    case getMasterEditionAccountInfoError(Error)
    case getMetadataAccountInfoError(Error)
    case getFindNftsByCreatorOperation(Error)
    case getFindNftsByOwnerOperation(Error)
}

protocol OperationHandler {
    associatedtype I
    associatedtype O
    
    var metaplex: Metaplex { get }
    func handle(operation: OperationResult<I, OperationError>) -> OperationResult<O, OperationError>
}
