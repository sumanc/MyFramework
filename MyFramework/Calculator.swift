//
//  MyFramework.swift
//  MyFramework
//
//  Created by Suman Cherukuri on 6/28/23.
//

import Foundation

public class Calculator {
    
    public init() {
        
    }
    
    public func computeSecret(a: Int, b: Int) -> Int {
        return SecretCalculator.compute(a, b: b)
    }
}
