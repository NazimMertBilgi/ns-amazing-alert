import UIKit
import SCLAlertView

class NsAmazingAlertSwift: NSObject {

    var currentAlert: SCLAlertViewResponder?

    @objc public func showAlert(allJson: NSDictionary,
                               callback: @escaping (String, String?) -> Void) {
        let title = allJson["title"] as? String ?? ""
        let message = allJson["message"] as? String ?? ""
        let textColor = allJson["textColor"] as? String ?? "#000000"
        let contentViewColor = allJson["contentViewColor"] as? String ?? "#FFFFFF"
        let contentViewBorderColor = allJson["contentViewBorderColor"] as? String ?? "#FFFFFF"
        let confirmButtonText = allJson["confirmButtonText"] as? String ?? "Confirm"
        let cancelButtonText = allJson["cancelButtonText"] as? String ?? "Cancel"
        let cancelButtonColor = allJson["cancelButtonColor"] as? String ?? "#d24d57"
        let confirmButtonColor = allJson["confirmButtonColor"] as? String ?? "#26a65b"
        let cancelButtonTextColor = allJson["cancelButtonTextColor"] as? String ?? "#ffffff"
        let confirmButtonTextColor = allJson["confirmButtonTextColor"] as? String ?? "#ffffff"
        let hideWhenBackgroundViewIsTapped = allJson["hideWhenBackgroundViewIsTapped"] as? Bool ?? false
        let alertType = allJson["alertType"] as? String ?? "success"
        let animationStyle = allJson["animationStyle"] as? String ?? "topToBottom"
        let showCancelButton = allJson["showCancelButton"] as? Bool ?? true
        let showConfirmButton = allJson["showConfirmButton"] as? Bool ?? true
        let showCircularIcon = allJson["showCircularIcon"] as? Bool ?? true
        let buttonsLayout = allJson["buttonsLayout"] as? String ?? "horizontal"
        let input = allJson["input"] as? NSDictionary ?? nil

        // Alert stil tipini belirle
        var alertTypeEnum = SCLAlertViewStyle.success
        switch alertType {
            case "SUCCESS_TYPE": alertTypeEnum = SCLAlertViewStyle.success
            case "ERROR_TYPE": alertTypeEnum = SCLAlertViewStyle.error
            case "NOTICE_TYPE": alertTypeEnum = SCLAlertViewStyle.notice
            case "WARNING_TYPE": alertTypeEnum = SCLAlertViewStyle.warning
            case "INFO_TYPE": alertTypeEnum = SCLAlertViewStyle.info
            case "INPUT_TYPE": alertTypeEnum = SCLAlertViewStyle.edit
            default: alertTypeEnum = SCLAlertViewStyle.success
        }
        
        // Buton düzenini belirle
        var buttonsLayoutEnum = SCLAlertButtonLayout.horizontal
        if buttonsLayout == "vertical" {
            buttonsLayoutEnum = SCLAlertButtonLayout.vertical
        }

        var animationStyleEnum = SCLAnimationStyle.topToBottom
        switch animationStyle {
            case "noAnimation": animationStyleEnum = SCLAnimationStyle.noAnimation
            case "topToBottom": animationStyleEnum = SCLAnimationStyle.topToBottom
            case "bottomToTop": animationStyleEnum = SCLAnimationStyle.bottomToTop
            case "leftToRight": animationStyleEnum = SCLAnimationStyle.leftToRight
            case "rightToLeft": animationStyleEnum = SCLAnimationStyle.rightToLeft
            default: animationStyleEnum = SCLAnimationStyle.topToBottom
        }
        
        // Görünüm ayarlarını yapılandır
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: showCircularIcon,
            hideWhenBackgroundViewIsTapped: hideWhenBackgroundViewIsTapped,
            contentViewColor: UIColor(hex: contentViewColor),
            contentViewBorderColor: UIColor(hex: contentViewBorderColor),
            titleColor: UIColor(hex: textColor),
            buttonsLayout: buttonsLayoutEnum
        )
        
        // Alert nesnesini oluştur
        let alert = SCLAlertView(appearance: appearance)

        if showCancelButton && alertTypeEnum != SCLAlertViewStyle.edit {    
            alert.addButton(cancelButtonText, backgroundColor: UIColor(hex: cancelButtonColor), textColor: UIColor(hex: cancelButtonTextColor), action: {
                callback("cancel", nil) // Input değeri olmadığı için nil gönder
                alert.dismiss(animated: true)
                self.currentAlert = nil // Referansı temizle
            })
        }

        if showConfirmButton && alertTypeEnum != SCLAlertViewStyle.edit {
            alert.addButton(confirmButtonText, backgroundColor: UIColor(hex: confirmButtonColor), textColor: UIColor(hex: confirmButtonTextColor), action: {
                callback("confirm", nil) // Input değeri olmadığı için nil gönder
                alert.dismiss(animated: true)
                self.currentAlert = nil // Referansı temizle
            })
        }
        
        // Alert tipine göre göster
        switch alertTypeEnum {
            case SCLAlertViewStyle.success:
                self.currentAlert = alert.showSuccess(title, subTitle: message, animationStyle: animationStyleEnum )
            case SCLAlertViewStyle.error:
                self.currentAlert = alert.showError(title, subTitle: message, animationStyle: animationStyleEnum)
            case SCLAlertViewStyle.notice:
                self.currentAlert = alert.showNotice(title, subTitle: message, animationStyle: animationStyleEnum)
            case SCLAlertViewStyle.warning:
                self.currentAlert = alert.showWarning(title, subTitle: message, animationStyle: animationStyleEnum)
            case SCLAlertViewStyle.info:
                self.currentAlert = alert.showInfo(title, subTitle: message, animationStyle: animationStyleEnum)
            case SCLAlertViewStyle.edit:
                let txt = alert.addTextField(input?["placeholder"] as? String ?? "")
                txt.text = input?["defaultValue"] as? String ?? ""
                if showCancelButton {
                    alert.addButton(cancelButtonText, backgroundColor: UIColor(hex: cancelButtonColor), textColor: UIColor(hex: cancelButtonTextColor), action: {
                        callback("cancel", txt.text) // Input değeri olmadığı için nil gönder
                        alert.dismiss(animated: true)
                        self.currentAlert = nil // Referansı temizle
                    })
                }
                if showConfirmButton {
                    alert.addButton(confirmButtonText, backgroundColor: UIColor(hex: confirmButtonColor), textColor: UIColor(hex: confirmButtonTextColor), action: {
                        callback("confirm", txt.text)
                    })
                }
                self.currentAlert = alert.showEdit(title, subTitle: message, animationStyle: animationStyleEnum)
                if let iosInputOptions = input?["ios"] as? NSDictionary {
                    txt.layer.borderColor = UIColor(hex: iosInputOptions["inputBorderColor"] as? String ?? "#000000").cgColor
                } else {
                    txt.layer.borderColor = UIColor(hex: "#000000").cgColor
                }
            @unknown default:
                self.currentAlert = alert.showSuccess(title, subTitle: message, animationStyle: animationStyleEnum)
        }
    }

    // JavaScript tarafından çağrılacak kapatma fonksiyonu
    @objc public func close() {
        self.currentAlert?.close()
        self.currentAlert = nil
    }

}


@objc extension UIColor {
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    var toUInt: UInt {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = UInt(red * 255) << 16
        let g = UInt(green * 255) << 8
        let b = UInt(blue * 255)

        return r | g | b
    }
}
