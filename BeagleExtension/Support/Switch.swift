//
//  Switch.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import UIKit
import Beagle

class Switch: BaseServerDrivenComponent {
    var color: Expression<String>?
    var value: Expression<Bool>?
    var onChange: [Action]?
    
    enum CodingKeys: String, CodingKey {
        case color
        case value
        case onChange
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decodeIfPresent(Expression<String>.self, forKey: .color)
        value = try container.decodeIfPresent(Expression<Bool>.self, forKey: .value)
        onChange = try container.decodeIfPresent(forKey: .onChange)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    private class SwitchView: UISwitch {
        private var switchComponent: Switch?
        private var controller: BeagleController?
        
        private var colorString: String? {
            didSet {
                self.onTintColor = UIColor(hex: colorString ?? "#000000")
            }
        }
        
        private var value: Bool? {
            didSet {
                self.isOn = value ?? false
            }
        }
        
        init(_ switchComponent: Switch, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.switchComponent = switchComponent
            self.controller = renderer.controller
            self.addTarget(self, action: #selector(onChangeValue), for: .valueChanged)
            
            renderer.observe(switchComponent.color, andUpdate: \.colorString, in: self)
            renderer.observe(switchComponent.value, andUpdate: \.value, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func onChangeValue() {
            controller?.execute(actions: switchComponent?.onChange, with: "onChange", and: .bool(self.isOn), origin: self)
        }
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let switchComponent = SwitchView(self, renderer: renderer)
        return switchComponent
    }
}
