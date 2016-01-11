import UIKit

class WallPrompt: UIView {
    
    // MARK: - Interface
    
    /** 添加提示的木板视图到游戏中 */
    func add(location: CGPoint) {
        let move = FrameCalculator.wallFrameForTouch(location)
        subView.frame = move.0
        subView.transform = CGAffineTransformMakeRotation(move.1)
        addSubview(subView)
        self.move(location)
    }
    
    /** 移动木板视图，如果到不可放置区域会变色 */
    func move(location: CGPoint) {
        let move = FrameCalculator.wallFrameForTouch(location)
        UIView.animateWithDuration(0.2) {
            self.subView.frame = move.0
            self.subView.transform = CGAffineTransformMakeRotation(move.1)
        }
        let data = FrameCalculator.wallDataForTouch(location)
        if GameModel.shared.iWallIsAllow(data) {
            wallLayer.backgroundColor = kWallColor.CGColor
        } else {
            wallLayer.backgroundColor = kWrongColor.CGColor
        }
    }
    
    /** 结束移动，如果区域可以放置则返回数据，否则nil */
    func endMove(location: CGPoint) -> DataModel? {
        subView.removeFromSuperview()
        let data = FrameCalculator.wallDataForTouch(location)
        if GameModel.shared.iWallIsAllow(data) {
            return data
        } else {
            return nil
        }
    }
    
    /** 取消移动 */
    func cancelMove() {
        subView.removeFromSuperview()
    }
    
    // MARK: - Data
    
    private var wallLayer: CALayer!
    private var subView: UIView!
    
    // MARK: - Init Function
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayer()
    }
    
    /** 初始化 Top Down 层*/
    private func initLayer() {
        let cellSize = (UIScreen.mainScreen().bounds.width - 40) / 11
        let distance = cellSize * 0.25 + 2
        
        subView = UIView(frame: FrameCalculator.wallFrameForTouch(CGPointZero).0)
        subView.backgroundColor = UIColor.clearColor()
        
        wallLayer = CALayer()
        wallLayer.frame = CGRectMake(subView.frame.width / 2 - distance / 2, 0, distance, cellSize * 2.25)
        wallLayer.cornerRadius    = distance / 2
        wallLayer.backgroundColor = kWallColor.CGColor
        
        subView.layer.addSublayer(wallLayer)
    }

    
    // MARK: - DrawRect
    
    override func drawRect(rect: CGRect) {
        
    }
}
