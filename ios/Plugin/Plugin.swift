import Foundation
import Capacitor
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

            // Set up the credential service identifier (matches webcredentials domain)
            let serviceIdentifier = ASCredentialServiceIdentifier(
                identifier: "app.holbornassets.com",
                type: .domain
            )

            // Create a full credential with username and password
            let credential = ASPasswordCredential(
                user: username,
                password: password
            )

            // Use iOS' shared credential store
            let identityStore = ASCredentialIdentityStore.shared

            // Check if the user has enabled credential storage
            identityStore.getState { state in
                guard state.isEnabled else {
                    call.reject("Credential identity store is disabled on this device.")
                    return
                }

                // Create an identity based on the credential
                let credentialIdentity = ASPasswordCredentialIdentity(
                    serviceIdentifier: serviceIdentifier,
                    user: credential.user,
                    recordIdentifier: nil
                )

                identityStore.saveCredentialIdentities([credentialIdentity]) { success, error in
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
}
