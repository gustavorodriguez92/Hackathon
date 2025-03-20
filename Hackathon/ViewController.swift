//
//  ViewController.swift
//  Hackathon
//
//  Created by Gustavo Rodriguez on 19/03/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLogo()
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
}
