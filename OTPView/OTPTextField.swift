//
//  OTPTextField.swift
//  PaycellCoreExample
//
//  Created by Can Babaoğlu on 21.04.2020.
//  Copyright © 2020 BARAN BATUHAN KARAOGUZ. All rights reserved.
//

import Foundation
import UIKit

public class OTPTextField: UITextField {
    
    weak var previousTextField: OTPTextField?
    weak var nextTextField: OTPTextField?
    
    override public func deleteBackward(){
                
        if text == "" {
            previousTextField?.becomeFirstResponder()
        }
    }
    
}
