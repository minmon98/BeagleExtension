//
//  CircularProgressBar.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 18/06/2021.
//

import Foundation
import Beagle
import MBCircularProgressBar

class CircularProgressBar: BaseServerDrivenComponent {
    var showValue: Bool?
    var value: Expression<Double>?
    var showUnitString: Bool?
    var unitString: Expression<String>?
    var fontColor: String?
    var fontSize: Double?
    var angle: Double?
    var rotation: Double?
    var progressLineWidth: Double?
    var progressLineColor: Expression<String>?
    var progressType: ProgressType?
    var emptyLineWidth: Double?
    var emptyLineColor: Expression<String>?
    
    public enum ProgressType: String, Decodable, CaseIterable {
        case round = "ROUND"
        case square = "SQUARE"
    }
    
    enum CodingKeys: String, CodingKey {
        case showValue
        case value
        case showUnitString
        case unitString
        case fontColor
        case fontSize
        case angle
        case rotation
        case progressLineWidth
        case progressLineColor
        case progressType
        case emptyLineWidth
        case emptyLineColor
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showValue = try container.decodeIfPresent(Bool.self, forKey: .showValue)
        value = try container.decodeIfPresent(Expression<Double>.self, forKey: .value)
        showUnitString = try container.decodeIfPresent(Bool.self, forKey: .showUnitString)
        unitString = try container.decodeIfPresent(Expression<String>.self, forKey: .unitString)
        fontColor = try container.decodeIfPresent(String.self, forKey: .fontColor)
        fontSize = try container.decodeIfPresent(Double.self, forKey: .fontSize)
        angle = try container.decodeIfPresent(Double.self, forKey: .angle)
        rotation = try container.decodeIfPresent(Double.self, forKey: .rotation)
        progressLineWidth = try container.decodeIfPresent(Double.self, forKey: .progressLineWidth)
        progressLineColor = try container.decodeIfPresent(Expression<String>.self, forKey: .progressLineColor)
        progressType = try container.decodeIfPresent(ProgressType.self, forKey: .progressType)
        emptyLineWidth = try container.decodeIfPresent(Double.self, forKey: .emptyLineWidth)
        emptyLineColor = try container.decodeIfPresent(Expression<String>.self, forKey: .emptyLineColor)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let circularProgressBarView = CircularProgressBarView(self, renderer: renderer)
        view = circularProgressBarView
        let viewAfterConfig = super.toView(renderer: renderer)
        viewAfterConfig.backgroundColor = .white
        return viewAfterConfig
    }
    
    private class CircularProgressBarView: MBCircularProgressBarView {
        private var circularProgressBar: CircularProgressBar?
        private var controller: BeagleController?
        
        private var valueDouble: Double? {
            didSet {
                self.value = CGFloat(valueDouble ?? 0.0)
            }
        }

        private var progressLineColor: String? {
            didSet {
                self.progressColor = UIColor(hex: progressLineColor ?? "#000000")
            }
        }
        
        private var emptyLineColorString: String? {
            didSet {
                self.emptyLineStrokeColor = UIColor(hex: emptyLineColorString ?? "#ffffff")
            }
        }
        
        init(_ circularProgressBar: CircularProgressBar, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.circularProgressBar = circularProgressBar
            self.controller = renderer.controller
            
            configLayout()
            renderer.observe(circularProgressBar.unitString, andUpdate: \.unitString, in: self)
            renderer.observe(circularProgressBar.value, andUpdate: \.valueDouble, in: self)
            renderer.observe(circularProgressBar.progressLineColor, andUpdate: \.progressLineColor, in: self)
            renderer.observe(circularProgressBar.emptyLineColor, andUpdate: \.emptyLineColorString, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configLayout() {
            self.value = 0.0
            if let showValue = circularProgressBar?.showValue {
                self.showValueString = showValue
            }
            if let showUnitString = circularProgressBar?.showUnitString {
                self.showUnitString = showUnitString
            }
            if let fontColor = circularProgressBar?.fontColor {
                self.fontColor = UIColor(hex: fontColor)
            }
            if let fontSize = circularProgressBar?.fontSize {
                self.valueFontSize = CGFloat(fontSize)
                self.unitFontSize = CGFloat(fontSize)
            } else {
                self.valueFontSize = 30.0
                self.unitFontSize = 30.0
            }
            if let angle = circularProgressBar?.angle {
                self.progressAngle = CGFloat(angle)
            } else {
                self.progressAngle = 100.0
            }
            if let rotation = circularProgressBar?.rotation {
                self.progressRotationAngle = CGFloat(rotation)
            }
            if let progressLineWidth = circularProgressBar?.progressLineWidth {
                self.progressLineWidth = CGFloat(progressLineWidth)
            }
            if let emptyLineWidth = circularProgressBar?.emptyLineWidth {
                self.emptyLineWidth = CGFloat(emptyLineWidth)
            }
            if let progressType = circularProgressBar?.progressType {
                switch progressType {
                case .round:
                    self.progressCapType = 1
                case .square:
                    self.progressCapType = 2
                }
            }
            self.progressStrokeColor = .clear
            self.emptyLineStrokeColor = .clear
        }
    }
}
