import UIKit

func ==(lhs: Path, rhs: Path) -> Bool {
    return lhs.data == rhs.data
}

struct Path: Hashable {
    var data: Int
    var parent: Int
    var hashValue: Int {
        return data
    }
}

class GameAi: NSObject {
    
    // MARK: - Interface
    
    /** 获取最短路径 */
    class func pathForPlayer(play: Bool) -> [Int] {
        let player = play ? GameModel.shared.topPlayer.id : GameModel.shared.downPlayer.id
        let end = play ? topEnd : downEnd
        return pathForPlayer(Path(data: player, parent: -1), end: end)
    }
    
    /** 获取下一步 */
    class func Ai() -> DataModel {
        // 前几步可以按谱走
        if GameModel.shared.gameStack.count < 8 {
            return opening()
        }
        
        // 木板下完了，那就只能任人宰割了。
        if GameModel.shared.iWallIsEmpty() {
            let player = pathForPlayer(true)
            var i: Int
            let scope = GameModel.shared.scopeForPlayer(GameModel.shared.topPlayer.id, rival: GameModel.shared.downPlayer.id)
            for (i = player.count-1; i > 0; i--) {
                if scope.contains(player[i]) {
                    break
                }
            }
            return DataModel.idConvertToPlayer(player[i], player: true)
        }
        
        // 计算是否可以去除自己的最长路径。
        if let wall = longPathForPlayer() {
            return wall
        }
        
        return AiCount()
    }
    
    // MARK: - Ai
    
    /** 计算下一步的最佳路径 */
    private class func AiCount() -> DataModel {
        let game = GameModel.shared
        
        let player = pathForPlayer(true)
        let rival  = pathForPlayer(false)
        
        var maxPath = rival.count
        var bestWall: DataModel?
        
        // 查找阻挡对方的最佳木板位置
        for (var i = 0; i < rival.count-1; i++) {
            if let wall = wallData([rival[i], rival[i+1]]) {
                game.removeNearLink(wall)
                let rivalTest = pathForPlayer(false).count
                if rivalTest > maxPath {
                    if player.count >= pathForPlayer(true).count {
                        maxPath = rivalTest
                        bestWall = wall
                    }
                }
                game.removeGameWalls(wall)
                game.addNearLink(wall)
            }
        }
        
        // 假如寻找到合适的放置木板位置，则放置木板。否则找出下一步最佳位置。
        if let _ = bestWall {
            return bestWall!
        } else {
            var i: Int
            let scope = GameModel.shared.scopeForPlayer(GameModel.shared.topPlayer.id, rival: GameModel.shared.downPlayer.id)
            for (i = player.count-1; i > 0; i--) {
                if scope.contains(player[i]) {
                    break
                }
            }
            return DataModel.idConvertToPlayer(player[i], player: true)
        }
    }
    
    
    /** 检查自己是不是有必须要档的路径存在 */
    private class func longPathForPlayer() -> DataModel? {
        // 获取完全路径
        allPaths = [[Int]]()
        let playerId = GameModel.shared.topPlayer.id
        let path = Path(data: playerId, parent: -1)
        allPathForPlayer([path], queue: [path], end: topEnd)
        
        // 检查路径差
        if allPaths.count == 2 {
            // 获取最长路径信息
            let count0 = allPaths[0].count
            let count1 = allPaths[1].count
            let max = count0 > count1 ? allPaths[0] : allPaths[1]
            let min = count0 > count1 ? allPaths[1] : allPaths[0]
            
            if max.count - min.count > 4 {
                var i: Int
                for (i = max.count-1; i > 0; i--) {
                    if let wall = wallData([max[i], max[i-1]]) {
                        GameModel.shared.removeNearLink(wall)
                        allPaths = [[Int]]()
                        allPathForPlayer([path], queue: [path], end: topEnd)
                        if allPaths.count == 1 {
                            if allPaths[0].count == min.count {
                                return wall
                            }
                        }
                        GameModel.shared.removeGameWalls(wall)
                        GameModel.shared.addNearLink(wall)
                    }
                }
            }
        }
        return nil
    }
    
    
    /*
    // 查找阻挡对方的最佳木板位置
    for (var i = 0; i < rival.count-1; i++) {
    if let wall = wallData([rival[i], rival[i+1]]) {
    game.removeNearLink(wall)
    let rivalTest = pathForPlayer(false).count
    if rivalTest > maxPath {
    if player.count >= pathForPlayer(true).count {
    maxPath = rivalTest
    bestWall = wall
    }
    }
    game.removeGameWalls(wall)
    game.addNearLink(wall)
    }
    }*/
    
    /** 返回墙壁可能解 */
    private class func wallData(var ids: [Int]) -> DataModel? {
        ids.sortInPlace()
        let x = ids[0] % 9
        let y = ids[0] / 9
        let h = (ids[1] - ids[0]) == 9
        
        var id = (x * 2 + 1) + (y * 2 + 1) * 17
        let offset = h ? 1 : 17
        
        // 检查主位是否可以放置木板
        if x != 8 && y != 8 {
            if !GameModel.shared.gameWalls[id] {
                if !GameModel.shared.gameWalls[id + offset] {
                    GameModel.shared.gameWalls[id] = true
                    GameModel.shared.gameWalls[id+offset] = true
                    GameModel.shared.gameWalls[id-offset] = true
                    return DataModel(x: x, y: y, h: h)
                }
            }
        }
        // 检查副位置是否可以放置木板
        if (h && x > 0) || (!h && y > 0) {
            id -= (h ? 2 : 34)
            if !GameModel.shared.gameWalls[id] {
                if !GameModel.shared.gameWalls[id-offset] {
                    GameModel.shared.gameWalls[id] = true
                    GameModel.shared.gameWalls[id+offset] = true
                    GameModel.shared.gameWalls[id-offset] = true
                    return DataModel(x: h ? x-1 : x, y: h ? y : y-1, h: h)
                }
            }
        }
        return nil
    }
    
