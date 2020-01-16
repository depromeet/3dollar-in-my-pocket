import UIKit
import GoogleMaps

protocol WritingDelegate: class {
    func onWriteSuccess(storeId: Int)
}

class WritingVC: BaseVC {
    
    weak var deleagte: WritingDelegate?
    var viewModel = WritingViewModel()
    
    private lazy var writingView = WritingView(frame: self.view.frame)
    
    private let imagePicker = UIImagePickerController()
    
    private var imageList: [UIImage] = []
    
    private var selectedImageIndex = 0
    
    private var menuList: [Menu] = []
    
    var locationManager = CLLocationManager()
    
    
    static func instance() -> WritingVC {
        let controller = WritingVC(nibName: nil, bundle: nil)
        controller.modalPresentationStyle = .fullScreen
        
        return controller
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = writingView
        setupImageCollectionView()
        setupMenuTableView()
        setupKeyboardEvent()
        setupLocationManager()
        setupGoogleMap()
    }
    
    override func bindViewModel() {
        writingView.backBtn.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        writingView.bungeoppangBtn.rx.tap.bind { [weak self] in
            self?.writingView.tapCategoryBtn(index: 0)
            self?.viewModel.btnEnable.onNext(())
        }.disposed(by: disposeBag)
        
        writingView.takoyakiBtn.rx.tap.bind { [weak self] in
            self?.writingView.tapCategoryBtn(index: 1)
            self?.viewModel.btnEnable.onNext(())
        }.disposed(by: disposeBag)
        
        writingView.gyeranppangBtn.rx.tap.bind { [weak self] in
            self?.writingView.tapCategoryBtn(index: 2)
            self?.viewModel.btnEnable.onNext(())
        }.disposed(by: disposeBag)
        
        writingView.hotteokBtn.rx.tap.bind { [weak self] in
            self?.writingView.tapCategoryBtn(index: 3)
            self?.viewModel.btnEnable.onNext(())
        }.disposed(by: disposeBag)
        
        writingView.nameField.rx.text.bind { [weak self] (inputText) in
            self?.writingView.setFieldEmptyMode(isEmpty: inputText!.isEmpty)
            self?.viewModel.btnEnable.onNext(())
        }.disposed(by: disposeBag)
        
        writingView.myLocationBtn.rx.tap.bind {
            self.locationManager.requestLocation()
        }.disposed(by: disposeBag)
        
        writingView.registerBtn.rx.tap.bind { [weak self] in
            if let category = self?.writingView.getCategory(),
                let storeName = self?.writingView.nameField.text!,
                let images = self?.imageList,
                let latitude = self?.writingView.mapView.camera.target.latitude,
                let longitude = self?.writingView.mapView.camera.target.longitude,
                let menus = self?.menuList {
                let store = Store.init(category: category, latitude: latitude, longitude: longitude, storeName: storeName, menus: menus)
                
                StoreService.saveStore(store: store, images: images) { [weak self] (response) in
                    switch response.result {
                    case .success(let store):
                        self?.dismiss(animated: true, completion: nil)
                        self?.deleagte?.onWriteSuccess(storeId: store.id)
                    case .failure(let error):
                        if let vc = self {
                            AlertUtils.show(controller: vc, title: "Save store error", message: error.localizedDescription)
                        }
                    }
                }
            } else {
                AlertUtils.show(controller: self, message: "올바른 내용을 작성해주세요.")
            }
        }.disposed(by: disposeBag)
        
        viewModel.btnEnable
            .map { [weak self] (_) in
                if let vc = self {
                    return !vc.writingView.nameField.text!.isEmpty && vc.writingView.getCategory() != nil
                } else {
                    return false
                }
        }
        .bind(to: writingView.registerBtn.rx.isEnabled)
        .disposed(by: disposeBag)
    }
    
    private func isValid(category: StoreCategory?, storeName: String) -> Bool {
        return category != nil && !storeName.isEmpty
    }
    
    private func setupImageCollectionView() {
        imagePicker.delegate = self
        writingView.imageCollection.dataSource = self
        writingView.imageCollection.delegate = self
        writingView.imageCollection.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.registerId)
    }
    
    private func setupMenuTableView() {
        writingView.menuTableView.delegate = self
        writingView.menuTableView.dataSource = self
        writingView.menuTableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.registerId)
    }
    
    private func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupGoogleMap() {
        writingView.mapView.isMyLocationEnabled = true
    }
    
    @objc func onShowKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.writingView.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 50
        self.writingView.scrollView.contentInset = contentInset
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.writingView.scrollView.contentInset = contentInset
    }
}

extension WritingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.registerId, for: indexPath) as? ImageCell else {
            return BaseCollectionViewCell()
        }
        
        if indexPath.row < self.imageList.count {
            cell.setImage(image: self.imageList[indexPath.row])
        } else {
            cell.setImage(image: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 104, height: 104)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageIndex = indexPath.row
        AlertUtils.showImagePicker(controller: self, picker: self.imagePicker)
    }
}

extension WritingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if selectedImageIndex == self.imageList.count {
                self.imageList.append(image)
            } else {
                self.imageList[selectedImageIndex] = image
            }
        }
        self.writingView.imageCollection.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

extension WritingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.registerId, for: indexPath) as? MenuCell else {
            return BaseTableViewCell()
        }
        
        cell.nameField.rx.controlEvent(.editingDidEnd).bind { [weak self] in
            let name = cell.nameField.text!
            
            if !name.isEmpty {
                let menu = Menu.init(name: name)
                
                if indexPath.row == self?.menuList.count {
                    self?.menuList.append(menu)
                    self?.writingView.menuTableView.reloadData()
                    self?.view.layoutIfNeeded()
                } else {
                    self?.menuList[indexPath.row].name = name
                }
            }
        }.disposed(by: disposeBag)
        
        cell.descField.rx.controlEvent(.editingChanged).bind { [weak self] in
            let name = cell.nameField.text!
            let desc = cell.descField.text!
            
            if !name.isEmpty && !desc.isEmpty {
                let menu = Menu.init(name: name, price: desc)
                
                if let _ = self?.menuList[indexPath.row] {
                    self?.menuList[indexPath.row] = menu
                }
            }
            
        }.disposed(by: disposeBag)
        return cell
    }
}

extension WritingVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, zoom: 15)
        
        self.writingView.mapView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
    }
}

