//
//  NFTCollectionViewCell.swift
//  Sample
//
//  Created by Arturo Jamaica on 5/18/22.
//

import UIKit
import Metaplex
import Kingfisher

class NFTCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mintLabel: UILabel!
    
    func setMetadata(_ metadata: JsonMetadata){
        let screenRect = UIScreen.main.bounds
        let width  = (screenRect.width - 20) / 2
        let size = CGSize(width: width, height: 220)
        thumbnailImageView.kf.setImage(with: URL(string: metadata.image!),
                                       options: [
                                        .processor(DownsamplingImageProcessor(size: size)),
                                        .scaleFactor(UIScreen.main.scale),
                                        .cacheOriginalImage
                                       ])
    }
}
