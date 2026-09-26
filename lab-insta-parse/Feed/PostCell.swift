//
//  PostCell.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/3/22.
//

import UIKit
import Alamofire
import AlamofireImage
import ParseSwift

class PostCell: UITableViewCell {

    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    private var imageDataRequest: DataRequest?

    private var locationLabel: UILabel? {
        return viewWithTag(100) as? UILabel
    }

    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        blurView.isHidden = true

        return blurView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        postImageView.addSubview(blurView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: postImageView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: postImageView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: postImageView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: postImageView.trailingAnchor)
        ])
    }

    func configure(with post: Post) {

        // Show username
        usernameLabel.text = post.user?.username

        // Show caption
        captionLabel.text = post.caption

        // Show date/time
        if let date = post.createdAt {

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short

            dateLabel.text = formatter.string(from: date)
        }

        // Show location
        if let location = post.location {

            let latitude = location.latitude
            let longitude = location.longitude

            locationLabel?.text = String(
                format: "📍 %.4f, %.4f",
                latitude,
                longitude
            )

            locationLabel?.isHidden = false

        } else {

            locationLabel?.text = "📍 Location unavailable"
            locationLabel?.isHidden = false
        }

        // Decide whether the photo should be blurred
        if let currentUser = User.current,
           let lastPostedDate = currentUser.lastPostedDate,
           let postCreatedDate = post.createdAt,
           let diffHours = Calendar.current.dateComponents(
                [.hour],
                from: postCreatedDate,
                to: lastPostedDate
           ).hour {

            blurView.isHidden = abs(diffHours) < 24

        } else {

            blurView.isHidden = false
        }

        // Load post image
        if let imageURL = post.imageFile?.url {

            imageDataRequest = AF.request(imageURL).responseImage {
                [weak self] response in

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
        locationLabel?.text = nil

        // Reset blur
        blurView.isHidden = true
    }
}
