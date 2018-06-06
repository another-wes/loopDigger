//
//  SecondViewController.swift
//  loopDigger
//
//  Created by Shiflet, Wesley (UMSL-Student) on 7/29/17.
//  Copyright © 2017 Shiflet, Wesley (UMSL-Student). All rights reserved.
//

import UIKit
import AVFoundation
var loopNumber = -1
class SecondViewController: UIViewController {
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var waveform: DrawWaveform!
    
    @IBOutlet weak var startBigStep: UIStepper!
    @IBOutlet weak var startMedStep: UIStepper!
    @IBOutlet weak var startSmallStep: UIStepper!
    @IBOutlet weak var startSlider: UISlider!
    @IBOutlet weak var startField: UITextField!
    
    @IBOutlet weak var endBigStep: UIStepper!
    @IBOutlet weak var endMedStep: UIStepper!
    @IBOutlet weak var endSmallStep: UIStepper!
    @IBOutlet weak var endSlider: UISlider!
    @IBOutlet weak var endField: UITextField!
    
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedField: UITextField!
    
    @IBOutlet weak var preDelay: UITextField!
    var predelayValue:Double = 0.0
    var postdelayValue:Double = 0.0
    var loopLength:TimeInterval = 0.0 //should speed things up; every bit counts
    var timer = Timer()
    func play(){
        if let track = trackOne{
            let file = try! AVAudioFile(forReading: trackOne!.pathToTrack)//Read File into AVAudioFile
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)//Format of the file
            
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))//Buffer
            try! file.read(into: buf)//Read Floats
            //Store the array of floats in the struct
            readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
            loopNumber = -1 //just in case
            newEnds(duration: audioPlayerOne.duration)
            syncStarts(value: 0.0)
            songName.text = track.trackName
            waveform.setNeedsDisplay()
        }
    }
    @IBAction func restart(_ sender: Any) {
        timer.invalidate()
        audioPlayerOne.currentTime = startBigStep.value
        if (predelayValue > 0){
            audioPlayerOne.pause()
            audioPlayerOne.play(atTime: predelayValue + audioPlayerOne.deviceCurrentTime)
        }
        timer = Timer.scheduledTimer(timeInterval: loopLength, target: self, selector: #selector(self.loop), userInfo: nil, repeats: false)
    }
    @IBAction func play(_ sender: Any) {
        if audioPlayerOne.isPlaying == false
        {
            audioPlayerOne.play()
        }
    }
    @IBAction func pause(_ sender: Any) {
        timer.invalidate()
        if audioPlayerOne.isPlaying == true
        {
            audioPlayerOne.pause()
        }
    }
    @IBAction func stop(_ sender: Any) {
        if audioPlayerOne.isPlaying == true
        {
            audioPlayerOne.stop()
            timer.invalidate()
            audioPlayerOne.currentTime = TimeInterval(startBigStep.value)
            //audioPlayerOne.prepareToPlay()
        }
    }

    @IBAction func startBigStep(_ sender: Any) {
        syncStarts(value: startBigStep.value)
    }
    @IBAction func startMedStep(_ sender: Any) {
        syncStarts(value: startMedStep.value)
    }
    @IBAction func startSmallStep(_ sender: Any) {
        syncStarts(value: startSmallStep.value)

    }
    @IBAction func startSlide(_ sender: Any) {
        syncStarts(value: Double(startSlider.value))//(round(Double(startSlider.value)*10000000)/10000000) )
    }
    @IBAction func startEdited(_ sender: UITextField) {
        guard let text:String = sender.text, let value:Double = Double(text) else{
            sender.backgroundColor = UIColor.red
            return
        }
        sender.backgroundColor = UIColor.white
        syncStarts(value: value)
    }
    
    @IBAction func endBigStep(_ sender: Any) {
        syncEnds(value: endBigStep.value)
    }
    @IBAction func endMedStep(_ sender: Any) {
        syncEnds(value: endMedStep.value)
        
    }
    @IBAction func endSmallStep(_ sender: Any) {
        syncEnds(value: endSmallStep.value)
        
    }
    @IBAction func endSlide(_ sender: Any) {
        syncEnds(value: Double(endSlider.value))//(round(Double(endSlider.value)*10000000)/10000000 ) )
    }
    @IBAction func endEdited(_ sender: UITextField) {
        guard let text:String = sender.text, let value:Double = Double(text) else{
            sender.backgroundColor = UIColor.red
            return
        }
        sender.backgroundColor = UIColor.white
        syncEnds(value: value)
    }
    @IBAction func volumeChanged(_ sender: UISlider) {
        audioPlayerOne.volume = sender.value
    }
    @IBAction func speedSlide(_ sender: UISlider) {
        speedField.text = String(round(speedSlider.value*1000)/10) + "%"
        let wasPlaying = audioPlayerOne.isPlaying
        if wasPlaying { audioPlayerOne.stop() }
        audioPlayerOne.rate = sender.value
        audioPlayerOne.prepareToPlay()
        loopLength=Double(Float(endBigStep.value-startBigStep.value) * 1/sender.value)
        if wasPlaying { audioPlayerOne.play() }
    }
    @IBAction func saveLoop(_ sender: Any) {
        trim()
    }
    @IBAction func saveStruct(_ sender: Any) {
        trackOne?.loops.append(LocalLoop(trackName: songName.text,loopStart: startBigStep.value,loopStop: endBigStep.value, preDelay: predelayValue, postDelay: postdelayValue, relativeRate: audioPlayerOne.rate))
    }
    func loadStruct(loop: LocalLoop){
        justSelectedLoop = false
        syncStarts(value: loop.loopStart)
        syncEnds(value: loop.loopStop)
        predelayValue = loop.preDelay
        postdelayValue = loop.postDelay
        preDelay.text=String(predelayValue)
        audioPlayerOne.rate = loop.relativeRate
    }
    
    func loop(){
            audioPlayerOne.currentTime = TimeInterval(startBigStep.value)
            if ((predelayValue > 0)||(postdelayValue > 0)){
                audioPlayerOne.pause()
                audioPlayerOne.play(atTime: audioPlayerOne.deviceCurrentTime + postdelayValue + predelayValue)
                timer = Timer.scheduledTimer(timeInterval: loopLength, target: self, selector: #selector(self.loop), userInfo: nil, repeats: false)
            }
            else{
                timer = Timer.scheduledTimer(timeInterval: loopLength, target: self, selector: #selector(self.loop), userInfo: nil, repeats: false)
            }
    }
    func redrawBox(){
        if let sublayers = waveform.layer.sublayers {        for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
        let linesPath = UIBezierPath()
        let linesLayer = CAShapeLayer()
        var value = Int(waveform!.bounds.width * CGFloat(startBigStep.value/audioPlayerOne.duration) + waveform!.bounds.minX)
        linesPath.move(to: CGPoint(x: value, y: Int(waveform!.bounds.minY)))
        linesPath.addLine(to: CGPoint(x: value, y: Int(waveform!.bounds.maxY)))
        value = Int(waveform!.bounds.width * CGFloat(endBigStep.value/audioPlayerOne.duration) + waveform.bounds.minX)
        linesPath.move(to: CGPoint(x: value, y: Int(waveform!.bounds.minY)))
        linesPath.addLine(to: CGPoint(x: value, y: Int(waveform!.bounds.maxY)))
        linesLayer.path = linesPath.cgPath
        linesLayer.lineWidth = 2.0
        linesLayer.strokeColor = UIColor.yellow.cgColor
        waveform.layer.addSublayer(linesLayer)
    }
    func syncStarts(value: Double)
    {
        startBigStep.value = value
        startMedStep.value = value
        startSmallStep.value = value
        startSlider.value = Float(value)
        startField.text = String(value)
        loopLength=(endBigStep.value-startBigStep.value) * Double(1/audioPlayerOne.rate)
        if (value>audioPlayerOne.currentTime) && (audioPlayerOne.isPlaying){
            timer.invalidate()
            audioPlayerOne.currentTime = value
        }
        if loopLength<0{
            syncEnds(value: value)
        }
        redrawBox()
    }
    func newEnds(duration: Double){
        startBigStep.maximumValue = duration
        startMedStep.maximumValue = duration
        startSmallStep.maximumValue = duration
        startSlider.maximumValue = Float(duration)
        endBigStep.maximumValue = duration
        endMedStep.maximumValue = duration
        endSmallStep.maximumValue = duration
        endSlider.maximumValue = Float(duration)
        syncEnds(value: duration)
    }
    func syncEnds(value: Double)
    {
        endBigStep.value = value
        endMedStep.value = value
        endSmallStep.value = value
        endSlider.value = Float(value)
        endField.text = String(value)
        loopLength=(endBigStep.value-startBigStep.value) * Double(1/audioPlayerOne.rate)
        if loopLength<0{
            syncStarts(value: value)
        }
        else if (audioPlayerOne.isPlaying){
            if (value<audioPlayerOne.currentTime){
                timer.invalidate()
                loop()
            }
            else{
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: (endBigStep.value-audioPlayerOne.currentTime), target: self, selector: #selector(self.loop), userInfo: nil, repeats: false)
            }
        }
        redrawBox()
    }
    func trim() {
        var string = Date().description
        string.append(".mp3")
        let asset = AVAsset(url: (trackOne?.pathToTrack)!) as AVAsset
        exportAsset(asset: asset, fileName: string)
    }
    func exportAsset(asset:AVAsset, fileName:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] //output, reset to documents
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        
        let filemanager = FileManager.default
        if filemanager.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists ")
        }
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        exporter?.outputFileType = AVFileTypeAppleM4A
        exporter?.outputURL = trimmedSoundFileURL
        
        let duration = CMTimeGetSeconds(asset.duration)
        if duration > 60 {
            print("too long to be a loop")
            return
        }
        let stopTime = CMTimeMakeWithSeconds(Float64(endSlider.value), 1)
        let startTime = CMTimeMakeWithSeconds(Float64(startSlider.value), 1)
        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
        exporter?.timeRange = exportTimeRange
        
        
        // do it
        exporter?.exportAsynchronously(completionHandler: {
            switch exporter!.status as AVAssetExportSessionStatus {
            case  .failed :
                print("export failed \(exporter!.error)\n")
            case .cancelled :
                print("export cancelled \(exporter!.error)\n")
            default:
                print("export complete\n")
            }
        })
    }
    @IBAction func preChange(_ sender: UITextField) {
        guard let text = sender.text, let num = Double(text) else{
            sender.text = "0.000"
            print("0")
            predelayValue = 0
            return
        }
        print(num)
        predelayValue = num
    }
    @IBAction func postChange(_ sender: UITextField) {
        guard let text = sender.text, let num = Double(text) else{
            sender.text = "0.000"
            print("0")
            postdelayValue = 0
            return
        }
        print(num)
        postdelayValue = num
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (trackOne == nil) { return }
//        let file = try! AVAudioFile(forReading: trackOne!.pathToTrack)//Read File into AVAudioFile
//        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)//Format of the file
//        
//        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))//Buffer
//        try! file.read(into: buf)//Read Floats
//        //Store the array of floats in the struct
//        readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if justSelectedLoop {
            if (-1 < loopNumber) {
                loadStruct(loop: trackOne!.loops[loopNumber % trackOne!.loops.count])
            }
        }
        else{
            play()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

