import UIKit

class Demonstration: UIView, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func pageControlAction(sender: UIPageControl) {
        let offset = CGFloat(sender.currentPage) * width
        scrollView.scrollRectToVisible(CGRect(x: offset, y: 0, width: width, height: height), animated: true)
    }
    
    // MARK: - Init View
    
    func initScrollView() {
        scrollView.contentSize = CGSizeMake(width * 6, height)
        addImageView("Win")
        addImageView("Control")
        addImageView("Move")
        addImageView("Wall")
        addImageView("Window")
        addImageView("End")
    }
    
    private var x: CGFloat = 0
    private let width = UIScreen.mainScreen().bounds.width - 40
    private let height = UIScreen.mainScreen().bounds.height - 65
    
    private func addImageView(name: String) {
        let imageView = UIImageView(frame: CGRectMake(x, 0, width, height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = UIImage(named: name)
        x += width
        scrollView.addSubview(imageView)
    }
    
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = offset
    }
    
    // MARK: - Draw rect
    
    override func drawRect(rect: CGRect) {
        // 将自己绘制成一个圆角矩形
        layer.backgroundColor = kBackgroundColor.CGColor
        layer.borderColor     = kLineColor.CGColor
        layer.borderWidth     = 2
        layer.cornerRadius    = 8
    }
    
}
