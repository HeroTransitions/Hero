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

class ExampleViewController: UITableViewController {

  var storyboards: [[String]] = [
    [],
    ["Basic", "MusicPlayer", "Menu", "BuiltInTransitions"],
    ["CityGuide", "ImageViewer", "VideoPlayer"],
    ["AppleHomePage", "ListToGrid", "ImageGallery"]
  ]

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomLayoutGuide.length, right: 0)
    tableView.scrollIndicatorInsets = tableView.contentInset
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.item < storyboards[indexPath.section].count {
      let storyboardName = storyboards[indexPath.section][indexPath.item]
      let vc = viewController(forStoryboardName: storyboardName)

      // iOS bug: https://github.com/lkzhao/Hero/issues/106 https://github.com/lkzhao/Hero/issues/79
      DispatchQueue.main.async {
        self.present(vc, animated: true, completion: nil)
      }
    }
  }
}
