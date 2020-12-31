import UIKit

class CategoryListHeaderView: BaseView {
  
  let nearImage = UIImageView().then {
    $0.image = UIImage.init(named: "ic_near")
  }
  
  let titleLable = UILabel().then {
    $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
    $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 12)
  }
  
  
  override func setup() {
    backgroundColor = .white
    addSubViews(nearImage, titleLable)
  }
  
  override func bindConstraints() {
    nearImage.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
    }
    
    titleLable.snp.makeConstraints { (make) in
      make.left.equalTo(nearImage.snp.right).offset(3)
      make.top.equalToSuperview().offset(16)
      make.bottom.equalToSuperview().offset(-16)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setupRadius()
  }
  
  private func setupRadius() {
    layer.cornerRadius = 12
    layer.masksToBounds = true
    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  func setDistanceHeader(section: Int) {
    nearImage.image = UIImage.init(named: "ic_near")
    switch section {
    case 0:
      titleLable.text = "category_header_50m".localized
    case 1:
      titleLable.text = "category_header_100m".localized
    case 2:
      titleLable.text = "category_header_500m".localized
    case 3:
      titleLable.text = "category_header_1k".localized
    case 4:
      titleLable.text = "category_header_over_1k".localized
    default:
      titleLable.text = ""
    }
  }
  
  func setReviewHeader(section: Int) {
    nearImage.image = UIImage.init(named: "ic_star_outline")
    switch section {
    case 0:
      titleLable.text = "category_header_4point".localized
    case 1:
      titleLable.text = "category_header_3point".localized
    case 2:
      titleLable.text = "category_header_2point".localized
    case 3:
      titleLable.text = "category_header_1point".localized
    case 4:
      titleLable.text = "category_header_0point".localized
    default:
      titleLable.text = ""
    }
  }
}
