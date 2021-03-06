//
//  AppDetailController.swift
//  AppStoreClone
//
//  Created by Emmanuoel Haroutunian on 2/16/17.
//  Copyright © 2017 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class AppDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var app: App? {
    didSet {
      
      // escape mechanism
      if app?.screenshots != nil {
        return
      }
      
      if let id = app?.id {
        let urlString = "http://www.statsallday.com/appstore/appdetail?id=\(id)"
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) in
          guard error == nil else {
            print(error!)
            return
          }
          
          do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String, Any>
            
            let appDetail = App()
            appDetail.setValuesForKeys(json)
            
            // This triggers the didSet in an infinite loop, must add escape mechanism before setting app value
            self.app = appDetail
            
            DispatchQueue.main.async {
              self.collectionView?.reloadData()
            }
            
          } catch let error {
            print(error)
          }

        }).resume()
      }
      
    }
  }
  
  private let headerId = "headerId"
  private let cellId = "cellId"
  private let descriptionCellId = "descriptionCellId"
  
  private func descriptionAttributedText() -> NSAttributedString {
    let attributedText = NSMutableAttributedString(string: "Description\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
    
    // Add line spacing after "Description" header
    let style = NSMutableParagraphStyle()
    style.lineSpacing = 10
    let range = NSMakeRange(0, attributedText.string.characters.count)
    attributedText.addAttribute(NSParagraphStyleAttributeName, value: style, range: range)
    
    // Concat app description if not nil
    if let desc = app?.desc {
      attributedText.append(NSAttributedString(string: desc, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 11), NSForegroundColorAttributeName: UIColor.darkGray]))
    }
    
    return attributedText
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.register(AppDetailHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    collectionView?.register(ScreenshotsCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(AppDetailDescriptionCell.self, forCellWithReuseIdentifier: descriptionCellId)
    
    collectionView?.backgroundColor = .white
    collectionView?.alwaysBounceVertical = true
  }
  
  // Return Header View
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! AppDetailHeader
    header.app = app
    
    return header
  }
  
  // Header Size
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.frame.width, height: 170)
  }
  
  // Number of Items
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  // Dequeue Cell
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotsCell
    
    if indexPath.item == 1 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId, for: indexPath) as! AppDetailDescriptionCell
      cell.textView.attributedText = descriptionAttributedText()
      return cell
    }
    cell.app = app
    
    return cell
  }
  
  // Size Cell
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    
    // Return diff size based on Description cell
    // Somehow these options passed into boundRect function of attr string gives us the rect and we use the textfield height to determine cell height
    if indexPath.item == 1 {
      let dummySize = CGSize(width: view.frame.width - 8 - 8, height: 1000)
      let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
      
      let rect = descriptionAttributedText().boundingRect(with: dummySize, options: options, context: nil)
      // Add 30 because it usually cuts off
      return CGSize(width: view.frame.width, height: rect.height + 30)
    }
    
    return CGSize(width: view.frame.width, height: 170)
  }
}

class AppDetailHeader: BaseCell {
  
  var app: App? {
    didSet {
      if let imageName = app?.imageName {
        imageView.image = UIImage(named: imageName)
      }
      if let appName = app?.name {
        nameLabel.text = appName
      }
      
      if let price = app?.price {
        buyButton.setTitle("$\(price)", for: .normal)
      }
    }
  }
  
  let segmentedControl: UISegmentedControl = {
    let sc = UISegmentedControl(items: ["Details","Reviews","Related"])
    sc.tintColor = .darkGray
    sc.selectedSegmentIndex = 0
    return sc
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }()
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 16
    iv.layer.masksToBounds = true
    return iv
  }()
  
  let buyButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("BUY", for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.layer.borderColor = UIColor(red: 0, green: 129/255, blue: 250/255, alpha: 1).cgColor
     button.layer.borderWidth = 1
    button.layer.cornerRadius = 5
    return button
  }()
  
  let dividerView: UIView = {
    let divider = UIView()
    divider.backgroundColor = UIColor.init(white: 0.4, alpha: 0.4)
    return divider
  }()
  
  override func setupViews(){
    addSubview(imageView)
    addSubview(segmentedControl)
    addSubview(nameLabel)
    addSubview(buyButton)
    addSubview(dividerView)
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    buyButton.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    
    imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14).isActive = true
    imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 14).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    
    segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
    segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
    segmentedControl.heightAnchor.constraint(equalToConstant: 34).isActive = true
    segmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
    
    nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
    nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 14).isActive = true
    nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    
    buyButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
    buyButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14).isActive = true
    buyButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    buyButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -56 ).isActive = true
    
    dividerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
    dividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    dividerView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    dividerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    
    // Visual Format Helper Func
//    addConstraints(with: "H:|-14-[v0(100)]", views: imageView)
  }
  
}

extension UIView {
  func addConstraints(with format: String, views: UIView...) {
    var viewsDict = [String: Any]()
    
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      viewsDict[key] = view
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict))
  }
}

class BaseCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupViews() {
    
  }
  
}

class AppDetailDescriptionCell: BaseCell {
  
  let textView: UITextView = {
    let tv = UITextView()
    tv.text = "SAMPLE DESC"
    return tv
  }()
  
  let dividerView: UIView = {
    let divider = UIView()
    divider.backgroundColor = UIColor.init(white: 0.4, alpha: 0.4)
    return divider
  }()
  
  override func setupViews() {
    super.setupViews()
    
    addSubview(textView)
    addSubview(dividerView)
    
    textView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    
    textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
    textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
    textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
    textView.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -4).isActive = true
    
    dividerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14).isActive = true
    dividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    dividerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
  }
  
}
