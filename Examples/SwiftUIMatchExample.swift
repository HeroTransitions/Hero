#if canImport(SwiftUI)

import UIKit
import SwiftUI
import Hero

@available(iOS 13.0, *)
class SwiftUIMatchExampleViewController: UIHostingController<ImagesTableView> {

  required init() {
    super.init(rootView: ImagesTableView())
    rootView.dismiss = self.dismiss
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
    
  func dismiss(){
    self.dismiss(animated: true, completion: nil)
  }
}

struct ImageInfo: Identifiable {

  let id: Int
  let name: String
}

@available(iOS 13.0, *)
struct ImagesTableView: View {
  var dismiss: (() -> Void)?
  var onTapRow: ((ImageInfo)->())?

  @State var images = (0...9).map{ ImageInfo(id: $0, name: "Unsplash\($0)") }
    
  var body: some View {
    VStack {
      HStack{
        Button(action: {
            self.dismiss?()
        }) {
          Text("Back")
        }.padding(.leading)
        Spacer()
      }
      
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
}

@available(iOS 13.0, *)
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

//MARK: - Previews (Will only work when target of HeroExamples is set to iOS 13 +)

#if DEBUG

@available(iOS 13.0, *)
struct ImagesTableView_Previews: PreviewProvider {
  static var previews: some View {
    ImagesTableView(onTapRow: nil)
  }
}

@available(iOS 13.0, *)
struct ImageViewWrapper_Previews: PreviewProvider {
  static var previews: some View {
    ImageViewWrapper(name: "Unsplash0", heroID: nil)
  }
}

#endif
#endif
