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

    func setFeePayer(_ feePayer: Account) {
        self.feePayer = feePayer
    }

    // MARK: - Instructions

    func add(_ instruction: InstructionWithSigner) -> TransactionBuilder {
        instructions.append(instruction)
        return self
    }

    func when(_ condition: Bool, instruction: InstructionWithSigner?) -> TransactionBuilder {
        if condition, let instruction {
            return add(instruction)
        }
        return self
    }

    // MARK: - Send and Confirm

    func sendAndConfirm(metaplex: Metaplex, onComplete: @escaping (Result<SignatureStatus?, Error>) -> Void) {
        metaplex.connection.serializeTransaction(instructions: getInstructions(), recentBlockhash: nil, signers: getSigners()) { result in
            switch result {
            case .success(let transactionId):
                metaplex.sendAndConfirmTransaction(serializedTransaction: transactionId, configs: nil, onComplete: onComplete)
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
}
