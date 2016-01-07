import UIKit

class Background: UIView {
    override func drawRect(rect: CGRect) {
        // 将自己绘制成一个圆角矩形
        layer.backgroundColor = kBackgroundColor.CGColor
        layer.borderColor     = kLineColor.CGColor
        layer.borderWidth     = 2
        layer.cornerRadius    = 8
    }
}
