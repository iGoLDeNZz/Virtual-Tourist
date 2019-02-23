//
//  Constant.swift
//  Virtual Tourist
//
//  Created by Yousef Almassad on 21/02/2019.
//  Copyright © 2019 Yousef Almassad. All rights reserved.
//

import Foundation

struct Constant {
    
    struct API {
        static let key = "f441f05f6a02d961bbf1a05e15f85c14"
    }
    
    struct URL {
        static let baseURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key="
        static let latitude = "&lat="
        static let longitude = "&lon="
        static let extras = "&extras=url_m"
        static let perPage = "&per_page="
        static let page = "&page="
        static let format = "&format=json"
        static let callBack = "&nojsoncallback=1"
        
        static let perPageValue = "9"
    }
    
    static let segue = "showAlbum"
    static let reuserID = "albumCell"
    
}

// https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=f441f05f6a02d961bbf1a05e15f85c14&lat=1&lon=1&extras=url_m&per_page=12&page=1&format=json&nojsoncallback=1
