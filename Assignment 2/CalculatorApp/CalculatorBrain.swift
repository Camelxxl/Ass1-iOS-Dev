//
//  CalculatorBrain.swift
//  CalculatorApp
//
//  Created by app on 11.04.17.
//  Copyright © 2017 Hazu. All rights reserved.
//

import Foundation



struct CalculatorBrain{
    
    
    
    
    private var stack = [Element]()
    
    
    //enum um die verschiedenen Fälle zu unterscheiden
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double) -> Double,(String)->String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private enum Element {
        case operation(String)
        case operand(Double)
        case variable(String)
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
    

    mutating func undo() {
        if !stack.isEmpty {
            stack.removeLast()
        }
    }
    
    
     @available(*, deprecated, message: "Wird nicht mehr benötigt")
    var result: Double? {
        return evaluate().result
    }
    
     @available(*, deprecated, message: "Wird nicht mehr benötigt")
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
     @available(*, deprecated, message: "Wird nicht mehr benötigt")
    var description: String? {
        return evaluate().description
    }
    
    
    
    func evaluate (using variables: Dictionary<String,Double>? = nil)
        ->(result: Double?, isPending: Bool, description: String){
            
            //accumulator ist ein Tupel aus String und Double + Optional
            var accumulator: (Double, String)?
            
            //computed Variable
            var result: Double? {
            
                    if accumulator != nil{
                        return accumulator!.0
                    }
                    return nil
                
            }
            
            //Die Variable zu untenstehendem struct
            var pendingBinaryOperation: PendingBinaryOperation?
            
            var description: String? {
            
                    if pendingBinaryOperation != nil {
                        return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
                    } else {
                        return accumulator?.1
                    }
                
            }
            
            
            
            //Ein struct um BinaryOperations zu realisieren
            struct PendingBinaryOperation{
                let function: (Double,Double) -> Double
                let description: (String, String) -> String
                let firstOperand: (Double, String)
                
                
                func perform(with secondOperand: (Double, String)) -> (Double, String) {
                    return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
                }
                
            }
            
            //Erst prüfen ob accumulator und pendingBinaryOperation schon gesetzt wurden, erst dann kann man die Perform Methode anwenden, da dann der erste Operand schon vorhanden ist
            func performPendingBinaryOperation(){
                if nil != pendingBinaryOperation && nil != accumulator {
                    accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                    pendingBinaryOperation = nil
                }else {
                    print("Dies ist der erste Operand")
                }
                
                
            }
            
            
                for element in stack {
                    switch element {
                    case .operand(let wert):
                        accumulator = (wert, "\(wert)")
                    case .variable(let zeichen):
                        
                        if let value = variables?[zeichen] {
                            accumulator = (value, zeichen)
                        } else {
                            accumulator = (0, zeichen)
                        }
          
                        
                    case .operation(let zeichen):
                        if let operation = operations[zeichen] {
                            switch operation {
                            case .constant(let value):
                                
                                accumulator = (Double(round(1000*value)/1000), zeichen)
                                
                            case .unaryOperation(let function, let description):
                                
                                let roundedDoubleAccumulator = Double(round(1000*function(accumulator!.0)/1000))
                                
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
            
            
            
            return (result, nil != pendingBinaryOperation, description ?? "")
            
            
    }
    
    
    
    
    
    
    //CalculatorBrain wird ermöglicht Eingaben von variablen zu erlauben
    mutating func setOperand(_ operand: Double) {
        stack.append(Element.operand(operand))
    }
    
    mutating func setOperand(variable named: String) {
        stack.append(Element.variable(named))
    }
    
    mutating func performOperation(_ symbol: String) {
        stack.append(Element.operation(symbol))
    }
    
    
    
    
    
    
    
    
}





