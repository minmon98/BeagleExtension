//
//  BaseServerDrivenComponent.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import Beagle
import UIKit

class BaseServerDrivenComponent: ServerDrivenComponent {
    var widgetProperties = WidgetProperties()
    var view: UIView?
    
    private enum CodingKeys: String, CodingKey {
        case widgetProperties
    }
    
    // example to init with widgetProperties
    required convenience init(from decoder: Decoder) throws {
        self.init()
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    // apply this toView method to render view by widgetProperties
    func toView(renderer: BeagleRenderer) -> UIView {
        var mainView = UIView()
        if let `view` = view {
            mainView = view
        }
        let layoutConfigurator = BeagleDependencies().style(mainView)
        layoutConfigurator.setup(widgetProperties.style)
        
        let viewConfigurator = BeagleDependencies().viewConfigurator(mainView)
        viewConfigurator.setup(style: widgetProperties.style)
        return mainView
    }
}
