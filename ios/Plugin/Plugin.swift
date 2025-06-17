import Foundation
import Capacitor
import UIKit
import AuthenticationServices

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

            // This must match your Associated Domain setup
            let serviceIdentifier = ASCredentialServiceIdentifier(
                identifier: "app.holbornassets.com",
                type: .domain
            )

            let credentialIdentity = ASPasswordCredentialIdentity(
                serviceIdentifier: serviceIdentifier,
                user: username,
                recordIdentifier: nil
            )

            ASCredentialIdentityStore.shared.saveCredentialIdentities([credentialIdentity]) { success, error in
                if let error = error {
                    print("❌ SavePassword error: \(error.localizedDescription)")
                    call.reject("Failed to save credential identity: \(error.localizedDescription)")
                } else {
                    print("✅ SavePassword: Save request sent successfully.")
                    call.resolve(["status": "prompt requested"])
                }
            }
        }
    }
}
