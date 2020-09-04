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
        case kb
        case mb
        case gb
    }
    
    let progress: Progress
    var bytesWritten: Int64 = 0
    
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
    
    func formattedTotalSize(in sizeRatio: Self.Size,upto decimalSpace: Int = 2) -> Double {
        totalSize(in: sizeRatio)
            .format(to: decimalSpace)
    }
    
    func formattedDynamicTotalSize(upto decimalSpace: Int = 2) -> String {
        let sizeRatio = getCorrectSize(for: progress.totalUnitCount)
        return totalSize(in: sizeRatio)
            .format(to: decimalSpace,sizeRatio: sizeRatio)
    }
    
    //MARK: Completed Size Computation
    func completedSize(in sizeRatio: Self.Size) -> Double {
        size(sizeRatio, for: progress.completedUnitCount)
    }
    
    func formattedCompletedSize(in sizeRatio: Self.Size,upto decimalSpace: Int = 2) -> Double {
        completedSize(in: sizeRatio).format(to: decimalSpace)
    }
    
    func formatteDynamicCompletedSize(upto decimalSpace: Int = 2) -> String {
        let sizeRatio = getCorrectSize(for: progress.completedUnitCount)
        return completedSize(in: sizeRatio)
            .format(to: decimalSpace,sizeRatio: sizeRatio)
    }
    
    //MARK: Fetches SizeRatio based the unit Count
    private func getCorrectSize(for unitCount: Int64, startsFrom sizeRatio: Self.Size = .byte) -> Self.Size{
        
        if unitCount >= 1024 {
            let newSize = unitCount/1024
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
    func format(to decimalSpaces: Int, sizeRatio: HTTPProgress.Size) -> String {
        return String(format: "%.\(decimalSpaces)f\(sizeRatio)", self)
    }
    
    func format(to decimalSpaces: Int) -> Double {
        let multiplier = (pow(10, Double(decimalSpaces)))
        return ((multiplier * Double(self)).rounded() / multiplier)
    }
}
