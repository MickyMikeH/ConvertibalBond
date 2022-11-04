//
//  WebViewController.swift
//  ConvertibalBond
//
//  Created by 金融研發一部-謝宜軒 on 2022/11/4.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    public var webLink: String?
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let webLink = webLink,
           let URL = URL(string: webLink) {
            let URLReq = URLRequest(url: URL)
            self.webView.load(URLReq)
        }
    }
}
