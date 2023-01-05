//
//  CandyMachineClient.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

public class CandyMachineClient {
    let metaplex: Metaplex

    public init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    // MARK: - Candy Machine

    public func create(
        candyMachine: Account = HotAccount()!,
        wallet: Account? = nil,
        payer: Account? = nil,
        authority: Account? = nil,
        collection: PublicKey? = nil,
        tokenMint: PublicKey? = nil,
        price: UInt64,
        sellerFeeBasisPoints: UInt16,
        itemsAvailable: UInt64,
        symbol: String = "",
        maxEditionSupply: UInt64 = 0,
        isMutable: Bool = true,
        retainAuthority: Bool = true,
        goLiveDate: Int64? = nil,
        endSettings: EndSettings? = nil,
        hiddenSettings: HiddenSettings? = nil,
        whitelistMintSettings: WhitelistMintSettings? = nil,
        gatekeeper: GatekeeperConfig? = nil,
        creatorState: CreatorState? = nil,
        onComplete: @escaping (Result<CandyMachine, OperationError>) -> Void
    ) {
        let operation = CreateCandyMachineOperationHandler(metaplex: metaplex)
        operation.handle(operation: CreateCandyMachineOperation.pure(.success(
            CreateCandyMachineInput(
                candyMachine: candyMachine,
                candyMachineConfig: CandyMachineConfig(
                    price: price,
                    sellerFeeBasisPoints: sellerFeeBasisPoints,
                    itemsAvailable: itemsAvailable,
                    creatorState: creatorState ?? .creator(metaplex.identity().publicKey)
                )
            )
        ))).run { onComplete($0) }
    }

    public func mint(
        candyMachine: CandyMachine,
        payer: Account? = nil,
        newMint: Account = HotAccount()!,
        newOwner: PublicKey? = nil,
        newToken: PublicKey? = nil,
        payerToken: PublicKey? = nil,
        whitelistToken: PublicKey? = nil,
        onComplete: @escaping (Result<NFT, OperationError>) -> Void
    ) {
        let operation = MintCandyMachineOperationHandler(metaplex: metaplex)
        operation.handle(operation: MintCandyMachineOperation.pure(.success(
            MintCandyMachineInput(
                candyMachine: candyMachine,
                payer: payer,
                newMint: newMint,
                newOwner: newOwner,
                newToken: newToken,
                payerToken: payerToken,
                whitelistToken: whitelistToken
            )
        ))).run { onComplete($0) }
    }

    public func findByAddress(
        _ address: PublicKey,
        onComplete: @escaping (Result<CandyMachine, OperationError>) -> Void
    ) {
        let operation = FindCandyMachineByAddressOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindCandyMachineByAddressOperation.pure(.success(address))).run { onComplete($0) }
    }
}
