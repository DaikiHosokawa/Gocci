//
//  TempLiquidButton.swift
//  Gocci
//
//  Created by Castela on 2015/10/07.
//  Copyright © 2015年 Massara. All rights reserved.
//

import Foundation

@objc class LiquidButtonWrapper : NSObject, LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate {
    
    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!

    func addLiquidButton(vc: UIViewController, x:CGFloat, y:CGFloat) {
        
        //        self.view.backgroundColor = UIColor(red: 55 / 255.0, green: 55 / 255.0, blue: 55 / 255.0, alpha: 1.0)

        let floatingActionButton = LiquidFloatingActionButton(frame: CGRect(x: x, y: y, width: 56, height: 56))
        floatingActionButton.animateStyle = LiquidFloatingActionButtonAnimateStyle.Up
        floatingActionButton.dataSource = self
        floatingActionButton.delegate = self
        floatingActionButton.color = UIColor(red: 155 / 255.0, green: 55 / 255.0, blue: 55 / 255.0, alpha: 1.0)

        cells.append(LiquidFloatingCell(icon: UIImage(named: "icon_record_cam")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "icon_record_cam")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "icon_record_cam")!))
        cells.append(LiquidFloatingCell(icon: UIImage(named: "icon_record_cam")!))

        vc.view.addSubview(floatingActionButton)
    }
    
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        print("did Tapped! \(index)")
        liquidFloatingActionButton.close()
    }
}
