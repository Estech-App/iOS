
import UIKit
import BDRUIComponents

protocol LoginView: AnyObject  {
    func navigateToStudentFlow()
    func navigateToTeacherFlow()
    
    func showError(message: String)
    func showLoading(isActive: Bool)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var Usuario: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    
    var presenter: LoginPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func IniciarSesion(_ sender: Any) {
       // self.navigateToTabBarController(withIdentifier: "StudentController", token: "")
        guard let email = Usuario.text, let password = Contraseña.text, !email.isEmpty, !password.isEmpty else {
            //showAlert(message: "Por favor, introduce tu correo y contraseña")
            showErrorMessage(message: "Por favor, introduce tu correo y contraseña")
            return
        }
        presenter?.login(email: email, password: password)
    }
    
    func navigateToTabBarController(withIdentifier identifier: String, token: String) {
        // Guardar el token en UserDefaults
        UserDefaults.standard.set(token, forKey: "Token")
        
        // Navegar al tab bar controller adecuado
        if let tabBarController = storyboard?.instantiateViewController(withIdentifier: identifier) {
            tabBarController.modalPresentationStyle = .fullScreen
            present(tabBarController, animated: true, completion: nil)
        }
    }

}

extension ViewController: LoginView {
    func navigateToStudentFlow() {
        self.navigateToTabBarController(withIdentifier: "StudentController", token: "")
    }
    
    func navigateToTeacherFlow() {
        self.navigateToTabBarController(withIdentifier: "TeacherController", token: "")
    }
    
    func showError(message: String) {
        showErrorMessage(message: message)
    }
    
    func showLoading(isActive: Bool) {
        if isActive {
            displayAnimatedActivityIndicatorView()
        } else {
            hideAnimatedActivityIndicatorView()
        }
    }
    
    
}
