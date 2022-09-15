//
//  CroppingView.swift
//  InstaScan
//
//  Created by Can Şener on 9.06.2022.
//

import UIKit

final class InstaScanCroppingView: UIView {
    
    @IBOutlet weak var lblGuide: UILabel!

    
    @IBOutlet private var overlayView: UIView!
    @IBOutlet private var cropReferenceView: UIView!
    
    private let shapeLayer = CAShapeLayer()
    
    
    var referenceFrame:CGRect?
    
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    var guideText:String!{
        didSet{
            lblGuide.text = guideText
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var guideTextFont:UIFont!{
        didSet{
            lblGuide.font = guideTextFont
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var guideTextColor:UIColor!{
        didSet{
            lblGuide.textColor = guideTextColor
        
        }
    }
    
    var overlayColor:UIColor!{
        didSet{
            self.overlayView.backgroundColor = overlayColor
        
        }
    }
    
    func setup(){
        overlayView.frame = self.bounds
    
    }
    
    func updateReferenceFrame(_ rect:CGRect){
        referenceFrame = rect
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        overlayView.frame = self.bounds

        if let refFrame = referenceFrame {
            var frame = refFrame
            cropReferenceView.frame  = frame
         
        } else {
            var frame = cropReferenceView.frame
            frame.origin.x = 40
            frame.size = CGSize(width: superview!.frame.width - 80, height: 0)
            frame.origin.y = (superview!.frame.height - frame.size.height) / 2.0
            cropReferenceView.frame  = frame
        }
        
        let labelWidth = superview!.frame.size.width - 80
        let labelHeight = lblGuide.sizeThatFits(CGSize(width:labelWidth , height: CGFloat.greatestFiniteMagnitude)).height
        let labelOriginY = cropReferenceView.frame.origin.y - labelHeight - 16
        lblGuide.frame = CGRect(x: 40, y: labelOriginY, width: labelWidth, height: labelHeight)
        
        shapeLayer.frame = overlayView.bounds
        shapeLayer.fillRule = .evenOdd
        
        let path = UIBezierPath(rect: overlayView.bounds)
        path.append(UIBezierPath(roundedRect: cropReferenceView.frame, cornerRadius: 16.0))
        shapeLayer.path = path.cgPath
      
        

        overlayView.layer.mask = shapeLayer
    }
}
