//
//  FeedViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var posts = [Post]() {
        didSet {
            // Reload table view data any time posts gets updated
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }

    private func queryPosts() {

        // Get the date from 24 hours ago
        let yesterdayDate = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: Date()
        )!

        // Get the 10 most recent posts from the last 24 hours
        let query = Post.query()
            .include("user")
            .where("createdAt" >= yesterdayDate)
            .order([.descending("createdAt")])
            .limit(10)

        query.find { [weak self] result in
            DispatchQueue.main.async {
                switch result {

                case .success(let posts):
                    print("✅ Found \(posts.count) posts")
                    self?.posts = posts

                case .failure(let error):
                    print("❌ Error getting posts: \(error)")
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    private func showConfirmLogoutAlert() {

        let alertController = UIAlertController(
            title: "Log out of your account?",
            message: nil,
            preferredStyle: .alert
        )

        let logOutAction = UIAlertAction(
            title: "Log out",
            style: .destructive
        ) { _ in

            NotificationCenter.default.post(
                name: Notification.Name("logout"),
                object: nil
            )
        }

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )

        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
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

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return posts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostCell",
            for: indexPath
        ) as? PostCell else {

            return UITableViewCell()
        }

        cell.configure(with: posts[indexPath.row])

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate { }
