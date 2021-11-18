# iw03-youneta
181860009 陈香秀

# 作业要求：
1. App界面设计见模板工程的Main Storyboard，首届面通过tab bar controller分为5个栏目
2. 前4个分别对应网站4个信息栏目（如下），下载list.htm内容并将新闻条目解析显示在Table View中
   - https://itsc.nju.edu.cn/xwdt/list.htm
   - https://itsc.nju.edu.cn/tzgg/list.htm
   - https://itsc.nju.edu.cn/wlyxqk/list.htm
   - https://itsc.nju.edu.cn/aqtg/list.htm
3. 点击table view中任意一个cell，获取该cell对应新闻的详细内容页面，解析内容并展示在内容详情场景中
4. 最后一个栏目显示 https://itsc.nju.edu.cn/main.htm 最后“关于我们”部分的信息

# 运行录屏
https://www.bilibili.com/video/BV1o3411878i

# 实现细节
实际上这次作业依然放弃了storyboard而是纯代码写UI。

## 网络通信模块
  这里把网络相关的做成了一个模块`networkManager`，网络请求相关的部分都由这个模块负责，开放接口`fetchData`供外界调用，同时提供`completionBlk`回调闭包供调用者得知请求完成并对获取到的请求html进行处理解析。
  ``` swift 
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
   ```
   这个请求方法的写法参考了课件上的写法。
   在vc中调用：
   ``` swift   
      init(style: UITableView.Style, pageName: String, urlString: String) {
         ...
         DispatchQueue.global().async {
            self._fetchData(url: urlString)
         }
         ...
      }
      func _fetchData(url: String) {
         weak var weakSelf = self
         var listUrl = url.appendingFormat("/list.htm")
         networkManager.shared.fetchData(url: listUrl) { string in
            let result = ITSCParser.shared.parseNewsListHtml(html: string, modelsArray: weakSelf!.allModelsArray, startIndex: 1)
            weakSelf!.resultModelsArray = weakSelf!.allModelsArray
            ...
            DispatchQueue.main.async {
                  weakSelf?.tableView.reloadData()
            }
         }
         ...
      }
   ```
   值得注意的是，涉及UI的操作都要放到主线程来做，而网络请求则可以放到其他线程异步执行，然后回调时回到主线程执行UI相关的操作。

## 解析html
   这个我认为是这次作业的最大工作量及难点来源。
   这里采用了`swiftSoup`库来辅助解析，核心思路其实就像数学找规律题对着答案反推，从初步解析html的结果中抽取关键字段的内容（例如新闻列表html中的`class="col_news_con"`这一节的内容，即为当前页面的新闻列表），然后再逐步深入，根据各个字段把关键信息抽取出来。同样的，我把这一部分解析方法独立成一个`ITSCParser`模块，暴露接口以供调用。
   ``` swift
      // 解析新闻列表
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
            ... // 逐步抽取各个关键字段（标题、时间、url）并生成model加入modelsArray中，返回值为每页个数、当前页数、总页数这三个字段信息
         }
      }
      catch Exception.Error(let type, let message) {
         print(type, message)
      } catch {
         print("error")
      }
      return (0, 0, 0)
   }
   ```


## vc
   ### 新闻列表
   四个新闻列表页面采用了同一个模板的viewcontroller（`pageTableViewController`）来实现，初始化时传入对应要展示的页面的url，然后在初始化时调用网络模块中的`fetchData`方法，在请求完成的回调中调用解析模块的对应方法对请求得到的html进行解析，然后回到主线程中对UI进行操作。   
   值得注意的是，由于可能不只有一页，而作业要求展示所有的新闻，因此在拿到返回值后需要判断当前页数和总页数是否相等，如不相等则需要继续请求并解析剩下页数的内容，这一部分的内容放在vc中交由vc判断并执行。
   ``` swift
      let result = ITSCParser.shared.parseNewsListHtml(html: string, modelsArray: weakSelf!.allModelsArray, startIndex: 1)
      ...//判断返回值的当前页与总页数，如不相等则继续请求并解析。
   ```

   ### 新闻页面
   这里采用了`UIScrollView`来展示新闻内容，在


# 总结反思
1. 首先是我认为还可以优化的地方，我想还是很多的，例如进一步解析新闻内容页的html的文本属性（如字体、大小、颜色、对齐方式等等）、对一定数量的内容进行缓存，在下次启动app时先读取缓存对UI进行初始化、在网络请求完成时刷新UI，对`tableView`设置一次请求的项目上限而非一次性全部加载完所有条目，在下拉到底时再继续请求一定数量的项目以减轻负担并加速，对新闻内容中的url链接做一个外链点击跳转至浏览器……总的来说我认为可以优化的地方还有很多，我觉得想要继续做的话可以做的东西远比想象的多。
2. 这次作业最大的收获无非是对于网络通信及多线程这块以及对html的解析的学习。