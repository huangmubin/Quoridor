import UIKit
import AVFoundation

class GameController: UIViewController, TouchViewDelegate {
    // MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameLaunch()
        gameAppear()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        kOffset = view.frame.width < 380
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    // MARK: Init Game
    
    /** 初始化游戏启动配置。 */
    private func gameLaunch() {
        initDemonstrationView()
        initSound()
    }
    
    /** 更新游戏显示内容 */
    private func gameAppear() {
        alignmentButtons()
        updateButtonsTitle()
        updateGameColor()
        initTouchView()
        updateScreen()
        chessPlayer.update(true)
        chessPlayer.update(false)
    }
    
    /** 更新视图颜色 */
    private func updateGameColor() {
        view.backgroundColor = kBackgroundColor
        chessBoard.setNeedsDisplay()
        centerBackground.setNeedsDisplay()
        chessWall.update()
        topBackground.setNeedsDisplay()
        downBackground.setNeedsDisplay()
        topScreen.setNeedsDisplay()
        downScreen.setNeedsDisplay()
    }
    
    // MARK: - Game Logic
    
    private var isAiPlayer: Bool {
        get {
            return GameModel.shared.gameAi
        }
        set {
            GameModel.shared.gameAi = newValue
            if newValue {
                aiPlay()
            }
        }
    }
    
    /** 交换棋手，true为添加木板，false为移动棋子。 */
    private func changePlayer(type: Bool) {
        // 更新画面
        if type {
            chessWall.update()
        } else {
            chessPlayer.update(!GameModel.shared.player)
        }
        pushSound.play()
        updateScreen()
        updateButtonsTitle()
        
        // 判断游戏是否已经结束
        if GameModel.shared.status != GameStatus.Runing {
            pushEndScreen(GameModel.shared.status)
            return
        }
        
        // 计算下一步
        aiPlay()
    }
    
    /** Ai行棋 */
    private func aiPlay() {
        if isAiPlayer {
            if GameModel.shared.player {
                NSThread.detachNewThreadSelector("gameAiThread", toTarget: self, withObject: nil)
            }
        }
    }
    
    /** Game Ai Thread */
    func gameAiThread() {
        touchView.userInteractionEnabled = false
        NSThread.sleepForTimeInterval(1)
        let data = GameAi.Ai()
        if data.t {
            GameModel.shared.iPutWall(data)
        } else {
            GameModel.shared.iMove(data)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.aiSound.play()
            self.touchView.userInteractionEnabled = true
            self.changePlayer(data.t)
        }
    }
    
    // MARK: - Buttons
    
    @IBOutlet weak var topRetractButton: UIButton!
    @IBOutlet weak var topStepButton: UIButton!
    @IBOutlet weak var topWoodButton: UIButton!
    @IBOutlet weak var topRestartButton: UIButton!
    
    
    @IBOutlet weak var downRestartButton: UIButton!
    @IBOutlet weak var downWoodButton: UIButton!
    @IBOutlet weak var downStepButton: UIButton!
    @IBOutlet weak var downRetractButton: UIButton!
    
    // MARK: Display
    
    /** 将顶部按钮的方向调整好 */
    private func alignmentButtons() {
        topBackground.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        topScreen.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
    }
    
    /** 更新按钮标题 */
    private func updateButtonsTitle() {
        topStepButton.setTitle("\(GameAi.pathForPlayer(true).count)", forState: .Normal)
        topWoodButton.setTitle("\(10 - GameModel.shared.topWalls.count)", forState: .Normal)
        downStepButton.setTitle("\(GameAi.pathForPlayer(false).count)", forState: .Normal)
        downWoodButton.setTitle("\(10 - GameModel.shared.downWalls.count)", forState: .Normal)
    }
    
    // MARK: Action
    
    @IBAction func retractGameAction(sender: UIButton) {
        GameModel.shared.iRetractGame()
        updateButtonsTitle()
        chessWall.update()
        chessPlayer.update(true)
        chessPlayer.update(false)
    }
    
    @IBAction func restartGameAction(sender: UIButton) {
        GameModel.shared.iRestartGame()
        gameAppear()
        changePlayer(false)
    }
    
    @IBAction func stepGameAction(sender: UIButton) {
        GameModel.shared.color = !GameModel.shared.color
        updateGameColor()
    }
    
    @IBAction func woodGameAction(sender: UIButton) {
        isAiPlayer = !isAiPlayer
    }
    
    
    // MARK: - Touch View
    
    @IBOutlet weak var touchView: TouchView!
    
    /** 初始化TouchView */
    func initTouchView() {
        touchView.delegate = self
    }
    
    // MARK: Touch View Delegate
    
