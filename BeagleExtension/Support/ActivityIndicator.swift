//
//  ActivityIndicator.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import UIKit
import Beagle

class ActivityIndicator: BaseServerDrivenComponent {
    var color: Expression<String>?
    var indicatorStyle: ActivityIndicatorStyle?
    
    public enum ActivityIndicatorStyle: String, Decodable, CaseIterable {
        case large = "LARGE"
        case medium = "MEDIUM"
    }
    
    enum CodingKeys: String, CodingKey {
        case color
        case indicatorStyle
    }
        
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decodeIfPresent(Expression<String>.self, forKey: .color)
        indicatorStyle = try container.decodeIfPresent(ActivityIndicatorStyle.self, forKey: .indicatorStyle)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    private class ActivityIndicatorView: UIActivityIndicatorView {
        private var textColorString: String? {
            didSet {
                self.color = UIColor(hex: textColorString ?? "#000000")
            }
        }
        
        init(_ activityIndicator: ActivityIndicator, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            if let `style` = activityIndicator.indicatorStyle {
                switch style {
                case .large:
                    if #available(iOS 13.0, *) {
                        self.style = .large
                    }
                case .medium:
                    if #available(iOS 13.0, *) {
                        self.style = .medium
                    }
                }
            }
            self.startAnimating()
            renderer.observe(activityIndicator.color, andUpdate: \.textColorString, in: self)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let view = super.toView(renderer: renderer)
        let activityIndicatorView = ActivityIndicatorView(self, renderer: renderer)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.anchorTo(superview: view)
        return view
    }
}
