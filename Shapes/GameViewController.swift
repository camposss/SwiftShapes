import UIKit
import SpriteKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let scene = GameScene(size: CGSize(width: 1536, height: 2048))
    let skView = self.view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .aspectFill
    skView.presentScene(scene)
  }
//  jaklsdjflasjdfklajsdfkla
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
