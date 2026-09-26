//
//  PostViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit
import PhotosUI
import ParseSwift
import ImageIO
import UniformTypeIdentifiers

class PostViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!

    private var pickedImage: UIImage?
    private var pickedLocation: ParseGeoPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onPickedImageTapped(_ sender: UIBarButtonItem) {

        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }

    @IBAction func onShareTapped(_ sender: Any) {

        // Dismiss keyboard
        view.endEditing(true)

        guard let pickedImage = pickedImage,
              let imageData = pickedImage.jpegData(compressionQuality: 0.5) else {
            showAlert(description: "Please choose a photo first.")
            return
        }

        guard var currentUser = User.current else {
            showAlert(description: "No user is logged in.")
            return
        }

        let imageFile = ParseFile(
            name: "image.jpg",
            data: imageData
        )

        var post = Post()
        post.user = currentUser
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.location = pickedLocation

        shareButton.isEnabled = false

        post.save { [weak self] result in

            switch result {

            case .success:

                print("✅ Post saved successfully!")

                // Update the user's last posted date
                currentUser.lastPostedDate = Date()

                currentUser.save { userResult in

                    DispatchQueue.main.async {

                        self?.shareButton.isEnabled = true

                        switch userResult {

                        case .success:

                            print("✅ User lastPostedDate updated!")

                            self?.navigationController?.popViewController(
                                animated: true
                            )

                        case .failure(let error):

                            print("❌ Error updating user: \(error)")

                            self?.showAlert(
                                description: error.localizedDescription
                            )
                        }
                    }
                }

            case .failure(let error):

                DispatchQueue.main.async {

                    self?.shareButton.isEnabled = true

                    print("❌ Error saving post: \(error)")

                    self?.showAlert(
                        description: error.localizedDescription
                    )
                }
            }
        }
    }

    @IBAction func onViewTapped(_ sender: Any) {

        // Dismiss keyboard
        view.endEditing(true)
    }

    private func getLocation(from url: URL) -> ParseGeoPoint? {

        guard let imageSource = CGImageSourceCreateWithURL(
            url as CFURL,
            nil
        ) else {
            return nil
        }

        guard let imageProperties =
                CGImageSourceCopyPropertiesAtIndex(
                    imageSource,
                    0,
                    nil
                ) as? [CFString: Any] else {
            return nil
        }

        guard let gpsData =
                imageProperties[kCGImagePropertyGPSDictionary]
                    as? [CFString: Any] else {

            print("⚠️ No GPS data found in photo")
            return nil
        }

        guard let latitude =
                gpsData[kCGImagePropertyGPSLatitude] as? Double,
              let longitude =
                gpsData[kCGImagePropertyGPSLongitude] as? Double else {

            print("⚠️ GPS coordinates missing")
            return nil
        }

        let latitudeRef =
            gpsData[kCGImagePropertyGPSLatitudeRef] as? String

        let longitudeRef =
            gpsData[kCGImagePropertyGPSLongitudeRef] as? String

        var finalLatitude = latitude
        var finalLongitude = longitude

        if latitudeRef == "S" {
            finalLatitude = -latitude
        }

        if longitudeRef == "W" {
            finalLongitude = -longitude
        }

        print(
            "📍 Photo location found: \(finalLatitude), \(finalLongitude)"
        )

        return try? ParseGeoPoint(
            latitude: finalLatitude,
            longitude: finalLongitude
        )
    }

    private func showAlert(description: String? = nil) {

        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(description ?? "Please try again...")",
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: "OK",
            style: .default
        )

        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension PostViewController: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {

        picker.dismiss(animated: true)

        guard let result = results.first else {
            return
        }

        let itemProvider = result.itemProvider

        // Load the photo file so we can read GPS metadata
        if itemProvider.hasItemConformingToTypeIdentifier(
            UTType.image.identifier
        ) {

            itemProvider.loadFileRepresentation(
                forTypeIdentifier: UTType.image.identifier
            ) { [weak self] url, error in

                if let url = url {

                    let location = self?.getLocation(from: url)

                    DispatchQueue.main.async {
                        self?.pickedLocation = location
                    }

                } else if let error = error {

                    print(
                        "❌ Error reading photo metadata: \(error)"
                    )
                }
            }
        }

        // Load the image for preview/upload
        itemProvider.loadObject(
            ofClass: UIImage.self
        ) { [weak self] object, error in

            guard let image = object as? UIImage else {

                DispatchQueue.main.async {
                    self?.showAlert(
                        description: error?.localizedDescription
                    )
                }

                return
            }

            DispatchQueue.main.async {

                self?.pickedImage = image
                self?.previewImageView.image = image
            }
        }
    }
}
