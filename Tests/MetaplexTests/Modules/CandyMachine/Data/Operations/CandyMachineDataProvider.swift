//
//  CandyMachineDataProvider.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/8/22.
//

import CandyMachine
import Foundation
import Solana

@testable import Metaplex

struct CandyMachineDataProvider {
    static func create(_ metaplex: Metaplex) -> CandyMachine? {
        var result: Result<CandyMachine, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CreateCandyMachineOperationHandler(metaplex: metaplex)
            operation.handle(
                operation: CreateCandyMachineOperation.pure(.success(
                    CreateCandyMachineInput(
                        candyMachineConfig: CandyMachineConfig(
                            price: 100,
                            sellerFeeBasisPoints: 500,
                            itemsAvailable: 100,
                            creatorState: .creator(metaplex.identity().publicKey)
                        )
                    )
                ))
            ).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func createTest(_ metaplex: Metaplex, candyMachine: CandyMachine) -> SignatureStatus? {
        var result: Result<SignatureStatus, Error>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let input = MintCandyMachineInput(candyMachine: candyMachine)
            let defaultIdentity = metaplex.identity()

            guard let candyMachineCreatorPda = try? Candymachine.pda(address: input.candyMachine.address).get()
            else { return }

            guard let metadata = try? MetadataAccount.pda(mintKey: input.newMint.publicKey).get()
            else { return }

            guard let masterEdition = try? MasterEditionAccount.pda(mintKey: input.mint).get()
            else { return }

            let owner = input.newOwner ?? defaultIdentity.publicKey
            guard let associatedAccount = PublicKey.findAssociatedTokenAccountPda(mint: input.mint, owner: owner)
            else { return }

            let parameters = MintCandyMachineBuilderParameters(
                mintCandyMachineInput: input,
                candyMachineCreatorPda: candyMachineCreatorPda,
                metadata: metadata,
                masterEdition: masterEdition,
                associatedAccount: associatedAccount,
                defaultIdentity: defaultIdentity
            )
            let tx = TransactionBuilder.createMintBuilder(parameters: parameters.createTokenWithMintParameters.createMintParameters)
            tx.sendAndConfirm(metaplex: metaplex) {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func mintCandyMachine(_ metaplex: Metaplex, candyMachine: CandyMachine) -> NFT? {
        var result: Result<NFT, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = MintCandyMachineOperationHandler(metaplex: metaplex)
            operation.handle(
                operation: MintCandyMachineOperation.pure(.success(MintCandyMachineInput(candyMachine: candyMachine)))
            ).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func findCandyMachineByAddress(_ metaplex: Metaplex, address: PublicKey) -> CandyMachine? {
        var result: Result<CandyMachine, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = FindCandyMachineByAddressOperationHandler(metaplex: metaplex)
            operation.handle(
                operation: FindCandyMachineByAddressOperation.pure(.success(address))
            ).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }
}
