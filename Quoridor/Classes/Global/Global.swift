import UIKit

// MARK: - 游戏状态

/** 游戏状态 */
enum GameStatus {
    case TopWin
    case DownWin
    case Draw
    case Runing
}

// MARK: - 尺寸

var kOffset: Bool = false
let kOffsetLong:CGFloat = 50


// MARK: - 颜色

/** 背景颜色 */
var kBackgroundColor: UIColor {
    if GameModel.shared.color {
        return UIColor(red: 186.0/255.0, green: 153.0/255.0, blue: 241.0/255.0, alpha: 1)
    } else {
        return UIColor(red: 109.0/255.0, green: 41.0/255.0, blue: 70.0/255.0, alpha: 1)
    }
}


/** 边线颜色 */
var kLineColor: UIColor {
    if GameModel.shared.color {
        return UIColor.whiteColor()
    } else {
        return UIColor.whiteColor()
    }
}

/** 格子边线颜色 */
var kCellLineColor: UIColor {
    if GameModel.shared.color {
        return UIColor(red: 137.0/255.0, green: 223.0/255.0, blue: 241.0/255.0, alpha: 1)
    } else {
        return UIColor(red: 103.0/255.0, green: 103.0/255.0, blue: 103.0/255.0, alpha: 1)
    }
}

/** 墙壁颜色 */
var kWallColor: UIColor {
    if GameModel.shared.color {
        return UIColor(red: 118.0/255.0, green: 255.0/255.0, blue: 208.0/255.0, alpha: 1)
    } else {
        return UIColor(red: 124.0/255.0, green: 255.0/255.0, blue: 229.0/255.0, alpha: 1)
    }
}

/** 棋谱格子阴影颜色 */
var kCellShadowColor: UIColor {
    if GameModel.shared.color {
        return UIColor.clearColor()
    } else {
        return UIColor.whiteColor()
    }
}

/** Top棋子颜色 */
var kTopColor: UIColor {
    if GameModel.shared.color {
        return UIColor(red: 244.0/255.0, green: 165.0/255.0, blue: 35.0/255.0, alpha: 1)
    } else {
        return UIColor(red: 244.0/255.0, green: 165.0/255.0, blue: 35.0/255.0, alpha: 1)
    }
}

/** 棋子颜色 */
var kDownColor: UIColor {
    if GameModel.shared.color {
        return UIColor(red: 238.0/255.0, green: 142.0/255.0, blue: 154.0/255.0, alpha: 1)
    } else {
        return UIColor(red: 238.0/255.0, green: 142.0/255.0, blue: 154.0/255.0, alpha: 1)
    }
}

/** 错误提示色 */
var kWrongColor: UIColor {
    if GameModel.shared.color {
        return UIColor(red: 255.0/255.0, green: 124.0/255.0, blue: 184.0/255.0, alpha: 1)
    } else {
        return UIColor(red: 255.0/255.0, green: 124.0/255.0, blue: 184.0/255.0, alpha: 1)
    }
}