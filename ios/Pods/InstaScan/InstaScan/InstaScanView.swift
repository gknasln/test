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
    
    weak var overlayView: InstaScanCroppingView!
    weak var previewView:InstaScanPreviewView!
    var contentView:UIView!

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
        let pView = InstaScanPreviewView(frame: self.bounds)
        pView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        pView.backgroundColor = .black
        addSubview(pView)
        self.previewView = pView
        
        let cView = InstaScanCroppingView(frame: self.bounds)
        cView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        cView.backgroundColor = .clear
        addSubview(cView)
        self.overlayView = cView
  
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
        for (replaceKey,replaceValue) in rules.replaceMap {
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

    func onError(_ error:Error){
        delegate?.onError(error: error)
    }
    
    func onPincodeReaded(_ result:InstaScanResult){
        delegate?.pincodeReaded(result: result)
        recordScan {[weak self] success, error, response in
           if let err = error{
               self?.onError(err)
            }
        }
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
    
    func invokeApi(_ relativePath:String, _ resultHandler:@escaping ((_ success: Bool, _ error:Error?, _ responseData:[String:Any]?) -> Void)){
        
        func convertStringToDictionary(text: String) -> [String:Any]? {
           if let data = text.data(using: .utf8) {
               do {
                   let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                   return json
               } catch {
                  
               }
           }
           return nil
       }
        
        let deviceInfo = InstaScanDeviceInfo()
        let packageId = deviceInfo.bundleId
        let appName = deviceInfo.appName
        let appVersion = deviceInfo.appVersion
        let os = deviceInfo.systemName
        let osVersion = deviceInfo.systemVersion
        let uuid = deviceInfo.uuid
        let deviceModel = deviceInfo.deviceModel
        let brandName = deviceInfo.brandName
        
        let apiKey = configuration.apiKey ?? ""
        let url = URL(string: "https://test-instascan.peraplatform.com/api/" + relativePath)!
        var request = URLRequest(url: url)
        request.setValue(
            apiKey,
            forHTTPHeaderField: "X-kt-apikey"
        )
        
        request.setValue(
            "application/json;charset=utf-8",
            forHTTPHeaderField: "Content-Type"
        )
        
        let body = ["os": os, "osVersion":osVersion, "instaScanUUID" : uuid, "appVersion":appVersion, "appDeviceBrand":brandName, "appDeviceModel":deviceModel, "packageId":packageId, "appName":appName]
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error as? NSError{
                DispatchQueue.main.async {
                    resultHandler(false,error,nil)
                }
            } else if let data = data {
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                
                    let errorDescription =  "Unauthorized API key. Please verify your API key is valid."
                   
                    if statusCode == 401 {
                        let error = NSError(domain: "com.kaizen.InstaScan", code: 401,userInfo: [NSLocalizedDescriptionKey:errorDescription ,NSLocalizedFailureReasonErrorKey:errorDescription,NSLocalizedRecoverySuggestionErrorKey:errorDescription])
                        DispatchQueue.main.async {
                            resultHandler(false,error,nil)
                        }
                    } else if statusCode == 200 {
                        DispatchQueue.main.async {
                            resultHandler(true,nil,convertStringToDictionary(text: responseString))
                        }
                    }
                }
              
            }
        }
        
        task.resume()
        
    }
    
    func recordScan( _ resultHandler:@escaping ((_ success: Bool, _ error:Error?, _ data:[String:Any]?) -> Void)){
        invokeApi("Scan", resultHandler)
        
    }
    
    func validateApiKey( _ resultHandler:@escaping ((_ success: Bool, _ error:Error?, _ data:[String:Any]?) -> Void)){
        invokeApi("Initialize", resultHandler)
    }
    
    func fillConfiguration(_ response:[String:Any]){
        if let resolution = response["cameraResolution"] as? String{
            switch resolution {
            case "hdw1280h720":
                settings.resolution = .hdw1280h720
            case "hd4Kw3840h2160":
                settings.resolution = .hd4Kw3840h2160
            case "hdw1920h1080":
                settings.resolution = .hdw1920h1080
            case "vgaw640h480":
                settings.resolution = .vgaw640h480
            default:
                settings.resolution = .hdw1280h720
            }
        }
        
        if let sampleCount = response["sampleCount"] as? Int{
            settings.sampleCount = sampleCount
        }
      
        if let guideAreaAspectRatio = response["guideAreaAspectRatio"] as? Double{
            settings.guideAreaAspectRatio = guideAreaAspectRatio
        }
        
        if let guideAreaWidthRatio = response["guideAreaWidthRatio"] as? Double{
            settings.guideAreaWidthRatio = guideAreaWidthRatio
        }
        
        if let minTextHeight = response["minTextHeight"] as? Double{
            settings.minTextHeight = minTextHeight
        }
        
        if let zoomLevel = response["zoomLevel"] as? Double{
            settings.zoomFactor = zoomLevel
        }
        
        if let allowedChars = response["allowedChars"] as? String{
            rules.allowedChars = allowedChars
        }
        
        if let minDigits = response["minDigits"] as? Int{
            rules.minDigits = minDigits
        }
        
        if let maxDigits = response["maxDigits"] as? Int{
            rules.maxDigits = maxDigits
        }
        
        if let replaceMap = response["replaceMap"] as? [String:String]{
            rules.replaceMap = replaceMap
        }
        
        if let validTextHighlightColor = response["validTextHighlightColor"] as? String{
            style.validTextHighlightColor = UIColor(hexString: validTextHighlightColor)
        }
        
        if let invalidTextHighlightColor = response["invalidTextHighlightColor"] as? String{
            style.invalidTextHighlightColor = UIColor(hexString: invalidTextHighlightColor)
        }
        
        if let guideTextColor = response["guideTextColor"] as? String{
            style.guideTextColor = UIColor(hexString: guideTextColor)
        }
        
        if let overlayColor = response["overlayColor"] as? String{
            style.overlayColor = UIColor(hexString: overlayColor)
        }
        
        if let guideTextFontName = response["guideTextFontName"] as? String, let guideTextFontSize = response["guideTextFontSize"] as? Double{
            if let font = UIFont(name: guideTextFontName, size: guideTextFontSize){
                style.guideTextFont = font
            }
        }
        
        if let guideText = response["guideText"] as? String{
            configuration.guideText = guideText
        }
        
    }
    
    open func startScan(configuration:InstaScanConfiguration){
        self.configuration = configuration
        overlayView.lblGuide.isHidden = false
        overlayView.guideText = ""
        overlayView.guideTextFont = configuration.style.guideTextFont
        overlayView.guideTextColor = configuration.style.guideTextColor
        overlayView.overlayColor  = configuration.style.overlayColor
        
        validateApiKey {[weak self] success, error, response in
            if success{
                if let resp = response{
                    self?.fillConfiguration(resp)
                }
                self?.overlayView.guideText = self?.configuration.guideText
                self?.setupCaptureSession()
            } else if let err = error{
                self?.onError(err)
                self?.updateGuideText(err.localizedDescription)
            }
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
        overlayView.frame = self.bounds
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
        overlayView.frame = self.bounds
    }
}
