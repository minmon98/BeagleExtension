//
//  BeagleAppConfig.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 10/06/2021.
//

import Foundation
import Beagle
import BeagleScaffold

class BeagleAppConfig {
    static let shared = BeagleAppConfig()
    
    func config(url: String) {
        let dependencies = BeagleDependencies()
        dependencies.urlBuilder = UrlBuilder(
            baseUrl: URL(string: url)!
        )
        dependencies.decoder.register(component: Card.self)
        dependencies.decoder.register(component: Label.self)
        dependencies.decoder.register(component: ContainerExtension.self)
        dependencies.decoder.register(component: ActivityIndicator.self)
        dependencies.decoder.register(component: Switch.self)
        dependencies.decoder.register(component: TextField.self)
        dependencies.decoder.register(component: DatePicker.self)
        dependencies.decoder.register(component: Picker.self)
        dependencies.decoder.register(component: Slider.self)
        dependencies.decoder.register(component: SegmentedControl.self)
        dependencies.decoder.register(component: WebViewExtension.self)
        dependencies.decoder.register(component: DropDownContainer.self)
        
        dependencies.decoder.register(action: AlertExtension.self)
        dependencies.decoder.register(action: ShowLoading.self)
        dependencies.decoder.register(action: DismissLoading.self)
        dependencies.decoder.register(action: ShowDatePickerDialog.self)
        
        Beagle.dependencies = dependencies
        BeagleConfig.start(dependencies: dependencies)
    }
}
