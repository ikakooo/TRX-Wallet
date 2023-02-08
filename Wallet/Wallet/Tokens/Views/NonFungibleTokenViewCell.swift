// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

class NonFungibleTokenViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var annotationTextLabel: UILabel!
    @IBOutlet weak var nameTextLabel: UILabel!

    func configure(viewModel: NonFungibleTokenCellViewModel) {
        tokenImageView.kf.setImage(
            with: viewModel.imagePath,
            placeholder: Image(systemName: "plus")
        )
        nameTextLabel.text = viewModel.name
        annotationTextLabel.text = viewModel.annotation
    }
}
