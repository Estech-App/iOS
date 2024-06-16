
import UIKit
import BDRModel

protocol MentoringStudentView: AnyObject  {
    
    func showMentorings(_ data: [Mentoring])
    func updateMentoringSuccess(_ mentoring: Mentoring)
    func showLoading(isActive: Bool)
    func showErrorMessage(_ msg: String)
}

class MentoringStudentTableViewCell: UITableViewCell {

    @IBOutlet weak var hourDate: UILabel!
    @IBOutlet weak var nameStudentLabel: UILabel!
    @IBOutlet weak var roomNameLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(_ data: Mentoring) {
        hourDate.text = DateFormatter.sharedFormatter.stringFromDate(
            data.date,
            withFormat: kHour24Formatter
        )
        nameStudentLabel.text = "\(data.student.fullName)"
        roomNameLabel.text = "Aula N# \(data.roomId)"
    }

}


class MentoringStudentViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let presenter = MentoringStudentPresenterDefault()
    var teacherMentoring: [Mentoring] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = SessionManager.shared.user?.firstName ?? ""
        presenter.view = self
        presenter.fetchMentorings()
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

extension MentoringStudentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teacherMentoring.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MentoringStudentTableViewCell", for: indexPath) as? MentoringStudentTableViewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = indexPath.row%2 == 0 ? .white : .lightGray
        cell.selectionStyle = .none
        cell.populate(teacherMentoring[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
}

extension MentoringStudentViewController: MentoringStudentView {
    func showMentorings(_ data: [Mentoring]) {
        self.teacherMentoring = data
    }
    
    func updateMentoringSuccess(_ mentoring: Mentoring) {
        
    }
    
    func showLoading(isActive: Bool) {
        isActive ? displayAnimatedActivityIndicatorView() : hideAnimatedActivityIndicatorView()
    }
    
    func showErrorMessage(_ msg: String) {
        self.showErrorMessage(message: msg)
    }
    
    
}
