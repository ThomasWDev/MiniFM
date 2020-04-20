//
//  FSVideoCameraView.swift
//  Fusuma
//
//  Created by Brendan Kirchner on 3/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation

@objc protocol FSVideoCameraViewDelegate: class {
    func videoFinished(withFileURL fileURL: NSURL)
    func cameraVideoShotFinished(image: UIImage)
    func cameraVideo(recording : Bool)
}

final class FSVideoCameraView: UIView {
    
    @IBOutlet weak var buttonsViewContainer: UIView!
    @IBOutlet weak var previewViewContainerRef: UIView!
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var bottomPreviewLayout: NSLayoutConstraint!
    @IBOutlet weak var shotButton: RecordButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    weak var previewLayer : AVCaptureVideoPreviewLayer?
    @IBOutlet weak var smileButton: UIButton!
    
    weak var delegate: FSVideoCameraViewDelegate? = nil
    weak var fusumaViewController : FusumaViewController?
    internal var session: AVCaptureSession?
    internal var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    
    internal var cameraPosition: AVCaptureDevicePosition = .front
    
    var videoOutput: AVCaptureMovieFileOutput?
    var videoDataOutput: AVCaptureVideoDataOutput?
    var imageOutput: AVCaptureStillImageOutput?
    
    //var videoOutput: AVCaptureMovieFileOutput?
    var focusView: UIView?
    
    var flashOffImage: UIImage?
    var flashOnImage: UIImage?
    var flashAutoImage: UIImage?
    var videoStartImage: UIImage?
    var videoStopImage: UIImage?
    var updateUIOnly : Bool = false
    var currentFlashMode : AVCaptureFlashMode = .auto
    //    var faceDetector : CIDetector!
    
    var maxVideoSeconds : Float64 = 60 {
        didSet {
            let timeScale: Int32 = 30 //FPS
            let maxDuration = CMTimeMakeWithSeconds(maxVideoSeconds, timeScale)
            self.videoOutput?.maxRecordedDuration = maxDuration
        }
    } //Total Seconds of capture time
    
    public var isRecording = false
    /// Property to check video recording duration when in progress
    private var recordedDuration : CMTime { return videoOutput?.recordedDuration ?? kCMTimeZero }
    
    /// Property to check video recording file size when in progress
    private var recordedFileSize : Int64 { return videoOutput?.recordedFileSize ?? 0 }
    
