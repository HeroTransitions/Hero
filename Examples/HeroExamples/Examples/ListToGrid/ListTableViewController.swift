//
//  ListTableViewController.swift
//  HeroExamples
//
//  Created by Luke Zhao on 2016-12-08.
//  Copyright © 2016 Luke Zhao. All rights reserved.
//

import UIKit
import Hero

class ListTableViewCell:UITableViewCell{
  override func layoutSubviews() {
    super.layoutSubviews()
    imageView?.frame.origin.x = 0
    textLabel?.frame.origin.x -= 15
    detailTextLabel?.frame.origin.x -= 15
  }
}


class ListTableViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 50
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)

    cell.heroModifiers = "fade translate(-100, 0)"
    cell.imageView?.heroID = "image_\(indexPath.item)"
    cell.imageView?.image = UIImage(named: "Unsplash\(indexPath.item % 10)")
    cell.textLabel?.text = "Item \(indexPath.item)"
    cell.detailTextLabel?.text = "Description \(indexPath.item)"
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 52
  }
  
  @IBAction func toGrid(_ sender: Any) {
    let next = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "grid") as! GridCollectionViewController
    next.collectionView?.contentOffset.y = tableView.contentOffset.y + tableView.contentInset.top
    heroReplaceViewController(with: next)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let currentCell = sender as? ListTableViewCell,
      let vc = segue.destination as? ImageViewController,
      let currentCellIndex = tableView.indexPath(for: currentCell){
      vc.selectedIndex = currentCellIndex
      vc.view.backgroundColor = UIColor.white
      vc.collectionView!.backgroundColor = UIColor.white
    }
  }
}

extension ListTableViewController:HeroViewControllerDelegate{
  func heroWillStartAnimatingTo(viewController: UIViewController) {
    if let _ = viewController as? GridCollectionViewController{
      tableView.heroModifiers = "clearSubviewClasses"
    } else {
      tableView.heroModifiers = "cascade(0.02)"
    }
  }
  func heroWillStartAnimatingFrom(viewController: UIViewController) {
    if let _ = viewController as? GridCollectionViewController{
      tableView.heroModifiers = "clearSubviewClasses"
    } else {
      tableView.heroModifiers = "cascade(0.02)"
    }
    if let vc = viewController as? ImageViewController,
      let originalCellIndex = vc.selectedIndex,
      let currentCellIndex = vc.collectionView?.indexPathsForVisibleItems[0] {
      if tableView.indexPathsForVisibleRows?.contains(currentCellIndex) != true{
        // make the cell visible
        tableView.scrollToRow(at: currentCellIndex,
                              at: originalCellIndex < currentCellIndex ? .bottom : .top,
                              animated: false)
      }
    }
  }
}
