//
//  ViewController.swift
//  MachineLearningApp
//
//  Created by Bekir Geriş on 30.09.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeClick(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
        if let ciImage = CIImage(image: imageView.image!) {
            recognizeImage(image: ciImage)
        }
    }
    
    func recognizeImage(image: CIImage) {
        label.text = "loading..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    
                    let topResult = results.first
                    
                    DispatchQueue.main.async {
                        
                        let confidenceLevel = (topResult?.confidence ?? 0) * 100
                        let rounded = Int(confidenceLevel)
                        self.label.text = "\(rounded)% it's \(topResult?.identifier ?? "")"
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    self.label.text = error.localizedDescription
                    self.makeAlert(title: "Error!", message: error.localizedDescription)
                }
            }
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

