//
//  PostViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit
import PhotosUI
import ParseSwift

class PostViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!

    private var pickedImage: UIImage?

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

        guard let currentUser = User.current else {
            showAlert(description: "No user is logged in.")
            return
        }

        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        var post = Post()
        post.user = currentUser
        post.imageFile = imageFile
        post.caption = captionTextField.text

        shareButton.isEnabled = false

        post.save { [weak self] result in
            DispatchQueue.main.async {

                self?.shareButton.isEnabled = true

                switch result {

                case .success:
                    print("✅ Post saved successfully!")
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    print("❌ Error saving post: \(error)")
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func onViewTapped(_ sender: Any) {

        // Dismiss keyboard
        view.endEditing(true)
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

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

            guard let image = object as? UIImage else {
                DispatchQueue.main.async {
                    self?.showAlert(description: error?.localizedDescription)
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
