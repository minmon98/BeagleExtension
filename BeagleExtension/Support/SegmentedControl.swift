//
//  SegmenControl.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import Beagle

class SegmentedControl: BaseServerDrivenComponent {
    var dataSource: Expression<[String]>?
    var textColor: String?
    var backgroundColor: String?
    var tabColor: String?
    var onChangeTab: [Action]?
    var selectedIndex: Int?
    
    enum CodingKeys: String, CodingKey {
        case dataSource
        case textColor
        case backgroundColor
        case tabColor
        case onChangeTab
        case selectedIndex
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dataSource = try container.decodeIfPresent(Expression<[String]>.self, forKey: .dataSource)
        textColor = try container.decodeIfPresent(String.self, forKey: .textColor)
        backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
        tabColor = try container.decodeIfPresent(String.self, forKey: .tabColor)
        onChangeTab = try container.decodeIfPresent(forKey: .onChangeTab)
        selectedIndex = try container.decodeIfPresent(Int.self, forKey: .selectedIndex)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let segmentedControl = SegmentedControlView(self, renderer: renderer)
        view = segmentedControl
        return super.toView(renderer: renderer)
    }
    
    private class SegmentedControlView: UISegmentedControl {
        private var segmentedControl: SegmentedControl?
        private var controller: BeagleController?
        
        private var data: [String]? {
            didSet {
                self.configLayout()
            }
        }
        
        init(_ segmentedControl: SegmentedControl, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.segmentedControl = segmentedControl
            self.controller = renderer.controller
            configLayout()
            
            self.addTarget(self, action: #selector(valueChange), for: .valueChanged)
            renderer.observe(segmentedControl.dataSource, andUpdate: \.data, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configLayout() {
            if let tabColor = segmentedControl?.tabColor {
                self.selectedSegmentTintColor = UIColor(hex: tabColor)
            }
            if let textColor = segmentedControl?.textColor {
                let attributes: [NSAttributedString.Key:Any] = [
                    .foregroundColor: UIColor(hex: textColor) as Any
                ]
                self.setTitleTextAttributes(attributes, for: .normal)
            }
            if let backgroundColor = segmentedControl?.backgroundColor {
                self.backgroundColor = UIColor(hex: backgroundColor)
            }
            
            guard let `data` = data else { return }
            for tabName in data {
                let index = data.firstIndex(of: tabName) ?? 0
                self.insertSegment(withTitle: tabName, at: index, animated: true)
            }
            self.selectedSegmentIndex = 0
            if let selectedIndex = segmentedControl?.selectedIndex {
                self.selectedSegmentIndex = selectedIndex
            }
        }
        
        @objc func valueChange() {
            controller?.execute(actions: segmentedControl?.onChangeTab, with: "onChangeTab", and: .int(self.selectedSegmentIndex), origin: self)
        }
    }
}
