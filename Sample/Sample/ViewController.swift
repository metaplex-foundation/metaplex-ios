//
//  ViewController.swift
//  ViewController
//
//  Created by Metaplex Studios on 5/16/22.
//

import UIKit
import Metaplex
import Solana

let NFTCollectionViewCellId = "NFTCollectionViewCell"
class ViewController: UIViewController {
    
    private let ownerPublicKey = PublicKey(string: "CN87nZuhnFdz74S9zn3bxCcd5ZxW55nwvgAv5C2Tz3K7")!
    
    private var nftList:[NFT] = []
        
    lazy var metaplex: Metaplex = {
        let solana = SolanaConnectionDriver(endpoint: RPCEndpoint.mainnetBetaSolana)
        return Metaplex(connection: solana, identityDriver: GuestIdentityDriver(solanaRPC: solana.solanaRPC), storageDriver: URLSharedStorageDriver(urlSession: URLSession.shared))
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         * I dont recomend calling this like this. Its mixing UI and Business logic.
         * This is an example and it try to over simplifiend the arquitecture.
         */
        metaplex.nft.findNftsByOwner(publicKey: ownerPublicKey) { [weak self] result in
            switch result {
            case .success(let nftList):
                self?.nftList = nftList.compactMap{ $0 }
                self?.collectionView.reloadData()
            case .failure:
                break
            }
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.nftList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTCollectionViewCellId, for: indexPath)
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width  = (view.frame.width - 20) / 2
            return CGSize(width: width, height: 220)
    }
}