    func touchAddWood(location: CGPoint) {
        wallPrompt.add(location)
    }
    func touchAddPlayer(location: CGPoint) {
        playerPrompt.showHint()
        chessPlayer.move(location)
    }
    func touchMoved(location: CGPoint, type: Bool) {
        if type {
            wallPrompt.move(location)
        } else {
            chessPlayer.move(location)
        }
    }
    func touchEnded(location: CGPoint, type: Bool) {
        if type {
            if let newWall = wallPrompt.endMove(location) {
                GameModel.shared.iPutWall(newWall)
                changePlayer(true)
            }
        } else {
            playerPrompt.hideHint()
            if let newId = FrameCalculator.playerDataFromTouch(location) {
                GameModel.shared.iMoveWithId(newId)
                changePlayer(false)
            } else {
                chessPlayer.update(GameModel.shared.player)
            }
        }
    }
    func touchCancelled(type: Bool) {
        if type {
            wallPrompt.cancelMove()
        }
    }
    
    
    // MARK: - Screen
    
    @IBOutlet weak var topScreen: Screen!
    @IBOutlet weak var downScreen: Screen!
    
    private func updateScreen() {
        if isAiPlayer {
            topScreen.screenImageView.image = UIImage(named: "Computer")
        }
        if GameModel.shared.player {
            topScreen.hidden()
            downScreen.show()
        } else {
            downScreen.hidden()
            topScreen.show()
        }
    }
    
    // MARK: - EndScreen
    
    @IBOutlet weak var endScreen: EndScreen!
    @IBOutlet weak var endScreenCenterLayout: NSLayoutConstraint!
    
    @IBAction func tapEndScreen(sender: UITapGestureRecognizer) {
        popEndScreen(GameModel.shared.status)
        GameModel.shared.iRestartGame()
        gameAppear()
    }
    
    // MARK: Push Pop
    /** 弹出游戏结束画面 */
    private func pushEndScreen(end: GameStatus) {
        // 判定方向
        if end == GameStatus.TopWin {
            endScreen.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            endScreenCenterLayout.constant = -view.bounds.height
        } else {
            endScreen.transform = CGAffineTransformMakeRotation(0)
            endScreenCenterLayout.constant = view.bounds.height
        }
        view.layoutIfNeeded()
        endScreen.setNeedsDisplay()
        endSound.play()
        // 弹出窗口
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.endScreenCenterLayout.constant = 0
                self.endScreen.layoutIfNeeded()
            }) { (finish) -> Void in
                
        }
    }
    
    /** 收起游戏结束画面 */
    private func popEndScreen(end: GameStatus) {
        var constant: CGFloat
        if end == GameStatus.TopWin {
            constant = -view.bounds.height
        } else {
            constant = view.bounds.height
        }
        
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.endScreenCenterLayout.constant = constant
            }) { (finish) -> Void in
                self.endSound.stop()
                self.changePlayer(false)
        }
    }
     
    
    // MARK: - Domonstration
    
    @IBOutlet weak var demonstration: Demonstration!
    
    private func initDemonstrationView() {
        let width = UIScreen.mainScreen().bounds.width - 20
        let height = UIScreen.mainScreen().bounds.height - 20
        demonstration.frame = CGRectMake(10, 10, width, height)
        view.addSubview(demonstration)
        demonstration.initScrollView()
    }
    
    @IBAction func popDemonstration(sender: UIButton) {
        demonstration.removeFromSuperview()
        changePlayer(false)
    }
    
    
    // MARK: - Sound
    
    var aiSound: AVAudioPlayer!
    var pushSound: AVAudioPlayer!
    var endSound: AVAudioPlayer!
    
    private func initSound() {
        let pushBoundle = NSBundle.mainBundle().pathForResource("Control", ofType: "m4a")
        let pushUrl = NSURL(fileURLWithPath: pushBoundle!)
        aiSound = try! AVAudioPlayer(contentsOfURL: pushUrl)
        aiSound.prepareToPlay()
        pushSound = try! AVAudioPlayer(contentsOfURL: pushUrl)
        pushSound.prepareToPlay()
        let endBundle = NSBundle.mainBundle().pathForResource("Over", ofType: "m4a")
        let endUrl = NSURL(fileURLWithPath: endBundle!)
        endSound = try! AVAudioPlayer(contentsOfURL: endUrl)
        endSound.prepareToPlay()
    }
    
    
    // MARK: - Interface
    
    @IBOutlet weak var centerBackground: Background!
    @IBOutlet weak var topBackground: Background!
    @IBOutlet weak var downBackground: Background!
    @IBOutlet weak var chessBoard: ChessBoard!
    
    
    @IBOutlet weak var chessWall: ChessWall!
    @IBOutlet weak var chessPlayer: ChessPlayer!
    
    
    @IBOutlet weak var wallPrompt: WallPrompt!
    @IBOutlet weak var playerPrompt: PlayerPrompt!
    
    
    
}
