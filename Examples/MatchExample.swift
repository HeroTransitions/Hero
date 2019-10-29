import UIKit

/*:

 # Matching View

 Use `hero.id` to match views from one view controller to another view controller.
 Views that have the same hero.id will be automatically transitioned by Hero from its
 source state to its destination state.

 Use `hero.modifiers` to add extra animations or adjust how Hero handles the transition
 for that specific view.

 Check out `HeroModifiers.swift` for list of modifiers available.

 */

class MatchExampleViewController1: ExampleBaseViewController {
  let redView = UIView()
  let blackView = UIView()

  override func viewDidLoad() {
    super.viewDidLoad()

    redView.backgroundColor = UIColor(hexString: "FC3A5E")!
    redView.hero.id = "ironMan"
    redView.cornerRadius = 8
    view.addSubview(redView)

    blackView.backgroundColor = UIColor(hexString: "555555")!
    blackView.hero.id = "batMan"
    blackView.cornerRadius = 8
    view.addSubview(blackView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    redView.frame.size = CGSize(width: 200, height: 200)
    blackView.frame.size = CGSize(width: 200, height: 80)
    redView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + 50)
    blackView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 90)
  }

  @objc override func onTap() {
    let vc2 = MatchExampleViewController2()
    vc2.hero.isEnabled = true
    present(vc2, animated: true, completion: nil)
  }
}

class MatchExampleViewController2: ExampleBaseViewController {
  let redView = UIView()
  let blackView = UIView()
  let backgroundView = UIView()

  override func viewDidLoad() {
    super.viewDidLoad()

    redView.backgroundColor = UIColor(hexString: "FC3A5E")!
    redView.hero.id = "ironMan"
    view.insertSubview(redView, belowSubview: dismissButton)

    blackView.backgroundColor = UIColor(hexString: "555555")!
    blackView.hero.id = "batMan"
    blackView.cornerRadius = 8
    view.addSubview(blackView)

    if #available(iOS 13.0, tvOS 13, *) {
      backgroundView.backgroundColor = .systemBackground
    } else {
      backgroundView.backgroundColor = .white
    }
    backgroundView.cornerRadius = 8
    // .useGlobalCoordinateSpace modifier is needed here otherwise it will be covered by redView during transition.
    // see http://lkzhao.com/2018/03/02/hero-useglobalcoordinatespace-explained.html for detail
    backgroundView.hero.modifiers = [.translate(y: 500), .useGlobalCoordinateSpace]
    view.addSubview(backgroundView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    redView.frame = view.bounds
    blackView.frame.size = CGSize(width: 250, height: 60)
    blackView.center = CGPoint(x: view.bounds.midX, y: 130)
    backgroundView.frame = CGRect(x: (view.bounds.width - 250) / 2, y: 180, width: 250, height: view.bounds.height - 320)
  }
}
