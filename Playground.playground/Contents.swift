
import UIKit
import Hero

Hero.shared.containerColor = .black
class VC1: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }

    @objc func tap() {
        let vc2 = VC2()
        vc2.isHeroEnabled = true
        vc2.heroModalAnimationType = .pageIn(direction: .left)
        present(vc2, animated: true, completion: nil)
    }
}

class VC2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }

    @objc func tap() {
        dismiss(animated: true, completion: nil)
    }
}

configPlayground(initialVC: VC1())
