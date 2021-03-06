import UIKit
import RxSwift

class StoreDetailPhotoCollectionCell: BaseTableViewCell {
  
  static let registerId = "\(StoreDetailPhotoCell.self)"
  
  let photos = PublishSubject<[Image?]>()
  let photoCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(
      width: (UIScreen.main.bounds.width - 75)/4,
      height: (UIScreen.main.bounds.width - 75)/4
    )
    layout.minimumInteritemSpacing = 9
    $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    $0.collectionViewLayout = layout
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundColor = .clear
  }
  var count: Int?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.setupCollectionView()
  }
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.isUserInteractionEnabled = false
    self.addSubViews(photoCollectionView)
    self.setupCollectionView()
  }
  
  override func bindConstraints() {
    self.photoCollectionView.snp.makeConstraints { make in
      make.left.right.top.bottom.equalToSuperview()
      make.height.equalTo(100)
    }
  }
  
  func bind(photos: [Image]) {
    self.count = photos.count
    if photos.isEmpty {
      self.photos.onNext([nil])
    } else if photos.count <= 4 {
      self.photos.onNext(Array(photos[0..<photos.count]))
    } else {
      self.photos.onNext(Array(photos[0..<4]))
    }
  }
  
  private func setupCollectionView() {
    self.photoCollectionView.register(
      StoreDetailPhotoCell.self,
      forCellWithReuseIdentifier: StoreDetailPhotoCell.registerId
    )
    self.photos.bind(to: self.photoCollectionView.rx.items(
      cellIdentifier: StoreDetailPhotoCell.registerId,
      cellType: StoreDetailPhotoCell.self
    )) { [weak self] row, image, cell in
      cell.bind(image: image, isLast: row == 3, count: self?.count ?? 0)
    }.disposed(by: disposeBag)
  }
}
