//
//  LoginViewController.swift
//  CLASSified
//
//  Created by MunYong Jang on 7/15/17.
//  Copyright © 2017 MunYong Jang. All rights reserved.
//

import Foundation
import WebKit
import UIKit
import Kanna

class LogInViewController: UIViewController, UIWebViewDelegate {
    var uName: String?
    var casV: UIWebView?
    
    deinit {
        casV?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "CLASSified"
        view.backgroundColor = uicolorFromHex(rgbValue: 0x3D5B97)
        
        logInButtonSetUp()
        
        //TODO: set up a graphics image later
    }
    
    func logInButtonSetUp() {
        let loginButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = uicolorFromHex(rgbValue: 0x003366)
            button.setTitle("Log In with Princeton CAS", for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 7
            // this could be problematic
            button.addTarget(self, action: #selector(self.logInButtonAction(sender: )), for: UIControlEvents.touchUpInside)
            return button
        }()
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -36).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // all for CAS login
    
    func logInButtonAction(sender: UIButton!) {
        casV = UIWebView(frame: CGRect(origin: CGPoint(x:0, y:64), size: CGSize(width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)))
        
        // TODO: put Chris Hsu's URL for now and find out how to do this shit later
        let request = NSURLRequest(url: NSURL(string: "https://www.cs.princeton.edu/~cjhsu/fristrations/CASlogin.php")! as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        casV!.loadRequest(request as URLRequest)
        view.addSubview(casV!)
        casV!.delegate = self
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let docPage = casV!.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")!
        if let doc = Kanna.HTML(html: docPage, encoding: String.Encoding.utf8) {
            // Search for nodes by CSS
            let bods = doc.css("body")
            let bod = bods[0].text
            if (bod!.characters.count < 100) {
                let netID = bod!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                print(netID)
                uName = netID
                UIView.animate(withDuration: 0.5, animations: {self.casV!.alpha = 0}, completion: deleteAnimationComplete)
            }
        }
    }
    
    // removes the webview and loads up the tableview
    func deleteAnimationComplete(value: Bool) {
        if (value && casV != nil) {
            casV!.removeFromSuperview()
            let tableViewController = TableViewController()
            // passing in the netID to the tableView
            tableViewController.netID = uName
            let tableView = UINavigationController(rootViewController: tableViewController)
            present(tableView, animated: true, completion: nil)
        }
    }
}
