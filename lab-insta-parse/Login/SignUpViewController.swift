//
//  SignUpViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit
import ParseSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onSignUpTapped(_ sender: Any) {

        // Make sure all fields are filled out
        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {

            showMissingFieldsAlert()
            return
        }

        // Create a new Parse user
        var newUser = User()
        newUser.username = username
        newUser.email = email
        newUser.password = password

        newUser.signup { [weak self] result in
            DispatchQueue.main.async {
                switch result {

                case .success:
                    print("✅ User signed up successfully!")

                    NotificationCenter.default.post(
                        name: Notification.Name("login"),
                        object: nil
                    )

                case .failure(let error):
                    print("❌ Sign up error: \(error)")
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(description: String?) {

        let alertController = UIAlertController(
            title: "Unable to Sign Up",
            message: description ?? "Unknown error",
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: "OK",
            style: .default
        )

        alertController.addAction(action)
        present(alertController, animated: true)
    }

    private func showMissingFieldsAlert() {

        let alertController = UIAlertController(
            title: "Oops...",
            message: "We need all fields filled out in order to sign you up.",
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
