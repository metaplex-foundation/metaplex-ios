//
//  CreateNftOnChainOperationHandler.swift
//
//
//  Created by Michael J. Huber Jr. on 9/2/22.
//

import Foundation
import Solana

public enum AccountState {
    case new(Account)
    case existing(Account)

    var account: Account {
        switch self {
        case .new(let account):
            return account
        case .existing(let account):
            return account
        }
    }
}

struct CreateNftInput {
    let mintAccountState: AccountState
    let account: Account
    let name: String
    let symbol: String?
    let uri: String
    let sellerFeeBasisPoints: UInt16
    let hasCreators: Bool
    let addressCount: UInt32
    let creators: [MetaplexCreator]
    let collection: MetaplexCollection? = nil
    let uses: MetaplexUses? = nil
    let isMutable: Bool
}

typealias CreateNftOperation = OperationResult<CreateNftInput, OperationError>

class CreateNftOnChainOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = CreateNftInput
    typealias O = NFT

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: CreateNftOperation) -> OperationResult<NFT, OperationError> {
        let builder = InstructionBuilder(metaplex: metaplex)
        return operation.flatMap { input in
            OperationResult<[TransactionInstruction], Error>.init { callback in
                builder.createNftInstructions(input: input) {
                    callback($0)
                }
            }.mapError {
                OperationError.buildInstructionsError($0)
            }.flatMap { instructions in
                OperationResult<String, Error>.init { callback in
                    self.metaplex.connection.serializeTransaction(instructions: instructions, recentBlockhash: nil, signers: [input.account, input.mintAccountState.account]) {
                        callback($0)
                    }
                }
                .mapError { OperationError.serializeTransactionError($0) }
            }.flatMap { serializedTransaction in
                OperationResult<TransactionID, IdentityDriverError>.init { callback in
                    self.metaplex.sendTransaction(serializedTransaction: serializedTransaction) {
                        callback($0)
                    }
                }
                .mapError { OperationError.sendTransactionError($0) }
            }.flatMap { signature in
                let operation: () -> OperationResult<SignatureStatus, Retry<Error>> = {
                    OperationResult<SignatureStatus, Error>.init { callback in
                        sleep(3)
                        self.metaplex.confirmTransaction(
                            signature: signature,
                            configs: nil
                        ) { result in
                            switch result {
                            case .success(let signature):
                                guard let signature = signature, let status = signature.confirmationStatus, status == .finalized else {
                                    callback(.failure(OperationError.nilSignatureStatus))
                                    return
                                }
                                callback(.success(signature))
                            case .failure(let error):
                                callback(.failure(error))
                            }
                        }
                    }
                    .mapError { Retry.retry($0) }
                }
                let retry = OperationResult<SignatureStatus, Error>.retry(attempts: 5, operation: operation)
                    .mapError { OperationError.confirmTransactionError($0) }
                return retry
            }.flatMap { (status: SignatureStatus) -> OperationResult<NFT, OperationError> in
                let findNft = FindNftByMintOnChainOperationHandler(metaplex: self.metaplex)
                return findNft.handle(operation: FindNftByMintOperation.pure(.success(input.mintAccountState.account.publicKey)))
            }
        }
    }
}
