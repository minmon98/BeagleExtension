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
    var backgroundColor: Expression<String>?
    var backgroundOpacity: Double?
    var shadowOpacity: Double?
    var shadowRadius: Double?
    var shadowWidth: Double?
    var shadowHeight: Double?
    var shadowColor: String?
    
    enum CodingKeys: String, CodingKey {
        case child
        case backgroundColor
        case backgroundOpacity
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
        backgroundColor = try container.decodeIfPresent(Expression<String>.self, forKey: .backgroundColor)
        backgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .backgroundOpacity)
        shadowOpacity = try container.decodeIfPresent(Double.self, forKey: .shadowOpacity)
        shadowRadius = try container.decodeIfPresent(Double.self, forKey: .shadowRadius)
        shadowWidth = try container.decodeIfPresent(Double.self, forKey: .shadowWidth)
        shadowHeight = try container.decodeIfPresent(Double.self, forKey: .shadowHeight)
        shadowColor = try container.decodeIfPresent(String.self, forKey: .shadowColor)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let containerExtensionView = ContainerExtensionView(self, renderer: renderer)
        view = containerExtensionView
        let viewAfterConfig = super.toView(renderer: renderer)
        viewAfterConfig.layer.masksToBounds = false
        viewAfterConfig.layer.shadowOpacity = Float(shadowOpacity ?? 0.0)
        viewAfterConfig.layer.shadowRadius = CGFloat(shadowRadius ?? 0.0)
        if let `shadowColor` = shadowColor, let color = UIColor(hex: shadowColor) {
            viewAfterConfig.layer.shadowColor = color.cgColor
        } else {
            viewAfterConfig.layer.shadowColor = UIColor.black.cgColor
        }
        viewAfterConfig.layer.shadowOffset = CGSize(width: shadowWidth ?? 0.0, height: shadowHeight ?? 0.0)
        if let `child` = child {
            let beagleView = BeagleView(child)
            viewAfterConfig.addSubview(beagleView)
            beagleView.anchorTo(superview: viewAfterConfig)
        }
        return viewAfterConfig
    }
    
    private class ContainerExtensionView: UIView {
        private var backgroundOpacity = 1.0
        private var backgroundColorString: String? {
            didSet {
                self.backgroundColor = UIColor(hex: backgroundColorString ?? "#ffffff")?.withAlphaComponent(CGFloat(backgroundOpacity))
            }
        }
        
        init(_ containerExtension: ContainerExtension, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.backgroundOpacity = containerExtension.backgroundOpacity ?? 1.0
            renderer.observe(containerExtension.backgroundColor, andUpdate: \.backgroundColorString, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}
