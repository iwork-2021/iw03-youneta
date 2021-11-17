//
//  ViewController.swift
//  ITSC
//
//  Created by Chun on 2021/10/19.
//

import UIKit

class rootTabBarController: UITabBarController {
    
    //MARK: properties
    private var urlDict : [String : String] = ["新闻动态" : "https://itsc.nju.edu.cn/xwdt",
                                               "通知公告" : "https://itsc.nju.edu.cn/tzgg",
                                               "信息化动态" : "https://itsc.nju.edu.cn/wlyxqk",
                                               "安全公告" : "https://itsc.nju.edu.cn/aqtg",
                                               "关于" : "https://itsc.nju.edu.cn/main.htm"]
    
    
    //MARK: init
    init() {
        super.init(nibName: nil, bundle: nil)
        self._setupTabBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: setupUI
    func _setupTabBar() {
        let newsViewController = UINavigationController.init(rootViewController: pageTableViewController.init(style: .plain, pageName: "新闻动态", urlString: self.urlDict["新闻动态"]!))
        newsViewController.tabBarItem = UITabBarItem.init(title: "新闻动态", image: UIImage(named: "newsUnselected"), selectedImage: UIImage(named: "newsSelected")?.withRenderingMode(.alwaysOriginal))
        
        let noticeViewController = UINavigationController.init(rootViewController: pageTableViewController.init(style: .plain, pageName: "通知公告", urlString: self.urlDict["通知公告"]!))
        noticeViewController.tabBarItem = UITabBarItem.init(title: "通知公告", image: UIImage(named: "noticeUnselected"), selectedImage: UIImage(named: "noticeSelected")?.withRenderingMode(.alwaysOriginal))
        
        let infoDynamicViewController = UINavigationController.init(rootViewController: pageTableViewController.init(style: .plain, pageName: "信息化动态", urlString: self.urlDict["信息化动态"]!))
        infoDynamicViewController.tabBarItem = UITabBarItem(title: "信息化动态", image: UIImage(named: "infoDynamicUnselected"), selectedImage: UIImage(named: "infoDynamicSelected")?.withRenderingMode(.alwaysOriginal))
        
        let securityNoticeViewController = UINavigationController.init(rootViewController: pageTableViewController.init(style: .plain, pageName: "安全公告", urlString: self.urlDict["安全公告"]!))
        securityNoticeViewController.tabBarItem = UITabBarItem(title: "安全公告", image: UIImage(named: "securityUnselected"), selectedImage: UIImage(named: "securitySelected")?.withRenderingMode(.alwaysOriginal))
        
        let detailViewController = aboutUsViewController.init(pageName: "关于", urlString: self.urlDict["关于"]!)
        detailViewController.tabBarItem = UITabBarItem(title: "关于", image: UIImage(named: "detailUnselected"), selectedImage: UIImage(named: "detailSelected")?.withRenderingMode(.alwaysOriginal))
        
        self.viewControllers = [newsViewController, noticeViewController, infoDynamicViewController, securityNoticeViewController, detailViewController]
    }
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

}

