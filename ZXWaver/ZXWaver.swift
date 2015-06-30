//
//  ZXWaver.swift
//  ZXWaver
//
//  Created by 子循 on 15/6/30.
//  Copyright © 2015年 zixun. All rights reserved.
//

import Foundation
import UIKit

typealias waveLevelCallBackA = ((ZXWaver) -> Void)

class ZXWaver: UIView {
    
    //回调闭包
    private var levelCallBack : waveLevelCallBackA?
    
    // 波纹个数
    var waves: [CAShapeLayer] = [CAShapeLayer]()
    
    //频率
    var frequency: Float = 1.2
    
    //振幅比例
    var amplitude: Float = 1.0
    
    //空载振幅（外界没有声音的时候的振幅）
    var idleAmplitude: Float = 0.01
    
    //波纹颜色
    var waveColor: UIColor = UIColor.whiteColor()
    
    //主波纹线宽
    var mainWaveWidth: Float = 2.0
    
    //辅助波纹线宽
    var decorativeWavesWidth: Float = 1.0
    
    var phaseShift: Float = -0.25
    var density: Float = 1.0
    var level: Float = 0
    {
        didSet {
            self.phase += self.phaseShift
            self.amplitude = fmax(level, self.idleAmplitude)
            self.updateMeters()
        }
    }
    
    //波纹个数
    private var numberOfWaves: UInt = 5
    
    //波纹高度
    private var waveHeight: Float!
    
    //波纹宽度
    private var waveWidth: Float!
    
    //波纹半宽
    private var waveMid: Float!
    
    //波纹最大振幅
    private var maxAmplitude: Float!
    
    
    private var displayLink: CADisplayLink?
    
    private var phase: Float = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialization()
    }
    
    func stop() {
        self.displayLink?.invalidate()
    }
    
    private func initialization() {
        self.waveHeight = Float(CGRectGetHeight(self.bounds))
        self.waveWidth = Float(CGRectGetWidth(self.bounds))
        self.waveMid = self.waveWidth / 2.0
        self.maxAmplitude = self.waveHeight - 4.0
        
    }

    func waveLevelCallBack(myblock:waveLevelCallBackA) {
        self.levelCallBack = myblock
        
        self.displayLink = CADisplayLink(target: self, selector: Selector("invokeWaveCallback"))
        self.displayLink!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        
        for i in 0...self.numberOfWaves {
            let waveline : CAShapeLayer = CAShapeLayer()
            waveline.lineCap = kCALineCapButt
            waveline.lineJoin = kCALineJoinRound
            waveline.strokeColor = UIColor.clearColor().CGColor
            waveline.fillColor = UIColor.clearColor().CGColor
            waveline.lineWidth = CGFloat(i == 0 ? self.mainWaveWidth : self.decorativeWavesWidth)
            
            
            let progress: Float = 1.0 - Float(i) / Float(self.numberOfWaves)
            let multiplier: Float = min(1.0, (progress / 3.0 * 2.0) + (1.0 / 3.0))
            let color: UIColor = self.waveColor.colorWithAlphaComponent( i == 0 ? CGFloat(1.0) : CGFloat(1.0 * multiplier * 0.4))
            waveline.strokeColor = color.CGColor
            
            self.layer.addSublayer(waveline)
            self.waves.append(waveline)
        }
        
    }
    
    func invokeWaveCallback() {
        self.levelCallBack!(self)
    }
    
    func updateMeters() {
        
        self.waveHeight = Float(CGRectGetHeight(self.bounds))
        self.waveWidth = Float(CGRectGetWidth(self.bounds))
        self.waveMid = self.waveWidth / 2.0
        self.maxAmplitude = self.waveHeight - 4.0
        
        UIGraphicsBeginImageContext(self.frame.size)
        for i in 0...self.numberOfWaves {
            let wavelinePath: UIBezierPath = UIBezierPath()
            
            // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
            let progress = 1.0 - Float(i) / Float(self.numberOfWaves)
            let normedAmplitude: Float = (1.5 * progress - 0.5) * self.amplitude
            
            for var x: Float = 0; x < self.waveWidth + self.density; x += self.density {
                
                let scaling: Float = Float(-pow(x / self.waveMid - 1.0, 2) + 1) // make center bigger
                
                let y: Float = scaling * self.maxAmplitude * normedAmplitude * sinf(2.0 * Float(M_PI) * (x / self.waveWidth) * self.frequency + self.phase) + (self.waveHeight * 0.5)
                
                if x == 0 {
                    wavelinePath.moveToPoint(CGPointMake(CGFloat(x), CGFloat(y)))
                }else {
                    wavelinePath.addLineToPoint(CGPointMake(CGFloat(x), CGFloat(y)))
                }
            }
            
            let waveline: CAShapeLayer = self.waves[Int(i)]
            waveline.path = wavelinePath.CGPath
        }
        
        UIGraphicsEndImageContext()
        
    }
}
