// Plugin.swift
import Foundation
import Capacitor
import AuthenticationServices // <--- New and Crucial Import
import UIKit // Keep UIKit if other parts of your plugin use it, but for promptDialog it's no longer strictly needed.

@objc(SavePassword)
public class SavePassword: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SavePassword"
    public let jsName = "SavePassword"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "promptDialog", returnType: CAPPluginReturnPromise)
    ]

    @objc func promptDialog(_ call: CAPPluginCall) {
        // Ensure this runs on the main thread, as AuthenticationServices APIs might have UI implications
        DispatchQueue.main.async {
            guard let username = call.getString("username"),
                  let password = call.getString("password") else {
                call.reject("Missing username or password")
                return
            }

            // Define the service identifier for the credential.
            // This MUST match your website's domain exactly, and be configured in your
            // app's Associated Domains (webcredentials:yourdomain.com) and AASA file.
            // This tells iOS that the credentials belong to this specific website/service.
            let serviceIdentifier = ASCServiceIdentifier(identifier: "app.holbornassets.com", type: .web)

            // Create the credential identity object with the username and password
            let credentialIdentity = ASPasswordCredentialIdentity(serviceIdentifier: serviceIdentifier, user: username, password: password)

            // Request the system to save this credential identity.
            // This is the key API call that triggers the native "Save Password" prompt.
            // The system will decide if and when to show the prompt based on various factors,
            // including whether the user already has saved credentials, if the password has changed,
            // and most importantly, if the app is correctly associated with the domain.
            ASCCredentialIdentityStore.shared.saveCredentialIdentities([credentialIdentity]) { (error) in
                if let error = error {
                    // Log specific errors from AuthenticationServices for debugging
                    print("Capacitor SavePassword Plugin Error: Failed to save credential identity: \(error.localizedDescription)")
                    call.reject("Failed to save credential identity: \(error.localizedDescription)")
                } else {
                    print("Capacitor SavePassword Plugin: Credential identity save request sent successfully.")
                    // Resolve the call, indicating the request was successfully made to the OS.
                    // The actual appearance of the prompt depends entirely on iOS.
                    call.resolve(["status": "prompt requested"])
                }
            }
        }
    }
}
