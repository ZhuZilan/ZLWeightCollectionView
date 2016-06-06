//
//  DemoViewController.swift
//  ZLWeightCollectionViewDemo
//
//  Created by 子澜 on 16/4/26.
//  Copyright © 2016年 杉玉府. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{
    
// MARK: - Control
    
    private weak var headerView: UIView!
    private weak var headerLabel: UILabel!
    private weak var reloadButton: UIButton!
    private weak var demoCollectionView: UICollectionView!
    
// MARK: - Constant
    
// MARK: - Configuration
    
    var inGroupSplits: [Int] = [] {
        didSet {
            if inGroupSplits.count == 0 {
                inGroupSplits = [1]
            }
            
            _groupVolumn = 0
            for (i, split) in inGroupSplits.enumerate() {
                if split <= 0 {
                    inGroupSplits[i] = 1
                }
                
                _groupVolumn += inGroupSplits[i]
            }
        }
    }
    
    var groupVolumn: Int {
        get {
            return _groupVolumn
        }
    }
    
    private var _groupVolumn: Int = 1
    
// MARK: - Data
    
    var dataSource: [DataModel] = []
    var currentSelectedIndex: Int = -1
    
// MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.edgesForExtendedLayout = UIRectEdge.None
        self.createViews()
        self.createConstraints()
        self.createInteractions()
        
        // configure splits and simulate data
        self.inGroupSplits = [2, 4, 3]
        self.reloadButtonDidClick(reloadButton)
    }
    
    /** Create and bind views. */
    func createViews() {
        
        headerView = {
            let view = UIView()
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = RGB(66, 70, 73)
            
            headerLabel = {
                let label = UILabel()
                view.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = UIFont.systemFontOfSize(20)
                label.text = "Weight Mechanism"
                label.textColor = RGB(230)
                label.textAlignment = NSTextAlignment.Center
                return label
            } ()
            
            reloadButton = {
                let button = UIButton(type: UIButtonType.Custom)
                view.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("Reload", forState: UIControlState.Normal)
                button.setTitleColor(RGB(230), forState: UIControlState.Normal)
                button.setTitleColor(RGB(127), forState: UIControlState.Highlighted)
                return button
            } ()
            
            return view
        } ()
        
        demoCollectionView = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
            let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
            self.view.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.backgroundColor = RGB(25)
            collectionView.registerClass(DemoCollectionViewCell.self, forCellWithReuseIdentifier: DemoCollectionViewCell.identifier)
            collectionView.dataSource = self
            collectionView.delegate = self
            return collectionView
        } ()
    }
    
    /** Make constraints using visual format language. */
    func createConstraints() {
        let vflmetrics: [String: AnyObject] = ["navSize": CGFloat(66)]
        let vflviews: [String: AnyObject] = [
            "headerView": headerView,
            "headerLabel": headerLabel,
            "reloadButton": reloadButton,
            "demoCollectionView": demoCollectionView
        ]
        let vflformats: [String] = [
            "H:|-0-[headerView]-0-|",
            "H:|-navSize-[headerLabel]-0-[reloadButton(==navSize)]-0-|",
            "V:|-20-[headerLabel]-0-|",
            "V:|-20-[reloadButton]-0-|",
            "H:|-0-[demoCollectionView]-0-|",
            "V:|-0-[headerView(==64)]-0-[demoCollectionView]-0-|"
        ]
        
        var constraints: [NSLayoutConstraint] = []
        for vflformat in vflformats {
            constraints += NSLayoutConstraint.constraintsWithVisualFormat(vflformat, options: [], metrics: vflmetrics, views: vflviews)
        }
        
        self.view.addConstraints(constraints)
    }
    
    func createInteractions() {
        self.reloadButton.addTarget(self, action: "reloadButtonDidClick:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
// MARK: - Interaction
    
    func reloadButtonDidClick(sender: UIButton) {
        // here should lies a duplication checking mechanism
        // to avoid duplicate clicks.
        
        // simulate data and reload collection view.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {[weak self] () -> Void in
                
            // do data calculations in sub thread
            self?.simulateDataSource()
            self?.preCalculateCellSizeForDataSource()
                
            // and update ui in main thread
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                dispatch_get_main_queue(), { [weak self] () -> Void in
                self?.demoCollectionView.reloadData()
            })
        }
    }
    
// MARK: - Data Operation
    
    /** Simulate random data source models. */
    func simulateDataSource() {
        dataSource = []
        let randomCount = Int(30 + arc4random()%20)
        for i in 0...randomCount {
            let model = DataModel()
            model.content = "CONTENT \(i)"
            model.weight = Int(50 + arc4random()%100)
            model.colour = RGB(min(100 + model.weight, 255))
            dataSource.append(model)
        }
    }
    
    /** Pre calculate cell size for data source. */
    func preCalculateCellSizeForDataSource() {
        for (i, model) in dataSource.enumerate() {
            model.idealSize = cellSizeAtIndex(i)
        }
    }
    
    /** Calculate cell size at argument index. */
    func cellSizeAtIndex(index: Int) -> CGSize {
        guard let model = dataSource.objectAtIndex(index) else {
            return CGSizeZero
        }
        
        var cellWidth:          CGFloat = 0.0
        
        let groupIndex:         Int = index / groupVolumn   // count each 'groupVolumn' items as a group
        let itemIndexInGroup:   Int = index % groupVolumn   // index for item in itselves' group (0..<groupVolumn)
        var inGroupSplitAnchor: Int = 0                     // summary of all splits before current line
        
        // sum each line's weight,
        for splitIndex in 0..<inGroupSplits.count {
            let lineVolumn = inGroupSplits[splitIndex]      // volumn of current line
            if itemIndexInGroup < inGroupSplitAnchor + lineVolumn {
                var sumWeight = 0
                for lineIndex in 0..<lineVolumn {           // loop to sum all weight in a line
                    sumWeight += dataSource.objectAtIndex(groupIndex * groupVolumn + (inGroupSplitAnchor + lineIndex))?.weight ?? 0
                }
                
                // calculate cell width: divide current weight by line weight summary
                cellWidth = ceil((screenWidth - CGFloat(lineVolumn + 1)) * CGFloat(model.weight) / CGFloat(sumWeight) - 1)
                break
            } else {
                inGroupSplitAnchor += lineVolumn            // index is not in current line,
                continue                                    // so continue after move splitter anchor.
            }
        }
        
        return CGSizeMake(cellWidth, screenHeight * 0.15)
    }
    
// MARK: - Protocol - Collection View
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1, 1, 1, 1)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource.objectAtIndex(indexPath.item)?.idealSize ?? CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DemoCollectionViewCell.identifier, forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as? DemoCollectionViewCell)?.fillModel(dataSource.objectAtIndex(indexPath.item))
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        var indexPaths = [indexPath]
        if 0 <= currentSelectedIndex && currentSelectedIndex < dataSource.count && currentSelectedIndex != indexPath.item {
            indexPaths.append(NSIndexPath(forItem: currentSelectedIndex, inSection: 0))
            dataSource.objectAtIndex(currentSelectedIndex)?.selected = false
        }
        
        currentSelectedIndex = indexPath.item
        dataSource.objectAtIndex(indexPath.item)?.selected = !(dataSource.objectAtIndex(indexPath.item)?.selected ?? false)
        collectionView.reloadItemsAtIndexPaths(indexPaths)
    }
    
}

