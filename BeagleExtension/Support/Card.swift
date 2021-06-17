//
//  Card.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 04/06/2021.
//

import Foundation
import Beagle

import MaterialComponents.MDCCard
class Card: BaseServerDrivenComponent {
    var child: ServerDrivenComponent?
    
    enum CodingKeys: String, CodingKey {
        case child
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        child = try container.decodeIfPresent(forKey: .child)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let card = MDCCard()
        if let `child` = child {
            let beagleView = BeagleView(child)
            card.addSubview(beagleView)
            beagleView.anchorTo(superview: card)
        }
        view = card
        let viewAfterConfig = super.toView(renderer: renderer)
        viewAfterConfig.layer.masksToBounds = false
        return viewAfterConfig
    }
}
