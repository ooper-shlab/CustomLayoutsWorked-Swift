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
        self.collectionView!.register(MyCustomCell.self, forCellWithReuseIdentifier: ClassCellID)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: EmptyCellID)
        self.collectionView!.register(MyConnectionView.self, forSupplementaryViewOfKind: "ConnectionViewKind", withReuseIdentifier: SupplementaryViewID)
        self.collectionView!.reloadData()
        self.collectionView!.backgroundColor = UIColor.white
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
    
    @discardableResult
    private func fillNumRowsForClassAndChildren(_ classInfo: ClassInfo, inSection section: Int) -> Int {
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
    func numRowsForClassAndChildrenAtIndexPath(_ indexPath: IndexPath) -> Int {
        let item = indexPath.item
        let section = indexPath.section
        if section < classInfoBySection.count
            && item < classInfoBySection[section].count {
            return classInfoBySection[section][item].numRowsForClassAndChildren
        } else {
            return 0
        }
    }
    func numChildrenForClassAtIndexPath(_ indexPath: IndexPath) -> Int {
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
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return classInfoBySection.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classInfoBySection[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        let section = indexPath.section
        if section < classInfoBySection.count
            && item < classInfoBySection[section].count
        {
            let classInfo = classInfoBySection[section][item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClassCellID, for: indexPath) as! MyCustomCell
            cell.textLabel.text = classInfo.name
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCellID, for: indexPath)
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryViewID, for: indexPath) as! MyConnectionView
        return view
    }
}

