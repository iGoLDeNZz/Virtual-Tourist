//
//  Client.swift
//  Virtual Tourist
//
//  Created by Yousef Almassad on 20/02/2019.
//  Copyright © 2019 Yousef Almassad. All rights reserved.
//

import Foundation
import Alamofire

struct Client {
    
    static func getPhoto(latitude: Double, longitude: Double, page: Int? = 1, invoker: UIViewController, complitionHandler:@escaping ([String]?) -> Void){
        
        let url = constructURL(latitude: latitude, longitude: longitude, page: page!)
        Alamofire.request(url).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                if let result = (value as! [String:Any])["photos"] as? [String:Any]{
                    let photos = result["photo"] as! [[String:Any]]
                    
                    getArrayOfImageURL(photos: photos, complitionHandler: { (urls) in
                        complitionHandler(urls)
                    })
                }
                else{
                    guard let stat = (value as! [String:Any])["stat"] as? String else {return}
                    if stat == "fail"{
                        guard let message = (value as! [String:Any])["message"] as? String else { return }
                        showAlert(errorContent: message, title: "Error", target: invoker)
                    }
                }
                
            case .failure(let error):
                showAlert(errorContent: error.localizedDescription, title: "Error", target: invoker)
            }
        }
    }
    
    static func getArrayOfImageURL(photos: [[String:Any]], complitionHandler:@escaping ([String]?) -> Void) {
        
        var stringURLs = [String]()
        for photo in photos {
            if let url = photo["url_m"] as? String {
                stringURLs.append(url)
            }
        }
        complitionHandler(stringURLs)
    }
    
    static func constructURL(latitude: Double, longitude: Double, page: Int) -> URL {
        
        var strinURL  = "\(Constant.URL.baseURL)"
        strinURL += "\(Constant.API.key)"
        strinURL += "\(Constant.URL.latitude)\(latitude)"
        strinURL += "\(Constant.URL.longitude)\(longitude)"
        strinURL += "\(Constant.URL.extras)"
        strinURL += "\(Constant.URL.perPage)\(Constant.URL.perPageValue)"
        strinURL += "\(Constant.URL.page)\(page)"
        strinURL += "\(Constant.URL.format)"
        strinURL += "\(Constant.URL.callBack)"
        
        let url = URL(string: strinURL)
        
        return url!
    }
    
    static func showAlert(errorContent: String, title: String, target: UIViewController){
        
        let alert = UIAlertController(title: title, message: errorContent, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(action)
        
        alert.view.tintColor = #colorLiteral(red: 1, green: 0.6, blue: 0, alpha: 1)
        target.present(alert, animated: true, completion: nil)
    }
}


