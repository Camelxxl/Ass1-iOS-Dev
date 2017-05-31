//
//  CalculatorBrain.swift
//  CalculatorApp
//
//  Created by app on 11.04.17.
//  Copyright © 2017 Hazu. All rights reserved.
//

import Foundation



struct CalculatorBrain{
    
    
    //accumulator ist ein Tupel aus String und Double + Optional
    private var accumulator: (Double, String)?
    
    
    //enum um die verschiedenen Fälle zu unterscheiden
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double) -> Double,(String)->String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
        
    }
    
    //Bool-Variable um den aktuellen Zustand von Binaryoperationen festzustellen
    var resultIsPending: Bool {
        get{
            return nil != pendingBinaryOperation
        }
    }
    
    
    // Das Dictionary beinhaltet alle Operationen, die mit einem Keyword abgerufen werden können
    private var operations: Dictionary<String,Operation> =
        [
            "π" : Operation.constant(Double.pi),
            "e"  : Operation.constant(M_E),
            "√" : Operation.unaryOperation(sqrt,{"√(" + $0 + ")"} ),
            "sin": Operation.unaryOperation(sin, {"sin(" + $0 + ")"} ),
            "cos": Operation.unaryOperation(cos, {"cos(" + $0 + ")"} ),
            "tan": Operation.unaryOperation(tan, {"tan(" + $0 + ")"} ),
            "±": Operation.unaryOperation({ -$0 }, { "-(" + $0 + ")" }),
            "+": Operation.binaryOperation({$0 + $1}, { $0 + "+" + $1 }),
            "-": Operation.binaryOperation({$0 - $1}, { $0 + "-" + $1 }),
            "×": Operation.binaryOperation({$0 * $1}, { $0 + "×" + $1 }),
            "÷": Operation.binaryOperation({$0 / $1}, { $0 + "÷" + $1 }),
            "=": Operation.equals,
            ]
    
    
    
    //Hier setzen wird den aktuellen Operanden
    mutating func setOperand(_ operand: Double){
        accumulator = (operand,"\(operand)")
    }


    
    
    //Erst prüfen ob accumulator und pendingBinaryOperation schon gesetzt wurden, erst dann kann man die Perform Methode anwenden, da dann der erste Operand schon vorhanden ist
    private mutating func performPendingBinaryOperation(){
        if nil != pendingBinaryOperation && nil != accumulator {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }else {
         print("Dies ist der erste Operand")
        }
        
        
    }
    
    var description: String? {
        get {
            if resultIsPending {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            } else {
                return accumulator?.1
            }
        }
    }

    
    //Die Variable zu untenstehendem struct
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    //Ein struct um BinaryOperations zu realisieren
    private struct PendingBinaryOperation{
        let function: (Double,Double) -> Double
        let description: (String, String) -> String
        let firstOperand: (Double, String)
        
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
        }
        
    }
    
    
    
    //computed Variable
    var result: Double? {
        get {
            if accumulator != nil{
                return accumulator!.0
            }
            return nil
        }
    }
    
    
    
    //Diese Funktion wird vom Controller aufgerufen
    
    mutating func performOperation (_ symbol: String){
        
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                
                accumulator = (Double(round(1000*value)/1000),symbol)
                
            case .unaryOperation(let function, let description):
                
                let roundedDoubleAccumulator = Double(round(1000*function(accumulator!.0))/1000)
                
                accumulator = (roundedDoubleAccumulator, description(accumulator!.1))
                
                
                
            case .binaryOperation(let function, let description):
                performPendingBinaryOperation()
                if nil != accumulator {
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                    accumulator = nil
                }
                
                
                
            case .equals:
                performPendingBinaryOperation()

                
            }
            
        }
        
        
    }
    
}
