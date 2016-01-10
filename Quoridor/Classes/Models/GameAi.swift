import UIKit

func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.data == rhs.data
}

struct Node: Hashable {
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
        return pathForPlayer(Node(data: player, parent: -1), end: end)
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
    
    
    class func allPath(player: Bool) -> [[Int]]? {
        let playId = player ? GameModel.shared.topPlayer.id : GameModel.shared.downPlayer.id
        let node = Node(data: playId, parent: -1)
        let end  = player ? topEnd : downEnd
        return allPathForPlayer([node], scanQueue: [node], end: end)
    }
    
    // MARK: - Ai
    
    /** 计算下一步的最佳路径 */
    private class func AiCount() -> DataModel {
        let game = GameModel.shared
        
        let player = pathForPlayer(true)
        let rival  = pathForPlayer(false)
        
        var maxPath = rival.count
        var bestWall: DataModel?
        
        if player.count > rival.count {
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
        if let allPaths = allPath(true) {
            // 检查路径差
            if allPaths.count == 2 {
                // 获取最长路径信息
                let count0 = allPaths[0].count
                let count1 = allPaths[1].count
                let max = count0 > count1 ? allPaths[0] : allPaths[1]
                let min = count0 > count1 ? allPaths[1] : allPaths[0]
                
                if max.count - min.count > 3 {
                    var i: Int
                    for (i = max.count-1; i > 0; i--) {
                        if let wall = wallData([max[i], max[i-1]]) {
                            GameModel.shared.removeNearLink(wall)
                            if let allPathTemp = allPath(true) {
                                if allPathTemp.count == 1 {
                                    if allPaths[0].count == min.count {
                                        if pathForPlayer(false).count > 0 {
                                            print("longPathForPlayer")
                                            return wall
                                        }
                                    }
                                }
                            }
                            GameModel.shared.removeGameWalls(wall)
                            GameModel.shared.addNearLink(wall)
                        }
                    }
                }
            }
        }
        return nil
    }
    
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
    private class func pathForPlayer(player: Node, end: (Int)->Bool) -> [Int] {
        var logs = [player]
        var queue = [player]
        var finish: Node?
        
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
                        logs.append(Node(data: n, parent: path.data))
                        queue.append(Node(data: n, parent: path.data))
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
    
