//
//  OTPStackView.swift
//  PaycellCoreExample
//
//  Created by Can Babaoğlu on 21.04.2020.
//  Copyright © 2020 BARAN BATUHAN KARAOGUZ. All rights reserved.
//

import Foundation
import UIKit

public protocol OTPDelegate: class {
   
    func didChangeValidity(isValid: Bool) // checks fulfilled
}

// TODO: hangi textfield a:  .textContentType = .oneTimeCode set edilecek ayarlamayı unutma!!!!!  #available(iOS 12.0, *)

public class OTPStackView: UIStackView {
    
    var OTPcode: String = ""
    //Customise the OTPField here
    let numberOfFields = 4
    var textFieldsCollection: [OTPTextField] = []
    public weak var delegate: OTPDelegate?
    var showsWarningColor = false
    var textfieldCtr = 1
    //Attributes colors.. etcs.
    let inactiveFieldBorderColor = UIColor.clear
    let textBackgroundColor = UIColor.clear
    let activeFieldBorderColor = UIColor.clear
    let textColor = UIColor.white
    let placeholderString = "○"
    let placeholderColor = UIColor.white
    let placeholderSize = 16.0
    let spacingBetweenTextfields = 40
    var getStackX = NSLayoutXAxisAnchor()
    

    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        addOTPFields()
    }
    
    //Customisation and setting stackView
    private func setupStackView() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = true
        self.contentMode = .center
        self.distribution = .fillEqually
        self.spacing = 5
        getStackX = self.centerXAnchor

    }
    
    //Adding each OTPfield to stack view
    private func addOTPFields() {
        for index in 0..<numberOfFields{
            let field = OTPTextField()
            setupTextField(field, index)
            textFieldsCollection.append(field)
            //Adding a marker to previous field
            index != 0 ? (field.previousTextField = textFieldsCollection[index-1]) : (field.previousTextField = nil)
            //Adding a marker to next field for the field at index-1
            index != 0 ? (textFieldsCollection[index-1].nextTextField = field) : ()
        }
        //setting first field as firstResponder
        textFieldsCollection[0].becomeFirstResponder()
    }
    
    //Customisation and setting OTPTextFields
    private func setupTextField(_ textField: OTPTextField, _ index: Int){
        textField.delegate = self

        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(textField)
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let pose = (((numberOfFields - 1) * spacingBetweenTextfields / 2) + (index * spacingBetweenTextfields) - ( numberOfFields - 1) * spacingBetweenTextfields)
        textField.centerXAnchor.constraint(equalTo: getStackX, constant: CGFloat(pose)).isActive = true
        textField.backgroundColor = textBackgroundColor
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = false
        textField.font = UIFont(name: "System", size: 100)
        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
        textField.keyboardType = .numberPad
        textField.textColor = textColor
       // textField.tintColor = UIColor.red
        textField.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [
            .foregroundColor: placeholderColor,
            .font : UIFont.boldSystemFont(ofSize: CGFloat(placeholderSize))])
      //  textField.isSecureTextEntry = true
        
    }
    
    //checks if all the OTPfields are filled
    public func checkForValidity(){
        for fields in textFieldsCollection{
            if (fields.text == ""){
                delegate?.didChangeValidity(isValid: false)
                return
            }
        }
        delegate?.didChangeValidity(isValid: true)
    }
    
    public func clearAllTextfields(){
        for index in 0..<textFieldsCollection.count{
                textFieldsCollection[index].text = ""
                
            }
        OTPcode.removeAll()
        textFieldsCollection[0].becomeFirstResponder()
    }
    
    
    //gives the OTP text
    public func getOTP() -> String {
        return OTPcode
    }
    
    public func checkOTP(passCode: String ) -> Bool {
        
        if(OTPcode == passCode){
            return true
        }else{
            
            let shake = CABasicAnimation(keyPath: "position")
            let xDelta = CGFloat(5)
            shake.duration = 0.15
            shake.repeatCount = 1
            shake.autoreverses = true

            let from_point = CGPoint(x: self.center.x - xDelta, y: self.center.y)
            let from_value = NSValue(cgPoint: from_point)

            let to_point = CGPoint(x: self.center.x + xDelta, y: self.center.y)
            let to_value = NSValue(cgPoint: to_point)

            shake.fromValue = from_value
            shake.toValue = to_value
            shake.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.layer.add(shake, forKey: "position")
            clearAllTextfields()
            return false
        }
        
    }
    
    //set isWarningColor true for using it as a warning color
    public func setAllFieldColor(isWarningColor: Bool = false, color: UIColor){
        for textField in textFieldsCollection{
            textField.layer.borderColor = color.cgColor
        }
        showsWarningColor = isWarningColor
    }
    
}

//TextField related operations
extension OTPStackView: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if showsWarningColor {
            setAllFieldColor(color: inactiveFieldBorderColor)
            showsWarningColor = false
        }
        textField.layer.borderColor = activeFieldBorderColor.cgColor
    }
    
  public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
    }
    
    //switches between OTPTextfields
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String) -> Bool {
        
        guard let textField = textField as? OTPTextField else { return true }
        
        if (range.length == 0){ // sayı girilirse
                        
            if textField.text == nil || textField.text == "" {
                 OTPcode.append(contentsOf: string)
            }
            if textField.nextTextField == nil {
                textField.resignFirstResponder()
            }else{
                textField.nextTextField?.becomeFirstResponder()
            }
           
            textField.previousTextField?.text = "●"
            
            if (OTPcode.count == numberOfFields){
                textField.text? = "●"
            }else{
                if(textField.text == ""){
                textField.text? = string
                }
            }

            checkForValidity()
            return false
            
        }
        else if (range.length == 1) { // dolu silme yapılırsa
                       
            
            if (textField.text == nil || textField.text == ""){
                
            }
          //  textField.previousTextField?.becomeFirstResponder()
          //  textField.previousTextField?.text? = ""
            if (OTPcode.count > 0){
                OTPcode.removeLast()
            }
            
            textField.text? = ""
            checkForValidity()
            
            return false
            
        }
        return true
    }
    
}
