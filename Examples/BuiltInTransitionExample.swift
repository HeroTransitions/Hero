import UIKit
import Hero

/*:

 # Builtin transitions

 Hero has a few basic transition builtin.
 These can be used by setting `hero.modalAnimationType` to any ViewController that you want to present.

 These can be:

 ```
 .none
 .push(direction: Direction)
 .pull(direction: Direction)
 .cover(direction: Direction)
 .uncover(direction: Direction)
 .slide(direction: Direction)
 .zoomSlide(direction: Direction)
 .pageIn(direction: Direction)
 .pageOut(direction: Direction)
 .fade
 .zoom
 .zoomOut
 ```

 There are also three special ones

 * `.auto` is the default animation type. It uses the following animations depending on the presentation style:

 `.none` if source root view or destination root view have existing animations (defined via heroID or heroModifiers).
 `.push` & `.pull` if animating within a UINavigationController.
 `.slide` if animating within a UITabbarController.
 `.fade` if presenting modally.
 `.none` if presenting modally with modalPresentationStyle == .overFullScreen.

 * `.autoReverse(presenting: HeroDefaultAnimationType)` runs the given animation when presenting and runs
 the reverse animation when dismising.

 When not using .autoReverse, present and dismiss animation will be in the same direction.

 * `.selectBy(presenting: HeroDefaultAnimationType, dismissing: HeroDefaultAnimationType)`

 runs the given `presenting` animation during present and runs the `dismissing` animation during dismiss

 */

class BuiltInTransitionExampleViewController1: ExampleBaseViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hexString: "FC3A5E")!
  }

  @objc override func onTap() {
    let vc2 = BuiltInTransitionExampleViewController2()

    // this enables Hero
    vc2.hero.isEnabled = true

    // this configures the built in animation
    //    vc2.hero.modalAnimationType = .zoom
    //    vc2.hero.modalAnimationType = .pageIn(direction: .left)
    //    vc2.hero.modalAnimationType = .pull(direction: .left)
    //    vc2.hero.modalAnimationType = .autoReverse(presenting: .pageIn(direction: .left))
    vc2.hero.modalAnimationType = .selectBy(presenting: .pull(direction: .left), dismissing: .slide(direction: .down))

    // lastly, present the view controller like normal
    present(vc2, animated: true, completion: nil)
  }
}

class BuiltInTransitionExampleViewController2: ExampleBaseViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hexString: "555555")!
  }
}
