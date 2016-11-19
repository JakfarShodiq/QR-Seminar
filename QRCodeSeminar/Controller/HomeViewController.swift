//
//  HomeViewController.swift
//  QRCodeSeminar
//
//  Created by JAKFAR on 11/16/16.
//  Copyright © 2016 JAKFAR. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import SCLAlertView
import RappleProgressHUD

class HomeViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    lazy var reader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
        $0.showTorchButton = true
    })
    
    @IBAction func scanButtonTapped(_ sender: Any) {
        if QRCodeReader.supportsMetadataObjectTypes() {
            reader.modalPresentationStyle = .formSheet
            reader.delegate               = self
            
            reader.completionBlock = { (result: QRCodeReaderResult?) in
                if let result = result {
                    print("Completion with result: \(result.value) of type \(result.metadataType)")
                    
                    RappleActivityIndicatorView.startAnimatingWithLabel("Processing...")
                    
                    Alamofire.request("https://demo2864625.mockable.io/login")
                        .validate()
                        .responseJSON { response in
                            
                            switch response.result {
                            case .success:
                                
                                let json = JSON(response.result.value!)
                                print(json)
                                
                                let responseCode = json["code"].rawString()
                                let responseMsg = json["msg"].rawString()
                                
                                
                                if responseCode == "100" {
                                    let alert = SCLAlertView()
                                    _ = alert.showSuccess("Congratulations", subTitle: responseMsg!)
                                } else {
                                    let alert = SCLAlertView()
                                    _ = alert.showWarning("Warning", subTitle: responseMsg!)
                                }
                                
                                RappleActivityIndicatorView.stopAnimating()
                                self.dismiss(animated: true, completion: nil)
                                
                                break
                            case .failure(let error):
                                print(error)
                                break
                            }
                    } // End Alamofire
                }
            }
            
            present(reader, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - QRCodeReader Delegate Methods
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func createReader() -> QRCodeReaderViewController {
        let builder = QRCodeReaderViewControllerBuilder { builder in
            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
            builder.showTorchButton = true
        }
        
        return QRCodeReaderViewController(builder: builder)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
