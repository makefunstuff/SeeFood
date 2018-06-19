//
//  ViewController.swift
//  SeeFood
//
//  Created by Iurii Plugatarov on 19/06/2018.
//  Copyright © 2018 Iurii Plugatarov. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet weak var imageView: UIImageView!
  
  let imagePicker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imagePicker.delegate = self
    imagePicker.sourceType = .camera
    imagePicker.allowsEditing = false
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      fatalError("Could not read image")
    }
    
    imageView.image = userPickedImage
    
    guard let coreImage = CIImage(image: userPickedImage) else {
      fatalError("Could not convert to CIImage")
    }
    
    detect(image: coreImage )
    
    imagePicker.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
    present(imagePicker, animated: true, completion: nil)
  }
  
  func detect(image: CIImage) {
    guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
      fatalError("Could not initialize the model")
    }
    
    let request = VNCoreMLRequest(model: model) { request, error in
      guard let results = request.results as? [VNClassificationObservation] else {
        fatalError("Could not fetch results")
      }
      
      if let firstResult = results.first {
        if firstResult.identifier.contains("hotdog") {
          self.navigationItem.title = "Hotdog!"
        } else {
          self.navigationItem.title = "Not Hotdog!"
        }
      }
    }
    
    let handler = VNImageRequestHandler(ciImage: image)
    do {
      try handler.perform([request])
    } catch {
      print("Could not detect")
    }
  }
  
}

