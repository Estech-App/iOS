
import Foundation
import UIKit
import BDRModel
class GroupsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameGroupLabel: UILabel!
    @IBOutlet weak var imageGroups: UIImageView!
    @IBOutlet weak var numberGroupsLabel: UILabel!
    
    func setup(_ data: Group) {
        nameGroupLabel.text = data.name
        numberGroupsLabel.text = data.numberStudents.description
        imageGroups.image = data.image
    }
}

protocol GroupsView: AnyObject {
    func showGroups(grouos: [Group])
    func showLoading(isActive: Bool)
    func showErrorMessage(_ msg: String)
}
class GroupsViewController: UIViewController {
    
    @IBOutlet weak var navBar: CustomNavBar!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let presenter = GroupsPresenterDefault()
    var groups: [Group] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.hideBackButton()
        navBar.setTitle("Grupos")
        todayLabel.text = DateFormatter.sharedFormatter.stringFromDate(Date(), withFormat: prettyFormat)
        presenter.view = self
        presenter.fetchGroups()
    }
}

extension GroupsViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupsCollectionViewCell", for: indexPath) as? GroupsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setup(groups[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = groups[indexPath.row]
        guard let vc =  UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GroupsUserViewController") as? GroupsUserViewController else {
            return
        }
        vc.user = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension GroupsViewController: GroupsView {
    func showGroups(grouos: [Group]) {
        self.groups = grouos
    }
    
    func showLoading(isActive: Bool) {
        isActive ? displayAnimatedActivityIndicatorView() :  hideAnimatedActivityIndicatorView()
    }
    
    func showErrorMessage(_ msg: String) {
        self.showErrorMessage(message: msg)
    }
    
}
