//
//  OperationHandler.swift
//  
//
//  Created by Arturo Jamaica on 4/11/22.
//

import Foundation

public enum OperationError: Error {
    case nilDataOnAccount
    case nilSignatureStatus
    case couldNotFindPDA
    case gmaBuilderError(Error)
    case getAccountInfoError(Error)
    case getMasterEditionAccountInfoError(Error)
    case getMetadataAccountInfoError(Error)
    case getFindNftsByCreatorOperation(Error)
    case getFindNftsByOwnerOperation(Error)
    case buildInstructionsError(Error)
    case serializeTransactionError(Error)
    case sendTransactionError(Error)
    case confirmTransactionError(Error)
    case findAuctionHouseByAddressError(Error)
    case findAuctionHouseByCreatorAndMintError(Error)
    case findBidByReceiptError(Error)
    case findBidByTradeStateError(Error)
    case findListingByReceiptError(Error)
    case findPurchaseByReceiptError(Error)
    case createExecuteSaleError(ExecuteSaleError)

    case couldNotFindAuctionHouse
    case couldNotFindBuyerTradeStatePda
    case couldNotFindSellerTradeStatePda
    case couldNotFindFreeTradeStatePda
    case couldNotFindProgramAsSignerPda
    case couldNotFindMetadata
    case couldNotFindTokenAccount
    case couldNotFindAuctionHouseFeePda
    case couldNotFindAuctionHouseTreasuryPda
    case couldNotFindTreasuryWithdrawalDestination
    case couldNotFindEscrowPaymentAccount
    case couldNotFindPaymentAccount
    case couldNotFindBuyerTokenAccount
    case couldNotFindBuyerReceiptAccount
    case couldNotFindSellerReceiptAccount
}

protocol OperationHandler {
    associatedtype I
    associatedtype O

    var metaplex: Metaplex { get }
    func handle(operation: OperationResult<I, OperationError>) -> OperationResult<O, OperationError>
}
