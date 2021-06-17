//
//  DismissLoading.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 07/06/2021.
//

import Foundation
import Beagle
import SVProgressHUD

class DismissLoading: Action {
    func execute(controller: BeagleController, origin: UIView) {
        SVProgressHUD.dismiss()
    }
}
