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
    
    var userTyping = false
    
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
            
        }
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
        if let result = brain.result {
            displayValue = result
        }
        
        displayHistory()
    }
    
    
    private func displayHistory(){
     
        if let description = brain.description {
            Description.text = description + (brain.resultIsPending ? "…" : "=")
        } else {
            Description.text = " "
        }
    
    
    }
    
    
    @IBAction func clear(_ sender: Any) {
        displayValue = 0
        userTyping = false
        Description.text = ""
        brain = CalculatorBrain()

    }
    

}

