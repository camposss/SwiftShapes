import SpriteKit

class GameScene: SKScene {
  
  /*
   MARK: -TODO LIST
   1. Add a landing modal with options to play, settings, etc
   2. Add rewarding sound effect when colliding with correct color. Add a losing animation...objects break with options to restart or landing page
   3. Add you background music on loop or spotify/itunes
   4. Add more shapes: Triangle
   5. 
 */
  
  struct PhysicsCategory {
    static let Player: UInt32 = 1
    static let Obstacle: UInt32 = 2
    static let Edge: UInt32 = 4
  }
  
  let player = SKShapeNode(circleOfRadius: 25)
  let colors = [SKColor.yellow, SKColor.red, SKColor.blue, SKColor.purple]
  let cameraNode = SKCameraNode()
  
  var obstacles: [SKNode] = []
  let obstacleSpacing: CGFloat = 800
  
  //scoring
  let scoreLabel = SKLabelNode()
  var score = 0
  
  //Player taps the screen
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    player.physicsBody?.velocity.dy = 800.0
  }
  //check for updates (players position)
  
  override func update(_ currentTime: TimeInterval) {
    if player.position.y > obstacleSpacing * CGFloat(obstacles.count - 2) {
      print("score")
      // TODO: Update score
      
      score += 1
      scoreLabel.text = String(score)
      addObstacle()
    }
    
    let playerPositionInCamera = cameraNode.convert(player.position, from: self)
    if playerPositionInCamera.y > 0 && !cameraNode.hasActions() {
      cameraNode.position.y = player.position.y
    }
    
    if playerPositionInCamera.y < -size.height/2 {
      dieAndRestart()
    }
  }
  //The object has moved
  override func didMove(to view: SKView) {
    setupPlayerAndObstacles()
    
    let playerBody = SKPhysicsBody(circleOfRadius: 30)
    playerBody.mass = 1.5
    playerBody.categoryBitMask = PhysicsCategory.Player
    playerBody.collisionBitMask = 4
    player.physicsBody = playerBody
    
    let ledge = SKNode()
    ledge.position = CGPoint(x: size.width/2, y: 160)
    let ledgeBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 10))
    ledgeBody.isDynamic = false
    ledgeBody.categoryBitMask = PhysicsCategory.Edge
    ledge.physicsBody = ledgeBody
    addChild(ledge)
    physicsWorld.gravity.dy = -22
    physicsWorld.contactDelegate = self
    
    addChild(cameraNode)
    camera = cameraNode
    cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
    
    scoreLabel.position = CGPoint(x: -350, y: -900)
    scoreLabel.fontColor = .white
    scoreLabel.fontSize = 150
    scoreLabel.text = String(score)
    cameraNode.addChild(scoreLabel)
  }
  

  func setupPlayerAndObstacles() {
    addPlayer()
    addObstacle()
  }
  func addPlayer(){
    player.fillColor = .blue
    player.strokeColor = .blue
    player.position = CGPoint(x: size.width/2, y: 200)
    
    addChild(player)
  }
  
  func addObstacle(){
    
    let choice = Int(arc4random_uniform(2))
    switch choice {
    case 0:
      addCircleObstacle()
    case 1:
      addSquareObstacle()
    default:
      print("something went wrong")
    }
  }
  //Creates a Circle Object using UIBezierPath
  func addCircleObstacle () {
    //draw arc
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: -200))
    path.addLine(to: CGPoint(x: 0, y: -160))
    path.addArc(withCenter: CGPoint.zero, radius: 160, startAngle: CGFloat(3.0 * Double.pi/2), endAngle: CGFloat(0), clockwise: true)
    
    path.addLine(to: CGPoint(x: 200, y: 0))
    path.addArc(withCenter: CGPoint.zero, radius: 200, startAngle: CGFloat(0.0), endAngle: CGFloat(3.0 * Double.pi/2), clockwise: false)
    
    //Create new shape and fill with current path with colors and position
    let obstacle = obstacleByDuplicatingPath(path, clockwise: true)
    obstacles.append(obstacle)
    obstacle.position = CGPoint(x: size.width/2, y: obstacleSpacing * CGFloat(obstacles.count))
    addChild(obstacle)
    
    let rotateAction = SKAction.rotate(byAngle: 2.0 * CGFloat(Double.pi/2), duration: 4.0)
    obstacle.run(SKAction.repeatForever(rotateAction))
    
  }
  //Creates a Circle Object using UIBezierPath
  func addSquareObstacle(){
    let path = UIBezierPath(roundedRect: CGRect(x: -200, y: -200, width: 400, height: 40), cornerRadius: 20)
    let obstacle = obstacleByDuplicatingPath(path, clockwise: false)
    obstacles.append(obstacle)
    obstacle.position = CGPoint(x: size.width/2, y: obstacleSpacing * CGFloat(obstacles.count))
    addChild(obstacle)
    
    let rotateAction = SKAction.rotate(byAngle: -2.0 * CGFloat(Double.pi/2), duration: 4.0)
    obstacle.run(SKAction.repeatForever(rotateAction))
    
  }
  func obstacleByDuplicatingPath(_ path: UIBezierPath, clockwise: Bool) -> SKNode {
    let container = SKNode()
    
    var rotationFactor = CGFloat(Double.pi/2)
    if !clockwise {
      rotationFactor *= -1
    }
    for i in 0...3 {
      let section = SKShapeNode(path: path.cgPath)
      section.fillColor = colors[i]
      section.strokeColor = colors[i]
      section.zRotation = rotationFactor * CGFloat(i)
      
      //Allow for contact
      let sectionBody = SKPhysicsBody(polygonFrom: path.cgPath)
      sectionBody.categoryBitMask = PhysicsCategory.Obstacle
      //This body shouldn't collide with any other bodies so player can pass through
      sectionBody.collisionBitMask = 0
      sectionBody.contactTestBitMask = PhysicsCategory.Player
      sectionBody.affectedByGravity = false
      section.physicsBody = sectionBody
      
      container.addChild(section)
    }
    return container
  }
  func dieAndRestart(){
    print("boom")
    player.physicsBody?.velocity.dy = 0
    player.removeFromParent()
    
    //Remove Obstacles
    for node in obstacles {
      node.removeFromParent()
    }
    obstacles.removeAll()
    
    setupPlayerAndObstacles()
    cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
    
    //reset score
    score = 0
    scoreLabel.text = String(score)

    
  }

}
extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    if let nodeA = contact.bodyA.node as? SKShapeNode, let nodeB = contact.bodyB.node as? SKShapeNode {
      if nodeA.fillColor != nodeB.fillColor {
        dieAndRestart()
      }
    }
  }
}





