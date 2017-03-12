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
import ChameleonFramework

class AnimationSelectHeaderCell: UITableViewCell {
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var heroLogo: TemplateImageView!
  @IBOutlet weak var promptLabel: UILabel!
}

class AnimationSelectTableViewController: UITableViewController {

  var animations: [HeroDefaultAnimationType] = [
    .push(direction: .left),
    .pull(direction: .left),
    .slide(direction: .left),
    .zoomSlide(direction: .left),
    .cover(direction: .up),
    .uncover(direction: .up),
    .pageIn(direction: .left),
    .pageOut(direction: .left),
    .fade,
    .zoom,
    .zoomOut,
    .none
  ]

  var labelColor: UIColor!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = UIColor.randomFlat
    labelColor = UIColor(contrastingBlackOrWhiteColorOn: tableView.backgroundColor!, isFlat: true)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : animations.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let header = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! AnimationSelectHeaderCell
      header.heroLogo.tintColor = labelColor
      header.promptLabel.textColor = labelColor
      header.backButton.tintColor = labelColor
      return header
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
    cell.textLabel!.text = animations[indexPath.item].label
    cell.textLabel!.textColor = labelColor
    return cell
  }

  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath.section == 0 ? nil : indexPath
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = self.storyboard!.instantiateViewController(withIdentifier: "animationSelect")

    // the following two lines configures the animation. default is .auto
    Hero.shared.setDefaultAnimationForNextTransition(animations[indexPath.item])
    Hero.shared.setContainerColorForNextTransition(.lightGray)

    hero_replaceViewController(with: vc)
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.section == 0 ? 300 : 44
  }
}
