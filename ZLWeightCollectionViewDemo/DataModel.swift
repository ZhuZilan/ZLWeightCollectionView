//
//  DataModel.swift
//  ZLWeightCollectionViewDemo
//
//  Created by 子澜 on 16/4/26.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

class DataModel {
    
    // content of data
    var content: String = "content"
    
    // extra values for weighted display
    var weight: Int = 0
    var colour: UIColor = UIColor.black
    var selected: Bool = false
    
    // pre-calculated size
    var idealSize: CGSize = CGSize.zero
}
