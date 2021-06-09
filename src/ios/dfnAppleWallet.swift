import Foundation
import PassKit

@objc(DFNAppleWallet) class DFNAppleWallet : CDVPlugin, PKAddPassesViewControllerDelegate {
      @objc(addPass:)
      func addPass(command: CDVInvokedUrlCommand) {

            let url = URL(string: command.argument(at: 0) as! String)!
            let reference = command.argument(at: 1) as! String?
            let iban = command.argument(at: 2) as! String?
            let account = command.argument(at: 3) as! String?

            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let json = [
                "reference": reference,
                "iban": iban,
                "account": account
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])

            let task : URLSessionDataTask = session.uploadTask(with: request, from: jsonData) { data, response, error in
                if error != nil {
                    print("Some error occurred!")
                    print(error!)
                } else {
                    let pass = try? PKPass(data: data!, error: nil)
                    let pkvc: PKAddPassesViewController! = PKAddPassesViewController(pass: pass!)
                    pkvc.delegate = self
                    self.viewController.present(pkvc, animated: true, completion: nil)
                }
            }
            task.resume()
      }
}
