
import Foundation
import Foundation
import BDRCoreNetwork
import BDRModel

protocol RequestMentoringByStudentPresenter: AnyObject {
    var view: RequestMentoringByStudentView? { get set }
    func fetchMentorings()
    func createNewMentoring(date: Date, roomId: String, teacher: String)
    func cancelMentoring(mentoring: Mentoring)
}

class RequestMentoringByStudentPresenterDefault: RequestMentoringByStudentPresenter {

    
    weak var view: RequestMentoringByStudentView?
    
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
        let endpoint = EstechAppEndpoints.listMentoringsByStudent(id: userID)
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
                        return
                    }
                    
                    let mappedMentorings = response.map { rawData in
                        Mentoring(
                            id: rawData.id,
                            roomId: rawData.roomId ?? 0,
                            date: DateFormatter.sharedFormatter.dateFromString(rawData.start ?? "", withFormat: kServerDateFormatter) ?? Date(),
                            status: MentoringStatus(rawValue: rawData.status ?? "") ?? .pending,
                            student: .init(
                                id: rawData.teacher?.id ?? 0,
                                email: rawData.teacher?.email ?? "",
                                firstName: rawData.teacher?.name ?? "",
                                lastName: rawData.teacher?.lastName ?? ""
                            ),
                            teacher: .init(
                                id: rawData.teacher?.id ?? 0,
                                email: rawData.teacher?.email ?? "",
                                firstName: rawData.teacher?.name ?? "",
                                lastName: rawData.teacher?.lastName ?? ""
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
        guard let room = Int(roomId), let teacher = Int(teacher) else {
           view?.showErrorMessage("Debes ingresar una aula válida")
            return
        }
        
        var dataDate = DateFormatter.sharedFormatter.stringFromDate(date, withFormat: kJSONDateFormatter)
        
        guard let userID = session.user?.id else {
            return
        }
        let endpoint = EstechAppEndpoints.createeMentoring(
            [
                "start": dataDate,
                "end": dataDate,
                "roomId": room,
                "status": "PENDING",
                "teacher":
                    ["id" : teacher],
                "student":
                    [ "id": userID]
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
    
    func cancelMentoring(mentoring: Mentoring) {
        let endpoint = EstechAppEndpoints.updatePartialMentoring(id: mentoring.id,[
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
