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
  private let headerId = "headerId"
  
  var featuredApps: FeaturedApps?
  var appCategories: [AppCategory]?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.backgroundColor = .white
    collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(LargeCategoryCell.self, forCellWithReuseIdentifier: largeCellId)
    collectionView?.register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    
    AppCategory.fetchFeaturedApps { (featuredApps) in
      self.featuredApps = featuredApps
      self.appCategories = featuredApps.appCategories
      self.collectionView?.reloadData()
    }
    
    navigationItem.title = "Featured Apps"
  }
  
  func showAppDetail(for app: App) {
    let appDetailController = AppDetailController(collectionViewLayout: UICollectionViewFlowLayout())
    appDetailController.app = app
    navigationController?.pushViewController(appDetailController, animated: true)
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
    cell.featuredAppsController = self
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
  
  // Return size for Header View
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.frame.width, height: 120)
  }
  
  // Return Header View
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CollectionHeader
    header.appCategory = featuredApps?.bannerCategory
    
    return header
  }
  
}
