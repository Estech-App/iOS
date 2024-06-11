

import Foundation
import UIKit
class LoginBuilder {
    static func buildView() -> UIViewController? {
        guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as? ViewController else {
            return nil
        }
        let presenter = LoginPresenterDefault()
        presenter.view = vc
        vc.presenter = presenter
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}
