//
//  InstructionBuilder+CreateNft.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation
import Solana

extension InstructionBuilder {
    func createNftInstructions(
        input: CreateNftInput,
        onComplete: @escaping (Result<[TransactionInstruction], Error>) -> Void
    ) {
        metaplex.connection.getCreatingTokenAccountFee { result in
            switch result {
            case .success(let lamports):
                let transactions = buildCreateNftInstructions(for: input, with: lamports)
                onComplete(.success(transactions))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }

    private func buildCreateNftInstructions(for input: CreateNftInput, with lamports: UInt64) -> [TransactionInstruction] {
        var instructions = [TransactionInstruction]()

        let mint = input.mintAccountState.account.publicKey

        switch input.mintAccountState {
        case .new:
            let createInstruction = SystemProgram.createAccountInstruction(
                from: metaplex.identity().publicKey,
                toNewPubkey: mint,
                lamports: lamports,
                space: MINT_SIZE
            )
            instructions.append(createInstruction)

            let initMintInstruction = TokenProgram.initializeMintInstruction(
                tokenProgramId: PublicKey.tokenProgramId,
                mint: mint,
                decimals: 0,
                authority: metaplex.identity().publicKey,
                freezeAuthority: metaplex.identity().publicKey
            )
            instructions.append(initMintInstruction)

        case .existing:
            break
        }

        if case let .success(associatedAccount) = PublicKey.associatedTokenAddress(
            walletAddress: metaplex.identity().publicKey,
            tokenMintAddress: mint
        ) {
            let associatedInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                mint: mint,
                associatedAccount: associatedAccount,
                owner: metaplex.identity().publicKey,
                payer: metaplex.identity().publicKey
            )
            instructions.append(associatedInstruction)

            let toMintInstruction = TokenProgram.mintToInstruction(
                tokenProgramId: MetaplexTokenProgram.publicKey,
                mint: mint,
                destination: associatedAccount,
                authority: metaplex.identity().publicKey,
                amount: 1
            )
            instructions.append(toMintInstruction)
        }

        let metadata = try! MetadataAccount.pda(mintKey: mint).get()
        let nftData = MetaplexDataV2(
            name: input.name,
            symbol: input.symbol ?? "",
            uri: input.uri,
            sellerFeeBasisPoints: input.sellerFeeBasisPoints,
            hasCreators: input.hasCreators,
            addressCount: input.addressCount,
            creators: input.creators,
            collection: input.collection,
            uses: input.uses
        )
        let metadataInstruction = CreateMetadataAccountV3.createMetadataAccountV3Instruction(
            accounts: .init(
                metadata: metadata,
                mint: mint,
                mintAuthority: metaplex.identity().publicKey,
                payer: metaplex.identity().publicKey,
                updateAuthority: metaplex.identity().publicKey,
                systemProgram: nil,
                rent: nil
            ),
            arguments: .init(
                data: nftData,
                isMutable: input.isMutable,
                collectionDetails: nil
            )
        )
        instructions.append(metadataInstruction)

        // NOTE: Need to verify creators

        let edition = try! MasterEditionAccount.pda(mintKey: mint).get()
        let masterEditionInstruction = CreateMasterEditionV3.createMasterEditionV3(
            accounts: .init(
                edition: edition,
                mint: mint,
                updateAuthority: metaplex.identity().publicKey,
                mintAuthority: metaplex.identity().publicKey,
                payer: metaplex.identity().publicKey,
                metadata: metadata,
                tokenProgram: nil,
                systemProgram: nil,
                rent: nil
            ),
            arguments: .init(maxSupply: 1)
        )
        instructions.append(masterEditionInstruction)

        // NOTE: Need to verify collection

        return instructions
    }
}
