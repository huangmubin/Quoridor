import UIKit

extension GameModel {
    
    /** 获取棋子的有效区域 */
    func scopeForPlayer(player: Int, rival: Int) -> [Int] {
        var nears = [Int]()
        for near in gameNears[player] {
            if near != rival {
                nears.append(near)
            } else {
                for rivalNear in gameNears[rival] {
                    if rivalNear != player {
                        nears.append(rivalNear)
                    }
                }
            }
        }
        return nears
    }
    
}