    static func instance() -> FSVideoCameraView {
        
        return UINib(nibName: "FSVideoCameraView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSVideoCameraView
    }
    
    var progressTimer : Timer?
    var progress : CGFloat = 0
    
    func updateProgress() {
        
        let maxDuration = CGFloat(self.maxVideoSeconds) // Max duration of the recordButton
        progress = progress + (CGFloat(0.05) / maxDuration)
        shotButton.setProgress(newProgress: progress)
        
        let durationSeconds = CMTimeGetSeconds(self.recordedDuration)
        let text = textForPlaybackTime(time: durationSeconds)
        self.timerLabel.text  = text
    }
    
    @IBAction func normalTap(_ sender: Any) {
        // Take photo
        //shotButton.didTouchUp()
        
        guard let imageOutput = imageOutput else {
            
            return
        }
        
        self.shotButton.isEnabled = false
        DispatchQueue.global(qos: .background).async { [weak self]
            () -> Void in
            let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
            
            imageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) -> Void in
                
                guard let sampleBuffer = buffer else {
                    return
                }
                
                self?.session?.stopRunning()
                
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                
                if let image = UIImage(data: data!), let delegate = self?.delegate {
                    
                    // Image size
                    let iw = image.size.width
                    let ih = image.size.height
                    
                    // Frame size
                    let sw = self?.previewViewContainer.frame.width
                    
                    // The center coordinate along Y axis
                    let rcy = ih * 0.5
                    
                    let imageRef = image.cgImage?.cropping(to: CGRect(x: rcy-iw*0.5, y: 0 , width: iw, height: iw))
                    
                    DispatchQueue.main.async(execute: {
                        if fusumaCropImage {
                            let resizedImage = UIImage(cgImage: imageRef!, scale: sw!/iw, orientation: image.imageOrientation)
                            print(resizedImage.size)
                            delegate.cameraVideoShotFinished(image: resizedImage.fs_fixOrientation())
                        } else {
                            print(image.size)
                            delegate.cameraVideoShotFinished(image: image.fs_fixOrientation())
                        }
                        
                        self?.session     = nil
                        self?.device      = nil
                        self?.imageOutput = nil
                    })
                }
                
            })
        }
    }
    
    
    func longTap(longgesture: UILongPressGestureRecognizer) {
        
        if (longgesture.state == UIGestureRecognizerState.began) {
            
            //Start recording
            
            session?.removeOutput(videoDataOutput)
            
            if (session?.canAddOutput(videoOutput))! {
                session?.addOutput(videoOutput)
            }
            
            self.toggleRecording()
            
        }
        if (longgesture.state == UIGestureRecognizerState.ended) {
            //Stop recording and switch
            
            self.toggleRecording()
            
        }
    }
    
    func switchUIElementsToRecordVideoMode() {
        
        let newPreviewLayerSize = CGSize(width: previewViewContainerRef.bounds.size.width, height: previewViewContainerRef.bounds.size.height + buttonsViewContainer.bounds.size.height)
        let newPreviewLayerFrame = CGRect(origin: CGPoint.zero, size: newPreviewLayerSize)
        
        UIView.animate(withDuration: 0.33, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.previewViewContainer.frame = CGRect(origin: self.previewViewContainerRef.frame.origin, size: newPreviewLayerFrame.size)
            //self.bottomPreviewLayout.constant = 0
            
            self.previewLayer?.frame = newPreviewLayerFrame
            self.buttonsViewContainer.backgroundColor = UIColor.clear
            self.flipButton.isHidden = true
            self.fusumaViewController?.hideFlash = true
        }, completion: nil)
    }
    
    func revertUIElementsToTakePhotoMode() {
        
        let newPreviewLayerSize = previewViewContainerRef.frame.size
        let newPreviewLayerFrame = CGRect(origin: CGPoint.zero, size: newPreviewLayerSize)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.previewViewContainer.frame = CGRect(origin: self.previewViewContainerRef.frame.origin, size: newPreviewLayerFrame.size)
            //self.bottomPreviewLayout.constant = self.buttonsViewContainer.bounds.size.height
            self.previewLayer?.frame = newPreviewLayerFrame
            self.buttonsViewContainer.backgroundColor = fusumaBackgroundColor
            self.flipButton.isHidden = false
            self.fusumaViewController?.hideFlash = (self.device?.hasFlash == false)
        }, completion: nil)
        
    }
    
    func initialize() {
        
        if session != nil { return }
        fusumaViewController = delegate as? FusumaViewController
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        shotButton.isEnabled = true
        shotButton.buttonColor = UIColor.white
        shotButton.progressColor = .red
        shotButton.progressLineWidth = 4
        shotButton.gestureDeplay = 1.5
        shotButton.closeWhenFinished = false
        shotButton.rb_addTarget(target: self, action: #selector(FSVideoCameraView.longTap(longgesture:)), forGestureEvents: .LongPress)
        
        self.backgroundColor = fusumaBackgroundColor
        
        self.isHidden = false
        
        // AVCapture
        
        session = AVCaptureSession()
        
        #if TARGET_OS_EMBEDDED
            if (session?.canSetSessionPreset(AVCaptureSessionPreset1280x720)) != nil {
                session?.sessionPreset = AVCaptureSessionPreset1280x720
            }
        #endif
        
        //search for device if nil
        if self.device == nil {
            for device in AVCaptureDevice.devices() {
                if let device = device as? AVCaptureDevice , device.position == self.cameraPosition{
                    self.device = device
                }
            }
        }
        
//        self.fusumaViewController?.hideFlash = !self.device!.hasFlash
        
        do {
            
            if let session = session {
                
                videoInput = try AVCaptureDeviceInput(device: device)
                
                session.addInput(videoInput)
                
                imageOutput = AVCaptureStillImageOutput()
                
                videoOutput = AVCaptureMovieFileOutput()
                let timeScale: Int32 = 30 //FPS
                let maxDuration = CMTimeMakeWithSeconds(maxVideoSeconds, timeScale)
                
                videoOutput?.maxRecordedDuration = maxDuration
                videoOutput?.minFreeDiskSpaceLimit = 1024 * 1024 //SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
                
                videoDataOutput = AVCaptureVideoDataOutput()
                videoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable:kCVPixelFormatType_32BGRA]
                videoDataOutput?.alwaysDiscardsLateVideoFrames = true
                let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
                videoDataOutput?.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
                
                if session.canAddOutput(imageOutput) {
                    session.addOutput(imageOutput)
                }
                
                if session.canAddOutput(videoDataOutput) {
                    session.addOutput(videoDataOutput)
                }
                
                // Add audio device to the recording
                
                let audioDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
                do {
                    let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                    session.addInput(audioInput)
                    
                } catch {
                    print("Unable to add audio device to the recording.")
                }
                
                self.previewViewContainer.frame = self.previewViewContainerRef.frame
                //self.bottomPreviewLayout.constant = self.buttonsViewContainer.bounds.size.height
                
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer?.frame = self.previewViewContainer.bounds
                videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                for layer in self.previewViewContainer.layer.sublayers ?? [] {
                    layer.removeFromSuperlayer()
                }
                self.previewViewContainer.layer.addSublayer(videoLayer!)
                self.previewLayer = videoLayer
                
                session.startRunning()
                
                self.setMirror()
                
            }
            
            // Focus View
            
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action: #selector(FSVideoCameraView.focus(recognizer:)))
            self.previewViewContainer.addGestureRecognizer(tapRecognizer)
            
        } catch {
            
        }
        
        // Config icons for control buttons
        
        let bundle = Bundle(for: self.classForCoder)
        
        flashAutoImage = UIImage(named: "flashAutoImage", in: bundle, compatibleWith: nil)
        
        flashOnImage = fusumaFlashOnImage != nil ? fusumaFlashOnImage : UIImage(named: "flashOnImage", in: bundle, compatibleWith: nil)
        flashOffImage = fusumaFlashOffImage != nil ? fusumaFlashOffImage : UIImage(named: "flashOffImage", in: bundle, compatibleWith: nil)
        let flipImage = fusumaFlipImage != nil ? fusumaFlipImage : UIImage(named: "cameraSwitchImage", in: bundle, compatibleWith: nil)
        videoStartImage = fusumaVideoStartImage != nil ? fusumaVideoStartImage : UIImage(named: "video_button", in: bundle, compatibleWith: nil)
        videoStopImage = fusumaVideoStopImage != nil ? fusumaVideoStopImage : UIImage(named: "video_button_rec", in: bundle, compatibleWith: nil)
        
        /*
        if(fusumaTintIcons) {
            flashButton.tintColor = fusumaBaseTintColor
            flipButton.tintColor  = fusumaBaseTintColor
            shotButton.tintColor  = fusumaBaseTintColor
            
            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            //shotButton.setImage(videoStartImage?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        } else {
            flashButton.setImage(flashOffImage, for: .normal)
            flipButton.setImage(flipImage, for: .normal)
            //shotButton.setImage(videoStartImage, forState: .Normal)
        }
        */
        
        self.flashConfiguration()
        
        self.startCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FSVideoCameraView.willEnterForegroundNotification(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func setMirror() {
        
        if let pictureConnection = imageOutput?.connection(withMediaType: AVMediaTypeVideo), pictureConnection.isVideoMirroringSupported {
            pictureConnection.isVideoMirrored = true
        }
    }
    
    func willEnterForegroundNotification(notification: NSNotification) {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {
            
            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            
            session?.stopRunning()
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func startCamera() {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {
            
            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            
            session?.stopRunning()
        }
    }
    
    func stopCamera() {
        if self.isRecording {
            self.toggleRecording()
        }
        session?.stopRunning()
    }
    
    private func toggleRecording() {
        
        self.isRecording = !self.isRecording
        //        let shotImage: UIImage?
        //        if self.isRecording {
        //            shotImage = videoStopImage
        //        } else {
        //            shotImage = videoStartImage
        //        }
        //        self.shotButton.setImage(shotImage, forState: .Normal)
        
        if self.isRecording {
            
            self.clearTmpDirectory()
            
            let outputPath = "\(NSTemporaryDirectory())output.mov"
            let outputURL = NSURL.fileURL(withPath: outputPath)
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: outputPath) {
                do {
                    try fileManager.removeItem(atPath: outputPath)
                } catch {
                    print("error removing item at path: \(outputPath)")
                    self.isRecording = false
                    return
                }
            }
            self.flipButton.isEnabled = false
            fusumaViewController?.hideFlash = true
            if (session?.canSetSessionPreset(AVCaptureSessionPresetMedium)) != nil {
                session?.sessionPreset = AVCaptureSessionPresetMedium
            }
            
            if (session?.inputs.count)! > 0 {
                self.switchUIElementsToRecordVideoMode()
                self.videoOutput?.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
            }
            
        } else {
            
            self.videoOutput?.stopRecording()
            self.session     = nil
            self.device      = nil
            self.imageOutput = nil
            self.flipButton.isEnabled = true
            fusumaViewController?.hideFlash = (device?.hasFlash == false)
        }
        
        return
    }
    
    private func clearTmpDirectory() {
        do {
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
    
    func startTimer() {
        
        self.progressTimer?.invalidate()
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(FSVideoCameraView.updateProgress), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        
        self.progressTimer?.invalidate()
        self.progressTimer = nil
        self.timerLabel.text = ""
        self.progress = 0
    }
    
    private func textForPlaybackTime(time: TimeInterval) -> String {
        
        if !time.isNormal {
            return ""
        }
        let hours = Int(floor(time / 3600))
        let minutes = Int(floor((time / 60).truncatingRemainder(dividingBy: 60)))
        let seconds = Int(round(time.truncatingRemainder(dividingBy: 60)))
        let minutesAndSeconds = NSString(format: "%02d:%02d", minutes, seconds) as String
        if hours > 0 {
            return NSString(format: "%02d:%@", hours, minutesAndSeconds) as String
        } else {
            return minutesAndSeconds
        }
    }
    
    @IBAction func flipButtonPressed(sender: UIButton) { // Same
        
        if !AVCaptureDevice.cameraIsAvailable() {
            
            return
        }
        
        session?.stopRunning()
        
        do {
            
            session?.beginConfiguration()
            
            if let session = session {
                
                for input in session.inputs {                    
                    session.removeInput(input as! AVCaptureInput)
                }
                
                let position = (videoInput?.device.position == AVCaptureDevicePosition.front) ? AVCaptureDevicePosition.back : AVCaptureDevicePosition.front
                self.cameraPosition = position
                
                for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
                    
                    if let device = device as? AVCaptureDevice , device.position == position {
                        videoInput = try AVCaptureDeviceInput(device: device)
                        self.device = device
                        session.addInput(videoInput)
                    }
                }
                
                
                // Add audio device to the recording
                
                let audioDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
                do {
                    let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                    session.addInput(audioInput)
                    
                } catch {
                    print("Unable to add audio device to the recording.")
                }
            }
            
            session?.commitConfiguration()
            
            
        } catch {
            
        }
        
        self.flashConfiguration()
        
        session?.startRunning()
        
        self.setMirror()
    }
    
    func printTest() {
        if let device = device {
            print("Device is back position: \(device.position == AVCaptureDevicePosition.back)")
            print("Device has torch: \(device.hasTorch)")
            print("Device has flash: \(device.hasFlash)")
            print("Device flash mode: \(device.flashMode)")
            print("Device flash available: \(device.isFlashAvailable)")
        }
    }
    
    @IBAction func flashButtonPressed(sender: UIButton) { // Same
        
        if !AVCaptureDevice.cameraIsAvailable() {
            
            return
        }
        
        do {
            
            if let device = device {
                try device.lockForConfiguration()
                
                let mode = device.flashMode
                
                if mode == AVCaptureFlashMode.off {
                    device.flashMode = AVCaptureFlashMode.auto
                    fusumaViewController?.doneButton.setImage(flashAutoImage, for: .normal)
                } else if mode == AVCaptureFlashMode.auto {
                    device.flashMode = AVCaptureFlashMode.on
                    fusumaViewController?.doneButton.setImage(flashOnImage, for: .normal)
                } else {
                    device.flashMode = AVCaptureFlashMode.off
                    fusumaViewController?.doneButton.setImage(flashOffImage, for: .normal)
                }
                currentFlashMode = device.flashMode
                device.unlockForConfiguration()
            }
            
        } catch _ {
            currentFlashMode = .off
            fusumaViewController?.doneButton.setImage(flashOffImage, for: .normal)
            return
        }
        
    }
    
}

extension FSVideoCameraView {
    
    func focus(recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.location(in: self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
            try device?.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus) == true {
            
            device?.focusMode = AVCaptureFocusMode.autoFocus
            device?.focusPointOfInterest = newPoint
        }
        
        if device?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure) == true {
            
            device?.exposureMode = AVCaptureExposureMode.continuousAutoExposure
            device?.exposurePointOfInterest = newPoint
        }
        
        device?.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        self.focusView?.backgroundColor = UIColor.clear
        self.focusView?.layer.borderColor = UIColor.white.cgColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.addSubview(self.focusView!)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0, options: UIViewAnimationOptions.curveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished) in
            self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.focusView!.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
        guard device?.hasTorch == true || device?.hasFlash == true else {
            fusumaViewController?.hideFlash = true
            return
        }
        
        guard device?.isFlashModeSupported(.on) == true || device?.isFlashModeSupported(.off) == true || device?.isFlashModeSupported(.auto) == true else {
            fusumaViewController?.hideFlash = true
            return
        }
        
        do {
            if let device = device {
                try device.lockForConfiguration()
                if device.isFlashModeSupported(self.currentFlashMode) {
                    device.flashMode = self.currentFlashMode
                } else {
                    self.currentFlashMode = .off
                    device.flashMode = .off
                }
                switch self.currentFlashMode {
                case .auto:
                    fusumaViewController?.doneButton.setImage(flashAutoImage, for: .normal)
                case .off:
                    fusumaViewController?.doneButton.setImage(flashOffImage, for: .normal)
                case .on:
                    fusumaViewController?.doneButton.setImage(flashOnImage, for: .normal)                    
                }
                device.unlockForConfiguration()
            }
            fusumaViewController?.hideFlash = false
            
        } catch _ {
            fusumaViewController?.hideFlash = true
            return
        }
    }
    
}

extension FSVideoCameraView: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("started recording to: \(fileURL)")
        
        DispatchQueue.main.async {
            if self.delegate != nil {
                self.delegate?.cameraVideo(recording: self.isRecording)
            }
        }
        self.startTimer()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("finished recording to: \(outputFileURL)")
        self.stopTimer()
        self.shotButton.didTouchUp()
        self.delegate?.videoFinished(withFileURL: outputFileURL as NSURL)
        self.revertUIElementsToTakePhotoMode()
    }
    
}

