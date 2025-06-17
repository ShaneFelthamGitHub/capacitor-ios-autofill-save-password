import Foundation
import Capacitor
import UIKit

@objc(SavePassword)
public class SavePassword: CAPPlugin {
    @objc func promptDialog(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let loginVC = UIViewController()
            loginVC.view.backgroundColor = .systemBackground

            let usernameField = UITextField(frame: CGRect(x: 20, y: 100, width: 280, height: 40))
            usernameField.placeholder = "Email"
            usernameField.text = call.getString("username") ?? ""
            usernameField.textContentType = .username
            usernameField.autocapitalizationType = .none
            usernameField.autocorrectionType = .no
            usernameField.borderStyle = .roundedRect

            let passwordField = UITextField(frame: CGRect(x: 20, y: 160, width: 280, height: 40))
            passwordField.placeholder = "Password"
            passwordField.text = call.getString("password") ?? ""
            passwordField.textContentType = .password
            passwordField.isSecureTextEntry = true
            passwordField.borderStyle = .roundedRect

            loginVC.view.addSubview(usernameField)
            loginVC.view.addSubview(passwordField)
            usernameField.becomeFirstResponder()

            // Let iOS show the iCloud prompt after delay
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .formSheet

            self.bridge?.viewController?.present(nav, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    nav.dismiss(animated: true) {
                        call.resolve()
                    }
                }
            }
        }
    }
}
