//
//  GridCollectionViewController.swift
//  HeroExamples
//
//  Created by Luke Zhao on 2016-12-08.
//  Copyright © 2016 Luke Zhao. All rights reserved.
//

import UIKit
import Hero
import ChameleonFramework

class GridImageCell:UICollectionViewCell{
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var detailTextLabel: UILabel!
}

class GridCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let currentCell = sender as? GridImageCell,
      let vc = segue.destination as? ImageViewController,
      let currentCellIndex = collectionView!.indexPath(for: currentCell){
      vc.selectedIndex = currentCellIndex
      vc.view.backgroundColor = UIColor.white
      vc.collectionView!.backgroundColor = UIColor.white
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 50
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! GridImageCell

    let image = UIImage(named: "Unsplash\(indexPath.item % 10)")!
    cell.heroModifiers = "fade translate(0, 20)"
    cell.imageView?.image = image
    cell.imageView?.heroID = "image_\(indexPath.item)"
    cell.textLabel?.text = "Item \(indexPath.item)"
    cell.detailTextLabel?.text = "Description \(indexPath.item)"
    cell.backgroundColor = UIColor(averageColorFrom: image)

    return cell
  }

  @IBAction func toList(_ sender: Any) {
    let next = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as! ListTableViewController
    next.tableView.contentOffset.y = collectionView!.contentOffset.y + collectionView!.contentInset.top
    heroReplaceViewController(with: next)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width / 3, height: 52*3)
  }
}

extension GridCollectionViewController:HeroViewControllerDelegate{
  func heroWillStartAnimatingTo(viewController: UIViewController) {
    if let _ = viewController as? ImageViewController,
       let index = collectionView!.indexPathsForSelectedItems?[0],
       let cell = collectionView!.cellForItem(at: index) as? GridImageCell{
      let cellPos = view.convert(cell.imageView.center, from: cell)
      collectionView!.heroModifiers = "scale(\(3)) translate(\(view.center.x - cellPos.x),\(view.center.y + collectionView!.contentInset.top/2/3 - cellPos.y)) clearSubviewClasses fade"
    } else {
      collectionView!.heroModifiers = "cascade(0.02, topToBottom)"
    }
  }
  
  func heroWillStartAnimatingFrom(viewController: UIViewController) {
    if let vc = viewController as? ImageViewController,
      let originalCellIndex = vc.selectedIndex,
      let currentCellIndex = vc.collectionView?.indexPathsForVisibleItems[0] {
      collectionView!.heroModifiers = "cascade(0.02, topToBottom)"
      if !collectionView!.indexPathsForVisibleItems.contains(currentCellIndex){
        // make the cell visible
        collectionView!.scrollToItem(at: currentCellIndex,
                                    at: originalCellIndex < currentCellIndex ? .bottom : .top,
                                    animated: false)
      }
    } else {
      collectionView!.heroModifiers = "cascade(0.02, topToBottom, 0.2)"
    }
  }
}
