import UIKit

extension GameModel {
    
    // MARK: - Game Walls
    
    /** 新增墙壁 */
    func addGameWalls(wall: DataModel) {
        for id in wall.wallIds {
            gameWalls[id] = true
        }
    }
    /** 移除墙壁 */
    func removeGameWalls(wall: DataModel) {
        for id in wall.wallIds {
            gameWalls[id] = false
        }
    }
    
    // MARK: - Game Nears
    
    /** 减少通道 */
    func removeNearLink(wall: DataModel) {
        let wallId = wall.id
        if wall.h {
            if let index = gameNears[wallId].indexOf(wallId+9) {
                gameNears[wallId].removeAtIndex(index)
            }
            if let index = gameNears[wallId+9].indexOf(wallId) {
                gameNears[wallId+9].removeAtIndex(index)
            }
            if let index = gameNears[wallId+1].indexOf(wallId+10) {
                gameNears[wallId+1].removeAtIndex(index)
            }
            if let index = gameNears[wallId+10].indexOf(wallId+1) {
                gameNears[wallId+10].removeAtIndex(index)
            }
        } else {
            if let index = gameNears[wallId].indexOf(wallId+1) {
                gameNears[wallId].removeAtIndex(index)
            }
            if let index = gameNears[wallId+1].indexOf(wallId) {
                gameNears[wallId+1].removeAtIndex(index)
            }
            if let index = gameNears[wallId+9].indexOf(wallId+10) {
                gameNears[wallId+9].removeAtIndex(index)
            }
            if let index = gameNears[wallId+10].indexOf(wallId+9) {
                gameNears[wallId+10].removeAtIndex(index)
            }
        }
    }
    
    /** 新增通道 */
    func addNearLink(wall: DataModel) {
        let wallId = wall.id
        if wall.h {
            gameNears[wallId].append(wallId+9)
            gameNears[wallId+9].append(wallId)
            gameNears[wallId+1].append(wallId+10)
            gameNears[wallId+10].append(wallId+1)
        } else {
            gameNears[wallId].append(wallId+1)
            gameNears[wallId+1].append(wallId)
            gameNears[wallId+9].append(wallId+10)
            gameNears[wallId+10].append(wallId+9)
        }
    }
    
    // MARK: - Actions
    
    /** 悔棋操作。
        必须是有移动或放置木板后才能操作。
        如果是木板，则直接移除木板。
        如果是棋子则往前查询，查看上一步的位置。*/
    func retractGame() {
        if gameStack.count > 3 {
            for _ in 0 ..< 2 {
                let data = gameStack.removeLast()
                if data.t {
                    if player {
                        topWalls.removeLast()
                    } else {
                        downWalls.removeLast()
                    }
                    removeGameWalls(data)
                    addNearLink(data)
                } else {
                    for (var i = gameStack.count-1; i >= 0; i--) {
                        if !gameStack[i].t {
                            if gameStack[i].h == data.h {
                                if data.h {
                                    topPlayer.copyMode(gameStack[i])
                                } else {
                                    downPlayer.copyMode(gameStack[i])
                                }
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}