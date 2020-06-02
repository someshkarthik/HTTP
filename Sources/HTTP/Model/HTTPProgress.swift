//
//  HTTPProgress.swift
//  HTTP
//
//  Created by somesh-8758 on 31/05/20.
//  Copyright © 2020 somesh-8758. All rights reserved.
//

import Foundation

public struct HTTPProgress {
    
    enum Size: Int {
        case byte = 0
        case kiloByte
        case megaByte
        case gigaByte
    }
    
    let progress: Progress
    
    var percentage: Float {
        Float(String(format: "%.2f", Double(progress.fractionCompleted) * 100.0))!
    }
    
    private func size(_ sizeRatio: Self.Size,for unitCount: Int64) -> Double {
        Double(unitCount)/pow(1024, Double(sizeRatio.rawValue))
    }
    
    //MARK: Total Size Computation
    func totalSize(in sizeRatio: Self.Size) -> Double {
        size(sizeRatio, for: progress.totalUnitCount)
    }
    
    func formattedTotalSize(in sizeRatio: Self.Size,upto decimalSpace: Int = 2) -> String {
        totalSize(in: sizeRatio).format(to: decimalSpace)
    }
    
    //MARK: Completed Size Computation
    func completedSize(in sizeRatio: Self.Size) -> Double {
        size(sizeRatio, for: progress.completedUnitCount)
    }
    
    func formattedCompletedSize(in sizeRatio: Self.Size,upto decimalSpace: Int = 2) -> Double {
        completedSize(in: sizeRatio).format(to: decimalSpace)
    }
    
    //MARK: Fetches SizeRatio based the unit Count
    func getCorrectSize(for unitCount: Int64, startsFrom sizeRatio: Self.Size = .byte) -> Self.Size{
        let newSize = unitCount/1024
        
        if newSize >= 1024 {
            return getCorrectSize(
                for: newSize,
                startsFrom: Size(rawValue: sizeRatio.rawValue+1)!
            )
        }
        
        return sizeRatio
    }
    
    
}

//MARK: Progress To HTTPProgress initialiser
extension Progress {
    var httpProgress: HTTPProgress {
        HTTPProgress(progress: self)
    }
}

//MARK: Precision Formatter
//only applicable to floating-point value type
extension CVarArg where Self: BinaryFloatingPoint {
    func format(to decimalSpaces: Int) -> String {
        return String(format: "%.\(decimalSpaces)f", self)
    }
    
    func format(to decimalSpaces: Int) -> Double {
        let multiplier = (pow(10, Double(decimalSpaces)))
        
        return ((multiplier * Double(self)).rounded() / multiplier)
    }
}
