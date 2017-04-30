//
//  AHDiscoverContainer.swift
//  AHPinterest
//
//  Created by Andy Hurricane on 4/27/17.
//  Copyright © 2017 AndyHurricane. All rights reserved.
//

import UIKit

class AHDiscoverVC: UICollectionViewController {
    let navVC = AHDiscoverNavVC()
    let pageLayout = AHPageLayout()
    
    var pageVCs = [UIViewController]()
    
    var categoryArr = [String]()
    
    var itemIndex: Int = -1 {
        didSet {
            self.discoverNavDidSelect(at: itemIndex)
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        collectionView?.frame.origin.y = 64 + AHDiscoverNavCellHeight
        collectionView?.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0 )
        setupCollecitonView()
        
        setupNavVC()
        
        setupPinVCs()
    }

    func setupPinVCs(){
        for _ in 0..<5 {
            let vc = createPinVC()
            pageVCs.append(vc)
        }
    }
    func createPinVC() -> AHPinVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AHPinVC") as! AHPinVC
        vc.refreshLayout.enableHeaderRefresh = false
        vc.showLayoutHeader = true
        
        // setup VC related
        vc.willMove(toParentViewController: self)
        self.addChildViewController(vc)
        vc.didMove(toParentViewController: self)
        
        return vc
    }
    
    func setupCollecitonView() {
        
        let detailCellNIb = UINib(nibName: AHDetailCellID, bundle: nil)
        collectionView?.register(detailCellNIb, forCellWithReuseIdentifier: AHDetailCellID)
        
        pageLayout.scrollDirection = .horizontal
        collectionView?.setCollectionViewLayout(pageLayout, animated: false)
    }
    
    func setupNavVC() {
        navVC.delegate = self
        navVC.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: AHDiscoverNavCellHeight)
        
        navVC.willMove(toParentViewController: self)
        self.addChildViewController(navVC)
        navVC.didMove(toParentViewController: self)
        
        
        navVC.view.willMove(toSuperview: self.view)
        self.view.addSubview(navVC.view)
        navVC.view.didMoveToSuperview()
        
        
        AHNetowrkTool.tool.reloadCategories { (categoryArr: [String]?) in
            if let categoryArr = categoryArr, !categoryArr.isEmpty {
                self.categoryArr.append(contentsOf: categoryArr)
                self.navVC.categoryArr = self.categoryArr
                self.collectionView?.reloadData()
            }
            
        }
    }


}

extension AHDiscoverVC {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let items = collectionView?.visibleCells
        if let items = items, items.count == 1 {
            if let indexPath = collectionView?.indexPath(for: items.first!) {
                self.itemIndex = indexPath.item
                print("itemIndex:\(self.itemIndex)")
            }else{
                fatalError("It has an visible cell without indexPath??")
            }
            
        }else{
            print("visible items have more then 1, problem?!")
        }
    }
}

extension AHDiscoverVC: AHDiscoverNavDelegate {
    func discoverNavDidSelect(at index: Int) {
        print("didSelecte category:\(self.categoryArr[index]) at index:\(index)")
    }
}

extension AHDiscoverVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // At first return, collecitonView.bounds.size is 1000.0 x 980.0
        return CGSize(width: screenSize.width, height: screenSize.height)
    }
    
}

extension AHDiscoverVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AHDetailCellID, for: indexPath) as! AHDetailCell
        
        guard !categoryArr.isEmpty else {
            return cell
        }
        
        let category = categoryArr[indexPath.item]
        let pageVC = pageVCs[indexPath.item] as! AHPinVC
        cell.pageVC = pageVC
        return cell
    }
}


