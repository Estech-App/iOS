
import UIKit
import BDRModel
protocol RequestMentoringByStudentView: AnyObject {
    func showMentorings(_ data: [Mentoring])
    func createMentoringSuccess()
    func cancelMentoringSuccess()
    func showLoading(isActive: Bool)
    func showErrorMessage(_ msg: String)
}

protocol RequestMentoringDelegate: AnyObject {
    func didCancelMentoring(_ mentoring: Mentoring)
}
class RequestMentoringTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var cancelDidSelect: UIButton!
    var delegate: RequestMentoringDelegate?
    var mentoring: Mentoring?
    
    func populate(_ data: Mentoring) {
        mentoring = data
        hourLabel.text = DateFormatter.sharedFormatter.stringFromDate(
            data.date,
            withFormat: kHour24Formatter
        )
        nameLabel.text = data.teacher.fullName
        dateLabel.text = DateFormatter.sharedFormatter.stringFromDate(
            data.date,
            withFormat: prettyFormat
        ) + "    Aula: \(data.roomId)"
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        guard let mentoring else { return }
        delegate?.didCancelMentoring(mentoring)
    }
}

class RequestMentoringByStudentViewController: UIViewController {
    
    @IBOutlet weak var navBar: CustomNavBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var teacherId: Person? = nil
    var roomSelected: Room? = nil
    var dateSelect: Date? = nil
    var pickerRoom: UIPickerView? = nil
    var pickerTeacher: UIPickerView? = nil
    var auxtextField: UITextField?
    let presenter = RequestMentoringByStudentPresenterDefault()
    var teacherMentoring: [Mentoring] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        navBar.setTitle("Tutorías")
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
        
        
        let alert = UIAlertController(title: "Pedir tutoría", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        alert.addTextField {(textField) in
            self.auxtextField = textField
            textField.inputView = hourPicker
            textField.placeholder = "Hora de la tutoría"
        }
      
        let pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 260, height: 162))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        alert.view.addSubview(pickerView)
        pickerRoom = pickerView
        
        let pickerViewTeacher = UIPickerView(frame:
            CGRect(x: 0, y: 210, width: 260, height: 162))
        pickerViewTeacher.dataSource = self
        pickerViewTeacher.delegate = self
        pickerViewTeacher.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        alert.view.addSubview(pickerViewTeacher)
        pickerTeacher = pickerViewTeacher
        
        let alertActionOk = UIAlertAction(title: "Confirmar", style: .default) { action in
            guard let safeDate = self.dateSelect else {
                self.showErrorMessage(message: "Seleccione una fecha y hora")
                return
            }
            
            guard let safeRoom = self.roomSelected else {
                self.showErrorMessage(message: "Seleccione un aula")
                return
            }
            
            guard let safeTeacher = self.teacherId else {
                self.showErrorMessage(message: "Seleccione un profesor")
                return
            }
            
            
            self.presenter.createNewMentoring(
                date: safeDate,
                roomId: safeRoom.roomId.description,
                teacher: safeTeacher.id.description
            )
        }
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

extension RequestMentoringByStudentViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerRoom {
            return SessionManager.shared.rooms.count
        }
        
        if pickerView == pickerTeacher {
            return SessionManager.shared.teachers.count
        }
        
       return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerRoom {
            return "Aula #\(SessionManager.shared.rooms[row].id)"
        }
        
        if pickerView == pickerTeacher {
            return "\(SessionManager.shared.teachers[row].fullName)"
        }
        
        return "Aula #\(SessionManager.shared.rooms[row].id)"
      
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerRoom {
            roomSelected = SessionManager.shared.rooms[row]
        }
        
        if pickerView == pickerTeacher {
            teacherId = SessionManager.shared.teachers[row]
        }
       // roomSelected = SessionManager.shared.rooms[row]
    }
    
    
}


extension RequestMentoringByStudentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teacherMentoring.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestMentoringTableViewCell", for: indexPath) as? RequestMentoringTableViewCell else {
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

extension RequestMentoringByStudentViewController: RequestMentoringDelegate {
    func didCancelMentoring(_ mentoring: Mentoring) {
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

extension RequestMentoringByStudentViewController: RequestMentoringByStudentView {
    func cancelMentoringSuccess() {
        presenter.fetchMentorings()
    }
    
    func showMentorings(_ data: [Mentoring]) {
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
