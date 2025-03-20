//
//  MainViewController.swift
//  Hackathon
//
//  Created by Cascade on 20/03/25.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    var userData: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogo()
        if let data = userData {
            updateUI(with: data)
        }
    }
    
    private func setupUI() {
        navigationItem.hidesBackButton = true
        
        profileImageView.layer.cornerRadius = 75
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    private func loadLogo() {
        guard let url = URL(string: "https://hackaton-rails-api.duckdns.org:3000/assets?logo_type=light") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error loading logo: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self?.logoImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private func updateUI(with data: [String: Any]) {
        welcomeLabel.text = "Welcome, \(data["name"] as? String ?? "")!"
        nameLabel.text = "Name: \(data["name"] as? String ?? "")"
        lastNameLabel.text = "Last Name: \(data["lastname"] as? String ?? "")"
        birthDateLabel.text = "Birth Date: \(data["birthdate"] as? String ?? "")"
        descriptionLabel.text = "Description: \(data["description"] as? String ?? "")"
        
        if let imageString = data["image"] as? String,
           let imageData = Data(base64Encoded: imageString),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
    }
    
    @objc private func logoutTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
