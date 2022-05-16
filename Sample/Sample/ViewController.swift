//
//  ViewController.swift
//  ViewController
//
//  Created by Metaplex Studios on 5/16/22.
//

import UIKit
import Metaplex
import Solana

public class AppStorageDriver: StorageDriver { }

class ViewController: UIViewController {
    
    lazy var metaplex: Metaplex = {
        let solana = SolanaConnectionDriver(endpoint: RPCEndpoint.mainnetBetaSolana)
        return Metaplex(connection: solana, identityDriver: GuestIdentityDriver(solanaRPC: solana.solanaRPC), storageDriver: AppStorageDriver())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metaplex.nft.findNftsByOwner(publicKey: PublicKey(string: "CN87nZuhnFdz74S9zn3bxCcd5ZxW55nwvgAv5C2Tz3K7")!) { result in
            
        }
        
        // Do any additional setup after loading the view.
    }
    
}

