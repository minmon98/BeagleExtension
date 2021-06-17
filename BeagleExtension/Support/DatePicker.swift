//
//  DatePicker.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import UIKit
import Beagle

class DatePicker: BaseServerDrivenComponent {
    var pickerStyle: DatePickerStyle?
    var pickerMode: DatePickerMode?
    var dateFormat: String?
    var onChange: [Action]?
    
    public enum DatePickerStyle: String, Decodable, CaseIterable {
        case wheels = "WHEELS"
        case inline = "INLINE"
        case compact = "COMPACT"
    }
    
    public enum DatePickerMode: String, Decodable, CaseIterable {
        case date = "DATE"
        case time = "TIME"
        case dateAndTime = "DATE_TIME"
        case countDownTimer = "COUNTDOWN"
        
        func mapToUIDatePickerMode() -> UIDatePicker.Mode {
            switch self {
            case .date:
                return .date
            case .time:
                return .time
            case .dateAndTime:
                return .dateAndTime
            case .countDownTimer:
                return .countDownTimer
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case pickerStyle
        case pickerMode
        case onChange
        case dateFormat
    }
    
    private class DatePickerView: UIDatePicker {
        private var datePicker: DatePicker?
        private var controller: BeagleController?
        
        init(_ datePicker: DatePicker, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.datePicker = datePicker
            self.controller = renderer.controller
            configLayout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configLayout() {
            if let pickerStyle = datePicker?.pickerStyle {
                switch pickerStyle {
                case .wheels:
                    if #available(iOS 13.4, *) {
                        self.preferredDatePickerStyle = .wheels
                    }
                case .compact:
                    if #available(iOS 13.4, *) {
                        self.preferredDatePickerStyle = .compact
                    }
                case .inline:
                    if #available(iOS 14.0, *) {
                        self.preferredDatePickerStyle = .inline
                    }
                }
            }
            if let pickerMode = datePicker?.pickerMode {
                switch pickerMode {
                case .date:
                    self.datePickerMode = .date
                case .time:
                    self.datePickerMode = .time
                case .dateAndTime:
                    self.datePickerMode = .dateAndTime
                case .countDownTimer:
                    self.datePickerMode = .countDownTimer
                    self.countDownDuration = 60
                }
            }
            self.addTarget(self, action: #selector(valueChange), for: .valueChanged)
        }
        
        @objc func valueChange() {
            var dateFormatter: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                dateFormatter.calendar = Calendar(identifier: .gregorian)
                return dateFormatter
            }()
            if let dateFormat = datePicker?.dateFormat {
                dateFormatter = {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = dateFormat
                    dateFormatter.calendar = Calendar(identifier: .gregorian)
                    return dateFormatter
                }()
            }
            controller?.execute(actions: datePicker?.onChange, with: "onChange", and: .string(dateFormatter.string(from: date)), origin: self)
        }
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pickerStyle = try container.decodeIfPresent(DatePickerStyle.self, forKey: .pickerStyle)
        pickerMode = try container.decodeIfPresent(DatePickerMode.self, forKey: .pickerMode)
        dateFormat = try container.decodeIfPresent(String.self, forKey: .dateFormat)
        onChange = try container.decodeIfPresent(forKey: .onChange)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let datePickerView = DatePickerView(self, renderer: renderer)
        view = datePickerView
        return super.toView(renderer: renderer)
    }
}
