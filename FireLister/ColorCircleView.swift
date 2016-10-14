//
//  ColorCircleView.swift
//  FireLister
//
//  Created by Connor Crawford on 10/13/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit

class ColorCircleView: UIView {
    
    var color: Color!
    var isSelected = false {
        didSet {
            
        }
    }
    
    enum Color {
        case purple
        case green
        case blue
        case yellow
        case brown
        case red
        case orange
        
        static var count = 7
        
        var value: UIColor {
            switch self {
            case .purple:
                return UIColor(colorLiteralRed: 204/255.0, green: 115/255.0, blue: 225/255.0, alpha: 1.0)
            case .green:
                return UIColor(colorLiteralRed: 99/255.0, green: 218/255.0, blue: 56/255.0, alpha: 1.0)
            case .blue:
                return UIColor(colorLiteralRed: 27/255.0, green: 173/255.0, blue: 248/255.0, alpha: 1.0)
            case .yellow:
                return UIColor(colorLiteralRed: 234/255.0, green: 187/255.0, blue: 0, alpha: 1.0)
            case .brown:
                return UIColor(colorLiteralRed: 162/255.0, green: 132/255.0, blue: 94/255.0, alpha: 1.0)
            case .red:
                return UIColor(colorLiteralRed: 1.0, green: 41/255.0, blue: 104/255.0, alpha: 1.0)
            case .orange:
                return UIColor(colorLiteralRed: 1.0, green: 149/255.0, blue: 0, alpha: 1.0)
            }
        }
        
        static func color(at index: Int) -> Color? {
            switch index {
            case 0:
                return .purple
            case 1:
                return .green
            case 2:
                return .blue
            case 3:
                return .yellow
            case 4:
                return .brown
            case 5:
                return .red
            case 6:
                return .orange
            default:
                return nil
            }
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // Outer Oval Drawing
        let outerOvalPath = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: rect.width - 2, height: rect.height - 2))
        color.value.setStroke()
        outerOvalPath.lineWidth = 1
        outerOvalPath.stroke()
        
        
        if (isSelected) {
            // Inner Oval Drawing
            let innerOvalPath = UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: rect.width - 6, height: rect.height - 6))
            color.value.setFill()
            innerOvalPath.fill()
        } else {
            color.value.setFill()
            outerOvalPath.fill()
        }
    }

}
