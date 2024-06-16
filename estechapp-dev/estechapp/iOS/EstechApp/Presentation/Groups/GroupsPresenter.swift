
import BDRCoreNetwork
import Foundation
protocol GroupsPresenter: AnyObject {
    var view: GroupsView? { get set }
    func fetchGroups()
}
class GroupsPresenterDefault: GroupsPresenter {
    weak var view: GroupsView?
    private let session: SessionManager
    private let networkRequest: BederrApiManager

    init(networkRequest: BederrApiManager = BederrApiManager.shared,
         session: SessionManager = SessionManager.shared) {
        self.networkRequest = networkRequest
        self.session = session
    }
    
    func fetchGroups() {
        guard let userID = session.user?.id else {
            return
        }
        let endpoint = EstechAppEndpoints.listGrouos(id: userID)
        view?.showLoading(isActive: true)

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
                        self?.view?.showErrorMessage("Error al decodificar la respuesta del servidor")
                        return
                    }
                    
                    let items = response.map { raw in
                        Group.init(
                            type: raw.name ?? "",
                            numberGroup: 0,
                            numberStudents: raw.users?.count ?? 0, users: []
                        )
                    }
                    self?.view?.showGroups(grouos: items)
                    self?.view?.showLoading(isActive: false)
                case .failure(let error):
                    self?.view?.showErrorMessage(error.localizedDescription)
                    self?.view?.showLoading(isActive: false)
                }
            }
    }
    
    
}
