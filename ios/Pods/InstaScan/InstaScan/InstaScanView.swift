//
//  InstaScanViewController.swift
//  InstaScan
//
//  Created by Can Şener on 6.06.2022.
//

import UIKit
import AVFoundation
import Vision
open class InstaScanView: UIView {

    public var delegate:InstaScanDelegate?

    var currentImage:UIImage!
    
    @IBOutlet weak var overlayView: InstaScanCroppingView!
    @IBOutlet weak var previewView:InstaScanPreviewView!
    @IBOutlet var contentView:UIView!

    var configuration = InstaScanConfiguration()
    
    var settings:InstaScanSettings{
        return configuration.settings
    }
    var style:InstaScanStyle{
        return configuration.style
    }
    var rules:InstaScanRules{
        return configuration.rules
    }
    
    var recognizedPincodes:[String:Int] = [:]
    
    var request: VNRecognizeTextRequest!
    
    var wasTorchActive = false
    //For displaying text rectangles.
    var textHighlightTransform = CGAffineTransform.identity

    var clearHighlightScheduler:DispatchWorkItem?
    
    var roi = CGRect(x: 0, y: 0, width: 1, height: 1)

    //Convert coordinate spaces.
    let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)

    //Portrait
    let rotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
    
    //Transform needed for user guide area.
    var cutOutTransform:CGAffineTransform = .identity
    
    //Default camera asepct ratio
    var cameraAspectRatio:CGFloat = 16/9
    
    private var captureSession:AVCaptureSession!
    let captureSessionQueue = DispatchQueue(label: "com.kaizen.instascan.CaptureSessionQueue")
    
    var captureDevice: AVCaptureDevice?
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: "com.kaizen.instascan.VideoDataOutputQueue")
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        let bundle = Bundle(identifier: "com.kaizen.InstaScan")!
        bundle.loadNibNamed("InstaScanView", owner: self, options: nil)
        addSubview(self.contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    func checkResults(){
                
        var validCandidates:[String] =  []
        for (candidate,count) in recognizedPincodes{
            if count >= settings.sampleCount{
                validCandidates.append(candidate)
                break
            }
        }
        
        if validCandidates.count > 0 {
            let result = validCandidates.joined()
            
            wasTorchActive = getTorchStatus()
            stopCapturing()
            displayResult(result)
        }
  
    }
    
    func replaceTransform(_ candidate:String) -> String{
        var result = candidate
        for (replaceKey,replaceValue) in rules.replaceMap {
            result = candidate.replacingOccurrences(of: replaceKey, with: replaceValue)
        }
        return result
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        
        DispatchQueue.main.async {[weak self] in
            self?.removeHighligts()

        }
     
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let maximumCandidates = 1
        
        var uppercasedCandidate = ""
        
        var lineRects:[CGRect]  = []
        
        for visionResult in results {
            
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
            uppercasedCandidate += candidate.string.uppercased(with: Locale(identifier: settings.lang))
            lineRects.append(visionResult.boundingBox)
          
        }
        
        uppercasedCandidate = replaceTransform(uppercasedCandidate)
        
        if isValidPincode(uppercasedCandidate){
            
            let validPincode = uppercasedCandidate
            
            if let pincodeCount = recognizedPincodes[validPincode] {
                recognizedPincodes[validPincode] = pincodeCount + 1
            } else {
                recognizedPincodes[validPincode] = 1
            }
            
            DispatchQueue.main.async {[weak self] in
                for rect in lineRects {
                    self?.highlightRecognizedText(rect, true)
                }
            }
            
            if let validPincodeCount = recognizedPincodes[validPincode], validPincodeCount == settings.sampleCount {
                
                DispatchQueue.main.async {[weak self] in
                    self?.checkResults()
                }
            }
            
        } else {
            DispatchQueue.main.async {[weak self] in
                for rect in lineRects {
                    self?.highlightRecognizedText(rect, false)
                }
            }
        }
    }
    
    var boxLayer = [CAShapeLayer]()

    func removeHighligts() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }
    
    func drawHighlight(_ frame: CGRect, _ color: CGColor) {
        let layer = CAShapeLayer()
        layer.opacity = 0.65
        layer.borderColor = color
        layer.borderWidth = 3
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.frame = frame
        boxLayer.append(layer)
        previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
    }
    
    func activateHighlightClearingScheduler(){
        clearHighlightScheduler?.cancel()
        clearHighlightScheduler = nil
        clearHighlightScheduler = DispatchWorkItem {
             self.removeHighligts()
         }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: clearHighlightScheduler!)
    }
    
    func highlightRecognizedText(_ box:CGRect, _ valid:Bool){
        //activateHighlightClearingScheduler()

        //removeHighligts()
        let layer = self.previewView.videoPreviewLayer
        let rect = layer.layerRectConverted(fromMetadataOutputRect: box.applying(self.textHighlightTransform))
        self.drawHighlight(rect,valid ? style.validTextHighlightColor.cgColor: style.invalidTextHighlightColor.cgColor)
    }
    
    func isValidPincode(_ string:String) -> Bool{
        let passesLengthCriteria = string.count >= rules.minDigits && string.count <= rules.maxDigits
        let allowedChars = rules.allowedChars
        let allowedCharArr = Array(allowedChars)
        for ch in string {
            if !allowedCharArr.contains(ch){
                return false
            }
        }
        
        return passesLengthCriteria
         
    }
    
    func displayResult(_ pincode:String){
        clearHighlightScheduler?.cancel()
        let result = InstaScanResult()
        result.pincode = pincode
        result.configuration = configuration
        result.image = currentImage
        onPincodeReaded(result)
    }

    func onPincodeReaded(_ result:InstaScanResult){
        delegate?.pincodeReaded(result: result)
    }
    
    
    open func restartScan(){
        removeHighligts()
        recognizedPincodes = [:]
        startCapturing()
        self.setTorch(self.wasTorchActive)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupUiConstraints()
        setupCutoutTransform()
    }
    
    public func updateGuideText(_ guideText:String){
        overlayView.guideText = guideText
    }
    
    func validateApiKey() -> Bool{
        let deviceInfo = InstaScanDeviceInfo()
        _ = deviceInfo.bundleId
        _ = deviceInfo.appName
        _ = deviceInfo.appVersion
        return configuration.apiKey == "abcdefgh"
    }
    
    open func startScan(configuration:InstaScanConfiguration){
        self.configuration = configuration
        overlayView.lblGuide.isHidden = false
        overlayView.guideText = configuration.guideText
        overlayView.guideTextFont = configuration.style.guideTextFont
        overlayView.guideTextColor = configuration.style.guideTextColor
        overlayView.overlayColor  = configuration.style.overlayColor
        if validateApiKey() {
            setupCaptureSession()

        } else {
            updateGuideText("INVALID API KEY")
        }

    }

    func setupCutoutTransform(){
       cutOutTransform = bottomToTopTransform.concatenating(rotationTransform)
    }
   
 
    func setupCaptureSession(){
       
        captureSession = AVCaptureSession()
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        previewView.session = captureSession
        
        captureSessionQueue.sync {
            self.setupCamera()
        }
        
        DispatchQueue.main.async {[weak self] in
            self?.setupRoi()
        }
    }
    
    func setupRoi() {

        let desiredAspectRatio = settings.guideAreaAspectRatio
        let desiredWidthRatio = settings.guideAreaWidthRatio
        let maxPortraitWidth = 1.0
        let minWidth = min(desiredWidthRatio, maxPortraitWidth)
        let size = CGSize(width:minWidth , height: minWidth/desiredAspectRatio * (self.width / self.height))
        
        roi.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        roi.size = size
        
        let roiTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
        textHighlightTransform = roiTransform.concatenating(bottomToTopTransform).concatenating(rotationTransform)
        
        DispatchQueue.main.async { [weak self] in
            self?.updateOverlayFrame()
        }
    }
    
    func updateOverlayFrame(){
        let cutoutFrame = previewView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: roi.applying(cutOutTransform))
        overlayView.updateReferenceFrame(cutoutFrame)
    }
    
    func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            return
        }
        self.captureDevice = captureDevice
        
        var sessionPreset = AVCaptureSession.Preset.hd1280x720
        switch settings.resolution{
        case .hd4Kw3840h2160:
            sessionPreset = .hd4K3840x2160
        case .hdw1920h1080:
            sessionPreset = .hd1920x1080
        case .hdw1280h720:
            sessionPreset = .hd1280x720
        case .vgaw640h480:
            sessionPreset = .vga640x480
        }
        
        captureSession.sessionPreset = sessionPreset
        switch captureSession.sessionPreset {
        case .hd4K3840x2160:
            cameraAspectRatio = 3840 / 2160
        case .hd1920x1080:
            cameraAspectRatio = 1920 / 1080
        case .hd1280x720:
            cameraAspectRatio = 1280 / 720
        case .vga640x480:
            cameraAspectRatio = 640 / 480
        default:
            cameraAspectRatio = 1280 / 720
        }
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
                
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        } else {
            return
        }
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = settings.zoomFactor
            var focusRestriction = AVCaptureDevice.AutoFocusRangeRestriction.near
            switch settings.focusRestriction{
            case .near:
                focusRestriction = .near
            case .far:
                focusRestriction = .far
            case .none:
                focusRestriction = .none
            }
            captureDevice.autoFocusRangeRestriction = focusRestriction
            captureDevice.unlockForConfiguration()
        } catch {
            return
        }
        
        captureSession.startRunning()
    }
    
    func setupUiConstraints() {
        previewView.frame = self.bounds
    }
    
    public func setTorch(_ on:Bool){
        do {
            try captureDevice?.lockForConfiguration()
            captureDevice?.torchMode = !on ? .off : .on
            captureDevice?.unlockForConfiguration()
          
        } catch {
        }
    }
    
    public func getTorchStatus() -> Bool {
        let status = captureDevice?.isTorchActive ?? false
        return status
    }
    
    public func toggleTorch() {
        let torchActive = (captureDevice?.isTorchActive ?? false)
        setTorch(!torchActive)
    }

    func stopCapturing(){
        setTorch(false)
        
        guard let captureSession = self.captureSession else{
            return
        }
    
        captureSessionQueue.sync {
            captureSession.stopRunning()
        }
        
      
    }
    
    func startCapturing(){
        
        guard let captureSession = self.captureSession else{
            return
        }
        
        captureSessionQueue.sync {
            if !captureSession.isRunning{
                captureSession.startRunning()
            }
        }
    }
    
    open func stopScan(){
        stopCapturing()
        removeHighligts()
    }

}

