//
//  String+CalculateHeight.swift
//  CleanYTBPTJ
//
//  Created by κΉλν on 2022/03/13.
//

import Foundation
import UIKit

extension String {
    func calculateHeight(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        return boundingBox.height
    }
}
