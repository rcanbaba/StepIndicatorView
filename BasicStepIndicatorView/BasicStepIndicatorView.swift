//
//  BasicStepIndicatorView.swift
//  PaycellUIKit
//
//  Created by Can Babaoğlu on 2.05.2020.
//  Copyright © 2020 BARAN BATUHAN KARAOGUZ. All rights reserved.
//

import Foundation
import UIKit
import PaycellCore


public enum StepType {
    case gradient
    case deneme
}

public final class BasicStepIndicatorView: UIStackView {
    
    private var stepCount = Int()
    private var stepType: StepType!
    private var stepCollection: [UIView] = []
    private var layerFrame = CGRect()
    

    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(type: StepType, stepCount: Int){
        super.init(frame: CGRect.zero)
        self.stepCount = stepCount
        self.stepType = type
        configure()
        restart()
    }
    
    
    private func configure(){
        
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = true
        self.contentMode = .center
        self.distribution = .fillEqually
        self.spacing = 7
                
        for _ in 0..<stepCount{
            createSteps()
        }

    }
    
    private func createSteps(){
        
        let mainWidth = UIScreen.main.bounds.size.width
        let totalStepSpacing = (stepCount - 1) * 7
        let leadingPlusTrailing = 16*2
        let totalStepWidth = Int(mainWidth) - leadingPlusTrailing - totalStepSpacing
        let stepWidth = totalStepWidth / stepCount
        
        let step = UIView(frame: CGRect(x: 0, y: 0, width:stepWidth + 1 , height: 5))
        layerFrame = step.bounds
                        
        step.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(step)
        stepCollection.append(step)
    }
    
    
    private func createGradientLayer(layerName: String) -> CALayer{
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.name = layerName
        gradientLayer.frame = layerFrame
        gradientLayer.colors = [UIColor(red: 47.0/255.0, green: 125.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor, UIColor(red: 34.0/255.0,green: 205.0/255.0, blue: 219.0/255.0, alpha: 1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.cornerRadius = 2.0
                           
        return gradientLayer
    }
    
    private func createInitialLayer(layerName: String) -> CALayer{
              
        let initialLayer = CAGradientLayer()
        initialLayer.name = layerName
        initialLayer.frame = layerFrame
        initialLayer.backgroundColor = UIColor.black.cgColor
        initialLayer.cornerRadius = 2.0
        initialLayer.borderColor = UIColor.white.cgColor
        initialLayer.borderWidth = 0.5
            
        return initialLayer
    }
    
    
    public func restart(){
        
        for index in 0..<stepCount{
            stepCollection[index].layer.sublayers?.removeAll()
        }
        
        for index in 0..<stepCount{
            stepCollection[index].layer.insertSublayer(createInitialLayer(layerName: "initial"), at: 0)
            
            if(index == 0){
                stepCollection[0].layer.insertSublayer(createGradientLayer(layerName: "gradient"), at: 1)
            }else{
                stepCollection[index].layer.insertSublayer(createInitialLayer(layerName: "initial"), at: 1)
            }
        }
    }
        
    public func goNext(){
        
        for index in 0..<stepCount{
            
            if(stepCollection[index].layer.sublayers![1].name == "initial"){
                
                stepCollection[index].layer.sublayers?.removeLast()
                stepCollection[index].layer.insertSublayer(createGradientLayer(layerName: "gradient"), at: 1)
                break
            }
        }
    }
    
    public func goBack(){
        
        for index in stride(from: stepCount - 1, to: 0, by: -1){ // not through, index 0 should always filled.
            
            if(stepCollection[index].layer.sublayers![1].name == "gradient"){
                
                stepCollection[index].layer.sublayers?.removeLast()
                stepCollection[index].layer.insertSublayer(createInitialLayer(layerName: "initial"), at: 1)
                break
            }
        }
    }
    
    public func getStepNumber() -> Int{
        
        var stepNo = 1 // default value(always first one filled)
        
        for index in stride(from: stepCount - 1, through: 0, by: -1){
            if(stepCollection[index].layer.sublayers![1].name == "gradient"){
                
                stepNo = index + 1
                break
            }

        }
        return stepNo
    }


    
}

