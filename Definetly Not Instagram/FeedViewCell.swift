//
//  FeedViewCell.swift
//  Definetly Not Instagram
//
//  Created by Zapad on 03/05/2019.
//  Copyright © 2019 FMI. All rights reserved.
//

import UIKit
import SDWebImage

protocol ProfileHandler {
    func openProfile(cell: UICollectionViewCell)
}

class FeedViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        avatarImage.clipsToBounds = true
        image.contentMode = UIView.ContentMode.scaleAspectFit
        firstStackView.isUserInteractionEnabled = true
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onProfileTap))
        
        firstStackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onProfileTap(sender: Any) {
        print("Let's see that profile")
        delegate?.openProfile(cell: self)
    }
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var avatarName: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstStackView: UIStackView!
    var tapGestureRecognizer: UITapGestureRecognizer!
    var delegate: ProfileHandler?
    
    var imageDimensions:CGSize = .zero {
        didSet {
            let imageWidth = UIScreen.main.bounds.width
            let scaleRatio = imageDimensions.width/imageWidth
            let scaledHeight = imageDimensions.height/scaleRatio
            imageWidthConstraint.constant = imageWidth
            imageHeightConstraint.constant = scaledHeight
        }
    }

}
