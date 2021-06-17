//
//  Slider.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import Beagle

class Slider: BaseServerDrivenComponent {
    var value: Expression<Double>?
    var color: String?
    var onChange: [Action]?
    
    enum CodingKeys: String, CodingKey {
        case value
        case color
        case onChange
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decodeIfPresent(Expression<Double>.self, forKey: .value)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        onChange = try container.decodeIfPresent(forKey: .onChange)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let slider = SliderView(self, renderer: renderer)
        view = slider
        return super.toView(renderer: renderer)
    }
    
    private class SliderView: UISlider {
        private var slider: Slider?
        private var controller: BeagleController?
        
        private var valueDouble: Double? {
            didSet {
                self.value = Float(valueDouble ?? 0.0)
            }
        }
        
        init(_ slider: Slider, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.slider = slider
            self.controller = renderer.controller
            configLayout()
            self.addTarget(self, action: #selector(valueChange), for: .valueChanged)
            renderer.observe(slider.value, andUpdate: \.valueDouble, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configLayout() {
            if let color = slider?.color {
                self.tintColor = UIColor(hex: color)
            }
        }
        
        @objc func valueChange() {
            controller?.execute(actions: slider?.onChange, with: "onChange", and: .double(Double(self.value)), origin: self)
        }
    }
}
