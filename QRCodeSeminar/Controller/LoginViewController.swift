//
//  LoginViewController.swift
//  QRCodeSeminar
//
//  Created by JAKFAR on 11/16/16.
//  Copyright © 2016 JAKFAR. All rights reserved.
//

import UIKit
import TextFieldEffects
import MMLoadingButton
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: YoshikoTextField!
    @IBOutlet weak var passwordField: YoshikoTextField!
    @IBOutlet weak var loginButton: MMLoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.usernameField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        }
        return true
    }
    
    func shakeTextField (textField : UITextField, numberOfShakes : Int, direction: CGFloat, maxShakes : Int) {
        
        let interval : TimeInterval = 0.03
        
        UIView.animate(withDuration: interval, animations: { () -> Void in
            textField.transform = CGAffineTransform(translationX: 5 * direction, y: 0)
            
        }, completion: { (aBool :Bool) -> Void in
            
            if (numberOfShakes >= maxShakes) {
                textField.transform = CGAffineTransform.identity
                textField.becomeFirstResponder()
                return
            }
            
            self.shakeTextField(textField: textField, numberOfShakes: numberOfShakes + 1, direction: direction * -1, maxShakes: maxShakes)
        })
        
    }
    
    @IBAction func logginButtonTapped(_ sender: Any) {
        if(usernameField.text == ""){
            shakeTextField(textField: usernameField, numberOfShakes: 0, direction: 1, maxShakes: 6)
        }else if(passwordField.text == ""){
            shakeTextField(textField: passwordField, numberOfShakes: 0, direction: 1, maxShakes: 6)
        }else{
            self.loginButton.startLoading()
            let delayTime = DispatchTime.now() + .seconds(2)
            
            Alamofire.request("https://demo2864625.mockable.io/login", method: .get)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success:
                        print("Login Successful")
                        
                        let json = JSON(response.result.value!)
                        print(json)
                        
                        let responseCode = json["code"]
                        let responseMsg = json["msg"] .rawString()
                        
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            
                            if responseCode == 101 {
                                
                                self.loginButton.stopWithError(responseMsg!, hideInternal: 2, completed: {
                                    print ("Fail Message Completed")
                                })
                                
                            } else {
                                
                                self.loginButton.stopLoading(true, completed: {
                                    print("Scuess Completed")
                                    // Clear form
                                    self.usernameField.text = ""
                                    self.passwordField.text = ""
                                })
                                
                            }
                        }
                        
                        break
                    case .failure(let error):
                        print(error)
                        break
                    }
            }
            
            // Login success
            if let HomeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController {
                self.loginButton.addScuessPresentVC(HomeVC)
            }
            
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