    /** 获取全路径 */
    private class func allPathForPlayer(var logs: [Node], var scanQueue: [Node], end: (Int)->Bool ) -> [[Int]]? {
        // 0. 循环处理搜索队列，直到队列为空时就退出处理程序
        while !scanQueue.isEmpty {
            // 0.0 检查队列是否包含终点目标，是的话输出路径
            for queueNode in scanQueue {
                if end(queueNode.data) {
                    // 0.0.1 输出路径
                    var node = queueNode
                    var path = [queueNode.data]
                    while node.parent != -1 {
                        let nodeIndexOfLogs = logs.indexOf({ $0.data == node.parent })!
                        node = logs[nodeIndexOfLogs]
                        path.append(node.data)
                    }
                    return [path]
                }
            }
            
            // 0.1 对队列进行扩展扫描，将没有阻隔的扩展节点组合成集合。
            /** 所有节点的集合数组 */
            var nodeSets = [Set<Node>]()
            
            for scanNode in scanQueue {
                var nodeScopes = [Node]()
                
                let nodeNears = GameModel.shared.gameNears[scanNode.data]
                for scope in nodeNears {
                    if !logs.contains({ $0.data == scope }) {
                        nodeScopes.append(Node(data: scope, parent: scanNode.data))
                    }
                }
                
                if nodeScopes.count == 2 {
                    let absValue = abs(nodeScopes[0].data - nodeScopes[1].data)
                    if absValue == 18 || absValue == 2 {
                        union(&nodeSets, newSet: [nodeScopes[0]])
                        union(&nodeSets, newSet: [nodeScopes[1]])
                    } else {
                        union(&nodeSets, newSet: Set(nodeScopes))
                    }
                } else if nodeScopes.count > 0 {
                    union(&nodeSets, newSet: Set(nodeScopes))
                }
            }
            
            // 0.2 对所有节点的集合数组进行判定，假如出现分支，则对每个分支进行迭代处理，然后退出。否则更新搜索队列。
//            printPath0(nodeSets)
            
            if nodeSets.count > 1 {
                var finishPath = [[Int]]()
                for nodeSet in nodeSets {
                    // 0.2.1 计算出该分组的父节点以及已经被查询过的领结点，作为新的logs
                    var nodes = nodeSet
                    var pathSet = Set(nodes)
                    while !nodes.isEmpty {
                        let node = nodes.removeFirst()
                        for nodeNear in GameModel.shared.gameNears[node.data] {
                            if let nearIndexOfLogs = logs.indexOf({ $0.data == nodeNear }) {
                                pathSet.insert(logs[nearIndexOfLogs])
                            }
                        }
                        pathSet.insert(node)
                        if node.parent != -1 {
                            let parentIndexOfLogs = logs.indexOf({ $0.data == node.parent })!
                            nodes.insert(logs[parentIndexOfLogs])
                        }
                    }
                    
//                    printPath(pathSet.reverse())
//                    print("==========----------====")
//                    printPath(nodeSet.reverse())
                    // 0.2.2 获取分支路径
                    if let path = allPathForPlayer(pathSet.reverse(), scanQueue: nodeSet.reverse(), end: end) {
                        finishPath += path
                    }
                }
                if finishPath.count > 0 {
                    return finishPath
                } else {
                    return nil
                }
            } else if nodeSets.count > 0 {
                logs += nodeSets[0].reverse()
                scanQueue = nodeSets[0].reverse()
            } else {
                return nil
            }
        }
        return nil
    }
    
    // MARK: - 开局
    
    /** 这本来应该是一个开局棋谱……然而，随便了。 */
    private class func opening() -> DataModel {
        // 获取最短路径
        let player = pathForPlayer(true)
        // 计算移动几率
        let isMove = Int(arc4random() % 10) < 7
        // 获取完全路径
        let allPathCount = allPath(false)!.count
        
        if isMove || allPathCount >= 2 {
            return DataModel.idConvertToPlayer(player[1], player: true)
        } else {
            var x: Int
            var y: Int
            var h: Bool
            while true {
                // 计算出一个随机木板位置，并检测是否合理
                x = Int(arc4random() % 8)
                y = Int(arc4random() % 8)
                h = Int(arc4random() % 2) == 0
                let data = DataModel(x: x, y: y, h: h)
                guard GameModel.shared.iWallIsAllow(data) else { continue }
                
                // 计算该木板是否会阻挡到自己。
                GameModel.shared.removeNearLink(data)
                let test = pathForPlayer(true)
                guard test.count <= player.count else { GameModel.shared.addNearLink(data); continue }
                
                // 计算该木板能否给对方增加变数，否则就不增加
                let allPathsCountTemp = allPath(false)!
                guard allPathsCountTemp.count >= 2 else { GameModel.shared.addNearLink(data); continue }
                
                // 还原设置，返回木板
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
    private class func union(inout allSets: [Set<Node>], newSet: Set<Node>) {
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
    
    /** 输出路径位置 */
    class func printPath(nodes: [Node]) {
        var board = [Int]()
        for _ in 0 ..< 81 {
            board.append(0)
        }
        for node in nodes {
            board[node.data] = 1
        }

        for (i,n) in board.enumerate() {
            print("\(n) ", separator: "", terminator: "")
            if (i + 1) % 9 == 0 {
                print("")
            }
        }
    }
    
    class func printPath0(nodesX: [Set<Node>]) {
        for nodes in nodesX {
            print("================")
            printPath(nodes.reverse())
        }
    }
}
