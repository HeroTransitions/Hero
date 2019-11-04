import UIKit
import SwiftUI

class SwiftUIMatchExampleViewController: UIHostingController<ImagesTableView> {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(rootView: ImagesTableView())
    
    rootView.onTapRow = { image in
      
      let destinationViewController = UIHostingController(rootView: ImageViewWrapper(name: image.name, heroID: image.name)
                                                                      .onTapGesture { [weak self] in
        self?.presentedViewController?.dismiss(animated: true, completion: nil)
      })
      
      destinationViewController.isHeroEnabled = true
      
      self.present(destinationViewController, animated: true, completion: nil)
    }
  }
  
  @objc required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

struct ImageInfo: Identifiable {

  let id: Int
  let name: String
}

struct ImagesTableView: View {
    
  var onTapRow: ((ImageInfo)->())?
    
  @State var images = (0...9).map{ ImageInfo(id: $0, name: "Unsplash\($0)") }
    
  var body: some View {
    List(images) { image in
      
      HStack {
        ImageViewWrapper(name: "\(image.name)_cell", heroID: image.name)
        Spacer()
        Text("Image number \(image.id)").padding()
      }.onTapGesture {
        self.onTapRow?(image)
      }
    }
  }
}

#if DEBUG
#endif

struct ImageViewWrapper: View, UIViewRepresentable {
    
  let name: String
  let heroID: String?
    
  func makeUIView(context: UIViewRepresentableContext<ImageViewWrapper>) -> UIImageView {
    UIImageView(frame: .zero)
  }
  
  func updateUIView(_ uiView: UIImageView, context: UIViewRepresentableContext<ImageViewWrapper>) {
    uiView.image = UIImage(named: name)
    uiView.hero.id = heroID
  }
}

//MARK: - Previews

#if DEBUG

struct ImagesTableView_Previews: PreviewProvider {
  static var previews: some View {
    ImagesTableView(onTapRow: nil)
  }
}

struct ImageViewWrapper_Previews: PreviewProvider {
  static var previews: some View {
    ImageViewWrapper(name: "Unsplash0", heroID: nil)
  }
}

#endif
