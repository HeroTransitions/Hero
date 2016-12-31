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

public class HeroDefaultAnimator:HeroAnimator{
  var context:HeroContext!
  let animatableOptions:Set<String> = ["fade", "opacity", "position", "size", "cornerRadius", "transform", "scale", "translate", "rotate"]
  var viewContexts:[UIView: HeroDefaultAnimatorViewContext] = [:]

  public func seekTo(timePassed:TimeInterval) {
    for viewContext in viewContexts.values{
      viewContext.seek(timePassed: timePassed)
    }
  }
  
  public func resume(timePassed:TimeInterval, reverse:Bool) -> TimeInterval{
    var duration:TimeInterval = 0
    for view in viewContexts.keys{
      viewContexts[view]!.resume(timePassed: timePassed, reverse: reverse)
      duration = max(duration, viewContexts[view]!.duration)
    }
    return duration
  }
  
  public func temporarilySet(view:UIView, to modifiers:HeroModifiers){
    guard viewContexts[view] != nil else {
      print("HERO: unable to temporarily set to \(view). The view must be running at least one animation before it can be interactively changed")
      return
    }
    viewContexts[view]!.temporarilySet(modifiers:modifiers)
  }

  public func canAnimate(context:HeroContext, view:UIView, appearing:Bool) -> Bool{
    if let modifierNames = context.modifierNames(for: view){
      return self.animatableOptions.intersection(Set(modifierNames)).count > 0
    }
    return false
  }
  
  public func takeSnapshot(for v:UIView) -> UIView{
    v.isHidden = false
    
    // capture a snapshot without cornerRadius
    let oldCornerRadius = v.layer.cornerRadius
    v.layer.cornerRadius = 0
    let snapshot = v.snapshotView(afterScreenUpdates: true)!
    v.layer.cornerRadius = oldCornerRadius
    
    // the Snapshot's contentView must have hold the cornerRadius value,
    // since the snapshot might not have maskToBounds set
    let contentView = snapshot.subviews[0]
    contentView.layer.cornerRadius = v.layer.cornerRadius
    contentView.layer.masksToBounds = true
    
    snapshot.layer.cornerRadius = v.layer.cornerRadius
    if let zPos = context[v, "zPosition"]?.getCGFloat(0){
      snapshot.layer.zPosition = zPos
    } else {
      snapshot.layer.zPosition = v.layer.zPosition
    }
    snapshot.layer.opacity = v.layer.opacity
    snapshot.layer.isOpaque = v.layer.isOpaque
    snapshot.layer.anchorPoint = v.layer.anchorPoint
    snapshot.layer.masksToBounds = v.layer.masksToBounds
    snapshot.layer.borderColor = v.layer.borderColor
    snapshot.layer.borderWidth = v.layer.borderWidth
    snapshot.layer.transform = v.layer.transform
    snapshot.layer.shadowRadius = v.layer.shadowRadius
    snapshot.layer.shadowOpacity = v.layer.shadowOpacity
    snapshot.layer.shadowColor = v.layer.shadowColor
    snapshot.layer.shadowOffset = v.layer.shadowOffset
    
    snapshot.frame = context.container.convert(v.bounds, from: v)
    snapshot.heroID = v.heroID

    v.isHidden = true

    context.container.addSubview(snapshot)
    
    return snapshot
  }

  public func animate(context:HeroContext, fromViews:[UIView], toViews:[UIView]) -> TimeInterval{
    self.context = context
    
    var duration:TimeInterval = 0

    // animate
    for v in fromViews{
      animate(view: v, appearing: false)
    }
    for v in toViews{
      animate(view: v, appearing: true)
    }
    
    for viewContext in viewContexts.values{
      duration = max(duration, viewContext.duration)
    }

    return duration
  }
  
  func animate(view:UIView, appearing:Bool){
    let snapshot = takeSnapshot(for: view)
    let viewContext = HeroDefaultAnimatorViewContext(animator:self, view: view, snapshot: snapshot, modifiers: context[view]!, appearing: appearing)
    viewContexts[view] = viewContext
  }
  
  public func clean(){
    context = nil
    viewContexts.removeAll()
  }
}
