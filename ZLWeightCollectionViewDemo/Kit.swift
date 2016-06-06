//
//  Kit.swift
//  ZLWeightCollectionViewDemo
//
//  Created by 子澜 on 16/4/26.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

let screenWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
let screenHeight: CGFloat = UIScreen.mainScreen().bounds.size.height

func RGB(rgb: Int) -> UIColor {
    return RGB(rgb, rgb, rgb)
}

func RGB(red: Int, _ green: Int, _ blue: Int, alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
}

extension Array {
    func objectAtIndex(index: Int) -> Element? {
        if 0 <= index && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
}
