
import Foundation
import BDRModel
import BDRCoreNetwork

protocol FichajePresenter: AnyObject {
    var view: FichajeView? { get set } 
    func fetchMentorings()
    func fetchHorarios()
    func fetchInfoUser()
    func fetchAddCheckin()
}

class FichajePresenterDefault: FichajePresenter {
    weak var view: FichajeView?
    private let networkRequest: BederrApiManager
    private let session: SessionManager
    private let kCheckInLasState = "kCheckInLasState"
    init(networkRequest: BederrApiManager = BederrApiManager.shared ,
         session: SessionManager = SessionManager.shared) {
        self.networkRequest = networkRequest
        self.session = session
    }
    
    func fetchMentorings() {
        guard let userID = session.user?.id else {
            return
        }
        let endpoint = EstechAppEndpoints.listMentoringsByTeacher(id: userID)
        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success(let dataRaw):
                    guard let raw = dataRaw as? Data,
                          let response = [MentoringTeacherResponse].decodeJsonData(raw) else {
                        self?.view?.showLoading(isActive: false)
                        self?.view?.showError(message: "Error al decodificar la respuesta del servidor")
                        return
                    }
                    
                    let mappedMentorings = response.map { rawData in
                        Mentoring(
                            id: rawData.id,
                            roomId: rawData.roomId ?? 0,
                            date: DateFormatter.sharedFormatter.dateFromString(rawData.start ?? "", withFormat: kServerDateFormatter) ?? Date(),
                            status: MentoringStatus(rawValue: rawData.status ?? "") ?? .pending,
                            student: .init(
                                id: rawData.student?.id ?? 0,
                                email: rawData.student?.email ?? "",
                                firstName: rawData.student?.name ?? "",
                                lastName: rawData.student?.lastName ?? ""
                            ), teacher: .init(
                                id: rawData.teacher?.id ?? 0,
                                email: rawData.teacher?.email ?? "",
                                firstName: rawData.teacher?.name ?? "",
                                lastName: rawData.teacher?.lastName ?? ""
                            )
                        )
                    }
                    self?.view?.showMentoringByTeacher(mappedMentorings)
                case .failure(let error):
                    self?.view?.showLoading(isActive: false)
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
    }
    
    func fetchHorarios() {
        
    }
    
    func fetchInfoUser() {
        view?.showName(name: session.user?.firstName ?? "")
        let lastState = UserDefaults.standard.bool(forKey: kCheckInLasState)
        view?.showStateCheckIn(isCheckIn: lastState)
    }
    
    func fetchAddCheckin() {
        let lastState = UserDefaults.standard.bool(forKey: kCheckInLasState)
        let endpoint = EstechAppEndpoints.addChekIn(
            [
                "checkIn": !lastState,
                "date": DateFormatter.sharedFormatter.stringFromDate(Date(), withFormat: kJSONDateFormatter),
                "user": ["id": session.user?.id ?? 0]
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
                          let response = CheckInResponse.decodeJsonData(raw) else {
                        self?.view?.showLoading(isActive: false)
                        self?.view?.showError(message: "Error al decodificar la respuesta del servidor")
                        return
                    }
                    
                    UserDefaults.standard.set(response.checkIn, forKey: self?.kCheckInLasState ?? "-")
                    self?.view?.showStateCheckIn(isCheckIn: response.checkIn)
                case .failure(let error):
                    self?.view?.showLoading(isActive: false)
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
    }
    
    
}
