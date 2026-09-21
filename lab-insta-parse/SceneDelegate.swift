//
//  SceneDelegate.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 10/29/22.
//

import UIKit
import ParseSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private enum Constants {
        static let loginNavigationControllerIdentifier = "LoginNavigationController"
        static let feedNavigationControllerIdentifier = "FeedNavigationController"
        static let storyboardIdentifier = "Main"
    }

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let _ = (scene as? UIWindowScene) else { return }

        NotificationCenter.default.addObserver(
            forName: Notification.Name("login"),
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.login()
        }

        NotificationCenter.default.addObserver(
            forName: Notification.Name("logout"),
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.logOut()
        }

        // Check for cached user for persisted login
        if User.current != nil {
            login()
        }
    }

    private func login() {

        let storyboard = UIStoryboard(
            name: Constants.storyboardIdentifier,
            bundle: nil
        )

        self.window?.rootViewController =
            storyboard.instantiateViewController(
                withIdentifier: Constants.feedNavigationControllerIdentifier
            )
    }

    private func logOut() {

        User.logout { [weak self] result in

            DispatchQueue.main.async {

                switch result {

                case .success:
                    print("✅ User logged out successfully!")

                    let storyboard = UIStoryboard(
                        name: Constants.storyboardIdentifier,
                        bundle: nil
                    )

                    self?.window?.rootViewController =
                        storyboard.instantiateViewController(
                            withIdentifier: Constants.loginNavigationControllerIdentifier
                        )

                case .failure(let error):
                    print("❌ Logout error: \(error)")
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
