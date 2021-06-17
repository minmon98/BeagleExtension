//
//  DropDownContainer.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 17/06/2021.
//

import Foundation
import Beagle
import DropDown

class DropDownContainer: BaseServerDrivenComponent {
    var child: ServerDrivenComponent?
    var dataSource: Expression<[String]>?
    var onChange: [Action]?
    
    enum CodingKeys: String, CodingKey {
        case child
        case dataSource
        case onChange
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        child = try container.decodeIfPresent(forKey: .child)
        dataSource = try container.decodeIfPresent(Expression<[String]>.self, forKey: .dataSource)
        onChange = try container.decodeIfPresent(forKey: .onChange)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let dropDownContainerView = DropDownContainerView(self, renderer: renderer)
        view = dropDownContainerView
        return super.toView(renderer: renderer)
    }
    
    private class DropDownContainerView: UIView {
        private var dropDownContainer: DropDownContainer?
        private var controller: BeagleController?
        private let dropDown = DropDown()
        
        private var dataSource: [String]? {
            didSet {
                self.configDropDown()
            }
        }
        
        init(_ dropDownContainer: DropDownContainer, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.dropDownContainer = dropDownContainer
            self.controller = renderer.controller
            
            renderer.observe(dropDownContainer.dataSource, andUpdate: \.dataSource, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configDropDown() {
            guard let `dataSource` = dataSource, let child = dropDownContainer?.child else { return }
            let beagleView = BeagleView(child)
            self.addSubview(beagleView)
            beagleView.anchorTo(superview: self)
            
            dropDown.anchorView = beagleView
            dropDown.dataSource = dataSource
            dropDown.selectionAction = { index, item in
                self.controller?.execute(actions: self.dropDownContainer?.onChange, with: "onChange", and: .string(item), origin: self)
                self.dropDown.hide()
            }
        
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(showDropDown))
            beagleView.addGestureRecognizer(tapGesture)
        }
        
        @objc func showDropDown() {
            dropDown.show()
        }
    }
}