extension FSVideoCameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Timer
    
    func startTakePicTimer() {
        self.progressTimer?.invalidate()
        self.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FSVideoCameraView.takeSmileSelfie), userInfo: nil, repeats: true)
    }
    
    func takeSmileSelfie() {
        self.stopTimer()
        normalTap(shotButton)
        self.smileButton.isSelected = false
    }
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // got an image
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer!).toOpaque()
        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
        let sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        
        let curDeviceOrientation : UIDeviceOrientation = UIDevice.current.orientation
        var exifOrientation : Int
        
        enum DeviceOrientation : Int {
            case PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
            PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
            PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
            PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
            PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
            PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
            PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
            PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
        }
        
        switch curDeviceOrientation {
            
        case UIDeviceOrientation.portraitUpsideDown:
            exifOrientation = DeviceOrientation.PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM.rawValue
        case UIDeviceOrientation.landscapeLeft:
            if device?.position == AVCaptureDevicePosition.front {
                exifOrientation = DeviceOrientation.PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT.rawValue
            } else {
                exifOrientation = DeviceOrientation.PHOTOS_EXIF_0ROW_TOP_0COL_LEFT.rawValue
            }
        case UIDeviceOrientation.landscapeRight:
            if device?.position == AVCaptureDevicePosition.front {
                exifOrientation = DeviceOrientation.PHOTOS_EXIF_0ROW_TOP_0COL_LEFT.rawValue
            } else {
                exifOrientation = DeviceOrientation.PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT.rawValue
            }
        default:
            exifOrientation = DeviceOrientation.PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP.rawValue
        }
        
        let imageOptions = [CIDetectorImageOrientation : NSNumber(value: exifOrientation), CIDetectorSmile : true, CIDetectorEyeBlink : false] as [String : Any]
        var features = [CIFeature]()
        
        if !shotButton.isEnabled {
            return
        }
        
        let detectorOptions = [CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorTracking: true] as [String : Any]
        if let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions) {
            features = faceDetector.features(in: sourceImage, options: imageOptions)
        }
        
        var hasSmile = false
        for faceFeature in features as! [CIFaceFeature] {
            if faceFeature.hasMouthPosition && faceFeature.hasSmile {
                hasSmile = true
                DispatchQueue.main.async { [weak self] in
                    self?.smileButton.isSelected = true
                }
                
                break
            }
            else {
                hasSmile = false
                DispatchQueue.main.async { [weak self] in
                    self?.smileButton.isSelected = false
                }
                
            }
        }
        
//        if hasSmile {
//            guard self.progressTimer == nil else {
//                return
//            }
//            DispatchQueue.main.async { [weak self] in
//                self?.startTakePicTimer()
//            }
//        }
//        else {
//            self.stopTimer()
//            DispatchQueue.main.async { [weak self] in
//                self?.smileButton.isSelected = false
//            }
//        }
        
    }
    
}
