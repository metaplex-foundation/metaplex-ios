//
//  TransactionBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/4/22.
//

import Foundation
import Solana

class TransactionBuilder {
    struct InstructionWithSigner {
        let instruction: TransactionInstruction
        let signers: [Account]
        let key: String
    }

    private let delay: TimeInterval = 1
    private let attempts = 60

    private var feePayer: Account?
    private var instructions: [InstructionWithSigner] = []

    // MARK: Initialization

    init(feePayer: Account? = nil, instructions: [InstructionWithSigner] = []) {
        self.feePayer = feePayer
        self.instructions = instructions
    }

    static func build(feePayer: Account? = nil, instructions: [InstructionWithSigner] = []) -> TransactionBuilder {
        TransactionBuilder(feePayer: feePayer)
    }

    // MARK: - Fee Payer

    func setFeePayer(_ feePayer: Account) -> TransactionBuilder {
        self.feePayer = feePayer
        return self
    }

    // MARK: - Instructions

    func add(_ instruction: InstructionWithSigner) -> TransactionBuilder {
        instructions.append(instruction)
        return self
    }

    func add(_ builder: TransactionBuilder) -> TransactionBuilder {
        instructions.append(contentsOf: builder.instructions)
        return self
    }

    func when(_ condition: Bool, instruction: InstructionWithSigner?) -> TransactionBuilder {
        if condition, let instruction {
            return add(instruction)
        }
        return self
    }

    // MARK: - Send and Confirm

    func sendAndConfirm(metaplex: Metaplex, onComplete: @escaping (Result<SignatureStatus, Error>) -> Void) {
        metaplex.connection.serializeTransaction(
            instructions: getInstructions(),
            recentBlockhash: nil,
            signers: getSigners().isEmpty ? [metaplex.identity()] : getSigners()
        ) { result in
            switch result {
            case .success(let serializedTransaction):
                self.sendTransaction(metaplex: metaplex, serializedTransaction: serializedTransaction) { result in
                    switch result {
                    case .success(let signature):
                        self.confirmTransaction(metaplex: metaplex, signature: signature, onComplete: onComplete)
                    case .failure(let error):
                        onComplete(.failure(OperationError.sendTransactionError(error)))
                    }
                }
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }

    // MARK: - Private Methods

    private func getInstructions() -> [TransactionInstruction] {
        instructions.map { $0.instruction }
    }

    private func getSigners() -> [Account] {
        var signers = feePayer != nil ? [feePayer!] : []
        let additionalSigners = instructions.flatMap { $0.signers }
        signers.append(contentsOf: additionalSigners)
        return signers
    }

    private func sendTransaction(
        metaplex: Metaplex,
        serializedTransaction: String,
        onComplete: @escaping (Result<TransactionID, IdentityDriverError>) -> Void
    ) {
        let operation = {
            OperationResult<TransactionID, IdentityDriverError>.init { onComplete in
                metaplex.sendTransaction(serializedTransaction: serializedTransaction, onComplete: onComplete)
            }.mapError { Retry.retry($0) }
        }
        let retry = OperationResult<TransactionID, IdentityDriverError>.retry(
            with: delay,
            attempts: attempts,
            operation: operation
        ).mapError { IdentityDriverError.sendTransactionError($0) }
        retry.run(onComplete)
    }

    private func confirmTransaction(
        metaplex: Metaplex,
        signature: String,
        onComplete: @escaping (Result<SignatureStatus, Error>) -> Void
    ) {
        let operation = {
            OperationResult<SignatureStatus?, Error>.init { onComplete in
                metaplex.confirmTransaction(signature: signature, configs: nil, onComplete: onComplete)
            }.flatMap { (status: SignatureStatus?) -> OperationResult<SignatureStatus, Error> in
                guard let status, status.confirmationStatus == .finalized else {
                    return OperationResult.failure(OperationError.nilSignatureStatus)
                }
                return OperationResult.success(status)
            }.mapError { Retry.retry($0) }
        }
        let retry = OperationResult<SignatureStatus, Error>.retry(with: delay, attempts: attempts, operation: operation)
        retry.run(onComplete)
    }
}
