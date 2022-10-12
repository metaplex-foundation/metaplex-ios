//
//  FindBidsByPublicKeyFieldOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/29/22.
//

import AuctionHouse
import Foundation
import Solana

struct FindBidsByPublicKeyFieldInput {
    enum Field {
        case buyer, metadata, mint
    }

    let field: Field
    let auctionHouse: Auctionhouse
    let publicKey: PublicKey
}

typealias FindBidsByPublicKeyFieldOperation = OperationResult<FindBidsByPublicKeyFieldInput, OperationError>

class FindBidsByPublicKeyFieldOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = FindBidsByPublicKeyFieldInput
    typealias O = [Bidreceipt]

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindBidsByPublicKeyFieldOperation) -> OperationResult<[Bidreceipt], OperationError> {
        operation.flatMap { input in
            OperationResult.pure(
                Auctionhouse.pda(
                    creator: input.auctionHouse.creator,
                    treasuryMint: input.auctionHouse.treasuryMint
                )
            ).flatMap { address in
                let accounts = AuctionHouseProgram.bidAccounts(connection: self.metaplex.connection)
                var query = accounts.whereAuctionHouse(address: address)
                switch input.field {
                case .buyer:
                    query = query.whereBuyer(address: input.publicKey)
                case .metadata:
                    query = query.whereBuyer(address: input.publicKey)
                case .mint:
                    query = query.whereBuyer(address: input.publicKey)
                }
                return query.getAndMap { (accounts: [AccountInfoWithPureData]) in
                    accounts.compactMap { (accountInfo: AccountInfoWithPureData) -> Bidreceipt? in
                        guard let data = accountInfo.account.data?.value else {
                            return nil
                        }
                        return Bidreceipt.fromAccountInfo(accountInfo: data).0
                    }
                }
            }.mapError { OperationError.findAuctionHouseByCreatorAndMintError($0) }
        }
    }
}
