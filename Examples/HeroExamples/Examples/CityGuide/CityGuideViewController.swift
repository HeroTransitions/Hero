// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Hero

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
          cell.heroModifiers = HeroComposition().fade().translate(x: beforeCurrentCell ? -100 : 100, y: 0).modifier
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
