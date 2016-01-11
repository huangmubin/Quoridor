import UIKit

class ChessPlayer: UIView {
    
    // MARK: - Interface
    
    /** 更新棋子位置 */
    func update(player: Bool) {
        if player {
            updateView(topView, rect: FrameCalculator.playerFrame(true))
        } else {
            updateView(downView, rect: FrameCalculator.playerFrame(false))
        }
    }
    
    /** 移动棋子 */
    func move(location: CGPoint) {
        if GameModel.shared.player {
            updateView(topView, rect: FrameCalculator.playerFrameForTouch(location))
        } else {
            updateView(downView, rect: FrameCalculator.playerFrameForTouch(location))
        }
    }
    
    // MARK: - Animation
    
    private func updateView(view: UIView, rect: CGRect) {
        UIView.animateWithDuration(0.2) {
            view.frame = rect
        }
    }
    
    // MARK: - Data
    
    private var topLayer: CALayer!
    private var downLayer: CALayer!
    private var topView: UIView!
    private var downView: UIView!
    
    // MARK: - Init Function
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayer()
    }
    
    /** 初始化 Top Down 层*/
    private func initLayer() {
        topView  = UIView(frame: FrameCalculator.playerFrame(true))
        downView = UIView(frame: FrameCalculator.playerFrame(false))
        topView.backgroundColor  = UIColor.clearColor()
        downView.backgroundColor = UIColor.clearColor()
        topView.layer.backgroundColor  = kTopColor.CGColor
        downView.layer.backgroundColor = kDownColor.CGColor
        topView.layer.cornerRadius  = topView.frame.width / 2
        downView.layer.cornerRadius = downView.frame.width / 2
        addSubview(topView)
        addSubview(downView)
        
//        topLayer  = CALayer()
//        downLayer = CALayer()
//        topLayer.frame  = FrameCalculator.playerFrame(true)
//        downLayer.frame = FrameCalculator.playerFrame(false)
//        topLayer.backgroundColor = kTopColor.CGColor
//        topLayer.cornerRadius    = topLayer.frame.width / 2
//        downLayer.backgroundColor = kDownColor.CGColor
//        downLayer.cornerRadius    = downLayer.frame.width / 2
//        layer.addSublayer(topLayer)
//        layer.addSublayer(downLayer)
    }
    
    // MARK: - Draw Function
    
    override func drawRect(rect: CGRect) {
        
    }
    
}
