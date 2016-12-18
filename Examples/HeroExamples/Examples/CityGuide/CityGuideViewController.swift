//
//  CityGuideViewController.swift
//  HeroTransitionExample
//
//  Created by Luke Zhao on 2016-11-23.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class CityGuideViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  var cities = City.cities
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let currentCell = sender as? CityCell,
       let vc = segue.destination as? CityViewController,
       let currentCellIndex = collectionView.indexPath(for: currentCell){
      vc.selectedIndex = currentCellIndex
      
      for indexPath in collectionView.indexPathsForVisibleItems{
        if let cell = collectionView.cellForItem(at: indexPath) as? CityCell,
          indexPath != currentCellIndex {
          let beforeCurrentCell = indexPath < currentCellIndex
          // want right side cells to slide right, and left side cells to slide left
          cell.heroModifiers = "fade translate(\(beforeCurrentCell ? -100 : 100),0)"
        }
      }
    }
  }
}

extension CityGuideViewController:UICollectionViewDataSource, UICollectionViewDelegate{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
    return cities.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! CityCell
    cell.city = cities[indexPath.item]
    return cell
  }
}
