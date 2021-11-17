//
//  webPageViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/16.
//

import UIKit

class webPageViewController: UIViewController, UIScrollViewDelegate {
    //MARK: properties
    static var rootURL = "https://itsc.nju.edu.cn"
    private var pageUrl: String = ""
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
//        scrollView.alwaysBounceVertical = true
//        scrollView.isDirectionalLockEnabled = true
        scrollView.delegate = self
        return scrollView
    }()
    private lazy var contentModelsArray: NSMutableArray = {
        var arr = NSMutableArray()
        return arr
    }()
    
    
    //MARK: init
    init(pageUrl: String) {
        super.init(nibName: nil, bundle: nil)
        self.pageUrl = pageUrl
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self._setupUI()
        self._loadURL()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {

    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        _ = self.scrollView.subviews.map {
            $0.removeFromSuperview()
        }
        self._addContentToScrollView()
    }
    
    //MARK: setupUI
    func _setupUI() {
        self._setupConstraints()
    }
    
    func _setupConstraints() {
        self.scrollView.autoresizesSubviews = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    
    //MARK: loadURL
    func _loadURL() {
        weak var weakSelf = self
        networkManager.shared.fetchData(url: self.pageUrl) { html in
//            print(html)
            ITSCParser.shared.parseNewsPageHTML(html: html, modelsArray:self.contentModelsArray)
            DispatchQueue.main.async {
                weakSelf?._addContentToScrollView()
            }
        }
    }

    func _addContentToScrollView() {
        
        var currentBottom:Double = 0.0
        for phaseContent in (self.contentModelsArray as! [NSArray]) {
            let contentType = phaseContent[0] as! ITSCPageContentType
            switch contentType {
            case .contentTypeTitle:
                let titleModel = phaseContent[1] as! ITSCNewsTextModel
                currentBottom = self._addTextToScrollView(text: titleModel.text ?? "", offset: currentBottom, type: .contentTypeTitle)
            case .contentTypeMeta:
                let metaModel = phaseContent[1] as! ITSCNewsTextModel
                currentBottom = self._addTextToScrollView(text: metaModel.text ?? "", offset: currentBottom, type: .contentTypeMeta)
            case .contentTypeImg:
                let imgModel = phaseContent[1] as! ITSCNewsImgModel
                let webImageView = SDAnimatedImageView()
                let imgUrl = webPageViewController.rootURL.appending(imgModel.imgUrl ?? "")
                webImageView.sd_setImage(with: URL(string: imgUrl), completed: nil)
                var imgWidth = min(self.view.frame.width, imgModel.imgWidth ?? 0.0)
                var imgHeight: Double = ((imgModel.imgHeight ?? 0.0) / (imgModel.imgWidth ?? 1.0)) * imgWidth
                if(imgWidth == 0) {
                    // 设置一个保险方案，图片的默认显示尺寸
                    imgWidth = 300
                    imgHeight = 200
                }
                self.scrollView.addSubview(webImageView)
                webImageView.autoresizesSubviews = false
                webImageView.translatesAutoresizingMaskIntoConstraints = false
                webImageView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: currentBottom).isActive = true
                webImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                webImageView.widthAnchor.constraint(equalToConstant: imgWidth).isActive = true
                webImageView.heightAnchor.constraint(equalToConstant: imgHeight).isActive = true
                currentBottom += imgHeight
                
            case .contentTypeText:
                let textModel = phaseContent[1] as! ITSCNewsTextModel
                if(textModel.text == "") { break }
                currentBottom =  self._addTextToScrollView(text: textModel.text ?? "", offset: currentBottom, type: .contentTypeText)
            }
        }
        self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: currentBottom)
    }
    
    func _addTextToScrollView(text: String, offset: CGFloat, type: ITSCPageContentType) -> (CGFloat){
        let textView = UITextView()
        textView.isScrollEnabled = false
        switch type {
        case .contentTypeTitle:
            textView.text = text
            textView.font = UIFont.systemFont(ofSize: 24)
            textView.textColor = UIColor.red
            textView.textAlignment = .center
        case .contentTypeMeta:
            textView.text = text
            textView.font = UIFont.systemFont(ofSize: 12)
            textView.textColor = .gray
            textView.textAlignment = .center
        case .contentTypeImg:
            break
        case .contentTypeText:
            let tabString = "\t"
            textView.text = tabString.appending(text)
            textView.font = UIFont.systemFont(ofSize: 18)
            textView.textColor = UIColor.black
            textView.textAlignment = .justified
        }

        textView.isEditable = false
        let fitSize = textView.sizeThatFits(CGSize.init(width: self.view.frame.width, height: CGFloat(MAXFLOAT)))
        
        self.scrollView.addSubview(textView)
        textView.autoresizesSubviews = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: offset).isActive = true
        textView.heightAnchor.constraint(equalToConstant: fitSize.height).isActive = true
        return offset + fitSize.height
    }
}
