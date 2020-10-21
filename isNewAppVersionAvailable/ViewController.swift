//
//  ViewController.swift
//  isNewAppVersionAvailable
//
//  Created by Sachin Daingade on 21/10/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var txtAppID: UITextField!
    @IBOutlet weak var btnCheckUpdate: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnCheckUpdateAction(_ sender: Any) {
        if let txtAppID = self.txtAppID.text{
            self.view.endEditing(true)
            
            // Start Activity Indicator
            self.isNewAppVersionAvailable(txtAppID) {[unowned self] isNewVersionAvailable in
                if isNewVersionAvailable  {
                   DispatchQueue.main.async {
                    self.lblStatus.isHidden = false
                    self.lblStatus.text = "New App version available kindly update"
                    }
                }else {
                    DispatchQueue.main.async {
                     self.lblStatus.isHidden = false
                     self.lblStatus.text = "No New App version available.... Your app is upto date"
                     }
                }
                // Stop Activity Indicator
            }
        }else {
            txtAppID.resignFirstResponder()
            lblStatus.isHidden = false
            lblStatus.text = "Please enter Application ID"
            
        }
    }
    
    
    private func isNewAppVersionAvailable(_ appID:String , completion: @escaping (Bool) -> Void) {
        
        let strURL = "https://itunes.apple.com/lookup?id=\(appID)"
        let applicationURL = URL(string:strURL )
        
        let task = URLSession.shared.dataTask(with: applicationURL!, completionHandler: { (data, response, error) in
            do {
                guard data != nil else {
                    completion(false)
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
                guard let results = json["results"] as? [[String: Any]] else {
                    completion(false)
                    return
                }
                guard let appStoreVersion = results.first?["version"] as? String else {
                    completion(false)
                    return
                }
                
                if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                
                    let appStoreVersionFloatValue =  (appStoreVersion as NSString).floatValue
                    let currentVersionFloatValue = (currentVersion as NSString).floatValue
                    
                    
                    if appStoreVersionFloatValue > currentVersionFloatValue {
                        completion(true)
                    }else {
                        completion(false)
                    }
                }else {
                    completion(false)
                }
            }catch {
                completion(false)
            }
        })
        task.resume()
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
