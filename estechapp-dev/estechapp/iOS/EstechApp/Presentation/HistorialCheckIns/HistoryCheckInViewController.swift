
import UIKit
protocol HistoryCheckinView: AnyObject {
    func showError(message: String)
    func showLoading(isActive: Bool)
    
    func show(checkIn: [Fichaje])
}

class HistoryCheckInViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: CustomNavBar!
    
    var checkIn: [Fichaje] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private let presenter = HistoryCheckInPresenterDefault()
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        navBar.setTitle("Consulta Fichajes")
        navBar.setup(context: self)
        presenter.fetchHistory()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HistoryCheckInViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkIn.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CheckInTableViewCell", for: indexPath) as? CheckInTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.backgroundColor = indexPath.row%2 == 0 ? .white : .lightGray
        cell.populate(checkIn[indexPath.row])
        return cell
    }
    
    
}
extension HistoryCheckInViewController: HistoryCheckinView {
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
    
    func show(checkIn: [Fichaje]) {
        self.checkIn = checkIn
    }
    
    
}
