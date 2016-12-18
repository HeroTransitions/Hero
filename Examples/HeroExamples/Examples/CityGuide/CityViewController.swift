//
//  CityViewController.swift
//  HeroTransitionExample
//
//  Created by Luke Zhao on 2016-11-23.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class CityViewController: UIViewController {
  var selectedIndex:IndexPath!
  var cities:[City] = City.cities
  
  @IBOutlet weak var collectionView: UICollectionView!
  override func viewDidLoad() {
    super.viewDidLoad()
    view.layoutIfNeeded()
    collectionView.reloadData()
    collectionView.scrollToItem(at: selectedIndex, at: .centeredHorizontally, animated: false)
  }
}

extension CityViewController:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cities.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return view.frame.size
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! CityCell
    cell.useShortDescription = false
    cell.city = cities[indexPath.item]
    return cell
  }
}
