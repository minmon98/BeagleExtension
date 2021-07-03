//
//  TextField.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import UIKit
import Beagle

class TextField: BaseServerDrivenComponent {
    var text: Expression<String>?
    var placeholder: String?
    var autoCorrect: Bool?
    var readOnly: Bool?
    var clearButtonMode: ClearButtonMode?
    var cursorColor: String?
    var placeholderColor: String?
    var textColor: String?
    var isPasswordTextField: Bool?
    var regex: String?
    var onChange: [Action]?
    var onSubmit: [Action]?
    var onTap: [Action]?
    var isFocus: Bool?
    
    public enum ClearButtonMode: String, Decodable, CaseIterable {
        case always = "ALWAYS"
        case editing = "EDITING"
        case never = "NEVER"
        case notEditing = "NOT_EDITING"
    }
    
    enum CodingKeys: String, CodingKey {
        case text
        case placeholder
        case autoCorrect
        case readOnly
        case clearButtonMode
        case cursorColor
        case textColor
        case placeholderColor
        case isPasswordTextField
        case regex
        case onChange
        case onSubmit
        case onTap
        case isFocus
    }
        
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(Expression<String>.self, forKey: .text)
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        textColor = try container.decodeIfPresent(String.self, forKey: .textColor)
        cursorColor = try container.decodeIfPresent(String.self, forKey: .cursorColor)
        placeholderColor = try container.decodeIfPresent(String.self, forKey: .placeholderColor)
        autoCorrect = try container.decodeIfPresent(Bool.self, forKey: .autoCorrect)
        readOnly = try container.decodeIfPresent(Bool.self, forKey: .readOnly)
        clearButtonMode = try container.decodeIfPresent(ClearButtonMode.self, forKey: .clearButtonMode)
        isPasswordTextField = try container.decodeIfPresent(Bool.self, forKey: .isPasswordTextField)
        regex = try container.decodeIfPresent(String.self, forKey: .regex)
        onChange = try container.decodeIfPresent(forKey: .onChange)
        onSubmit = try container.decodeIfPresent(forKey: .onSubmit)
        onTap = try container.decodeIfPresent(forKey: .onTap)
        isFocus = try container.decodeIfPresent(Bool.self, forKey: .isFocus)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    private class TextFieldView: UITextField, UITextFieldDelegate {
        private var textField: TextField?
        private var controller: BeagleController?
        
        init(_ textField: TextField, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.textField = textField
            self.controller = renderer.controller
            self.delegate = self
            configLayout()
            
            renderer.observe(textField.text, andUpdate: \.text, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configLayout() {
            self.placeholder = textField?.placeholder
            if let autoCorrect = textField?.autoCorrect {
                self.autocorrectionType = autoCorrect ? .yes : .no
            }
            if let clearButtonMode = textField?.clearButtonMode {
                switch clearButtonMode {
                case .always:
                    self.clearButtonMode = .always
                case .editing:
                    self.clearButtonMode = .whileEditing
                case .notEditing:
                    self.clearButtonMode = .unlessEditing
                case .never:
                    self.clearButtonMode = .never
                }
            }
            if let readOnly = textField?.readOnly {
                self.isEnabled = !readOnly
            }
            if let isPasswordTextField = textField?.isPasswordTextField {
                self.isSecureTextEntry = isPasswordTextField
            }
            if let placeholderColor = textField?.placeholderColor {
                let color = UIColor(hex: placeholderColor)
                let attributes: [NSAttributedString.Key:Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: color as Any
                ]
                self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: attributes)
            }
            if let cursorColor = textField?.cursorColor {
                self.tintColor = UIColor(hex: cursorColor)
            }
            if let textColor = textField?.textColor {
                self.textColor = UIColor(hex: textColor)
            }
            if let isFocus = textField?.isFocus, isFocus {
                self.becomeFirstResponder()
            }
            self.borderStyle = .none
            self.addTarget(self, action: #selector(valueChange), for: .editingChanged)
        }
        
        @objc func valueChange() {
            let regex = textField?.regex ?? ""
            controller?.execute(actions: textField?.onChange, with: "onChange", and: .dictionary([
                "isMatchRegex": regex.isEmpty ? DynamicObject.bool(true) : DynamicObject.bool(!BeagleUtil.shared.matches(regex: regex, text: text ?? "").isEmpty),
                "value": DynamicObject.string(text ?? "")
            ]), origin: self)
        }
        
        // TextFieldDelegate
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            controller?.execute(actions: self.textField?.onTap, event: "onTap", origin: self)
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.resignFirstResponder()
            let regex = self.textField?.regex ?? ""
            controller?.execute(actions: self.textField?.onSubmit, with: "onSubmit", and: .dictionary([
                "isMatchRegex": regex.isEmpty ? DynamicObject.bool(true) : DynamicObject.bool(!BeagleUtil.shared.matches(regex: regex, text: text ?? "").isEmpty),
                "value": DynamicObject.string(text ?? "")
            ]), origin: self)
            return true
        }
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let textField = TextFieldView(self, renderer: renderer)
        view = textField
        return super.toView(renderer: renderer)
    }
}
