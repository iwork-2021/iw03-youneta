//
//  networkManager.swift
//  ITSC
//
//  Created by nju on 2021/11/12.
//

import UIKit
typealias fetchCompletionBlock = (String) -> Void

class networkManager: NSObject {
    
    //MARK: SingletonClass
    static let shared = networkManager()
    private override init() {}
    override func copy() -> Any {
        return self
    }
    override func mutableCopy() -> Any {
        return self
    }
    
    
    //MARK: public methods
    func fetchData(url: String, completionBlock:@escaping fetchCompletionBlock) {
        let url = URL(string: url)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("server error")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html", let data = data, let string = String(data: data, encoding: .utf8) {
                completionBlock(string)
            }
        })
        task.resume()
    }
    
}
