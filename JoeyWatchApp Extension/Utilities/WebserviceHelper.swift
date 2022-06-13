//
//  WebserviceHelper.swift
//  IwatchDemo Extension
//
//  Created by webwerks on 4/16/18.
//  Copyright © 2018 webwerks. All rights reserved.
//

import WatchKit

import UIKit
let baseUrl:String = "http://dev.auxiliababy.com/"
class WebserviceHelper: NSObject {
    
    static let sharedInstance : WebserviceHelper = {
        let instance = WebserviceHelper()
        return instance
    }()
    
    func callPutDataWithMethod(strMethodName:String,requestDict:Dictionary<String, Any>,isHud:Bool,value:Dictionary<String, Any>,successBlock:@escaping (_ response:Any,_ responseStr: [Dictionary<String, Any>])->Void, errorBlock:@escaping (_ error:Any)->Void)  {
        var urlString = String()
        urlString.append(baseUrl)
        urlString.append("/")
        urlString.append(strMethodName)
        if requestDict.count > 0{
            var i = 0;
            let keysArray = requestDict.keys
            for  key in keysArray {
                if i == 0{
                    urlString.append("?\(key)=\(requestDict[key] as! String)")
                }else{
                    urlString.append("&\(key)=\(requestDict[key] as! String)")
                }
                i += 1
            }
        }
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        let url = NSURL(string: urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        //        print(url!)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "PUT"
        
        if value.count > 0{
            for (key,param) in value{
                request.addValue(param as! String, forHTTPHeaderField: key)
            }
        }
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            if data != nil && error == nil{
                do {
                    //                    let res = String(data: data!, encoding: .utf8)
                    //                    print("res\(String(describing: res))")
                    let responseStr = try JSONSerialization.jsonObject(with: (data)!, options: .mutableContainers) as! [Dictionary<String, Any>]
                    //                    print("responseStr\(responseStr)")
                    DispatchQueue.main.async {
                        successBlock(response!,responseStr)
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        errorBlock(error.localizedDescription)
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    func callGetDataWithMethod(strMethodName:String,requestDict:Dictionary<String, Any>,isHud:Bool,value:Dictionary<String, Any>,successBlock:@escaping (_ response:Any,_ responseStr: Dictionary<String, Any>)->Void, errorBlock:@escaping (_ error:Any)->Void)  {
        DispatchQueue.main.async {
      
        }
        
        var urlString = String()
        urlString.append(baseUrl)
        urlString.append(strMethodName)
        if requestDict.count > 0{
            var i = 0;
            let keysArray = requestDict.keys
            for  key in keysArray {
                if i == 0{
                    urlString.append("?\(key)=\(requestDict[key] as! String)")
                }else{
                    urlString.append("&\(key)=\(requestDict[key] as! String)")
                }
                i += 1
            }
        }
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        let url = NSURL(string: urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        //        print(url!)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        if value.count > 0{
            for (key,param) in value{
                request.addValue(param as! String, forHTTPHeaderField: key)
            }
        }
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            if data != nil && error == nil{
                do {
                    //                    let res = String(data: data!, encoding: .utf8)
                    //                    print(res as Any)
                    let responseStr = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    DispatchQueue.main.async {
                        successBlock(response ?? "",responseStr)
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        errorBlock(error.localizedDescription)
                    }
                }
            }else
            {
                DispatchQueue.main.async {
                    errorBlock(error?.localizedDescription ?? "")
                    print(error?.localizedDescription ?? "")
                }
            }
        })
        dataTask.resume()
    }
    
    func callPostDataWithMethod(methodName:String, requestDict:Dictionary<String, Any> , headerValue: Dictionary<String, Any>, isHud:Bool, successBlock:@escaping (_ response:Any, _ responseStr: Dictionary<String, Any> )->Void, errorBlock:@escaping (_ error:Any)->Void)  -> Void{
        var reqDict : [String:Any] = requestDict
        reqDict["language"]     = "en"
        reqDict["timezone"]     = "\(NSTimeZone.local.identifier)"
        reqDict["v"] = "1.2.4"

        //reqDict["access_token"] = "0675cfd058b18508a3893b58cb39f19df2fbd5dd506db7d0c11acdd86b8ec56f"
        
       var accessToken = "";
        if ((UserDefaults.standard.string(forKey: "wk_access_token")) != nil) {
            accessToken = (UserDefaults.standard.string(forKey: "wk_access_token"))!;
        }
        reqDict["access_token"] = accessToken
        
        let encodedUrl = (baseUrl + methodName).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let serverUrl: URL = URL(string: (encodedUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!)!
        
        var request = URLRequest(url: serverUrl)
        let session = URLSession.shared
        request.httpMethod = "POST"
        if(!requestDict.isEmpty){
            request.httpBody =  self.getParam(reqDict as NSDictionary).data(using: String.Encoding.utf8.rawValue)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 120
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if(data != nil && error == nil){
                do {
                    let responseStr = try JSONSerialization.jsonObject(with: (data)!, options: .mutableContainers) as! Dictionary<String, Any>
                    
                    DispatchQueue.main.async {
                        successBlock(response!,responseStr)
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        errorBlock(error.localizedDescription)
                    }
                }
            }
            else{
                errorBlock((error?.localizedDescription)! as String)
            }
        })
        task.resume()
    }
    
    func getParam(_ params: NSDictionary) -> NSString{
        var passparam : NSString!
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            let theJSONText = NSString(data: jsonData,
                                       encoding: String.Encoding.ascii.rawValue)
            passparam = theJSONText!
        } catch let error as NSError {
            //            print("getParam() \(error)")
            passparam = ""
        }
        //        print("getParam() \(passparam!)")
        return passparam
    }
    
}


