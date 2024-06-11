

import Foundation
import UIKit
import BDRModel
protocol FreeUsagesByStudentView: AnyObject {
    func showMentorings(_ data: [FreeUsages])
    func createMentoringSuccess()
    func cancelMentoringSuccess()
    func showLoading(isActive: Bool)
    func showErrorMessage(_ msg: String)
}

protocol FreeUsagesByStudentDelegate: AnyObject {
    func didCancelMentoring(_ mentoring: FreeUsages)
}
class FreeUsagesByStudentTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var cancelDidSelect: UIButton!
    var delegate: FreeUsagesByStudentDelegate?
    var mentoring: FreeUsages?
    
    func populate(_ data: FreeUsages) {
        mentoring = data
        hourLabel.text = DateFormatter.sharedFormatter.stringFromDate(
            data.start,
            withFormat: kHour24Formatter
        )
        nameLabel.text = data.user.fullName
        dateLabel.text = DateFormatter.sharedFormatter.stringFromDate(
            data.start,
            withFormat: prettyFormat
        ) + "    Aula: \(data.roomId)"
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        guard let mentoring else { return }
        delegate?.didCancelMentoring(mentoring)
    }
}

class FreeUsagesByStudentViewController: UIViewController {
    
    @IBOutlet weak var navBar: CustomNavBar!
    @IBOutlet weak var tableView: UITableView!
    
    var teacherId: String? = nil
    var dateSelect: Date? = nil
    var auxtextField: UITextField?
    let presenter = FreeUsagesByStudentPresenterDefault()
    var teacherMentoring: [FreeUsages] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        navBar.setTitle("Práctica Libre")
        navBar.hideBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.fetchMentorings()
    }
    
    @IBAction func didRequestNew(_ sender: Any) {
        didEditSelect()
    }
    
    
    func didEditSelect() {
        let hourPicker = UIDatePicker()
        hourPicker.datePickerMode = .dateAndTime
        if #available(iOS 14, *) {
            hourPicker.preferredDatePickerStyle = .wheels
        }
        hourPicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        
        let alert = UIAlertController(title: "Pedir tutoría", message: "", preferredStyle: .alert)
        
        alert.addTextField {(textField) in
            self.auxtextField = textField
            textField.inputView = hourPicker
            textField.placeholder = "Hora de la tutoría"
        }
        alert.addTextField {(textField) in
            textField.placeholder = "Profesor"
        }
        alert.addTextField {(textField) in
            textField.placeholder = "Aula"
        }
        let alertActionOk = UIAlertAction(title: "Confirmar", style: .default) { action in
            guard let safeDate = self.dateSelect else {
                self.showErrorMessage(message: "Seleccione una fecha y hora")
                return
            }
            
            guard let teacher = alert.textFields?[1].text, !teacher.isEmpty else {
                self.showErrorMessage(message: "Ingrese el Profesor")
                return
            }
            guard let room = alert.textFields?[2].text, !room.isEmpty else {
                self.showErrorMessage(message: "Ingrese el Aula")
                return
            }
            
            
            self.presenter.createNewMentoring(date: safeDate, roomId: room, teacher: teacher)        }
        let alertActionCancel = UIAlertAction(title: "Cancelar", style: .destructive) { action in
            
        }
        alert.addAction(alertActionOk)
        alert.addAction(alertActionCancel)
        self.present(alert, animated: true)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        dateSelect = sender.date
        auxtextField?.text = dateFormatter.string(from: sender.date)
    }
    
}


extension FreeUsagesByStudentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teacherMentoring.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FreeUsagesByStudentTableViewCell", for: indexPath) as? FreeUsagesByStudentTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.populate(teacherMentoring[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension FreeUsagesByStudentViewController: FreeUsagesByStudentDelegate {
    func didCancelMentoring(_ mentoring: FreeUsages) {
        let alert = UIAlertController(title: "Eliminar tutoría", message: "¿Seguro que desea eliminar esta tutoría?", preferredStyle: .alert)
        
        let alertActionOk = UIAlertAction(title: "Confirmar", style: .default) { action in
            //actionBlock?()
            self.presenter.cancelMentoring(mentoring: mentoring)
        }
        let alertActionCancel = UIAlertAction(title: "Cancelar", style: .destructive) { action in
            
        }
        alert.addAction(alertActionOk)
        alert.addAction(alertActionCancel)
        self.present(alert, animated: true)
    }
}

extension FreeUsagesByStudentViewController: FreeUsagesByStudentView {
    func cancelMentoringSuccess() {
        presenter.fetchMentorings()
    }
    
    func showMentorings(_ data: [FreeUsages]) {
        self.teacherMentoring = data
    }
    
    func createMentoringSuccess() {
        presenter.fetchMentorings()
    }
    
    func showLoading(isActive: Bool) {
        isActive ? displayAnimatedActivityIndicatorView() : hideAnimatedActivityIndicatorView()
    }
    
    func showErrorMessage(_ msg: String) {
        self.showErrorMessage(message: msg)
    }
}
