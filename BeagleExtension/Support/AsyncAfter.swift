//
//  AsyncAfter.swift
//  pbms
//
//  Created by VTN-MINHPV21 on 03/07/2021.
//  Copyright © 2021 Pham Binh. All rights reserved.
//

import Foundation
import Beagle

class AsyncAfter: Action {
    var onExecute: [Action]?
    var time: Double?
    
    enum CodingKeys: String, CodingKey {
        case onExecute
        case time
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        onExecute = try container.decodeIfPresent(forKey: .onExecute)
        time = try container.decodeIfPresent(Double.self, forKey: .time)
    }
    
    func execute(controller: BeagleController, origin: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (time ?? 0.0)) {
            controller.execute(actions: self.onExecute, event: "onExecute", origin: origin)
        }
    }
}
