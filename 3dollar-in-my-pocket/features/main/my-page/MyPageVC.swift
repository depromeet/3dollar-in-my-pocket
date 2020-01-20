import UIKit

class MyPageVC: BaseVC {
    
    private lazy var myPageView = MyPageView(frame: self.view.frame)
    
    
    static func instance() -> MyPageVC {
        return MyPageVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = myPageView
        setupRegisterCollectionView()
        setUpReviewTableView()
    }
    
    override func bindViewModel() {
        myPageView.modifyBtn.rx.tap.bind { [weak self] in
            if let currentName = self?.myPageView.nicknameLabel.text {
                self?.navigationController?.pushViewController(RenameVC.instance(currentName: currentName), animated: true)
            }
        }.disposed(by: disposeBag)
        
        myPageView.registerTotalBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.pushViewController(RegisteredVC.instance(), animated: true)
        }.disposed(by: disposeBag)
        
        myPageView.reviewTotalBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.pushViewController(MyReviewVC.instance(), animated: true)
        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMyInfo()
    }
    
    private func setupRegisterCollectionView() {
        myPageView.registerCollectionView.delegate = self
        myPageView.registerCollectionView.dataSource = self
        myPageView.registerCollectionView.register(RegisterCell.self, forCellWithReuseIdentifier: RegisterCell.registerId)
    }
    
    private func setUpReviewTableView() {
        myPageView.reviewTableView.delegate = self
        myPageView.reviewTableView.dataSource = self
        myPageView.reviewTableView.register(MyPageReviewCell.self, forCellReuseIdentifier: MyPageReviewCell.registerId)
    }
    
    private func getMyInfo() {
        UserService.getUserInfo { [weak self] (response) in
            switch response.result {
            case .success(let user):
                self?.myPageView.nicknameLabel.text = user.nickname
            case .failure(let error):
                if let vc = self {
                    AlertUtils.show(controller: vc, title: "error user info", message: error.localizedDescription)
                }
            }
        }
    }
}

extension MyPageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegisterCell.registerId, for: indexPath) as? RegisterCell else {
            return BaseCollectionViewCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 172, height: 172)
    }
}

extension MyPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPageReviewCell.registerId, for: indexPath) as? MyPageReviewCell else {
            return BaseTableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.setTopRadius()
            cell.setEvenBg()
        case 1:
            cell.setOddBg()
        case 2:
            cell.setBottomRadius()
            cell.setEvenBg()
        default:
            break
        }
        
        return cell
    }
    
    
}
