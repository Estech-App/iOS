
import Foundation
import BDRCoreNetwork

protocol LoginPresenter: AnyObject {
    func login(email: String, password: String)
}

class LoginPresenterDefault: LoginPresenter {
    
    weak var view: LoginView?
    private let networkRequest: BederrApiManager
    private let session: SessionManager
    
    init(networkRequest: BederrApiManager = BederrApiManager.shared ,
         session: SessionManager = SessionManager.shared) {
        self.networkRequest = networkRequest
        self.session = session
    }
    
    
    func login(email: String, password: String) {
        self.view?.showLoading(isActive: true)
        let endpoint = EstechAppEndpoints.login(
            [
                "email": email,
                "password": password
            ]
        )
        
        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success(let dataRaw):
                    guard let raw = dataRaw as? Data,
                          let response = LoginResponse.decodeJsonData(raw) else {
                        self?.view?.showLoading(isActive: false)
                        self?.view?.showError(message: "Error al decodificar la respuesta del servidor")
                        return
                    }
                    self?.session.openSession(response)
                    
                    guard let role = self?.session.role else {
                        self?.view?.showLoading(isActive: false)
                        self?.view?.showError(message: "Error al decodificar la respuesta del servidor")
                        return
                    }
                    self?.getUserInfo(email: response.username, role: role)
                case .failure(let error):
                    self?.view?.showLoading(isActive: false)
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
    }
    
    
    
    private func getUserInfo(email: String, role: SessionRole) {
        let endpoint = EstechAppEndpoints.userInfo(
            [
                "email": email
            ]
        )
        
        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success(let dataRaw):
                    guard let raw = dataRaw as? Data,
                          let response = UserInfoResponse.decodeJsonData(raw) else {
                        self?.view?.showLoading(isActive: false)
                        self?.view?.showError(message: "Error al decodificar la respuesta del servidor")
                        return
                    }
                    self?.session.saveUserInfo(response)
                    
                    // Desicion de navegación
                    
                    self?.getRooms(role: role)

                case .failure(let error):
                    self?.view?.showLoading(isActive: false)
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
    }
    
    private func getRooms(role: SessionRole) {
        let endpoint = EstechAppEndpoints.listRooms
        
        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success(let dataRaw):
                    guard let raw = dataRaw as? Data,
                          let response = [GroupsResponse].decodeJsonData(raw) else {
                        self?.view?.showLoading(isActive: false)
                        self?.view?.showError(message: "Error al decodificar la respuesta del servidor")
                        return
                    }
                    let items: [Room] = response.first?.timeTables?.map { raw in
                        Room(id: raw.id ?? 0, roomId: raw.roomId ?? 0)
                    } ?? []
                    SessionManager.shared.rooms = items
                    self?.getTeachers(role: role)
                case .failure(let error):
                    self?.view?.showLoading(isActive: false)
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
    }
    
    private func getTeachers(role: SessionRole) {
        let endpoint = EstechAppEndpoints.listTeachers
        
        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success(let dataRaw):
                    guard let raw = dataRaw as? Data,
                          let response = [UserInfoResponse].decodeJsonData(raw) else {
                        self?.view?.showLoading(isActive: false)
                        self?.view?.showError(message: "Error al decodificar la respuesta del servidor")
                        return
                    }
                    let items: [Person] = response.map { dataRaw in
                            .init(
                                id: dataRaw.id,
                                email: dataRaw.email ?? "",
                                firstName: dataRaw.name ?? "",
                                lastName: dataRaw.lastname ?? ""
                            )
                    }
                    SessionManager.shared.teachers = items
                    self?.view?.showLoading(isActive: false)
                    switch role {
                    case .teacher:
                        self?.view?.navigateToTeacherFlow()
                    case .student:
                        self?.view?.navigateToStudentFlow()
                    }
                case .failure(let error):
                    self?.view?.showLoading(isActive: false)
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
    }
}
