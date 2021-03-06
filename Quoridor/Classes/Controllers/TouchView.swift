import UIKit

// MARK: - TouchViewDelegate Protocol
@objc protocol TouchViewDelegate: NSObjectProtocol {
    optional func touchAddWood(location: CGPoint)
    optional func touchAddPlayer(location: CGPoint)
    /** type 为true表示是木板 */
    optional func touchMoved(location: CGPoint, type: Bool)
    optional func touchEnded(location: CGPoint, type: Bool)
    optional func touchCancelled(type: Bool)
}

class TouchView: UIView {

    weak var delegate: TouchViewDelegate?
    var touchType = false
    
    // MARK: - Touch Action
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 计算棋子所在区域。
        let model  = GameModel.shared
        let player = model.player ? model.topPlayer : model.downPlayer
        let cellSize = bounds.height / 11
        let distance = cellSize * 1.25
        var location: CGPoint
        
        // 假如是在小屏幕中，则扩大棋子区域。否则不需要。
        if kOffset {
            let x = CGFloat(player.x - 1) * distance
            let y = CGFloat(player.y - 1) * distance
            
            // 判断棋子是否棋子所在区域
            location = locationTouch(touches)
            if location.x >= x && location.x <= (x + cellSize * 3.5) {
                if location.y >= y && location.y <= (y + cellSize * 3.5) {
                    touchType = false
                    delegate?.touchAddPlayer?(location)
                    return
                }
            }
        } else {
            let x = CGFloat(player.x) * distance
            let y = CGFloat(player.y) * distance
            
            // 判断棋子是否棋子所在区域
            location = locationTouch(touches)
            if location.x >= x && location.x <= (x + cellSize) {
                if location.y >= y && location.y <= (y + cellSize) {
                    touchType = false
                    delegate?.touchAddPlayer?(location)
                    return
                }
            }
        }
        
        // 检查木板是否已经用光
        touchType = true
        if GameModel.shared.iWallIsEmpty() {
            touchType = false
            delegate?.touchAddPlayer?(location)
        } else {
            delegate?.touchAddWood?(location)
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.touchMoved?(locationTouch(touches), type: touchType)
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.touchEnded?(locationTouch(touches), type: touchType)
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        delegate?.touchCancelled?(touchType)
    }
    
    
    // MARK: - Count
    
    /** 获取触摸位置 */
    private func locationTouch(touches: Set<UITouch>) -> CGPoint {
        let touch = touches.first!
        return touch.locationInView(self)
    }
}
