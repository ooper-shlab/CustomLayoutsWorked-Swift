//
//  ViewController.swift
//  CustomLayoutsWorked
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/15.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit

private let EmptyCellID = "EmptyCellID"
private let ClassCellID = "ClassCellID"
private let SupplementaryViewID = "SupplementaryViewID"

private let classes: [(parent: String, name: String)] = [
    ("", "NSObject"),
        ("NSObject", "NSLayoutConstraint"),
        ("NSObject", "NSLayoutManager"),
        ("NSObject", "NSParagraphStyle"),
            ("NSParagraphStyle", "NSMutableParagraphStyle"),
        ("NSObject", "UIAcceleration"),
        ("NSObject", "UIAccelerometer"),
        ("NSObject", "UIAccessibilityElement"),
        ("NSObject", "UIBarItem"),
            ("UIBarItem", "UIBarButtonItem"),
            ("UIBarItem", "UITabBarItem"),
        ("NSObject", "UIActivity"),
        ("NSObject", "UIBezierPath"),
]
class ClassInfo {
    var name: String
    var children: [ClassInfo] = []
    var numRowsForClassAndChildren: Int = 0
    
    init(name: String) {
        self.name = name
    }
}
class ViewController: UICollectionViewController, MyCustomProtocol {
    
    private var classInfoBySection: [[ClassInfo]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fillClassInfo()
        self.collectionView!.registerClass(MyCustomCell.self, forCellWithReuseIdentifier: ClassCellID)
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: EmptyCellID)
        self.collectionView!.registerClass(MyConnectionView.self, forSupplementaryViewOfKind: "ConnectionViewKind", withReuseIdentifier: SupplementaryViewID)
        self.collectionView!.reloadData()
        self.collectionView!.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fillClassInfo() {
        var classInfoByName: [String: ClassInfo] = Dictionary(minimumCapacity: classes.count)
        classes.forEach {ci in
            let classInfo = ClassInfo(name: ci.name)
            classInfoByName[ci.name] = classInfo
            if let parent = classInfoByName[ci.parent] {
                parent.children.append(classInfo)
            }
        }
        fillNumRowsForClassAndChildren(classInfoByName["NSObject"]!, inSection: 0)
    }
    
    private func fillNumRowsForClassAndChildren(classInfo: ClassInfo, inSection section: Int) -> Int {
        if section < classInfoBySection.count {
            classInfoBySection[section].append(classInfo)
        } else {
            classInfoBySection.append([classInfo])
        }
        if classInfo.children.isEmpty {
            classInfo.numRowsForClassAndChildren = 1
        } else {
            var rows = 0
            for child in classInfo.children {
                rows += fillNumRowsForClassAndChildren(child, inSection: section + 1)
            }
            classInfo.numRowsForClassAndChildren = rows
        }
        return classInfo.numRowsForClassAndChildren
    }

    //MARK: MyCustomProtocol
    func numRowsForClassAndChildrenAtIndexPath(indexPath: NSIndexPath) -> Int {
        let item = indexPath.item
        let section = indexPath.section
        if section < classInfoBySection.count
            && item < classInfoBySection[section].count {
            return classInfoBySection[section][item].numRowsForClassAndChildren
        } else {
            return 0
        }
    }
    func numChildrenForClassAtIndexPath(indexPath: NSIndexPath) -> Int {
        let item = indexPath.item
        let section = indexPath.section
        if section < classInfoBySection.count
            && item < classInfoBySection[section].count {
                return classInfoBySection[section][item].children.count
        } else {
            return 0
        }
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return classInfoBySection.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classInfoBySection[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        let section = indexPath.section
        if section < classInfoBySection.count
            && item < classInfoBySection[section].count
        {
            let classInfo = classInfoBySection[section][item]
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ClassCellID, forIndexPath: indexPath) as! MyCustomCell
            cell.textLabel.text = classInfo.name
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EmptyCellID, forIndexPath: indexPath)
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: SupplementaryViewID, forIndexPath: indexPath) as! MyConnectionView
        return view
    }
}

