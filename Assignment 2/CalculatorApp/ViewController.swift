//
//  ViewController.swift
//  CalculatorApp
//
//  Created by app on 11.04.17.
//  Copyright © 2017 Hazu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var Description: UILabel!
    
    
    @IBOutlet weak var display: UILabel!
    
    private var variables = Dictionary<String,Double>()
    {
        didSet {
            if let Value = variables["M"]{
                
                mValue.text = "M=" + String(describing: Value)
            }else{
            
            mValue.text = ""
            }
                    }
        
    
    }

    @IBOutlet weak var mValue: UILabel!
    
    var userTyping = false
    
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
            
        }
    }
    
    
    @IBAction func useM(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        userTyping = false
        displayResultAndHis()
        
    }
    
    
    @IBAction func setM(_ sender: UIButton)
    {
        variables["M"] = displayValue
        userTyping = false
        displayResultAndHis()
    }
    
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        if userTyping {
            let textInDisplay = display.text
            display.text = textInDisplay! + digit
        }
        else{
            display.text! = sender.currentTitle!
            userTyping = true
        }
    }
    
    
    @IBAction func floatingPoint(_ sender: Any) {
        if(!display.text!.contains(".")){
            display.text!.append(".")
        }
    }
    
    
    
    private var brain = CalculatorBrain()
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        
        if(userTyping){
            brain.setOperand(displayValue)
            userTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        displayResultAndHis()
    }
    
    private func displayResultAndHis(){
        
        let evaluieren = brain.evaluate(using: variables)
        
        if let result = evaluieren.result{
            displayValue = result
        }
        
        let description = evaluieren.description
        
        if description != ""
        {
            Description.text = description + (brain.evaluate(using: variables).isPending ? "…" : "=")
        } else {
            Description.text = " "
        }
        
        
    }
    
    @IBAction func undo(_ sender: UIButton) {
        
        if userTyping, var text = display.text {
            text.remove(at: text.index(before: text.endIndex))
            if text.isEmpty || "0" == text {
                text = "0"
                userTyping = false
            }
            display.text = text
        }  else {
            brain.undo()
            displayResultAndHis()
        }
    }
    

    
    
    @IBAction func clear(_ sender: Any) {
        displayValue = 0
        userTyping = false
        Description.text = String(describing: 0.0)
        brain = CalculatorBrain()
        variables["M"] = 0
    }
    
    
}

