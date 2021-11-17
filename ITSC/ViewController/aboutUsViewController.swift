//
//  aboutUsViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/17.
//

import UIKit

class aboutUsViewController: UIViewController {

    //MARK: properties
    var urlString: String  = ""
    var pageName: String = ""
    lazy var stringArray: NSMutableArray = {
        var arr = NSMutableArray()
        return arr
    }()
    
    //MARK: init
    init(pageName: String, urlString: String) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = urlString
        self.pageName = pageName
        DispatchQueue.global().async {
            self._fetchData(url: urlString)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    //MARK: netWork
    func _fetchData(url: String) {
        weak var weakSelf = self
        networkManager.shared.fetchData(url: url) { html in
            ITSCParser.shared.parseAboutUsHtml(html: html, stringArray: self.stringArray)
            DispatchQueue.main.async {
                weakSelf?._showText()
            }
        }
    }

    func _showText() {
        let textView = UITextView()
        var text = ""
        for string in (self.stringArray as! [String]) {
            text = text.appending(string)
            text = text.appending("\n")
        }
        textView.text = text
        textView.textColor = .black
        textView.font = .systemFont(ofSize: 18)
        textView.textAlignment = .center
        self.view.addSubview(textView)
        let fitSize = textView.sizeThatFits(CGSize.init(width: self.view.frame.width, height: CGFloat(MAXFLOAT)))
        
        textView.autoresizesSubviews = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        textView.heightAnchor.constraint(equalToConstant: fitSize.height).isActive = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
