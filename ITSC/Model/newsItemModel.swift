//
//  cellModel.swift
//  ITSC
//
//  Created by nju on 2021/11/12.
//

import UIKit

class newsItemModel: NSObject {
    var title : String?
    var urlString : String?
    var time : String?
    
    init(title: String, urlString: String, time: String) {
        self.time = time
        self.title = title
        self.urlString = urlString
    }
}
