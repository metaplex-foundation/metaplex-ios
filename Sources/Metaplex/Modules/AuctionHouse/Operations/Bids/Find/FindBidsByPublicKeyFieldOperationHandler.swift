//
//  FindBidsByPublicKeyFieldOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/29/22.
//

import AuctionHouse
import Foundation
import Solana

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
                var query = accounts.whereAuctionHouse(address: address.publicKey)
                switch input.type {
                case .buyer(let address):
                    query = query.whereBuyer(address: address)
                case .metadata(let address):
                    query = query.whereMetadata(address: address)
                case .mint(let mintKey):
                    guard let address = try? MetadataAccount.pda(mintKey: mintKey).get() else { return .failure(OperationError.couldNotFindPDA) }
                    query = query.whereMetadata(address: address)
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
