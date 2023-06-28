//
//  game.swift
//  hackathon
//
//  Created by 赤星宏樹 on 2023/02/15.
//

import UIKit
import CoreMotion

class game: UIViewController {
    
    @IBOutlet weak var gear: UISwitch!
    @IBOutlet weak var gearLabel: UILabel!
    var webSocketTask: URLSessionWebSocketTask!
    var socketName = UserDefaults.standard
    
    var myMotionManager = CMMotionManager()
    
    var roll: Double = 0.0
    
    var accel: Int = 0
    var brake: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let urlSession = URLSession(configuration: .default)
        let url = URL.init(string: "ws://localhost:8000/control/\(socketName.string(forKey: "uuid")!)")!
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask.resume()
        
        myMotionManager.deviceMotionUpdateInterval = 0.3
        myMotionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion, error) in
            guard let motion = motion, error == nil else { return }
            if(self.roll != round(motion.attitude.pitch * 180 / Double.pi)){
                let msg = URLSessionWebSocketTask.Message.string("{\"accel\": \(self.accel), \"brake\": \(self.brake), \"gyro\": \(self.roll), \"gear\": \(self.gear.isOn ? 1 : 0)}")
                self.webSocketTask.send(msg){error in
                    if let error = error {
                        print(error)
                    }
                }
            }
            self.roll = round(motion.attitude.pitch * 180 / Double.pi)
        })
        
    }
    
    @IBAction func accelLongPress(_ sender: UILongPressGestureRecognizer){
        if(sender.state == UIGestureRecognizer.State.began){
            accel = 1
            let msg = URLSessionWebSocketTask.Message.string("{\"accel\": 1, \"brake\": 0, \"gyro\": \(roll), \"gear\": \(gear.isOn ? 1 : 0)}")
            webSocketTask.send(msg){error in
                if let error = error {
                    print("aaa")
                    print(error)
                }
            }
        }
        else if(sender.state == UIGestureRecognizer.State.ended){
            accel = 0
            let msg = URLSessionWebSocketTask.Message.string("{\"accel\": 0, \"brake\": 0, \"gyro\": \(roll), \"gear\": \(gear.isOn ? 1 : 0)}")
            webSocketTask.send(msg){error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func brakeLongPress(_ sender: UILongPressGestureRecognizer){
        if(sender.state == UIGestureRecognizer.State.began){
            brake = 1
            let msg = URLSessionWebSocketTask.Message.string("{\"accel\": 0, \"brake\": 1, \"gyro\": \(roll), \"gear\": \(gear.isOn ? 1 : 0)}")
            webSocketTask.send(msg){error in
                if let error = error {
                    print(error)
                }
            }
        }
        else if(sender.state == UIGestureRecognizer.State.ended){
            brake = 0
            let msg = URLSessionWebSocketTask.Message.string("{\"accel\": 0, \"brake\": 0, \"gyro\": \(roll), \"gear\": \(gear.isOn ? 1 : 0)}")
            webSocketTask.send(msg){error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func changeGear(_ sender: Any) {
        gearLabel.text = gearLabel.text == "D" ? "R" : "D"
    }
    
}
