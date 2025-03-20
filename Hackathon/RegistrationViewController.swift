//
//  RegistrationViewController.swift
//  Hackathon
//
//  Created by Cascade on 20/03/25.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    private var selectedImage: UIImage?
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Registration"
        setupUI()
        loadLogo()
    }
    
    private func setupUI() {
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.cornerRadius = 5
        
        if descriptionTextView.text == "Description" {
            descriptionTextView.textColor = .placeholderText
        }
        
        descriptionTextView.delegate = self
        imagePicker.delegate = self
        
        addImageButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
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
    
    @objc private func addImageTapped() {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.imagePicker.sourceType = .camera
                self?.present(self?.imagePicker ?? UIImagePickerController(), animated: true)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.imagePicker.sourceType = .photoLibrary
            self?.present(self?.imagePicker ?? UIImagePickerController(), animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func registerTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let description = descriptionTextView.text, description != "Description", !description.isEmpty else {
            showAlert(message: "Please fill in all fields", isSuccess: false)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthdate = dateFormatter.string(from: birthDatePicker.date)
        
        // Convert image to base64 string
        var imageString = ""
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.5) {
            imageString = imageData.base64EncodedString()
        }
        
        // Create registration data
        let registrationData: [String: Any] = [
            "name": name,
            "lastname": lastName,
            "birthdate": birthdate,
            "password": password,
            "description": description,
            "image": imageString
        ]
        
        // Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: registrationData) else {
            showAlert(message: "Error creating registration data", isSuccess: false)
            return
        }
        
        // Create request
        guard let url = URL(string: "https://hackaton-rails-api.duckdns.org:3000/users") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(message: "Error: \(error.localizedDescription)", isSuccess: false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        // Registration successful, get user data from response
                        if let data = data,
                           let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            self?.navigateToMainScreen(with: userData)
                        } else {
                            self?.showAlert(message: "Registration successful but error getting user data", isSuccess: false)
                        }
                    } else {
                        self?.showAlert(message: "Registration failed", isSuccess: false)
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
    
    private func showAlert(message: String, isSuccess: Bool) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension RegistrationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = .placeholderText
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            addImageButton.setTitle("Image Selected ", for: .normal)
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
