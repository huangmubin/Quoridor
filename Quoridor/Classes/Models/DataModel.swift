import UIKit

/** 基础数据模型，用以表示棋子，墙壁。 */
class DataModel: NSObject {
    
    // MARK: - Data
    /* 数据具体坐标和类型 */
    
    /** x轴坐标 */
    var x: Int { didSet { updateId() } }
    /** y轴坐标 */
    var y: Int { didSet { updateId() } }
    /** Horizontal: 如果是木板，则表示横向horizontal与竖向vertical。如果是棋子，则表示顶方Top与下方Down。 */
    var h: Bool {
        didSet {
            if t {
                updateWallIds()
            }
        }
    }
    /** Type: 类型，True表示木板，False表示棋子。 */
    var t: Bool
    
    
    // MARK: Count Data
    /* 不进行存储的辅助数据 */
    
    /** 棋子坐标 */
    var id: Int = 0
    
    /** 墙壁坐标 */
    var wallIds: [Int] = [Int]()
    
    // MARK: - Init Function
    /** 初始化方法 */
    
    override init() {
        x = 0
        y = 0
        h = true
        t = true
    }
    
    init(x: Int, y: Int, h: Bool, t: Bool) {
        self.x = x
        self.y = y
        self.h = h
        self.t = t
        super.init()
        updateId()
        updateWallIds()
    }
    
    convenience init(x: Int, y: Int, h: Bool) {
        self.init(x: x,y: y,h: h, t: true)
    }
    
    
    // MARK: - Copy Model
    
    /** 复制并建立新值 */
    func copyMode() -> DataModel {
        return DataModel(x: x, y: y, h: h, t: t)
    }
    
    /** 复制 */
    func copyMode(model: DataModel) {
        x = model.x
        y = model.y
        h = model.h
        t = model.t
    }
    
    // MARK: - Private Action
    
    /** Update the Id and WallIds. */
    private func updateId() {
        id = x + y * 9
    }
    
    /** Update the WallIds */
    private func updateWallIds() {
        wallIds = []
        if t {
            for i in [-1,0,1] {
                var wallId = (x * 2 + 1) + (y * 2 + 1) * 17
                if h {
                    wallId += i
                } else {
                    wallId += (i * 17)
                }
                wallIds.append(wallId)
            }
        }
    }
    
    // MARK: - Action Interface
    
    /** Id Convert to DataModel */
    class func idConvertToPlayer(id: Int, player: Bool) -> DataModel {
        let x = id % 9
        let y = id / 9
        return DataModel(x: x, y: y, h: player, t: false)
    }
    
    /** description Data */
    override var description: String {
        return "x = \(x), y = \(y), h = \(h), t = \(t), Address = \(super.description)"
    }
}
