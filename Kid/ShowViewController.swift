//
//  ViewController.swift
//  RotateTogether
//
//  Created by Artem Misesin on 6/1/17.
//
//

import UIKit
import CoreMotion


class ShowViewController: UIViewController {

    var motionManager = CMMotionManager()
    
    var webHandler = WebHandler()
    
    var image = UIImageView()
    var prevX: CGFloat = 0.0
    
    var imageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webHandler.send(data: "exited")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        webHandler.connect()
        image.frame = UIScreen.main.bounds
        let defaultTransform = self.image.transform
        let flipTransform = self.image.transform.rotated(by: CGFloat.pi)
        image.contentMode = .scaleAspectFit
        view.addSubview(image)
        image.image = UIImage(named: "1")
        var flip = false
        var scaleFlip = false
        var offHandle = false
        var _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(changePic), userInfo: nil, repeats: true)
        motionManager.accelerometerUpdateInterval = 0.02
        if motionManager.isAccelerometerAvailable{
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                if let accelData = data{
                    let newX = CGFloat(accelData.acceleration.x)
                    let newY = CGFloat(accelData.acceleration.y)
                    let newZ = CGFloat(accelData.acceleration.z)
                    if abs(newZ) > 0.5 {
                        offHandle = true
                    }
                    let diff: CGFloat = self.prevX - newX
                    if abs(diff) > 0.005 {
                        if newY > 0{
                            flip = true
                        } else {
                            flip = false
                        }
                        if newX < 0 {
                            scaleFlip = true
                        } else {
                            scaleFlip = false
                        }
                        UIView.transition(with: self.image, duration: 0.2, options: .curveLinear, animations: {
                            if abs(newX) < 0.1, !flip{
                                self.image.transform = defaultTransform
                            } else if abs(newX) < 0.01, flip{
                                self.image.transform = flipTransform
                            }
                            if !flip{
                                self.image.transform = self.image.transform.rotated(by: diff*1.6)
                            } else {
                                self.image.transform = self.image.transform.rotated(by: -diff*1.6)
                            }
                            if scaleFlip{
                                self.image.transform = self.image.transform.scaledBy(x: 1 - diff/2, y: 1 - diff/2)
                            } else {
                                self.image.transform = self.image.transform.scaledBy(x: 1 - (-1 * (diff/2)), y: 1 - (-1 * (diff/2)))
                            }
                        }, completion: nil)
                        if self.webHandler.isConnected{
                            var data = ""
                            if offHandle {
                                data = "\(self.image.transform.a) \(self.image.transform.b) \(self.image.transform.c) \(self.image.transform.d) 1"
                            } else {
                                data = "\(self.image.transform.a) \(self.image.transform.b) \(self.image.transform.c) \(self.image.transform.d) 0"
                            }
                            self.webHandler.send(data: data)
                        }
                    }
                    self.prevX = newX
                    
                } else {
                    print(error?.localizedDescription ?? "Something's wrong")
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "You accelerometer is not active.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func changePic(){
        if !self.webHandler.isConnected{
            self.webHandler.connect()
        }
        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        crossFade.duration = 2
        let image1 = UIImage(named: String(imageIndex))
        if UIImage(named: String(imageIndex + 1)) == nil{
            imageIndex = 0
        }
        let image2 = UIImage(named: String(imageIndex + 1))
        crossFade.toValue = image2!.cgImage
        crossFade.fromValue = image1!.cgImage
        self.image.image = image2
        self.image.layer.add(crossFade, forKey: "animateContents")
        imageIndex += 1
    }
}

