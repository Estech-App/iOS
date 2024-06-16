

import UIKit
import BDRModel
protocol MentoringView: AnyObject  {
    
    func showMentorings(_ data: [Mentoring])
    func updateMentoringSuccess(_ mentoring: Mentoring)
    func showLoading(isActive: Bool)
    func showErrorMessage(_ msg: String)
}

protocol CellActionDelegate {
    func didCancel(mentoring: Mentoring)
    func didEditSelect(mentoring: Mentoring)
    func didAcceptSelect(mentoring: Mentoring)
}

class AsignedMentoringTableViewCell: UITableViewCell {
    @IBOutlet weak var dateMentoring: UILabel!
    @IBOutlet weak var nameStudent: UILabel!
    var delegate: CellActionDelegate?
    var mentoring: Mentoring?
    
    
    @IBAction func cancelDidSelect(_ sender: Any) {
        delegate?.didCancel(mentoring: mentoring!)
    }
    @IBAction func editDidSelect(_ sender: Any) {
        delegate?.didEditSelect(mentoring: mentoring!)
    }
    
    func setupData(_ mentoring: Mentoring) {
        self.mentoring = mentoring
        nameStudent.text = "Alumno \(mentoring.student.fullName)"
        dateMentoring.text = DateFormatter.sharedFormatter.stringFromDate(mentoring.date, withFormat: kFormatLocal)
    }
}

class PendingAcceptMentoringTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateMentoring: UILabel!
    @IBOutlet weak var nameStudent: UILabel!
    var delegate: CellActionDelegate?
    var mentoring: Mentoring?

    @IBAction func acceptDidSelect(_ sender: Any) {
        delegate?.didAcceptSelect(mentoring: mentoring!)
    }
    
    @IBAction func cancelDidSelect(_ sender: Any) {
        delegate?.didCancel(mentoring: mentoring!)
    }
    @IBAction func editDidSelect(_ sender: Any) {
        delegate?.didEditSelect(mentoring: mentoring!)
    }

    func setupData(_ mentoring: Mentoring) {
        self.mentoring = mentoring
        nameStudent.text = "Alumno \(mentoring.student.fullName)"
        dateMentoring.text = DateFormatter.sharedFormatter.stringFromDate(mentoring.date, withFormat: kFormatLocal)
    }
}

class MentoringViewController: UIViewController {

    @IBOutlet weak var navBar: CustomNavBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var roomSelect: Room? = nil
    var dateSelect: Date? = nil
    var auxtextField: UITextField?
    var presenter: MentoringPresenter = MentoringPresenterDefault()
    
    
    
    var mentorings: [Mentoring] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.hideBackButton()
        navBar.setTitle("Tutorías")
        presenter.view = self
       
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.fetchMentorings()
    }
}

extension MentoringViewController: CellActionDelegate {
    func didCancel(mentoring: Mentoring) {
        let alert = UIAlertController(title: "Eliminar tutoría", message: "¿Seguro que desea eliminar esta tutoría?", preferredStyle: .alert)
        
        let alertActionOk = UIAlertAction(title: "Confirmar", style: .default) { action in
            //actionBlock?()
            self.showSuccessMessage(message: "Tutoría eliminada con exito")
        }
        let alertActionCancel = UIAlertAction(title: "Cancelar", style: .destructive) { action in
            
        }
        alert.addAction(alertActionOk)
        alert.addAction(alertActionCancel)
        self.present(alert, animated: true)
    }
    
