import UIKit

struct AlertUtils {
    
    static func show(title: String? = nil, message: String? = nil) {
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        show(title: title, message: message, [okAction])
    }
    
    static func showWithCancel(title: String? = nil, message: String? = nil) {
        let okAction = UIAlertAction(title: "확인", style: .default)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        show(title: title, message: message, [okAction, cancelAction])
    }
    
    static func show(title: String?, message: String?, _ actions: [UIAlertAction]) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let rootVC = sceneDelegate.window?.rootViewController {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            for action in actions {
                controller.addAction(action)
            }
            rootVC.present(controller, animated: true)
        }
    }
    
    static func showImagePicker(controller: UIViewController, picker: UIImagePickerController) {
        let alert = UIAlertController(title: "이미지 불러오기", message: nil, preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "앨범", style: .default) { ( _) in
            picker.sourceType = .photoLibrary
            controller.present(picker, animated: true)
        }
        let cameraAction = UIAlertAction(title: "카메라", style: .default) { (_ ) in
            picker.sourceType = .camera
            controller.present(picker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true)
    }
}


