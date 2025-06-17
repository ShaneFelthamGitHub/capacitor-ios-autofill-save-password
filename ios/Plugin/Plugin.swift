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

        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Login", for: .normal)
        submitButton.frame = CGRect(x: 20, y: 220, width: 280, height: 44)
        submitButton.addTarget(nil, action: #selector(self.submitTapped(_:)), for: .touchUpInside)

        loginVC.view.addSubview(usernameField)
        loginVC.view.addSubview(passwordField)
        loginVC.view.addSubview(submitButton)

        usernameField.becomeFirstResponder()

        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .formSheet

        // Store call and fields for access in button action
        objc_setAssociatedObject(submitButton, &AssociatedKeys.callKey, call, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(submitButton, &AssociatedKeys.navKey, nav, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        self.bridge?.viewController?.present(nav, animated: true)
    }
}

@objc func submitTapped(_ sender: UIButton) {
    if let call = objc_getAssociatedObject(sender, &AssociatedKeys.callKey) as? CAPPluginCall,
       let nav = objc_getAssociatedObject(sender, &AssociatedKeys.navKey) as? UINavigationController {
        nav.dismiss(animated: true) {
            call.resolve()
        }
    }
}

private struct AssociatedKeys {
    static var callKey = "CAPPluginCallKey"
    static var navKey = "UINavigationControllerKey"
}