    func didEditSelect(mentoring: Mentoring) {
        let hourPicker = UIDatePicker()
        hourPicker.datePickerMode = .dateAndTime
        if #available(iOS 14, *) {
            hourPicker.preferredDatePickerStyle = .wheels
        }
        hourPicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)


        let alert = UIAlertController(title: "Modificar tutoría", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)

        let pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 260, height: 162))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        alert.view.addSubview(pickerView)
        
        
        alert.addTextField {(textField) in
            self.auxtextField = textField
            textField.inputView = hourPicker
            textField.placeholder = "Hora de la tutoría"
        }
        
        
    
      //  alert.view.addSubview(datePicker)
        let alertActionOk = UIAlertAction(title: "Confirmar", style: .default) { action in
            //actionBlock?()
            
            guard let safeDate = self.dateSelect else {
                self.showErrorMessage(message: "Seleccione una fecha y hora")
                return
            }
            
            guard let safeRoom = self.roomSelect else {
                self.showErrorMessage(message: "Seleccione un aula")
                return
            }
            
            
           
            self.presenter.updateMentoring(
                mentoring: mentoring,
                date: safeDate,
                roomId: safeRoom.roomId.description
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
         // fieldValueTextField.text = dateFormatter.string(from: sender.date)
     }
    
    func didAcceptSelect(mentoring: Mentoring) {
        
        let hourPicker = UIDatePicker()
        hourPicker.datePickerMode = .time
        if #available(iOS 14, *) {
            hourPicker.preferredDatePickerStyle = .wheels
        }
        hourPicker.addTarget(self, action: #selector(handleDateTimePicker(sender:)), for: .valueChanged)


        let alert = UIAlertController(title: "Asignar hora tutoría", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)

        let pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 260, height: 162))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        alert.view.addSubview(pickerView)
        
        alert.addTextField {(textField) in
            self.auxtextField = textField
            textField.inputView = hourPicker
            textField.placeholder = "Hora de la tutoría"
        }
        
      //  alert.view.addSubview(datePicker)
        let alertActionOk = UIAlertAction(title: "Confirmar", style: .default) { action in
            //actionBlock?()
            
            guard let safeDate = self.dateSelect else {
                self.showErrorMessage(message: "Seleccione una fecha y hora")
                return
            }
            
            guard let safeRoom = self.roomSelect else {
                self.showErrorMessage(message: "Seleccione un aula")
                return
            }
            
            self.presenter.updateMentoring(
                mentoring: mentoring,
                date: safeDate,
                roomId: safeRoom.roomId.description
            )
        }
        let alertActionCancel = UIAlertAction(title: "Cancelar", style: .destructive) { action in
            
        }
        alert.addAction(alertActionOk)
        alert.addAction(alertActionCancel)
        self.present(alert, animated: true)
    }
    
    @objc func handleDateTimePicker(sender: UIDatePicker) {
          let dateFormatter = DateFormatter()
            
          dateFormatter.dateFormat = "HH:mm"
            dateSelect = sender.date
        auxtextField?.text = dateFormatter.string(from: sender.date)
         // fieldValueTextField.text = dateFormatter.string(from: sender.date)
     }
}

extension MentoringViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SessionManager.shared.rooms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Aula #\(SessionManager.shared.rooms[row].id)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        roomSelect = SessionManager.shared.rooms[row]
    }
}

extension MentoringViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            mentorings.filter({$0.status == .approved}).count
        } else {
            mentorings.filter({$0.status != .approved}).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AsignedMentoringTableViewCell", for: indexPath) as? AsignedMentoringTableViewCell else {
                return   UITableViewCell()

            }
            cell.setupData(mentorings[indexPath.row])
            cell.delegate = self
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PendingAcceptMentoringTableViewCell", for: indexPath) as? PendingAcceptMentoringTableViewCell else {
                return   UITableViewCell()

            }
            cell.setupData(mentorings[indexPath.row])
            cell.delegate = self
            return cell
        default:
           return UITableViewCell()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 87
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewContainer = UIView()
        viewContainer.backgroundColor = UIColor.white
        let labelHeader = UILabel()
        
        labelHeader.textColor = UIColor.black
        labelHeader.font = .boldSystemFont(ofSize: 16)
        if section == 0 {
            labelHeader.text = "Mis tutorias asignadas"
        }
        if section == 1 {
            labelHeader.text =  "Tutorias pendientes de asignar"
        }
        viewContainer.addSubview(labelHeader)
        labelHeader.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        labelHeader.frame = viewContainer.frame
        
        return viewContainer
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }


    
}


extension MentoringViewController: MentoringView {
    func updateMentoringSuccess(_ mentoring: Mentoring) {
        showSuccessMessage(message: "Tutoría modificada con éxito!")
        presenter.fetchMentorings()
    }
    
    func showMentorings(_ data: [Mentoring]) {
        self.mentorings = data
    }
    
    func showLoading(isActive: Bool) {
        isActive ? displayAnimatedActivityIndicatorView() :  hideAnimatedActivityIndicatorView()
    }
    
    func showErrorMessage(_ msg: String) {
        self.showErrorMessage(message: msg)
    }
    
    
}
