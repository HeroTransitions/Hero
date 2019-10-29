import UIKit
import Hero
import CollectionKit

/*:
 
 # App Store Transition
 
 This is a much more advanced transition mimicking the iOS 11 App Store.
 It is intended to demostrate Hero's ability in creating an advance transition.
 It does not look 100% like the app store and the article page currently doesn't scroll.
 
 There are a few advance technique that is used in this example:
 
 1. Interactive transition
 
 When dismissing, a pan gesture recognizer is used to adjust the progress of the transition.
 When user lift its finger, we determine whether or not we should cancel or finish the
 transition by how far the user have moved and how fast the user is moving.
 
 See `@objc func handlePan(gr: UIPanGestureRecognizer)` down below for detail.
 
 2. The `.useNoSnapshot` modifier
 
 Whenever this modifier is used on a view, Hero won't create snapshot for that view during
 the transition. Instead, hero will grab the view from its superview, insert it into the
 transition container view, and use it directly during the transition.
 
 A few things to point out when using `.useNoSnapshot`:
 
 1. It improves the performance a lot! since snapshot takes a long time to create.
 
 2. It doesn't work with auto layout.
 
 This is because Hero will remove the view from its original view hierarchy.
 Therefore, breaking all the constraints.
 
 3. Becareful of when to layout the cell. Do not set the `frame` of the cell when Hero is
 using it for transition. Otherwise it will create weird effect during the transition.
 
 If you are using `layoutSubviews` to layout a child view with `.useNoSnapshot`, first check
 whether or not the child view is still your child by verifying `childView.superview == self`
 before actually setting the frame of the child view. This way, you won't accidentally
 modify the child view's frame during the transition. The child view's superview
 will not be the original superview during a transiton, but when it finishes, Hero
 will insert the view back to its original view hierarchy.
 
 3. Setting `hero.modalAnimationType` to `.none`
 
 without this, a fade animation will be applied to the destination root view.
 Since we use a visual effect view as our background and applied `.fade` hero modifier manually,
 we don't need the builtin fade animation anymore. Also when dismissing,
 we don't want the background view to fade in, instead, we want it to be opaque through
 out the transition.
 
 */


class CardView: UIView {
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let imageView = UIImageView(image: #imageLiteral(resourceName: "Unsplash6"))
  let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    
    titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
    subtitleLabel.font = UIFont.systemFont(ofSize: 17)
    imageView.contentMode = .scaleAspectFill
    
    addSubview(imageView)
    addSubview(visualEffectView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    imageView.frame = bounds
    visualEffectView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 90)
    titleLabel.frame = CGRect(x: 20, y: 20, width: bounds.width - 40, height: 30)
    subtitleLabel.frame = CGRect(x: 20, y: 50, width: bounds.width - 40, height: 30)
  }
}

class RoundedCardWrapperView: UIView {
  let cardView = CardView()
  
  var isTouched: Bool = false {
    didSet {
      var transform = CGAffineTransform.identity
      if isTouched { transform = transform.scaledBy(x: 0.96, y: 0.96) }
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
        self.transform = transform
      }, completion: nil)
    }
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
  override init(frame: CGRect) {
    super.init(frame: frame)
    cardView.layer.cornerRadius = 16
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowRadius = 12
    layer.shadowOpacity = 0.15
    layer.shadowOffset = CGSize(width: 0, height: 8)
    addSubview(cardView)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    if cardView.superview == self {
      // this is necessary because we used `.useNoSnapshot` modifier on cardView.
      // we don't want cardView to be resized when Hero is using it for transition
      cardView.frame = bounds
    }
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    isTouched = true
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    isTouched = false
  }
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    isTouched = false
  }
}

