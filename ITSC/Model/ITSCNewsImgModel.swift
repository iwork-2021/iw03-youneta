//
//  ITSCNewsImgModel.swift
//  ITSC
//
//  Created by nju on 2021/11/17.
//

import UIKit

class ITSCNewsImgModel: NSObject {
    var imgUrl: String?
    var imgHeight: Double?
    var imgWidth: Double?
    
    init(imgUrl: String, imgHeight: Double, imgWidth: Double) {
        self.imgUrl = imgUrl
        self.imgHeight = imgHeight
        self.imgWidth = imgWidth
    }
}
