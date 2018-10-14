import UIKit
import CollectionKit

class MainViewController: UIViewController {
  let collectionView = CollectionView()
  let examples: [(UIViewController.Type, String)] = [
    (BuiltInTransitionExampleViewController1.self, "Built In Animations"),
    (MatchExampleViewController1.self, "Match Animation"),
    (MatchInCollectionExampleViewController1.self, "Match Cell in Collection"),
    (AppStoreViewController1.self, "App Store Transition"),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    let examplesProvider = CollectionProvider(
      data: examples,
      viewUpdater: { (label: UILabel, data, index) in
        label.text = "\(index + 1). \(data.1)"
        label.textAlignment = .center
        label.layer.borderColor = UIColor.gray.cgColor
        label.layer.borderWidth = 0.5
        label.layer.cornerRadius = 8
      },
      layout: FlowLayout(lineSpacing: 10),
      sizeProvider: { (index, data, collectionSize) in
        return CGSize(width: collectionSize.width, height: 64)
      },
      tapHandler: { [unowned self] (label, index, dataProvider) in
        let vc = dataProvider.data(at: index).0.init()
        self.present(vc, animated: true, completion: nil)
      }
    )

    // TODO: Migrate the example to CollectionKit 2.2.0

    let imageView = UIImageView(image: #imageLiteral(resourceName: "HeroLogo"))
    imageView.contentMode = .scaleAspectFit
    //let imageProvider = ViewCollectionProvider(imageView, sizeStrategy: (.fill, .fit))

    let legacyButton = UIButton(type: .system)
    legacyButton.setTitle("Legacy Examples", for: .normal)
    legacyButton.addTarget(self, action: #selector(showLegacy), for: .touchUpInside)
    //let legacyExamplesProvider = ViewCollectionProvider(legacyButton, sizeStrategy: (.fill, .fit))

//    collectionView.provider = CollectionComposer(
//      layout: FlowLayout(lineSpacing: 10).inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)),
//      sections: [imageProvider, examplesProvider, legacyExamplesProvider]
//    )

    view.addSubview(collectionView)
  }

  @objc func showLegacy() {
    hero.replaceViewController(with: viewController(forStoryboardName: "Main"))
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
  }
}
