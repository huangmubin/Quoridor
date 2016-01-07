import UIKit

class PlayerPrompt: UIView {

    // MARK: - Interface
    
    /** 显示提示 */
    func showHint() {
        datas = []
        let player = GameModel.shared.player
        let ids = GameModel.shared.iScopeForPlayer()
        for id in ids {
            datas.append(DataModel.idConvertToPlayer(id, player: player))
        }
        setNeedsDisplay()
    }
    
    /** 隐藏提示 */
    func hideHint() {
        datas = []
        setNeedsDisplay()
    }
    
    // MARK: - DrawRect
    
    var datas = [DataModel]()
    
    override func drawRect(rect: CGRect) {
        // 绘制棋盘方格
        let cellSize = bounds.height / 11
        let distance = cellSize * 1.25
        
        kCellLineColor.setFill()
        
        for data in datas {
            let x = CGFloat(data.x) * distance
            let y = CGFloat(data.y) * distance
            let path = UIBezierPath(roundedRect: CGRectMake(x, y, cellSize, cellSize), cornerRadius: 4)
            path.fill()
        }
    }

}
