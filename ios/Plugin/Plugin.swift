import Foundation
import Capacitor
import UIKit

@objc(SavePassword)
public class SavePassword: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SavePassword"
    public let jsName = "SavePassword"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "promptDialog", returnType: CAPPluginReturnPromise)
    ]

    @objc func promptDialog(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let username = call.getString("username"),
                  let password = call.getString("password") else {
                call.reject("Missing username or password")
                return
            }

            let loginVC = UIViewController()
            loginVC.view.backgroundColor = .systemBackground

            let usernameField = UITextField(frame: CGRect(x: 20, y: 100, width: 280, height: 40))
            usernameField.placeholder = "Username"
            usernameField.text = username
            usernameField.textContentType = .username
            usernameField.autocapitalizationType = .none
            usernameField.borderStyle = .roundedRect

            let passwordField = UITextField(frame: CGRect(x: 20, y: 160, width: 280, height: 40))
            passwordField.placeholder = "Password"
            passwordField.text = password
            passwordField.textContentType = .password
            passwordField.isSecureTextEntry = true
            passwordField.borderStyle = .roundedRect

            loginVC.view.addSubview(usernameField)
            loginVC.view.addSubview(passwordField)

            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .formSheet

            self.bridge?.viewController?.present(nav, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    nav.dismiss(animated: true) {
                        call.resolve()
                    }
                }
            }
        }
    }
}
