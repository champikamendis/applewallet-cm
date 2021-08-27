import Foundation
import PassKit

@objc(DFNAppleWallet) class DFNAppleWallet : CDVPlugin, PKAddPassesViewControllerDelegate {
    
    func successCallback(callbackId: String, message: String) {
        self.commandDelegate!.send(
            CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: message
            ),
            callbackId: callbackId
        )
    }
    
    func errorCallback(callbackId: String, message: String) {
        self.commandDelegate!.send(
            CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: message
            ),
            callbackId: callbackId
        )
    }
    
    @objc(addPass:)
    func addPass(command: CDVInvokedUrlCommand) {
        let url = URL(string: command.argument(at: 0) as! String)!
        let jsonString = command.argument(at: 1) as! String?
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = jsonString!.data(using: String.Encoding.utf8)
        
        let task : URLSessionDataTask = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if error != nil {
                self.errorCallback(callbackId: command.callbackId, message: "PKPASS_NETWORK_ERROR")
            } else {
                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                          self.errorCallback(callbackId: command.callbackId, message: "PKPASS_SERVER_ERROR")
                          
                          return
                      }
                
                do {
                    let pass = try PKPass(data: data!, error: nil)
                    let passLibrary = try PKPassLibrary()
                    let contains = passLibrary.containsPass(pass)
                    
                    if (contains) {
                        self.errorCallback(callbackId: command.callbackId, message: "PKPASS_ALREADY_ADDED")
                        
                        return
                    }
                    
                    let pkvc = try PKAddPassesViewController(pass: pass)
                    
                    pkvc.delegate = self
                    
                    func onCompletion() {
                        self.successCallback(callbackId: command.callbackId, message: "PKPASS_GENERATED")
                    }
                    
                    self.viewController.present(pkvc, animated: true, completion: onCompletion)
                } catch {
                    self.errorCallback(callbackId: command.callbackId, message: "PKPASS_ERROR")
                }
            }
        }
        
        task.resume()
    }
    
    
    
    @objc(contains:)
    func contains(command: CDVInvokedUrlCommand) {
        let url = URL(string: command.argument(at: 0) as! String)!
        let jsonString = command.argument(at: 1) as! String?
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = jsonString!.data(using: String.Encoding.utf8)
        
        let task : URLSessionDataTask = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if error != nil {
                self.errorCallback(callbackId: command.callbackId, message: "PKPASS_NETWORK_ERROR")
            } else {
                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                          self.errorCallback(callbackId: command.callbackId, message: "PKPASS_SERVER_ERROR")
                          
                          return
                      }
                
                do {
                    let pass = try PKPass(data: data!, error: nil)
                    let passLibrary = try PKPassLibrary()
                    
                    let contains = try passLibrary.containsPass(pass)
                    
                    self.commandDelegate!.send(
                        CDVPluginResult(
                            status: CDVCommandStatus_OK,
                            messageAs: contains
                        ),
                        callbackId: command.callbackId
                    )
                } catch {
                    self.errorCallback(callbackId: command.callbackId, message: "PKPASS_ERROR")
                }
            }
        }
        
        task.resume()
    }
}
