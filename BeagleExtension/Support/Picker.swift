//
//  Picker.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import Beagle

class Picker: BaseServerDrivenComponent {
    var dataSource: Expression<[[String]]>?
    var onSelect: [Action]?
    
    enum CodingKeys: String, CodingKey {
        case dataSource
        case onSelect
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dataSource = try container.decodeIfPresent(Expression<[[String]]>.self, forKey: .dataSource)
        onSelect = try container.decodeIfPresent(forKey: .onSelect)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let pickerView = PickerView(self, renderer: renderer)
        view = pickerView
        return super.toView(renderer: renderer)
    }
    
    private class PickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
        private var picker: Picker?
        private var controller: BeagleController?
        
        private var data: [[String]]? {
            didSet {
                self.reloadAllComponents()
            }
        }
        
        init(_ picker: Picker, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.picker = picker
            self.controller = renderer.controller
            self.dataSource = self
            self.delegate = self
            
            renderer.observe(picker.dataSource, andUpdate: \.data, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return data?.count ?? 0
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            guard let `data` = data else { return 0 }
            return data[component].count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            guard let `data` = data else { return nil }
            return data[component][row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            guard let `data` = data else { return }
            controller?.execute(actions: picker?.onSelect, with: "onSelect", and: .dictionary([
                "row": DynamicObject.int(row),
                "component": DynamicObject.int(component),
                "value": DynamicObject.string(data[component][row])
            ]), origin: self)
        }
    }
}
