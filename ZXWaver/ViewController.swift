//
//  ViewController.swift
//  ZXWaver
//
//  Created by 子循 on 15/6/30.
//  Copyright © 2015年 zixun. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    var recorder : AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRecorder()
        self.view.backgroundColor = UIColor.blackColor()
        
        let waver: ZXWaver = ZXWaver(frame: CGRectMake(0, CGRectGetHeight(self.view.bounds) / 2.0 - 50.0, CGRectGetWidth(self.view.bounds), 100))
        
        waver.waveLevelCallBack { (aWaver) -> Void in
            
            self.recorder.updateMeters()
            let normalizedValue = pow (10, self.recorder .averagePowerForChannel(0) / 40);
            
            waver.level = normalizedValue;
            
        }
        
        waver.backgroundColor = UIColor.redColor()
        self.view.addSubview(waver)
    }

    
    func setupRecorder() {
        
        do{
            let url : NSURL = NSURL(fileURLWithPath: "/dev/null")
            
            let setttings : [String : AnyObject] = [AVSampleRateKey:44100,
                AVFormatIDKey : Int(kAudioFormatAppleLossless),
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey:AVAudioQuality.Min.rawValue]
            
            try self.recorder = AVAudioRecorder(URL: url, settings: setttings)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            self.recorder.prepareToRecord()
            self.recorder.meteringEnabled = true
            self.recorder.record()
        }catch {
            print(error)
        }
    }

}

