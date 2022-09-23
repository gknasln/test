import Foundation
import UIKit

open class InstaScanViewController: UIViewController, InstaScanDelegate {
    
    public var delegate:InstaScanDelegate?{
        didSet{
            
            scanView.delegate = delegate
            
        }
    }
    
    var configuration:InstaScanConfiguration = InstaScanConfiguration()
    var scanView:InstaScanView{
        return self.view as! InstaScanView
    }
    
    public convenience init(configuration:InstaScanConfiguration) {
        self.init()
        self.configuration = configuration
    }
    
    open override func loadView() {
        self.view = InstaScanView(frame: .zero)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scanView.delegate = delegate ?? self
        scanView.startScan(configuration: self.configuration)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanView.stopScan()
    }
    
    public func restartScan(){
        scanView.restartScan()
    }
    
    public func getTorchStatus() -> Bool{
        return scanView.getTorchStatus()
    }
    
    public func toggleTorch(){
        scanView.toggleTorch()
    }
    
    public func setTorch(_ on:Bool){
        scanView.setTorch(on)
    }
    
    open func pincodeReaded(result: InstaScanResult) {
        
    }
    
    open func onError(error: Error) {
        
    }
    
}
