//
//  PostCell.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/3/22.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {

    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    private var imageDataRequest: DataRequest?

    func configure(with post: Post) {

        // Show username
        usernameLabel.text = post.user?.username

        // Show caption
        captionLabel.text = post.caption

        // Show date
        if let date = post.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: date)
        }

        // Load post image
        if let imageURL = post.imageFile?.url {

            imageDataRequest = AF.request(imageURL).responseImage { [weak self] response in

                switch response.result {

                case .success(let image):
                    self?.postImageView.image = image

                case .failure(let error):
                    print("❌ Error loading image: \(error)")
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Cancel old image download
        imageDataRequest?.cancel()
        imageDataRequest = nil

        postImageView.image = nil
        usernameLabel.text = nil
        captionLabel.text = nil
        dateLabel.text = nil
    }
}
