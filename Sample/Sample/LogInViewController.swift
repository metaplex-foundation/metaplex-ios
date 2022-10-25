//
//  LogInViewController.swift
//  Sample
//
//  Created by Arturo Jamaica on 6/14/22.
//

import UIKit
import Solana

class LogInViewController: UIViewController {
    private var ownerPublicKeyString: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onLogInWithPhantom(_ sender: Any) {
//        let windowScene: SceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
//        windowScene.phantom.connect()
//        windowScene.phantom.onConnect = { result in
//            self.ownerPublicKeyString = result.public_key
            self.performSegue(withIdentifier: "goToWallet", sender: sender)
//        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
//        if segue.identifier == "goToWallet",
//           let walletViewController = segue.destination as? ViewController,
//           let ownerPublicKeyString = self.ownerPublicKeyString,
//           let ownerPublicKey = PublicKey(string: ownerPublicKeyString) {
//            walletViewController.ownerPublicKey = ownerPublicKey
//        }
//    }
}
