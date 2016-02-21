//
//  ViewController.swift
//  CompressApp
//
//  Created by 也许、 on 16/2/21.
//  Copyright © 2016年 K. All rights reserved.
//

import UIKit

class ViewController: UIViewController,NSURLConnectionDataDelegate {

    // 压缩包下载地址
    let zipFilePath = "https://github.com/cocos2d/bindings-generator/archive/v3.zip"
    
    // 文件处理对象
    var fileHandle:NSFileHandle?
    
    // 压缩包文件大小
    var fileContentLength:String?
    var currentContentLength:Int?
    
    // 沙盒中的压缩包路径
    var zipPath:String?
    
    // 解压路径
    var documentPath:NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 压缩指定文件
    @IBAction func zipFiles(sender: UIButton) {
        
        // 压缩包路径 放到了缓存文件夹中
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).last as! NSString
        let zipPath = cachePath.stringByAppendingPathComponent("image.zip")
        
        // 被压缩的文件路径
        let imageArray = [
            NSBundle.mainBundle().pathForResource("11", ofType: "jpeg")!,
            NSBundle.mainBundle().pathForResource("22", ofType: "jpeg")!,
            NSBundle.mainBundle().pathForResource("33", ofType: "jpeg")!
        ]
        
        SSZipArchive.createZipFileAtPath(zipPath, withFilesAtPaths: imageArray)
        
        print("压缩完成,压缩包路径:",zipPath)
        
    }
    
    /**
        压缩指定文件夹路径下的文件
     */
    @IBAction func zipPathOfFile(sender: UIButton) {
        
        // 指定项目中的Images文件夹路径
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last! as NSString
        
        let zipPath = documentPath.stringByAppendingPathComponent("img.zip")
        
        // 沙盒中Document下的Images文件夹 测试的时候需要在下面放置一个文件夹,也可以在指定本机桌面上的文件夹
        let folderPath = documentPath.stringByAppendingPathComponent("Images")
        
        SSZipArchive.createZipFileAtPath(zipPath, withContentsOfDirectory: folderPath)
        
        print("压缩完成,压缩包路径:",zipPath)
        
    }
    
    /**
        解压文件
     */
    @IBAction func unzipFile(sender: UIButton) {
        
        // 压缩包请求下载
        let request = NSURLRequest(URL: NSURL(string: zipFilePath)!)
        NSURLConnection(request: request, delegate: self)
        
    }
    
    /**
        接收响应
     */
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        
        let connResp = response as! NSHTTPURLResponse
        let connDic = connResp.allHeaderFields as NSDictionary
       
        // 文件大小
        self.fileContentLength = connDic.objectForKey("Content-Length") as? String
        print(self.fileContentLength)
        
        self.currentContentLength = 0
        
        // 压缩包路径
        self.documentPath = NSSearchPathForDirectoriesInDomains( .DocumentDirectory, .UserDomainMask, true).last! as NSString
        self.zipPath = self.documentPath!.stringByAppendingPathComponent("gift.zip")
        
        // 创建一个空文件
        NSFileManager.defaultManager().createFileAtPath(zipPath!, contents: nil, attributes: nil)
        
        // 初始化文件处理对象 一定要先有文件才能创建fileHandle,否则创建的文件处理对象将为nil
        self.fileHandle = NSFileHandle(forWritingAtPath: zipPath!)
        
        
    }
    
    // 接收数据
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        // 将写入坐标移动至文件末尾
        self.fileHandle?.seekToEndOfFile()
        
        // 写入沙盒中
        self.fileHandle?.writeData(data)
        
        // 计算下载进度
        self.currentContentLength! += data.length
        let percent = Float(self.currentContentLength!) / Float(self.fileContentLength!)!
        print( String(format: "已下载%.2f%%", percent * 100) )
    }
    
    // 接收数据失败
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print("下载失败")
    }
    
    // 下载完成
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        print("下载完成")
        self.fileHandle?.closeFile()
        self.fileHandle = nil
        
        print("开始解压")
        SSZipArchive.unzipFileAtPath(zipPath, toDestination: self.documentPath! as String)
        print("解压完成")
        print("解压路径:",self.documentPath)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

