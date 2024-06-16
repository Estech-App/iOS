
import Foundation
import BDRCoreNetwork
import BDRModel

protocol HistoryCheckInPresenter {
    var view: HistoryCheckinView? { get set }
    func fetchHistory()
}

class HistoryCheckInPresenterDefault: HistoryCheckInPresenter {
    weak var view: HistoryCheckinView?
    private let networkRequest: BederrApiManager
    private let session: SessionManager
    init(networkRequest: BederrApiManager = BederrApiManager.shared ,
         session: SessionManager = SessionManager.shared) {
        self.networkRequest = networkRequest
        self.session = session
    }
    
    func fetchHistory() {
        let endpoint = EstechAppEndpoints.listCheckins(id: session.user?.id ?? 0)
        
        networkRequest
            .setEndpoint(endpoint.path, .v5)
            .setHttpMethod(endpoint.method)
            .setParameter(endpoint.parameters)
            .subscribeAndReceivedData{ [weak self] (result) in
                switch result {
                case .success(let dataRaw):
                    guard let raw = dataRaw as? Data,
                          let response = [CheckInResponse].decodeJsonData(raw) else {
                        self?.view?.showLoading(isActive: false)
                        self?.view?.showError(message: "Error al decodificar la respuesta del servidor")
                        return
                    }
                    
                    let results = response.map({
                        item in
                        if let date = DateFormatter.sharedFormatter.dateFromString(item.date, withFormat: kServerDateFormatter) {
                            let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: date)
                            
                            
                            
                           return Fichaje(
                                day: calendarDate.day ?? 0,
                                month: date.month,
                                year: calendarDate.year ?? 0,
                                hour: DateFormatter.sharedFormatter.stringFromDate(date, withFormat: kHour24Formatter)
                            )
                        } else {
                            return Fichaje(day: 0, month: "-", year: 0, hour: "--:--")

                        }
                     
                    })
                    
                    self?.view?.show(checkIn: results)
                case .failure(let error):
                    self?.view?.showLoading(isActive: false)
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
    }
    
    
}
extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}
