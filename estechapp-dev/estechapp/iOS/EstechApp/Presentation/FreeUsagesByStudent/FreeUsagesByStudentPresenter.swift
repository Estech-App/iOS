
import BDRCoreNetwork
import BDRModel
import Foundation

protocol FreeUsagesByStudentPresenter: AnyObject {
    var view: FreeUsagesByStudentView? { get set }
    func fetchMentorings()
    func createNewMentoring(date: Date, roomId: String, teacher: String)
    func cancelMentoring(mentoring: FreeUsages)
}

class FreeUsagesByStudentPresenterDefault: FreeUsagesByStudentPresenter {
    weak var view: FreeUsagesByStudentView?
    private let session: SessionManager
    private let networkRequest: BederrApiManager

    init(networkRequest: BederrApiManager = BederrApiManager.shared,
         session: SessionManager = SessionManager.shared) {
        self.networkRequest = networkRequest
        self.session = session
    }
    
    
    func fetchMentorings() {
        guard let userID = session.user?.id else {
            return
        }
        let endpoint = EstechAppEndpoints.freeUsagesByStudent(id: userID)
        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success(let dataRaw):
                    guard let raw = dataRaw as? Data,
                          let response = [FreeUsagesResponse].decodeJsonData(raw) else {
                        self?.view?.showLoading(isActive: false)
                        return
                    }
                    
                    let mappedMentorings = response.map { rawData in
                        
                        FreeUsages.init(
                            id: rawData.id,
                            roomId: rawData.room?.id ?? 0,
                            start: DateFormatter.sharedFormatter.dateFromString(rawData.start ?? "", withFormat: kServerDateFormatter) ?? Date(),
                            status: MentoringStatus(rawValue: rawData.status ?? "") ?? .pending,
                            name: rawData.room?.name ?? "",
                            description: rawData.room?.description ?? "",
                            mentoringRoom: rawData.room?.mentoringRoom ?? false,
                            studyRoom: rawData.room?.studyRoom ?? false,
                            timeTables: [],
                            user: .init(
                                id: userID,
                                email: self?.session.user?.email ?? "",
                                firstName: self?.session.user?.firstName ?? "",
                                lastName: self?.session.user?.lastName ?? ""
                            )
                        )
                    }
                    self?.view?.showMentorings(mappedMentorings.filter({ mentoring in
                        mentoring.status == .approved ||    mentoring.status == .pending
                    }))
                case .failure(let error):
                    self?.view?.showLoading(isActive: false)
                }
            }
    }
    
    
    func createNewMentoring(date: Date, roomId: String, teacher: String) {
        guard let room = Int(roomId) else {
           view?.showErrorMessage("Debes ingresar una aula válida")
            return
        }
        
        var dataDate = DateFormatter.sharedFormatter.stringFromDate(date, withFormat: kJSONDateFormatter)
        
        guard let userID = session.user?.id else {
            return
        }
        let endpoint = EstechAppEndpoints.createFreeUsage(
            [
                "start": dataDate,
                "end": dataDate,
                "room": ["id": roomId],
                "status": "PENDING",
                "user":
                    ["id" : userID]
            ]
        )
        
        view?.showLoading(isActive: true)

        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success:
                    self?.view?.createMentoringSuccess()
                    self?.view?.showLoading(isActive: false)
                case .failure(let error):
                    self?.view?.showErrorMessage(error.localizedDescription)
                    self?.view?.showLoading(isActive: false)
                }
            }
    }
    
    func cancelMentoring(mentoring: FreeUsages) {
        let endpoint = EstechAppEndpoints.updatePartialFreeUsage(id: mentoring.id,[
                                                                             "status": "DENIED"])
        view?.showLoading(isActive: true)

        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success:
                    self?.view?.cancelMentoringSuccess()
                    self?.view?.showLoading(isActive: false)
                case .failure(let error):
                    self?.view?.showErrorMessage(error.localizedDescription)
                    self?.view?.showLoading(isActive: false)
                }
            }
    }
   
}