    // MARK: - 最短路径
    
    /** 获取最短路径 */
    private class func pathForPlayer(player: Path, end: (Int)->Bool) -> [Int] {
        var logs = [player]
        var queue = [player]
        var finish: Path?
        
        // 查找最短路径
        while !queue.isEmpty {
            let path = queue.removeFirst()
            
            if end(path.data) {
                finish = path
                break
            } else {
                let near = GameModel.shared.gameNears[path.data]
                for n in near {
                    if !logs.contains({ $0.data == n }) {
                        logs.append(Path(data: n, parent: path.data))
                        queue.append(Path(data: n, parent: path.data))
                    }
                }
            }
        }
        
        // 输出结果
        if let _ = finish {
            var node = finish!
            var path = [node.data]
            
            while node.parent != -1 {
                if let log = logs.indexOf({ $0.data == node.parent }) {
                    node = logs[log]
                    path.insert(node.data, atIndex: 0)
                } else {
                    break
                }
            }
            return path
        } else {
            return []
        }
    }
    
    // MARK: - 获取全路径
    /** 路径记录 */
    private static var allPaths = [[Int]]()
    
    /** 获取棋子全路径 */
    private class func allPathForPlayer(var logs: [Path], var queue: [Path], end: (Int)->Bool) {
        while !queue.isEmpty {
            // 检查是否抵达终点，是的话输出路径
            for path in queue {
                if end(path.data) {
                    var node = path
                    var pathNode = [path.data]
                    while node.parent != -1 {
                        let log = logs.indexOf({ $0.data == node.parent })!
                        node = logs[log]
                        pathNode.append(node.data)
                    }
                    allPaths.append(pathNode)
                    return
                }
            }
            
            /** 储存扩展集合 */
            var pathSets = [Set<Path>]()
            
            // 计算相邻区域集合
            for path in queue {
                // 把棋子的相邻区域获取出来，查看是否有已经包含的区域
                let scopes = GameModel.shared.gameNears[path.data]
                var newScopes = [Path]()
                for scope in scopes {
                    if !logs.contains({ $0.data == scope }) {
                        newScopes.append(Path(data: scope, parent: path.data))
                    }
                }
                // 把区域建立集合并跟pathSets进行交集操作
                if newScopes.count == 2 {
                    let absValue = abs(newScopes[0].data - newScopes[1].data)
                    if absValue == 18 || absValue == 2 {
                        union(&pathSets, newSet: [newScopes[0]])
                        union(&pathSets, newSet: [newScopes[1]])
                    } else {
                        union(&pathSets, newSet: Set(newScopes))
                    }
                } else if newScopes.count > 0 {
                    union(&pathSets, newSet: Set(newScopes))
                } else {
                    return
                }
                
            }
            
            // 对路径进行下一步操作
            if pathSets.count > 1 {
                for pathSet in pathSets {
                    allPathForPlayer(logs + pathSet.reverse(), queue: pathSet.reverse(), end: end)
                }
                return
            } else if pathSets.count > 0 {
                logs += pathSets[0].reverse()
                queue = pathSets[0].reverse()
            }
        }
    }
    
    // MARK: - 开局
    
    /** 这本来应该是一个开局棋谱……然而，随便了。 */
    private class func opening() -> DataModel {
        let player = pathForPlayer(true)
        let isMove = Int(arc4random() % 10) < 7
        if isMove {
            return DataModel.idConvertToPlayer(player[1], player: true)
        } else {
            var x: Int
            var y: Int
            var h: Bool
            while true {
                x = Int(arc4random() % 8)
                y = Int(arc4random() % 8)
                h = Int(arc4random() % 2) == 0
                let data = DataModel(x: x, y: y, h: h)
                guard GameModel.shared.iWallIsAllow(data) else { continue }
                GameModel.shared.removeNearLink(data)
                let test = pathForPlayer(true)
                guard test.count <= player.count else { GameModel.shared.addNearLink(data); continue }
                GameModel.shared.addNearLink(data)
                return data
            }
        }
    }
    
    
    // MARK: - Action
    
    /** 上方玩家终点 */
    private class func topEnd(data: Int) -> Bool {
        return data > 71
    }
    /** 下方玩家终点 */
    private class func downEnd(data: Int) -> Bool {
        return data < 9
    }
    
    /** 把集合进行合并操作 */
    private class func union(inout allSets: [Set<Path>], newSet: Set<Path>) {
        var i: Int
        var hasUnion: Bool = false
        
        for (i = 0; i < allSets.count; i++) {
            if !allSets[i].isDisjointWith(newSet) {
                allSets[i] = allSets[i].union(newSet)
                hasUnion = true
                
                var j = i + 1
                while j < allSets.count {
                    if !allSets[i].isDisjointWith(allSets[j]) {
                        allSets[i] = allSets[i].union(allSets[j])
                        allSets.removeAtIndex(j)
                    } else {
                        j++
                    }
                }
                
                break
            }
        }
        
        if !hasUnion {
            allSets.append(newSet)
        }
    }

}
