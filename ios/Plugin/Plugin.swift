import Foundation
import Capacitor
import UIKit
import AuthenticationServices // Required for password APIs

@objc(SavePassword)
public class SavePassword: CAPPlugin, CAPBridgedPlugin, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    public let identifier = "SavePassword"
    public let jsName = "SavePassword"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "promptDialog", returnType: CAPPluginReturnPromise)
    ]

    private var currentCall: CAPPluginCall?

    @objc func promptDialog(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.currentCall = call

            guard let username = call.getString("username"),
                  let password = call.getString("password") else {
                call.reject("Missing username or password")
                return
            }

            // Create a password credential.
            let passwordCredential = ASPasswordCredential(user: username, password: password)

            // Create an authorization request for password management.
            let request = ASAuthorizationPasswordProvider().createRequest()

            // Use ASAuthorizationController to trigger the native prompt.
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()

            call.resolve(["status": "prompt requested, awaiting user interaction"])
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let passwordCredential = authorization.credential as? ASPasswordCredential {
            print("✅ Authorization completed for user: \(passwordCredential.user)")
            self.currentCall?.resolve(["status": "credential saved", "user": passwordCredential.user])
        } else {
            print("✅ Authorization completed with unknown credential type.")
            self.currentCall?.resolve(["status": "completed with unknown credential type"])
        }
        self.currentCall = nil
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Authorization error: \(error.localizedDescription)")
        self.currentCall?.reject("Authorization failed: \(error.localizedDescription)")
        self.currentCall = nil
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("No key window found for presenting ASAuthorizationController.")
        }
        return window
    }
}