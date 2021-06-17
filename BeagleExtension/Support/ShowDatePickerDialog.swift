//
//  ShowDatePickerDialog.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 17/06/2021.
//

import Foundation
import Beagle

class ShowDatePickerDialog: Action {
    var title: String?
    var doneButtonTitle: String?
    var showCancelButton: Bool? = true
    var cancelButtonTitle: String?
    var dateFormat: String?
    var date: String?
    var maximumDate: String?
    var minimumDate: String?
    var datePickerMode: DatePicker.DatePickerMode? = .date
    var onSubmit: [Action]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case doneButtonTitle
        case showCancelButton
        case cancelButtonTitle
        case dateFormat
        case date
        case maximumDate
        case minimumDate
        case datePickerMode
        case onSubmit
    }
    
    func execute(controller: BeagleController, origin: UIView) {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        if let `dateFormat` = dateFormat {
            dateFormatter.dateFormat = dateFormat
        }
        var minDate: Date?
        var maxDate: Date?
        if let `minimumDate` = minimumDate {
            minDate = dateFormatter.date(from: minimumDate)
        }
        if let `maximumDate` = maximumDate {
            maxDate = dateFormatter.date(from: maximumDate)
        }
        var currentDate = Date()
        if let `date` = date {
            currentDate = dateFormatter.date(from: date) ?? Date()
        }
        guard let mode = datePickerMode, let `showCancelButton` = showCancelButton else { return }
        DatePickerDialog(showCancelButton: showCancelButton).show(title ?? "", doneButtonTitle: doneButtonTitle ?? "", cancelButtonTitle: cancelButtonTitle ?? "", defaultDate: currentDate, minimumDate: minDate, maximumDate: maxDate, datePickerMode: mode.mapToUIDatePickerMode()) { date in
            guard let `date` = date else { return }
            controller.execute(actions: self.onSubmit, with: "onSubmit", and: .string(dateFormatter.string(from: date)), origin: origin)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        doneButtonTitle = try container.decodeIfPresent(String.self, forKey: .doneButtonTitle)
        showCancelButton = try container.decodeIfPresent(Bool.self, forKey: .showCancelButton)
        cancelButtonTitle = try container.decodeIfPresent(String.self, forKey: .cancelButtonTitle)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        dateFormat = try container.decodeIfPresent(String.self, forKey: .dateFormat)
        maximumDate = try container.decodeIfPresent(String.self, forKey: .maximumDate)
        minimumDate = try container.decodeIfPresent(String.self, forKey: .minimumDate)
        datePickerMode = try container.decodeIfPresent(DatePicker.DatePickerMode.self, forKey: .datePickerMode)
        onSubmit = try container.decodeIfPresent(forKey: .onSubmit)
    }
}
