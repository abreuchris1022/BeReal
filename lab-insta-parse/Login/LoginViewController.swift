///
//  LoginViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 10/29/22.
//

import UIKit
import ParseSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onLoginTapped(_ sender: Any) {

        // Make sure all fields are filled out
        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !password.isEmpty else {

            showMissingFieldsAlert()
            return
        }

        // Log in the Parse user
        User.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {

                case .success:
                    print("✅ User logged in successfully!")

                    NotificationCenter.default.post(
                        name: Notification.Name("login"),
                        object: nil
                    )

                case .failure(let error):
                    print("❌ Login error: \(error)")
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(description: String?) {

        let alertController = UIAlertController(
            title: "Unable to Log in",
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
            message: "We need all fields filled out in order to log you in.",
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
