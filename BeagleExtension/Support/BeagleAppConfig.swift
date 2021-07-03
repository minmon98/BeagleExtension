//
//  BeagleAppConfig.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 10/06/2021.
//

import Foundation
import Beagle
import BeagleScaffold
import IQKeyboardManagerSwift

public class BeagleAppConfig {
    public static let shared = BeagleAppConfig()
    
    public func config(url: String) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
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
        dependencies.decoder.register(action: AsyncAfter.self)
        
        Beagle.dependencies = dependencies
        BeagleConfig.start(dependencies: dependencies)
    }
}
