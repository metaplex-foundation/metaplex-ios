//
//  ViewController.swift
//  ViewController
//
//  Created by Metaplex Studios on 5/16/22.
//

import UIKit
import Metaplex
import Solana

class ViewController: UIViewController {
    
    lazy var metaplex: Metaplex = {
        let solana = SolanaConnectionDriver(endpoint: RPCEndpoint.mainnetBetaSolana)
        return Metaplex(connection: solana, identityDriver: GuestIdentityDriver(solanaRPC: solana.solanaRPC), storageDriver: MemoryStorageDriver())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}

