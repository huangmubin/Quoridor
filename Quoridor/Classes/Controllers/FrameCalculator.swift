import UIKit

class FrameCalculator: NSObject {
    // MARK: - Chess
    
    /** 计算棋盘坐标 */
    class func chessFrame() -> CGRect {
        let screen = UIScreen.mainScreen().bounds
        let w = screen.width - 40
        let y = (screen.height - w) / 2
        return CGRectMake(20, y, w, w)
    }
    
    // MARK: - Player
    
    /** 计算棋子坐标 */
    class func playerFrame(player: Bool) -> CGRect {
        let data = player ? GameModel.shared.topPlayer : GameModel.shared.downPlayer
        
        let cellSize = (UIScreen.mainScreen().bounds.width - 40) / 11
        let distance = cellSize * 1.25
        
        let x = CGFloat(data.x) * distance + cellSize * 0.1
        let y = CGFloat(data.y) * distance + cellSize * 0.1
        let s = cellSize * 0.8
        
        return CGRectMake(x, y, s, s)
    }
    
    /** 根据触摸点计算棋子偏移位置 */
    class func playerFrameForTouch(location: CGPoint) -> CGRect {
        let frame = playerFrame(GameModel.shared.player)
        var offset = kOffset ? kOffsetLong : 0
        offset = GameModel.shared.player ? offset : -offset
        let x = location.x - frame.width / 2
        let y = location.y - frame.height / 2 + offset
        return CGRectMake(x, y, frame.width, frame.height)
    }
    
    /** 根据当前触摸点计算棋子数据位置。 */
    class func playerDataFromTouch(location: CGPoint) -> Int? {
        let model = GameModel.shared
        
        // 计算尺寸
        let cellSize = (UIScreen.mainScreen().bounds.width - 40) / 11
        let distance = cellSize * 1.25
        
        // 计算偏移量
        var offset = kOffset ? kOffsetLong : 0
        offset  = model.player ? offset : -offset
        
        // 计算坐标
        let x = Int(Float((location.x + cellSize * 0.125) / distance))
        let y = Int(Float((location.y + cellSize * 0.125 + offset) / distance))
        
        let id = y * 9 + x
        
        // 根据坐标检查合理性，如果合理则直接更新数据
        let scope = model.iScopeForPlayer()
        if scope.contains(id) {
            return id
        } else {
            return nil
        }
    }
    
    // MARK: - Wall
    
    /** 根据当前触碰点计算木板视图的尺寸和方向 */
    class func wallFrameForTouch(location: CGPoint) -> (CGRect, CGFloat) {
        let cellSize = (UIScreen.mainScreen().bounds.width - 40) / 11
        let distance = cellSize * 1.75
        
        var offset = kOffset ? kOffsetLong : 0
        offset = GameModel.shared.player ? offset : -offset
        let x = location.x - distance
        let y = location.y - distance + offset
        let rect = CGRectMake(x, y, distance * 2, distance * 2)
        
        var rotate  = GameModel.shared.player ? CGFloat(M_PI) : 0
        let horizon = Int((location.x - cellSize * 0.3125) / (cellSize * 0.625)) % 2 == 1
        rotate = horizon ? rotate : rotate + CGFloat(M_PI * 1.5)
        return (rect, rotate)
    }
    
    /** 根据当前触摸点计算墙壁数据 */
    class func wallDataForTouch(location: CGPoint) -> DataModel {
        let cellSize = (UIScreen.mainScreen().bounds.width - 40) / 11
        let horizon = Int((location.x - cellSize * 0.3125) / (cellSize * 0.625)) % 2 == 0
        let player  = GameModel.shared.player
        
        // 计算墙壁中心点
        var x: CGFloat
        var y: CGFloat
        var offset: CGFloat
        if horizon {
            x = player ? location.x + cellSize * 0.625 : location.x - cellSize * 0.625
            offset = kOffset ? kOffsetLong : 0
            y = player ? location.y + offset : location.y - offset
        } else {
            x = location.x
            offset = kOffset ? cellSize * 0.625 + kOffsetLong : cellSize * 0.625
            y = player ? location.y + offset : location.y - offset
        }
        
        if x < cellSize * 0.5 || x > cellSize * 1.25 * 8.5 {
            x = -1000
        } else if y < cellSize * 0.5 || y > cellSize * 1.25 * 8.5 {
            y = -1000
        }
        // 计算坐标
        let xCoord = Int(x / (cellSize * 1.25) - 0.5)
        let yCoord = Int(y / (cellSize * 1.25) - 0.5)
        
        return DataModel(x: xCoord, y: yCoord, h: horizon)
    }
}
