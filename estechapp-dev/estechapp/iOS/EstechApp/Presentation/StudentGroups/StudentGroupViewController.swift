
import UIKit
import BDRModel
protocol StudentGroupView: AnyObject {
    func showGroups(_ data: [Group])
    func showLoading(isActive: Bool)
    func showErrorMessage(_ msg: String)
}

class OneGroupCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
}

class TwoGroupCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!

}
class StudentGroupViewController: UIViewController {

    @IBOutlet weak var navBar: CustomNavBar!
    @IBOutlet weak var firstSearchBar: UISearchBar!
    @IBOutlet weak var secondSearchBar: UISearchBar!
    @IBOutlet weak var secondtableView: UITableView!
    @IBOutlet weak var onetableView: UITableView!
    
    private let presenter: StudentGroupPresenter = StudentGroupPresenterDefault()
    
    var groups: [Group] = [] {
        didSet {
            onetableView.reloadData()
            secondtableView.reloadData()
        }
    }
    
    var auxAllGroups: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.fetchGroups()
        navBar.hideBackButton()
        navBar.setTitle("DAM 1º")
    }
}

extension StudentGroupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == onetableView {
            return groups.first?.users.filter({ $0.role == .student}).count ?? 0
        }
        if tableView == secondtableView {
            return groups.first?.users.filter({ $0.role == .teacher}).count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == onetableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OneGroupCell", for: indexPath) as? OneGroupCell else {
                return UITableViewCell()
            }
            cell.nameLabel.text = "\(indexPath.row + 1). " + (groups.first?.users.filter({ $0.role == .student})[indexPath.row].fullName ?? "")
            cell.selectionStyle = .none
            return cell
        }
        if tableView == secondtableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TwoGroupCell", for: indexPath) as? TwoGroupCell else {
                return UITableViewCell()
            }
            cell.nameLabel.text = "\(indexPath.row + 1). " + (groups.first?.users.filter({ $0.role == .teacher})[indexPath.row].fullName ?? "")
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


extension StudentGroupViewController: StudentGroupView {
    func showGroups(_ data: [Group]) {
        self.groups = data
        self.auxAllGroups = data
    }
    
    func showLoading(isActive: Bool) {
        isActive ? displayAnimatedActivityIndicatorView() : hideAnimatedActivityIndicatorView()
    }
    
    func showErrorMessage(_ msg: String) {
        self.showErrorMessage(message: msg)
    }
    
}
