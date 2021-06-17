//
//  Label.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation
import UIKit
import Beagle

class Label: BaseServerDrivenComponent {
    var text: Expression<String>?
    var textColor: Expression<String>?
    var backgroundColor: Expression<String>?
    var maxLines: Int?
    var textAlign: Text.Alignment?
    var fontFamily: String?
    var fontSize: Double?
    var fontStyle: FontStyle?
    
    public enum FontStyle: String, Decodable, CaseIterable {
        case italic = "ITALIC"
        case bold = "BOLD"
        case normal = "NORMAL"
        case underline = "UNDERLINE"
    }
    
    enum CodingKeys: String, CodingKey {
        case text
        case textColor
        case backgroundColor
        case maxLines
        case textAlign
        case fontFamily
        case fontSize
        case fontStyle
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(Expression<String>.self, forKey: .text)
        textColor = try container.decodeIfPresent(Expression<String>.self, forKey: .textColor)
        backgroundColor = try container.decodeIfPresent(Expression<String>.self, forKey: .backgroundColor)
        maxLines = try container.decodeIfPresent(Int.self, forKey: .maxLines)
        textAlign = try container.decodeIfPresent(Text.Alignment.self, forKey: .textAlign)
        fontFamily = try container.decodeIfPresent(String.self, forKey: .fontFamily)
        fontStyle = try container.decodeIfPresent(FontStyle.self, forKey: .fontStyle)
        fontSize = try container.decodeIfPresent(Double.self, forKey: .fontSize)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    private class LabelView: UILabel {
        private var label: Label?
        private var textColorString: String? {
            didSet {
                self.textColor = UIColor(hex: textColorString ?? "#000000")
                self.configLayout()
            }
        }
        
        private var backgroundColorString: String? {
            didSet {
                self.backgroundColor = UIColor(hex: backgroundColorString ?? "#ffffff")
                self.configLayout()
            }
        }
        
        init(_ label: Label, renderer: BeagleRenderer) {
            super.init(frame: .zero)
            self.label = label
            configLayout()
            
            renderer.observe(label.text, andUpdate: \.text, in: self)
            renderer.observe(label.textColor, andUpdate: \.textColorString, in: self)
            renderer.observe(label.backgroundColor, andUpdate: \.backgroundColorString, in: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configLayout() {
            var fontSize = 17.0
            var fontFamily = ""
            
            if let maxLines = label?.maxLines {
                self.numberOfLines = maxLines
            }
            
            if let textAlign = label?.textAlign {
                switch textAlign {
                case .right:
                    self.textAlignment = .right
                case .left:
                    self.textAlignment = .left
                case .center:
                    self.textAlignment = .center
                }
            }
            
            if let size = label?.fontSize {
                fontSize = size
                self.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let name = label?.fontFamily {
                fontFamily = name
                self.font = UIFont(name: fontFamily, size: CGFloat(fontSize))
            }
            
            if let fontStyle = label?.fontStyle {
                switch fontStyle {
                case .italic:
                    self.font = UIFont.italicSystemFont(ofSize: CGFloat(fontSize))
                case .bold:
                    self.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
                case .underline:
                    let attributes: [NSAttributedString.Key:Any] = [
                        .font: fontFamily.isEmpty ? UIFont.systemFont(ofSize: CGFloat(fontSize)) : UIFont(name: fontFamily, size: CGFloat(fontSize))!,
                        .foregroundColor: textColor as Any,
                        .backgroundColor: backgroundColor as Any,
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .underlineColor: textColor as Any
                    ]
                    self.attributedText = NSMutableAttributedString(string: text ?? "", attributes: attributes)
                default: break
                }
            }
        }
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let label = LabelView(self, renderer: renderer)
        view = label
        return super.toView(renderer: renderer)
    }
}
