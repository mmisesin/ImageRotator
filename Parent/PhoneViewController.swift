//
//  ViewController.swift
//  Parent
//
//  Created by Artem Misesin on 6/1/17.
//
//

import UIKit
import Starscream

class PhoneViewController: UIViewController {

    var image = UIImageView()
    var webHandler = WebHandler()
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var prevData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        webHandler.setup(with: "wss://ios-devchallenge-11.tk/read?id=organicMutt")
        webHandler.connect()
        image.frame = view.bounds
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "IPhone")
        view.insertSubview(image, at: 0)
        let _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(rotateImage), userInfo: nil, repeats: true)
    }
    
    func rotateImage(){
        if webHandler.isConnected{
            spinner.stopAnimating()
            let dataArray = webHandler.receivedData.components(separatedBy: " ")
            
            guard let a = Double(dataArray[0]) else {
                return
            }
            guard let b = Double(dataArray[1]) else {
                return
            }
            guard let c = Double(dataArray[2]) else {
                return
            }
            
            guard let d = Double(dataArray[3]) else {
                return
            }
            if dataArray[0] == "exited"{
                handleLabel.text = "Kid's away"
            }
            
            if dataArray[4] == "1" {
                handleLabel.text = "Off handle"
            } else {
                handleLabel.text = "On handle"
            }
            prevData = dataArray[0]
            UIView.transition(with: self.image, duration: 0.2, options: .curveLinear, animations: {
                self.image.transform = CGAffineTransform(a: CGFloat(a), b: CGFloat(b), c: CGFloat(c), d: CGFloat(d), tx: 0, ty: 0)
            }, completion: nil)
        } else {
            spinner.startAnimating()
            handleLabel.text = "Connecting"
            webHandler.connect()
        }
    }
}
