//
//  DemoCollectionViewCell.swift
//  ZLWeightCollectionViewDemo
//
//  Created by 子澜 on 16/4/26.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

class DemoCollectionViewCell: UICollectionViewCell {
    
// MARK: - Identifier
    
    static let identifier: String = "DemoCollectionViewCell"
    
// MARK: - Control
    
    fileprivate weak var contentLabel: UILabel!
    fileprivate weak var selectionCover: UIView!
    
// MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createViews()
    }
    
    func createViews() {
        
        contentLabel = {
            let label = UILabel()
            self.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 18)
            label.textColor = RGB(0)
            label.textAlignment = NSTextAlignment.center
            return label
        } ()
        
        selectionCover = {
            let view = UIView()
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = RGB(255, 255, 255, alpha: 0.5)
            view.isHidden = true
            return view
        } ()
        
        self.createConstraints()
    }
    
    func createConstraints() {
        let vflviews: [String: AnyObject] = [
            "contentLabel": contentLabel,
            "selectionCover": selectionCover
        ]
        let vflformats: [String] = [
            "H:|-0-[contentLabel]-0-|",
            "V:|-0-[contentLabel]-0-|",
            "H:|-0-[selectionCover]-0-|",
            "V:|-0-[selectionCover]-0-|"
        ]
        
        var constraints: [NSLayoutConstraint] = []
        for vflformat in vflformats {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: vflformat, options: [], metrics: nil, views: vflviews)
        }
        
        self.addConstraints(constraints)
    }
    
// MARK: - Data Operation
    
    func fillModel(_ model: DataModel?) {
        guard let model = model else {
            return
        }
        
        self.backgroundColor = model.colour
        self.contentLabel.text = "\(model.weight)"
        self.selectionCover.isHidden = !model.selected
//        self.contentLabel.textColor = model.selected ? RGB(128) : RGB(0)
    }
    
}
