//
//  FavoriteCollectionViewCell.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 12/12/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

import UIKit
import Kingfisher

class FavoriteCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var moviePosterImageView: UIImageView!
  
  func setPoster(_ posterUrl: String) {
    let url = URL(string: posterUrl)
    
    let processor = RoundCornerImageProcessor(cornerRadius: 4) >>  ResizingImageProcessor(referenceSize: CGSize(width: 150, height: 200))
    moviePosterImageView.kf.setImage(with: url, options: [.processor(processor)])
  }
  
}
