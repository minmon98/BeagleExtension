//
//  ContainerExtension.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import UIKit
import Beagle

class ContainerExtension: BaseServerDrivenComponent {
    var child: ServerDrivenComponent?
    var shadowOpacity: Double?
    var shadowRadius: Double?
    var shadowWidth: Double?
    var shadowHeight: Double?
    var shadowColor: String?
    
    enum CodingKeys: String, CodingKey {
        case child
        case shadowOpacity
        case shadowRadius
        case shadowWidth
        case shadowHeight
        case shadowColor
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        child = try container.decodeIfPresent(forKey: .child)
        shadowOpacity = try container.decodeIfPresent(Double.self, forKey: .shadowOpacity)
        shadowRadius = try container.decodeIfPresent(Double.self, forKey: .shadowRadius)
        shadowWidth = try container.decodeIfPresent(Double.self, forKey: .shadowWidth)
        shadowHeight = try container.decodeIfPresent(Double.self, forKey: .shadowHeight)
        shadowColor = try container.decodeIfPresent(String.self, forKey: .shadowColor)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let view = super.toView(renderer: renderer)
        view.layer.masksToBounds = false
        view.layer.shadowOpacity = Float(shadowOpacity ?? 0.0)
        view.layer.shadowRadius = CGFloat(shadowRadius ?? 0.0)
        if let `shadowColor` = shadowColor, let color = UIColor(hex: shadowColor) {
            view.layer.shadowColor = color.cgColor
        } else {
            view.layer.shadowColor = UIColor.black.cgColor
        }
        view.layer.shadowOffset = CGSize(width: shadowWidth ?? 0.0, height: shadowHeight ?? 0.0)
        if let `child` = child {
            let beagleView = BeagleView(child)
            view.addSubview(beagleView)
            beagleView.anchorTo(superview: view)
        }
        return view
    }
}
