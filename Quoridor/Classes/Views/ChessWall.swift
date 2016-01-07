import UIKit

class ChessWall: UIView {
    
    // MARK: - Interface
    
    /** 更新当前墙壁视图。 */
    func update() {
        setNeedsDisplay()
    }
    
    // MARK: - Draw Function
    
    override func drawRect(rect: CGRect) {
        // 根据数据绘制墙壁
        let cellSize = bounds.height / 11
        let distance = cellSize * 1.25
        
        kWallColor.setFill()
        
        for wall in GameModel.shared.allWalls {
            let x = distance * CGFloat(wall.x) + cellSize + (wall.h ? -cellSize : 0) - 2
            let y = distance * CGFloat(wall.y) + cellSize + (wall.h ? 0 : -cellSize) - 2
            let w = cellSize * (wall.h ? 2.25 : 0.25) + 4
            let h = cellSize * (wall.h ? 0.25 : 2.25) + 4
            
            let rect = CGRectMake(x, y, w, h)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
            path.fill()
        }
    }
}
