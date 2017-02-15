//
//  ViewController.swift
//  AppStoreClone
//
//  Created by Emmanuoel Haroutunian on 2/14/17.
//  Copyright © 2017 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class FeaturedAppsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  private let cellId = "cellId"
  private let largeCellId = "largeCellId"
  
  var appCategories: [AppCategory]?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.backgroundColor = .white
    collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(LargeCategoryCell.self, forCellWithReuseIdentifier: largeCellId)
    
    AppCategory.fetchFeaturedApps { (appCategories) in
      
      self.appCategories = appCategories
      self.collectionView?.reloadData()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: Collection View Methods
  // Number of Items
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return appCategories?.count ?? 0
  }
  
  // Create Cells
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.item == 2 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: largeCellId, for: indexPath) as! LargeCategoryCell
      cell.appCategory = appCategories?[indexPath.item]
      return cell
    }
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
    cell.appCategory = appCategories?[indexPath.item]
    return cell
  }
  
  // Set Cell Size
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if indexPath.item == 2 {
      return CGSize(width: view.frame.width, height: 160.0)
    }
    return CGSize(width: view.frame.width, height: 230.0)
  }
  
}
