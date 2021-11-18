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
    private lazy var allModelsArray: NSMutableArray = {
        var arr = NSMutableArray.init()
        return arr
    }()
    
    private lazy var resultModelsArray: NSMutableArray = {
        var arr = NSMutableArray.init()
        return arr
    }()
    
    lazy var searchBar: UISearchBar = {
        var searchBar = UISearchBar(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 35))
        searchBar.delegate = self
        searchBar.placeholder = "搜索"
        return searchBar
    }()
    
    var urlString : String?
    var pageName : String?
    
    //MARK: init
    init(style: UITableView.Style, pageName: String, urlString: String) {
        super.init(style: style)
        self.tableView.register(pageTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(pageTableViewCell.self))
        self.tableView.tableHeaderView = self.searchBar
//        self.tableView.register(pageTableViewSearchHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(pageTableViewSearchHeader.self))
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
        self.view.backgroundColor = UIColor.white
    }

    //MARK: network
    func _fetchData(url: String) {
        weak var weakSelf = self
        var listUrl = url.appendingFormat("/list.htm")
        networkManager.shared.fetchData(url: listUrl) { string in
            let result = ITSCParser.shared.parseNewsListHtml(html: string, modelsArray: weakSelf!.allModelsArray, startIndex: 1)
            weakSelf!.resultModelsArray = weakSelf!.allModelsArray
            if result.currPage < result.allPages {
                var i: Int = 2
                while (i <= result.allPages) {
                    listUrl = url.appendingFormat("/list%d.htm", i)
                    networkManager.shared.fetchData(url: listUrl) { string in
                        let _ = ITSCParser.shared.parseNewsListHtml(html: string, modelsArray: weakSelf!.allModelsArray, startIndex: 0)
                        weakSelf!.resultModelsArray = weakSelf!.allModelsArray
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
        return self.resultModelsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = self.resultModelsArray[indexPath.row] as! newsItemModel
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    //MARK: searchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == "") {
            self.resultModelsArray = self.allModelsArray
        }
        else {
            self.resultModelsArray = []
            for cellModel in (self.allModelsArray as! [newsItemModel]) {
                if(cellModel.title!.lowercased().hasPrefix(searchText.lowercased())){
                    self.resultModelsArray.add(cellModel)
                }
            }
        }
        self.tableView.reloadData()
    }


    //MARK: private methods
    func _handleTapCell(cell: pageTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let cellModel = self.resultModelsArray[indexPath!.row] as! newsItemModel
        let url = self.urlString?.appending(cellModel.urlString ?? "") ?? ""
        let pageVC = webPageViewController.init(pageUrl: url)
        self.navigationController?.pushViewController(pageVC, animated: true)
    }
}
