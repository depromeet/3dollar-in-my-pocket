import RxSwift
import RxCocoa
import Photos

class RegisterPhotoViewModel: BaseViewModel{
  
  let input = Input()
  let output = Output()
  let storeService: StoreServiceProtocol
  var assets: PHFetchResult<PHAsset>!
  let storeId: Int
  let pagingSize = 100
  var lastIndex = 0
  var selectedIndex: [Int] = []
  var selectedPhoto: [UIImage] = []
  
  struct Input {
    let selectPhoto = PublishSubject<(Int, UIImage)>()
    let photoPrefetchIndex = PublishSubject<Int>()
    let tapRegisterButton = PublishSubject<Void>()
  }
  
  struct Output {
    let registerButtonIsEnable = PublishRelay<Bool>()
    let registerButtonText = PublishRelay<String>()
    let photos = PublishRelay<[PHAsset]>()
    let dismiss = PublishRelay<Void>()
    let showLoading = PublishRelay<Bool>()
  }
  
  init(storeId: Int, storeService: StoreServiceProtocol) {
    self.storeId = storeId
    self.storeService = storeService
    super.init()
    
    self.input.photoPrefetchIndex
      .filter { $0 >= self.lastIndex - 1 }
      .map { _ in Void() }
      .bind(onNext: self.fetchNextPhotos)
      .disposed(by: disposeBag)
    
    self.input.selectPhoto
      .bind(onNext: self.selectPhoto)
      .disposed(by: disposeBag)
    
    self.input.tapRegisterButton
      .map { (self.storeId, self.selectedPhoto) }
      .bind(onNext: self.savePhotos)
      .disposed(by: disposeBag)
  }
  
  func requestPhotosPermission() {
    let photoAuthorizationStatusStatus = PHPhotoLibrary.authorizationStatus()
    
    switch photoAuthorizationStatusStatus {
    case .authorized:
      self.requestPhotos()
    case .denied:
      print("Photo Authorization status is denied.")
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization() { status in
        switch status {
        case .authorized:
          self.requestPhotos()
        case .denied:
          print("User denied.")
        default:
          break
        }
      }
    case .restricted:
      print("Photo Authorization status is restricted.")
    default:
      break
    }
  }
  
  private func requestPhotos() {
    let fetchOption = PHFetchOptions().then {
      $0.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    }
    
    self.assets = PHAsset.fetchAssets(with: .image, options: fetchOption)
    self.fetchNextPhotos()
  }
  
  private func fetchNextPhotos() {
    if self.assets.count < self.lastIndex + self.pagingSize {
      self.lastIndex = self.assets.count
    } else {
      self.lastIndex = self.lastIndex + self.pagingSize
    }
    self.output.photos.accept(self.assets.objects(at: IndexSet(0..<self.lastIndex)))
  }
  
  private func selectPhoto(selectedIndex: Int, image: UIImage) {
    if self.selectedIndex.contains(selectedIndex) {
      if let index = self.selectedIndex.firstIndex(of: selectedIndex) {
        self.selectedPhoto.remove(at: index)
        self.selectedIndex.remove(at: index)
      }
    } else {
      self.selectedIndex.append(selectedIndex)
      self.selectedPhoto.append(image)
    }
    
    self.output.registerButtonIsEnable.accept(!self.selectedIndex.isEmpty)
    self.output.registerButtonText.accept(String(
      format: "register_photo_button_format".localized,
      self.selectedIndex.count
    ))
  }
  
  private func savePhotos(storeId: Int, photos: [UIImage]) {
    self.output.showLoading.accept(true)
    self.storeService.savePhoto(storeId: storeId, photos: photos)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          
          self.output.dismiss.accept(())
          self.output.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError{
            self.httpErrorAlert.accept(httpError)
          }
          self.output.showLoading.accept(false)
        }
      )
      .disposed(by: disposeBag)
  }
}
