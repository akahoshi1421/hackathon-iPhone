//
//  ViewController.swift
//  hackathon
//
//  Created by 赤星宏樹 on 2023/02/15.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var uuidText: UITextField!
    var webSocketTask: URLSessionWebSocketTask!
    var socketName = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func connectUnity(_ sender: Any) {
        let urlSession = URLSession(configuration: .default)
        let uuid: String! = uuidText.text!
        let url = URL.init(string: "ws://localhost:8000/control/\(uuidText.text!)")!
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask.resume()
        
        socketName.set(uuid, forKey: "uuid")
        
        receiveMessage()
        
        let msg = URLSessionWebSocketTask.Message.string("iPhoneOK")
        webSocketTask.send(msg){error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func receiveMessage() {
      webSocketTask.receive { [weak self] result in
        switch result {
          case .success(let message):
            switch message {
              case .string(let text):
                if(text == "UnityOK"){
                    DispatchQueue.main.async {
                        self!.webSocketTask.cancel(with: .goingAway, reason: nil)
                        self!.performSegue(withIdentifier: "toGame", sender: nil)
                    }
                }
              @unknown default:
                fatalError()
            }
            self!.receiveMessage()  // <- 継続して受信するために再帰的に呼び出す
          case .failure(let error):
            print("Failed! error: \(error)")
        }
      }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

