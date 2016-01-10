import UIKit

class Screen: UIView {

    // MARK: - Interface
    
    /** 显示 */
    func show() {
        showSelf()
    }
    /** 隐藏 */
    func hidden() {
        hiddenSelf()
    }
    
    // MARK: - Image
    
    @IBOutlet weak var screenImageView: UIImageView!
    
    // MARK: - Animation
    
    /** 显示动画 */
    private func showSelf() {
        self.hidden = false
    }
    /** 隐藏动画 */
    private func hiddenSelf() {
        self.hidden = true
    }
    // MARK: - DrawRect
    
    override func drawRect(rect: CGRect) {
        // 将自己绘制成一个圆角矩形
        layer.backgroundColor = kBackgroundColor.CGColor
        layer.borderColor     = kLineColor.CGColor
        layer.borderWidth     = 2
        layer.cornerRadius    = 8
    }

}
