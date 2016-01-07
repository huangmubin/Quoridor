import UIKit

/** 游戏数据模型 */
class GameModel: NSObject {
    
    // MARK: - Interface
    
    /** 放置墙壁 */
    func iPutWall(wall: DataModel) {
        if player {
            topWalls.append(wall)
        } else {
            downWalls.append(wall)
        }
        addGameWalls(wall)
        removeNearLink(wall)
        gameStack.append(wall.copyMode())
    }
    
    /** 移动棋子 */
    func iMove(data: DataModel) {
        if player {
            topPlayer.copyMode(data)
        } else {
            downPlayer.copyMode(data)
        }
        gameStack.append(data.copyMode())
    }
    
    /** 移动棋子 */
    func iMoveWithId(id: Int) {
        let data = DataModel.idConvertToPlayer(id, player: player)
        if player {
            topPlayer.copyMode(data)
        } else {
            downPlayer.copyMode(data)
        }
        gameStack.append(data.copyMode())
    }
    
    /** 重置游戏 */
    func iRestartGame() {
        initModelData()
    }
    
    /** 悔棋 */
    func iRetractGame() {
        retractGame()
    }
    
    /** 检查木板是否已经用光 */
    func iWallIsEmpty() -> Bool {
        if player {
            return topWalls.count >= 10
        } else {
            return downWalls.count >= 10
        }
    }
    
    /** 检查木板的位置是否合理 */
    func iWallIsAllow(data: DataModel) -> Bool {
        guard data.x >= 0 && data.y >= 0 else { return false }
        guard data.x < 9 && data.y < 9 else { return false }
        for id in data.wallIds {
            if gameWalls[id] {
                return false
            }
        }
        removeNearLink(data)
        if GameAi.pathForPlayer(true).count > 0 {
            if GameAi.pathForPlayer(false).count > 0 {
                addNearLink(data)
                return true
            }
        }
        addNearLink(data)
        return false
    }
    
    /** 获取棋子的有效区域 */
    func iScopeForPlayer() -> [Int] {
        let play  = player ? topPlayer.id : downPlayer.id
        let rival = player ? downPlayer.id : topPlayer.id
        return scopeForPlayer(play, rival: rival)
    }
    
    // MARK: - Datas
    /* 游戏数据集合。包括色彩方案；两棋子数据；各自使用的墙壁数据；棋谱数据；*/
    
    // MARK: 色彩方案
    /** Color Model */
    var color: Bool = true
    
    // MARK: 玩家数据
    /** Top Player Data */
    var topPlayer: DataModel  = DataModel()
    /** Down Player Data */
    var downPlayer: DataModel = DataModel()
    
    /** Top Walls Data */
    var topWalls: [DataModel]  = [DataModel]()
    /** Down Walls Data */
    var downWalls: [DataModel] = [DataModel]()
    
    /** All walls data */
    var allWalls: [DataModel] { return topWalls + downWalls }
    
    /** Ai is open */
    var gameAi: Bool = true
    
    // MARK: 棋谱
    /** Chess manual Stack */
    var gameStack: [DataModel] = [DataModel]()
    
    // MARK: 游戏数据
    /** The current player */
    var player: Bool {
        let firstPlayer = gameStack[0].h
        return firstPlayer == (gameStack.count % 2 == 0) ? firstPlayer : !firstPlayer
    }
    
    /** The game state */
    var status: GameStatus {
        if topPlayer.y == 8 {
            if GameAi.pathForPlayer(false).count == 1 {
                return GameStatus.Draw
            } else {
                return GameStatus.TopWin
            }
        }
        if downPlayer.y == 0 {
            if GameAi.pathForPlayer(true).count == 1 {
                return GameStatus.Draw
            } else {
                return GameStatus.DownWin
            }
        }
        return GameStatus.Runing
    }
    
    /** 棋盘通道记录 */
    var gameNears: [[Int]] = [[Int]]()
    
    /** 墙壁数据记录 */
    var gameWalls: [Bool] = [Bool]()
    
    // MARK: - Singleton Class
    /* 创建游戏模型的单例类，并禁止其他类初始化该方法 */
    
    /** 游戏模型的单例 */
    static var shared = GameModel()
    
    /** 私有化初始化方法 */
    private override init() {
        super.init()
        initModelData()
    }

    // MARK: - Init Function
    
    private func initModelData() {
        // Player Data
        topPlayer  = DataModel(x: 4, y: 0, h: true, t: false)
        downPlayer = DataModel(x: 4, y: 8, h: false, t: false)
        
        topWalls  = [DataModel]()
        downWalls = [DataModel]()
        
        // Chess manual
        arcFirstPlayer()
        
        initGameNearsAndWalls()
    }
    
    /** 随机先后手原则 */
    private func arcFirstPlayer() {
        let play = (arc4random() % 2) == 0
        if play {
            gameStack = [topPlayer.copyMode(), downPlayer.copyMode()]
        } else {
            gameStack = [downPlayer.copyMode(), topPlayer.copyMode()]
        }
    }
    
    /** 初始化棋盘数据 */
    private func initGameNearsAndWalls() {
        gameNears = [[Int]]()
        // GameNears
        for i in 0 ..< 82 {
            gameNears.append([])
            for j in [i+1,i-1] {
                if j > 0 && j < 81 && (j / 9) == (i / 9) {
                    gameNears[i].append(j)
                }
            }
            if i+9 < 82 {
                gameNears[i].append(i+9)
            }
            if i-9 >= 0 {
                gameNears[i].append(i-9)
            }
        }
        
        gameWalls = [Bool]()
        // GameWalls
        for _ in 0 ..< 289 {
            gameWalls.append(false)
        }
    }
    
    
    /** 更新墙壁数据 */
    private func updateWallsData() {
        for wall in allWalls {
            addGameWalls(wall)
            removeNearLink(wall)
        }
    }
}