extension InstaScanView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func orientation() -> UIImage.Orientation {
        let curDeviceOrientation = UIDevice.current.orientation
        var exifOrientation: UIImage.Orientation
        switch curDeviceOrientation {
            case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, Home button on the top
                exifOrientation = .left
            case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, Home button on the right
                exifOrientation = .upMirrored
            case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, Home button on the left
                exifOrientation = .down
            case UIDeviceOrientation.portrait:            // Device oriented vertically, Home button on the bottom
                exifOrientation = .up
            default:
                exifOrientation = .up
        }
        return exifOrientation
    }
    
    open func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            
            var recognitionLevel = VNRequestTextRecognitionLevel.accurate
            switch settings.algorithm{
            case .accurate:
                recognitionLevel = .accurate
            case .fast:
                recognitionLevel = .fast
            }
            request.recognitionLevel = recognitionLevel
            request.minimumTextHeight = Float(settings.minTextHeight)
            request.usesLanguageCorrection = settings.languageCorrection
            request.regionOfInterest = roi
            request.recognitionLanguages = [settings.lang]
            if #available(iOS 14.0, *) {
                request.revision = VNRecognizeTextRequestRevision2
            } else {
                // Fallback on earlier versions
                request.revision = VNRecognizeTextRequestRevision1

            }
            
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)

            let cropWidth = ciImage.extent.width * settings.guideAreaWidthRatio
            let cropHeight = cropWidth / settings.guideAreaAspectRatio
            let cropFrame = CGRect(x: (ciImage.extent.width - cropWidth) / 2.0, y: (ciImage.extent.height - cropHeight) / 2.0, width: cropWidth, height: cropHeight)
            let croppedImage = ciImage.cropped(to: cropFrame)
            
            let ciContext = CIContext()
            let cgImage = ciContext.createCGImage(croppedImage, from: croppedImage.extent)!
            
            currentImage = UIImage(cgImage: cgImage)
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
            }
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        previewView.frame = self.bounds
    }
}
