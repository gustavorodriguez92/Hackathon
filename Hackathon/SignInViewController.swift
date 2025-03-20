//
//  SignInViewController.swift
//  Hackathon
//
//  Created by Cascade on 20/03/25.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        setupUI()
    }
    
    private func setupUI() {
        nameTextField.delegate = self
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showAlert(message: "Please enter your name")
            return
        }
        
        checkUser(name: name)
    }
    
    private func checkUser(name: String) {
        guard let url = URL(string: "https://hackaton-rails-api.duckdns.org:3000/users/?name=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // User exists, get user data and navigate to main screen
                        if let data = data,
                           let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            self?.navigateToMainScreen(with: userData)
                        }
                    } else {
                        // User doesn't exist, navigate to registration
                        self?.navigateToRegistration()
                    }
                }
            }
        }.resume()
    }
    
    private func navigateToMainScreen(with userData: [String: Any]) {
        if let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            mainVC.userData = userData
            navigationController?.pushViewController(mainVC, animated: true)
        }
    }
    
    private func navigateToRegistration() {
        if let registrationVC = storyboard?.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController {
            navigationController?.pushViewController(registrationVC, animated: true)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
