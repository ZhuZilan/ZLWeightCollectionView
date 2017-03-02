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
    
    fileprivate weak var headerView: UIView!
    fileprivate weak var headerLabel: UILabel!
    fileprivate weak var reloadButton: UIButton!
    fileprivate weak var demoCollectionView: UICollectionView!
    
// MARK: - Constant
    
// MARK: - Configuration
    
    var inGroupSplits: [Int] = [] {
        didSet {
            if inGroupSplits.count == 0 {
                inGroupSplits = [1]
            }
            
            _groupVolumn = 0
            for (i, split) in inGroupSplits.enumerated() {
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
    
    fileprivate var _groupVolumn: Int = 1
    
// MARK: - Data
    
    var dataSource: [DataModel] = []
    var currentSelectedIndex: Int = -1
    
// MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.edgesForExtendedLayout = UIRectEdge()
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
                label.font = UIFont.systemFont(ofSize: 20)
                label.text = "Weight Mechanism"
                label.textColor = RGB(230)
                label.textAlignment = NSTextAlignment.center
                return label
            } ()
            
            reloadButton = {
                let button = UIButton(type: UIButtonType.custom)
                view.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("Reload", for: UIControlState())
                button.setTitleColor(RGB(230), for: UIControlState())
                button.setTitleColor(RGB(127), for: UIControlState.highlighted)
                return button
            } ()
            
            return view
        } ()
        
        demoCollectionView = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
            let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
            self.view.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.backgroundColor = RGB(25)
            collectionView.register(DemoCollectionViewCell.self, forCellWithReuseIdentifier: DemoCollectionViewCell.identifier)
            collectionView.dataSource = self
            collectionView.delegate = self
            return collectionView
        } ()
    }
    
    /** Make constraints using visual format language. */
    func createConstraints() {
        let vflmetrics: [String: AnyObject] = ["navSize": CGFloat(66) as AnyObject]
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
            constraints += NSLayoutConstraint.constraints(withVisualFormat: vflformat, options: [], metrics: vflmetrics, views: vflviews)
        }
        
        self.view.addConstraints(constraints)
    }
    
    func createInteractions() {
        self.reloadButton.addTarget(self, action: #selector(DemoViewController.reloadButtonDidClick(_:)), for: UIControlEvents.touchUpInside)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
// MARK: - Interaction
    
    func reloadButtonDidClick(_ sender: UIButton) {
        // here should lies a duplication checking mechanism
        // to avoid duplicate clicks.
        
        // simulate data and reload collection view.
        DispatchQueue(label: "ZL.Util.GlobalQueueLabel").async { [weak self] in
            
            // do data calculations in sub thread
            self?.simulateDataSource()
            self?.preCalculateCellSizeForDataSource()
            
            // and update ui in main thread
            DispatchQueue.main.async { [weak self] in
                self?.demoCollectionView.reloadData()
            }
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
        for (i, model) in dataSource.enumerated() {
            model.idealSize = cellSizeAtIndex(i)
        }
    }
    
    /** Calculate cell size at argument index. */
    func cellSizeAtIndex(_ index: Int) -> CGSize {
        guard let model = dataSource.objectAtIndex(index) else {
            return CGSize.zero
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
        
        return CGSize(width: cellWidth, height: screenHeight * 0.15)
    }
    
// MARK: - Protocol - Collection View
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1, 1, 1, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource.objectAtIndex(indexPath.item)?.idealSize ?? CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DemoCollectionViewCell.identifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? DemoCollectionViewCell)?.fillModel(dataSource.objectAtIndex(indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var indexPaths = [indexPath]
        if 0 <= currentSelectedIndex && currentSelectedIndex < dataSource.count && currentSelectedIndex != indexPath.item {
            indexPaths.append(IndexPath(item: currentSelectedIndex, section: 0))
            dataSource.objectAtIndex(currentSelectedIndex)?.selected = false
        }
        
        currentSelectedIndex = indexPath.item
        dataSource.objectAtIndex(indexPath.item)?.selected = !(dataSource.objectAtIndex(indexPath.item)?.selected ?? false)
        collectionView.reloadItems(at: indexPaths)
    }
    
}

