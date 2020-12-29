import RxSwift
import RxCocoa

class ReviewModalViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let storeId: Int
  let reviewService: ReviewServiceProtocol
  
  struct Input {
    let rating = BehaviorRelay<Int>(value: 0)
    let contents = PublishSubject<String>()
    let tapRegister = PublishSubject<Void>()
  }
  
  struct Output {
    let showLoading = PublishRelay<Bool>()
    let dismissOnSaveReview = PublishRelay<Void>()
    let showHTTPErrorAlert = PublishRelay<HTTPError>()
  }
  
  init(reviewService: ReviewServiceProtocol, storeId: Int) {
    self.reviewService = reviewService
    self.storeId = storeId
    super.init()
    
    self.input.tapRegister.withLatestFrom(Observable.combineLatest(self.input.rating, self.input.contents)) { Review(rating: $1.0, contents: $1.1) }
      .do(onNext: { _ in
        GA.shared.logEvent(event: .review_register_button_clicked, page: .review_write)
      })
      .bind(onNext: self.saveReview(review:))
      .disposed(by: disposeBag)
  }
  
  private func saveReview(review: Review) {
    if self.isValidateReview(text: review.contents) {
      self.output.showLoading.accept(true)
      self.reviewService.saveReview(review: review, storeId: self.storeId)
        .subscribe(
          onNext: { [weak self] _ in
            guard let self = self else { return }
            self.output.showLoading.accept(false)
            self.output.dismissOnSaveReview.accept(())
          },
          onError: { [weak self] error in
            guard let self = self else { return }
            if let httpError = error as? HTTPError {
              self.output.showLoading.accept(false)
              self.output.showHTTPErrorAlert.accept(httpError)
            } else if let error = error as? CommonError {
              let alertContent = AlertContent(title: nil, message: error.description)
              
              self.showSystemAlert.accept(alertContent)
            }
          })
        .disposed(by: disposeBag)
    } else {
      let alertContent = AlertContent(title: nil, message: "내용을 입력해주세요.")
      
      self.showSystemAlert.accept(alertContent)
    }
  }
  
  private func isValidateReview(text: String) -> Bool {
    if text == "review_modal_placeholder".localized {
      return false
    }
    
    return !text.trimmingCharacters(in: .whitespaces).isEmpty
  }
}