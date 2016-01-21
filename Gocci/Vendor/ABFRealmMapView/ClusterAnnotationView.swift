//
//  ClusterAnnotationView.swift
//  Gocci
//
//  Created by Ma Wa on 20.01.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation


class ABFClusterAnnotationView : MKAnnotationView {
    
    
    var count: Int = 0 {
        didSet {
            countDidSet(count)
        }
    }
    
    var color: UIColor? = nil
    
    
    // helper
    
    static let ABFScaleFactorAlpha = 0.3
    static let ABFScaleFactorBeta = 0.4
    
    static func ABFRectCenter(rect: CGRect) -> CGPoint {
        return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        
    }
    
    static func ABFCenterRect(rect: CGRect, center: CGPoint) -> CGRect {
        return CGRectMake(
            center.x - CGRectGetWidth(rect)/2.0,
            center.y - CGRectGetHeight(rect)/2.0,
            CGRectGetWidth(rect),
            CGRectGetHeight(rect))
    }
    
    
    static func ABFScaledValueForValue(value: Double) -> CGFloat
    {
        return CGFloat(1.0 / (1.0 + exp(-1 * ABFScaleFactorAlpha * pow(Double(value), ABFScaleFactorBeta))))
    }
    
    
    // Das wird irgendwie nich so richtig gebraucht. im heatmap view controller aber...
    /*
+ (nullable NSArray<ABFLocationSafeRealmObject *> *)safeObjectsForClusterAnnotationView:(nullable MKAnnotationView *)annotationView
    {
        if ([annotationView isKindOfClass:[self class]]) {
            ABFClusterAnnotationViewXXX *clusterView = (ABFClusterAnnotationViewXXX *)annotationView;

            if ([clusterView.annotation isKindOfClass:[ABFAnnotation class]]) {
                ABFAnnotation *clusterAnnotation = (ABFAnnotation *)clusterView.annotation;

            return clusterAnnotation.safeObjects;
            }
        }
        return nil;
    }
*/
    
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        setupLabel()
        self.count = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var countLabel: UILabel! = nil
    
    func setupLabel() {
        countLabel = UILabel(frame: self.frame)
        countLabel.backgroundColor = UIColor.clearColor()
        countLabel.textColor = UIColor.whiteColor()
        countLabel.textAlignment = NSTextAlignment.Center
        countLabel.shadowColor = UIColor.clearColor()
        countLabel.adjustsFontSizeToFitWidth = true;
        countLabel.numberOfLines = 1
        countLabel.font = UIFont(descriptor: UIFontDescriptor(), size: 12)
        countLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.addSubview(countLabel)
    }
    
    func countDidSet(count: Int) {
    
        let newBounds = CGRectMake(0,0,
            round(44.0 * ABFClusterAnnotationView.ABFScaledValueForValue(Double(count))),
            round(44.0 * ABFClusterAnnotationView.ABFScaledValueForValue(Double(count))))
    
        self.frame = ABFClusterAnnotationView.ABFCenterRect(newBounds, center: self.center);
    
        let newLabelBounds = CGRectMake(0, 0,
            newBounds.size.width / 1.3,
            newBounds.size.height / 1.3);
        
        countLabel.frame = ABFClusterAnnotationView.ABFCenterRect(newLabelBounds, center: ABFClusterAnnotationView.ABFRectCenter(newBounds));
        
        countLabel.text = "\(count)"
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
    
        let context = UIGraphicsGetCurrentContext();
        
        CGContextSetAllowsAntialiasing(context, true);
        
        let outerCircleStrokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.25)
        let innerCircleStrokeColor = UIColor.whiteColor()
        
        let clusterColor = color ?? UIColor.redColor()
        
        let innerCircleFillColor = clusterColor
        
        let circleFrame = CGRectInset(rect, 4, 4)
        
        outerCircleStrokeColor.setStroke()
        CGContextSetLineWidth(context, 5.0)
        CGContextStrokeEllipseInRect(context, circleFrame)
        
        innerCircleStrokeColor.setStroke()
        CGContextSetLineWidth(context, 4)
        CGContextStrokeEllipseInRect(context, circleFrame)
        
        innerCircleFillColor.setFill()
        CGContextFillEllipseInRect(context, circleFrame)
    }
    
    
    
    
    
    
    
    
    
    
    
}