class AppStoreViewController1: ExampleBaseViewController {
  let collectionView = CollectionView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.delaysContentTouches = false
    view.insertSubview(collectionView, belowSubview: dismissButton)
    setupCollection()
  }
  
  func setupCollection() {
    let dataSource = ArrayDataSource<Int>(data: Array(0..<10))
    
    let viewSource = ClosureViewSource { (view: RoundedCardWrapperView, data: Int, index) in
      view.cardView.titleLabel.text = "Hero"
      view.cardView.subtitleLabel.text = "App Store Card Transition"
      view.cardView.imageView.image = UIImage(named: "Unsplash\(data)")
    }
    
    let sizeSource = { (i: Int, data: Int, size: CGSize) -> CGSize in
      return CGSize(width: size.width, height: size.width + 20)
    }
    
    let provider = BasicProvider<Int, RoundedCardWrapperView>(
      dataSource: dataSource,
      viewSource: viewSource,
      sizeSource: sizeSource,
      layout: FlowLayout(spacing: 30).inset(by: UIEdgeInsets(top: 100, left: 20, bottom: 30, right: 20))
    )
    provider.tapHandler = { (context) in
      self.cellTapped(cell: context.view, data: context.data)
    }
    
    collectionView.provider = provider
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
  }
  
  func cellTapped(cell: RoundedCardWrapperView, data: Int) {
    // MARK: Hero configuration
    
    let cardHeroId = "card\(data)"
    cell.cardView.hero.modifiers = [.useNoSnapshot, .spring(stiffness: 250, damping: 25)]
    cell.cardView.hero.id = cardHeroId
    
    let vc = AppStoreViewController2()
    
    vc.hero.isEnabled = true
    vc.hero.modalAnimationType = .none
    
    vc.cardView.hero.id = cardHeroId
    vc.cardView.hero.modifiers = [.useNoSnapshot, .spring(stiffness: 250, damping: 25)]
    vc.cardView.imageView.image = UIImage(named: "Unsplash\(data)")
    
    vc.contentCard.hero.modifiers = [.source(heroID: cardHeroId), .spring(stiffness: 250, damping: 25)]
    
    vc.contentView.hero.modifiers = [.useNoSnapshot, .forceAnimate, .spring(stiffness: 250, damping: 25)]
    
    vc.visualEffectView.hero.modifiers = [.fade, .useNoSnapshot]
    
    present(vc, animated: true, completion: nil)
  }
}

class AppStoreViewController2: ExampleBaseViewController {
  let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  
  let contentCard = UIView()
  let cardView = CardView()
  let contentView = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    
    view.addSubview(visualEffectView)
    
    cardView.titleLabel.text = "Hero 2"
    cardView.subtitleLabel.text = "App Store Card Transition"
    
    contentView.numberOfLines = 0
    contentView.text = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent neque est, hendrerit vitae nibh ultrices, accumsan elementum ante. Phasellus fringilla sapien non lorem consectetur, in ullamcorper tortor condimentum. Nulla tincidunt iaculis maximus. Sed ut urna urna. Nulla at sem vel neque scelerisque imperdiet. Donec ornare luctus dapibus. Donec aliquet ante augue, at pellentesque ipsum mollis eget. Cras vulputate mauris ac eleifend sollicitudin. Vivamus ut posuere odio. Suspendisse vulputate sem vel felis vehicula iaculis. Fusce sagittis, eros quis consequat tincidunt, arcu nunc ornare nulla, non egestas dolor ex at ipsum. Cras et massa sit amet quam imperdiet viverra. Mauris vitae finibus nibh, ac vulputate sapien.
    """
    
    if #available(iOS 13.0, tvOS 13, *) {
      contentCard.backgroundColor = .systemBackground
    } else {
      contentCard.backgroundColor = .white
    }

    contentCard.clipsToBounds = true
    
    contentCard.addSubview(contentView)
    contentCard.addSubview(cardView)
    view.addSubview(contentCard)
    
    // add a pan gesture recognizer for the interactive dismiss transition
    view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:))))
  }
  @objc func handlePan(gr: UIPanGestureRecognizer) {
    let translation = gr.translation(in: view)
    switch gr.state {
    case .began:
      dismiss(animated: true, completion: nil)
    case .changed:
      Hero.shared.update(translation.y / view.bounds.height)
    default:
      let velocity = gr.velocity(in: view)
      if ((translation.y + velocity.y) / view.bounds.height) > 0.5 {
        Hero.shared.finish()
      } else {
        Hero.shared.cancel()
      }
    }
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let bounds = view.bounds
    visualEffectView.frame  = bounds
    contentCard.frame  = bounds
    cardView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width)
    contentView.frame = CGRect(x: 20, y: bounds.width + 20, width: bounds.width - 40, height: bounds.height - bounds.width - 20)
  }
}
