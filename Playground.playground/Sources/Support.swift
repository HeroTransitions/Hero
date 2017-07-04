import UIKit
import PlaygroundSupport

let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
public func configPlayground(initialVC: UIViewController) {
    PlaygroundPage.current.needsIndefiniteExecution = true
    window.rootViewController = initialVC
    window.makeKeyAndVisible()
    PlaygroundPage.current.liveView = window
}
