//
//  AlertExtension.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 07/06/2021.
//

import Foundation
import Beagle

class AlertExtension: Action {
    var title: Expression<String>?
    var message: Expression<String>?
    var okButtonTitle: String?
    var cancelButtonTitle: String?
    var okAction: [Action]?
    var cancelAction: [Action]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case message
        case okButtonTitle
        case cancelButtonTitle
        case okAction
        case cancelAction
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(Expression<String>.self, forKey: .title)
        message = try container.decodeIfPresent(Expression<String>.self, forKey: .message)
        okButtonTitle = try container.decodeIfPresent(String.self, forKey: .okButtonTitle)
        cancelButtonTitle = try container.decodeIfPresent(String.self, forKey: .cancelButtonTitle)
        okAction = try container.decodeIfPresent(forKey: .okAction)
        cancelAction = try container.decodeIfPresent(forKey: .cancelAction)
    }
    
    func execute(controller: BeagleController, origin: UIView) {
        let alertController = UIAlertController(title: title?.evaluate(with: origin), message: message?.evaluate(with: origin), preferredStyle: .alert)
        if let `okButtonTitle` = okButtonTitle {
            let okAction = UIAlertAction(title: okButtonTitle, style: .default) { _ in
                controller.execute(actions: self.okAction, event: "okAction", origin: origin)
            }
            alertController.addAction(okAction)
        }
        if let `cancelButtonTitle` = cancelButtonTitle {
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
                controller.execute(actions: self.cancelAction, event: "cancelAction", origin: origin)
            }
            alertController.addAction(cancelAction)
        }
        controller.present(alertController, animated: true, completion: nil)
    }
}
