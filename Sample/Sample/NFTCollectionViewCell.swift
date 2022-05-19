//
//  NFTCollectionViewCell.swift
//  Sample
//
//  Created by Arturo Jamaica on 5/18/22.
//

import UIKit
import Metaplex

class NFTCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mintLabel: UILabel!
    
    func setMetadata(_ metadata: JsonMetadata){
        
    }
}
