import UIKit

class ChessPlayer: UIView {
    
    // MARK: - Interface
    
    /** 更新棋子位置 */
    func update(player: Bool) {
        if player {
            topLayer.frame  = FrameCalculator.playerFrame(true)
        } else {
            downLayer.frame = FrameCalculator.playerFrame(false)
        }
    }
    
    /** 移动棋子 */
    func move(location: CGPoint) {
        if GameModel.shared.player {
            topLayer.frame = FrameCalculator.playerFrameForTouch(location)
        } else {
            downLayer.frame = FrameCalculator.playerFrameForTouch(location)
        }
    }
    
    // MARK: - Data
    
    private var topLayer: CALayer!
    private var downLayer: CALayer!
    
    // MARK: - Init Function
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayer()
    }
    
    /** 初始化 Top Down 层*/
    private func initLayer() {
        topLayer  = CALayer()
        downLayer = CALayer()
        topLayer.frame  = FrameCalculator.playerFrame(true)
        downLayer.frame = FrameCalculator.playerFrame(false)
        topLayer.backgroundColor = kTopColor.CGColor
        topLayer.cornerRadius    = topLayer.frame.width / 2
        downLayer.backgroundColor = kDownColor.CGColor
        downLayer.cornerRadius    = downLayer.frame.width / 2
        layer.addSublayer(topLayer)
        layer.addSublayer(downLayer)
    }
    
    // MARK: - Draw Function
    
    override func drawRect(rect: CGRect) {
        
    }
    
}
