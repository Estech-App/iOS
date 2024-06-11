

import UIKit


@IBDesignable
class CustomNavBar: UIView {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var view: UIView!
    weak var context: UIViewController?
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    func setup(context: UIViewController) {
        self.context = context
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    @IBAction func back(_ sender: Any) {
        context?.navigationController?.popViewController(animated: true)
    }
    
    public func hideBackButton() {
        backButton.isHidden = true
    }
    
    public func setTitle(_ titleMsg: String) {
        title.text = titleMsg
    }
    
}
