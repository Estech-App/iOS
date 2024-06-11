

import UIKit

class CheckInTableViewCell: UITableViewCell {

    @IBOutlet weak var hour: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func populate(_ fichaje: Fichaje) {
        hour.text = fichaje.hour
        year.text = fichaje.year.description
        month.text = fichaje.month
        day.text = fichaje.day.description
    }
}
