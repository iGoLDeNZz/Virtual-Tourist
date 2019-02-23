//
//  PinAnnotation.swift
//  Virtual Tourist
//
//  Created by Yousef Almassad on 20/02/2019.
//  Copyright © 2019 Yousef Almassad. All rights reserved.
//

import Foundation
import MapKit


class PinAnnotation: MKPointAnnotation{
    
    var pinObject: Pin!
    
    init(pin: Pin){
        super.init()
        self.pinObject = pin
    }
    
    override init() {
        super.init()
    }
}
