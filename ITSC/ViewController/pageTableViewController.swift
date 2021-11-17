//
//  pageTableViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/12.
//

import UIKit
import WebKit

class pageTableViewController: UITableViewController, UISearchBarDelegate {
    
    //MARK: static
    
    
    //MARK: properties
    private lazy var cellModelArray: NSMutableArray = {
        var arr = NSMutableArray.init()
        return arr
    }()
    var urlString : String?
    var pageName : String?
    private lazy var searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()
    
    //MARK: init
    init(style: UITableView.Style, pageName: String, urlString: String) {
        super.init(style: style)
        self.tableView.register(pageTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(pageTableViewCell.self))
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
//        self.view.addSubview(self.searchBar)
        self.view.backgroundColor = UIColor.white
//        self._setupUI()
    }
    
//    func _setupUI() {
//        self.searchBar.autoresizesSubviews = false
//        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
//        self.searchBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        self.searchBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        self.searchBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        self.searchBar.heightAnchor.constraint(equalToConstant: 25).isActive = true
//
//        self.tableView.autoresizesSubviews = false
//        self.tableView.translatesAutoresizingMaskIntoConstraints = false
//        self.tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor).isActive = true
//        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//    }
    
    //MARK: searchBar Delegate
    
    
    //MARK: network
    func _fetchData(url: String) {
        weak var weakSelf = self
        var listUrl = url.appendingFormat("/list.htm")
        networkManager.shared.fetchData(url: listUrl) { string in
            let result = ITSCParser.shared.parseNewsListHtml(html: string, modelsArray: weakSelf!.cellModelArray, startIndex: 1)
            if result.currPage < result.allPages {
                var i: Int = 2
                while (i <= result.allPages) {
                    listUrl = url.appendingFormat("/list%d.htm", i)
                    networkManager.shared.fetchData(url: listUrl) { string in
                        let _ = ITSCParser.shared.parseNewsListHtml(html: string, modelsArray: weakSelf!.cellModelArray, startIndex: 0)
                        DispatchQueue.main.async {
                            weakSelf?.tableView.reloadData()
                        }
                    }
                    i += 1
                }
            }
            DispatchQueue.main.async {
                weakSelf?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellModelArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = self.cellModelArray[indexPath.row] as! newsItemModel
        let cell = pageTableViewCell.init(style: .default, reuseIdentifier: NSStringFromClass(pageTableViewCell.self), title: cellModel.title ?? "", timeString: cellModel.time ?? "")
        weak var weakSelf = self
        cell.didClickCellBlk = { (cell: pageTableViewCell) -> () in
            weakSelf!._handleTapCell(cell: cell)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: private methods
    func _handleTapCell(cell: pageTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let cellModel = self.cellModelArray[indexPath!.row] as! newsItemModel
        let url = self.urlString?.appending(cellModel.urlString ?? "") ?? ""
        let pageVC = webPageViewController.init(pageUrl: url)
        self.navigationController?.pushViewController(pageVC, animated: true)
    }
}
