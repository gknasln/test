
import UIKit
import AVFoundation

class InstaScanPreviewView: UIView {
	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
		guard let layer = layer as? AVCaptureVideoPreviewLayer else {
			fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
		}
		
		return layer
	}
	
	var session: AVCaptureSession? {
		get {
			return videoPreviewLayer.session
		}
		set {
			videoPreviewLayer.session = newValue
            videoPreviewLayer.videoGravity = .resizeAspectFill
		}
	}
	
	
    override class var layerClass: AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
}
