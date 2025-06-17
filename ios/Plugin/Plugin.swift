// Plugin.swift
import Foundation
import Capacitor
import AuthenticationServices // <--- Crucial Import
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

            // Define the service identifier for the credential.
            // This MUST match your website's domain exactly, and be configured in your
            // app's Associated Domains (webcredentials:yourdomain.com) and AASA file.
            let serviceIdentifier = ASCServiceIdentifier(identifier: "app.holbornassets.com", type: .web)

            // Create the credential identity object with the username and password
            let credentialIdentity = ASPasswordCredentialIdentity(serviceIdentifier: serviceIdentifier, user: username, password: password)

            // Request the system to save this credential identity.
            ASCCredentialIdentityStore.shared.saveCredentialIdentities([credentialIdentity]) { (error) in
                if let error = error {
                    print("Capacitor SavePassword Plugin Error: Failed to save credential identity: \(error.localizedDescription)")
                    call.reject("Failed to save credential identity: \(error.localizedDescription)")
                } else {
                    print("Capacitor SavePassword Plugin: Credential identity save request sent successfully.")
                    call.resolve(["status": "prompt requested"])
                }
            }
        }
    }
}