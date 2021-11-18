//
//  ITSCParser.swift
//  ITSC
//
//  Created by nju on 2021/11/14.
//

import UIKit
import SwiftSoup

enum ITSCPageContentType {
    case contentTypeTitle
    case contentTypeMeta
    case contentTypeImg
    case contentTypeText
}


class ITSCParser: NSObject {
    //MARK: SingletonClass
    static let shared = ITSCParser()
    private override init() {}
    override func copy() -> Any {
        return self
    }
    override func mutableCopy() -> Any {
        return self
    }
    
    //MARK: parse ITSC
    func parseNewsListHtml(html: String, modelsArray: NSMutableArray, startIndex:Int) -> (perCount:Int, currPage: Int, allPages: Int){
        do {
            let doc: Document = try SwiftSoup.parse(html)
            var newsElement: Element?
            let elements = try doc.getAllElements()
            for element in elements {
                let ele = try element.select("[class=col_news_con]").first()
                if(ele != nil) {
                    newsElement = ele
                    break
                }
            }
            
            if(newsElement != nil) {
            
                let perCountElement = try newsElement?.select("[class=per_count]").first()
                let allCountElemnt = try newsElement?.select("[class=all_count]").last()
                let currPageElement = try newsElement?.select("[class=curr_page]").first()
                let allPagesElement = try newsElement?.select("[class=all_pages]").first()
                let perCount = Int(try (perCountElement?.text() ?? "0"))!
                let allCount = Int(try (allCountElemnt?.text() ?? "0"))!
                let currPage = Int(try (currPageElement?.text() ?? "0"))!
                let allPages = Int(try (allPagesElement?.text() ?? "0"))!
                var i:Int = 0
                var index:Int = startIndex
                while(i < perCount && index < allCount) {
                    let selectString = String.init(format: "[class=news n%d clearfix]", index)
                    let news = try newsElement?.select(selectString).first()
                    let title = try news?.select("a").first()?.attr("title")
                    let time = try news?.select("[class=news_meta]").first()?.text()
                    let newsUrl = try news?.select("a").first()?.attr("href")
                    if(title != nil && newsUrl != nil && time != nil) {
                        let newsModel = newsItemModel(title: title ?? "", urlString: newsUrl ?? "", time: time ?? "")
                        modelsArray.add(newsModel)
                    }
                    if(index > 15) {
                        print("hello")
                    }
                    i += 1
                    index += 1
                }
                return (perCount, currPage, allPages)
            }
        }
        catch Exception.Error(let type, let message) {
            print(type, message)
        } catch {
            print("error")
        }
        return (0, 0, 0)
    }
    
    func parseNewsPageHTML(html: String, modelsArray: NSMutableArray) {
        do {
//            print(html)
            let doc: Document = try SwiftSoup.parse(html)
            let articleElemnt = try doc.select("[class=article]").first()
            
            guard let title = try articleElemnt?.select("[class=arti_title]").first()?.text() else { return }
            let titleModel = ITSCNewsTextModel(text: title)
            modelsArray.add([ITSCPageContentType.contentTypeTitle, titleModel])
                        
//            let content = try articleElemnt?.select("[class=wp_articlecontent]").first()?.text()
//            print(content)
            let phases = try articleElemnt?.select("p")
            for phase in phases! {
                let artiMeta = try phase.select("[class=arti_metas]").first()?.text()
                if(artiMeta != nil) {
                    let metaModel = ITSCNewsTextModel(text: artiMeta ?? "")
                    modelsArray.add([ITSCPageContentType.contentTypeMeta, metaModel])
                    continue
                }
                
                let img = try phase.select("img").first()
                if(img != nil) {
                    let imgUrl = try img?.attr("src")
                    let imgHeight = try img?.attr("height") ?? "0"
                    let imgWidth = try img?.attr("width") ?? "0"
                    let imgModel = ITSCNewsImgModel(imgUrl: imgUrl ?? "", imgHeight: Double(imgHeight) ?? 0, imgWidth: Double(imgWidth) ?? 0)
                    modelsArray.add([ITSCPageContentType.contentTypeImg, imgModel])
                    continue
                }
                
                let phaseText = try phase.text()
                let textModel = ITSCNewsTextModel(text: phaseText)
                modelsArray.add([ITSCPageContentType.contentTypeText, textModel])
            }
        }
        catch Exception.Error(let type, let message) {
            print(type, message)
        } catch {
            print("error")
        }
    }
    
    func parseAboutUsHtml(html: String, stringArray: NSMutableArray) {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let detailElement = try doc.select("[id=wp_news_w91]")
            let elements = try detailElement.select("[class=news_box]")
            for element in elements {
                stringArray.add(try element.text())
            }
//            print(try detailElement.text())
        }
        catch Exception.Error(let type, let message) {
            print(type, message)
        } catch {
            print("error")
        }
    }
}
