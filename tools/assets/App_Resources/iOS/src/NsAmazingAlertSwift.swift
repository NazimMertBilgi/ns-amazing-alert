import UIKit
import SCLAlertView
import Foundation

class NsAmazingAlertSwift: NSObject {

    var currentAlert: SCLAlertViewResponder?

    @objc public func showAlert(allJson: NSDictionary,
                               callback: @escaping (String, String?) -> Void) {
        let title = allJson["title"] as? String ?? ""
        let message = allJson["message"] as? String ?? ""
        let width = allJson["width"] as? Int ?? 240
        let height = allJson["height"] as? Int ?? 178
        let imageHeight = allJson["imageHeight"] as? Int ?? 300 // Varsayılan 300px yükseklik
        let textColor = allJson["textColor"] as? String ?? "#000000"
        let contentViewColor = allJson["contentViewColor"] as? String ?? "#FFFFFF"
        let contentViewBorderColor = allJson["contentViewBorderColor"] as? String ?? "#FFFFFF"
        let confirmButtonText = allJson["confirmButtonText"] as? String ?? "Confirm"
        let cancelButtonText = allJson["cancelButtonText"] as? String ?? "Cancel"
        let cancelButtonColor = allJson["cancelButtonColor"] as? String ?? "#d24d57"
        let confirmButtonColor = allJson["confirmButtonColor"] as? String ?? "#26a65b"
        let cancelButtonTextColor = allJson["cancelButtonTextColor"] as? String ?? "#ffffff"
        let confirmButtonTextColor = allJson["confirmButtonTextColor"] as? String ?? "#ffffff"
        let progressBarColor = allJson["progressBarColor"] as? String ?? ""
        let hideWhenBackgroundViewIsTapped = allJson["hideWhenBackgroundViewIsTapped"] as? Bool ?? false
        let alertType = allJson["alertType"] as? String ?? "success"
        let animationStyle = allJson["animationStyle"] as? String ?? "topToBottom"
        let showCancelButton = allJson["showCancelButton"] as? Bool ?? true
        let showConfirmButton = allJson["showConfirmButton"] as? Bool ?? true
        let showCircularIcon = allJson["showCircularIcon"] as? Bool ?? true
        let buttonsLayout = allJson["buttonsLayout"] as? String ?? "horizontal"
        let input = allJson["input"] as? NSDictionary ?? nil
        let imageURLString = allJson["imageURL"] as? String ?? nil
        let imageLocalName = allJson["imageLocalName"] as? String ?? nil

        // Alert stil tipini belirle
        var alertTypeEnum = SCLAlertViewStyle.success
        switch alertType {
            case "SUCCESS_TYPE": alertTypeEnum = SCLAlertViewStyle.success
            case "ERROR_TYPE": alertTypeEnum = SCLAlertViewStyle.error
            case "NOTICE_TYPE": alertTypeEnum = SCLAlertViewStyle.notice
            case "WARNING_TYPE": alertTypeEnum = SCLAlertViewStyle.warning
            case "INPUT_TYPE": alertTypeEnum = SCLAlertViewStyle.edit
            case "URL_IMAGE_TYPE": alertTypeEnum = SCLAlertViewStyle.info
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
        
        // URL_IMAGE_TYPE için daha büyük bir window height kullan
        let adjustedHeight = alertType == "URL_IMAGE_TYPE" || alertType == "CUSTOM_IMAGE_TYPE" || alertType == "PROGRESS_TYPE" ? max(height, imageHeight + 150) : height
        
        // Görünüm ayarlarını yapılandır
let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: CGFloat(width),
            kWindowHeight: CGFloat(adjustedHeight),
            showCloseButton: false,
            showCircularIcon: alertType == "URL_IMAGE_TYPE" || alertType == "CUSTOM_IMAGE_TYPE" || alertType == "PROGRESS_TYPE" || alertType == "NORMAL_TYPE" ? false : showCircularIcon, // URL_IMAGE_TYPE için circular icon'ı kapatıyoruz
            hideWhenBackgroundViewIsTapped: hideWhenBackgroundViewIsTapped,
            contentViewColor: UIColor(hex: contentViewColor),
            contentViewBorderColor: UIColor(hex: contentViewBorderColor),
            titleColor: UIColor(hex: textColor),
            buttonsLayout: buttonsLayoutEnum
        )
        
        // Alert nesnesini oluştur
        let alert = SCLAlertView(appearance: appearance)

        if alertType == "URL_IMAGE_TYPE" {
            if let urlStr = imageURLString, let imageURL = URL(string: urlStr) {
                // Önce butonları ekle
                if showCancelButton {
                    alert.addButton(cancelButtonText, backgroundColor: UIColor(hex: cancelButtonColor), textColor: UIColor(hex: cancelButtonTextColor), action: {
                        callback("cancel", nil)
                        alert.dismiss(animated: true)
                        self.currentAlert = nil
                    })
                }

                if showConfirmButton {
                    alert.addButton(confirmButtonText, backgroundColor: UIColor(hex: confirmButtonColor), textColor: UIColor(hex: confirmButtonTextColor), action: {
                        callback("confirm", nil)
                        alert.dismiss(animated: true)
                        self.currentAlert = nil
                    })
                }
                
                // URL'den resmi asenkron olarak yükle
                loadImage(from: imageURL) { loadedImage in
                    DispatchQueue.main.async {
                        if let image = loadedImage {
                            // Resim yüklendiyse özel subview oluştur
                            let actualImageHeight = CGFloat(imageHeight)
                            
                            // Ekstra alan hesapla (title ve subtitle için)
                            let titleHeight: CGFloat = 30 // Başlık için minimum yükseklik
                            let subtitleHeight: CGFloat = 50 // Alt başlık için minimum yükseklik
                            let containerHeight = actualImageHeight + titleHeight + subtitleHeight + 10 // Ekstra boşluk için
                            
                            // Container view, tüm alert genişliğinde
                            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: containerHeight))
                            
                            // Resim görünümü - Üstte, tam genişlikte
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width - 25, height: actualImageHeight))
                            imageView.contentMode = .scaleAspectFill // Aspect fill kullanarak resmi tam kapla
                            imageView.clipsToBounds = true // Taşan kısımları kırp
                            imageView.image = image
                            containerView.addSubview(imageView)
                            
                            // Resim için üst köşeleri yuvarlat
                            let maskPath = UIBezierPath(roundedRect: imageView.bounds,
                                                       byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                                       cornerRadii: CGSize(width: 5.0, height: 5.0))
                            let maskLayer = CAShapeLayer()
                            maskLayer.path = maskPath.cgPath
                            imageView.layer.mask = maskLayer
                            
                            // Title etiketi - çok satırlı
                            let titleLabel = UILabel(frame: CGRect(x: 0, y: actualImageHeight + 10, width: containerView.frame.width - 30, height: titleHeight))
                            titleLabel.text = title
                            titleLabel.textColor = UIColor(hex: textColor)
                            titleLabel.textAlignment = .center
                            titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
                            titleLabel.numberOfLines = 0 // Sınırsız satır
                            titleLabel.lineBreakMode = .byWordWrapping // Kelimelerden satır sonu
                            titleLabel.adjustsFontSizeToFitWidth = false
                            containerView.addSubview(titleLabel)
                            
                            // Subtitle etiketi - çok satırlı
                            let subtitleLabel = UILabel(frame: CGRect(x: 0, y: actualImageHeight + titleHeight + 10, width: containerView.frame.width - 30, height: subtitleHeight))
                            subtitleLabel.text = message
                            subtitleLabel.textColor = UIColor(hex: textColor)
                            subtitleLabel.textAlignment = .center
                            subtitleLabel.font = UIFont.systemFont(ofSize: 14)
                            subtitleLabel.numberOfLines = 0 // Sınırsız satır
                            subtitleLabel.lineBreakMode = .byWordWrapping // Kelimelerden satır sonu
                            subtitleLabel.adjustsFontSizeToFitWidth = false
                            containerView.addSubview(subtitleLabel)
                            
                            // Custom view'ı alert'e ekle
                            alert.customSubview = containerView
                            
                            // Empty title ve subtitle ile göster (gerçek içerik custom view'da)
                            self.currentAlert = alert.showInfo("", subTitle: "", animationStyle: animationStyleEnum)
                        } else {
                            // Resim yüklenemezse normal alert göster
                            self.currentAlert = alert.showInfo(title, subTitle: message, animationStyle: animationStyleEnum)
                        }
                    }
                }
            } else {
                // URL yoksa normal butonları ekle ve alert'i göster
                if showCancelButton {
                    alert.addButton(cancelButtonText, backgroundColor: UIColor(hex: cancelButtonColor), textColor: UIColor(hex: cancelButtonTextColor), action: {
                        callback("cancel", nil)
                        alert.dismiss(animated: true)
                        self.currentAlert = nil
                    })
                }

                if showConfirmButton {
                    alert.addButton(confirmButtonText, backgroundColor: UIColor(hex: confirmButtonColor), textColor: UIColor(hex: confirmButtonTextColor), action: {
                        callback("confirm", nil)
                        alert.dismiss(animated: true)
                        self.currentAlert = nil
                    })
                }
                
                self.currentAlert = alert.showInfo(title, subTitle: message, animationStyle: animationStyleEnum)
            }
        }
        else if alertType == "PROGRESS_TYPE" {

            // Önce butonları ekle
            if showCancelButton {
                alert.addButton(cancelButtonText, backgroundColor: UIColor(hex: cancelButtonColor), textColor: UIColor(hex: cancelButtonTextColor), action: {
                    callback("cancel", nil)
                    alert.dismiss(animated: true)
                    self.currentAlert = nil
                })
            }

            if showConfirmButton {
                alert.addButton(confirmButtonText, backgroundColor: UIColor(hex: confirmButtonColor), textColor: UIColor(hex: confirmButtonTextColor), action: {
                    callback("confirm", nil)
                    alert.dismiss(animated: true)
                    self.currentAlert = nil
                })
            }
                            let actualImageHeight = CGFloat(50)
                            
                            // Ekstra alan hesapla (title ve subtitle için)
                            let titleHeight: CGFloat = 30 // Başlık için minimum yükseklik
                            let subtitleHeight: CGFloat = 50 // Alt başlık için minimum yükseklik
                            let containerHeight = actualImageHeight + titleHeight + subtitleHeight + 10 // Ekstra boşluk için

                            // Container view, tüm alert genişliğinde
                            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: containerHeight))
            
                            // Loading spinner
                            let loadingSpinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width - 10, height: 50))
                            loadingSpinner.startAnimating()
                            if progressBarColor != "" {
                                loadingSpinner.color = UIColor(hex: progressBarColor)
                            }
                            containerView.addSubview(loadingSpinner)

                            // Title etiketi - çok satırlı
                            let titleLabel = UILabel(frame: CGRect(x: 0, y: actualImageHeight + 10, width: containerView.frame.width - 30, height: titleHeight))
                            titleLabel.text = title
                            titleLabel.textColor = UIColor(hex: textColor)
                            titleLabel.textAlignment = .center
                            titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
                            titleLabel.numberOfLines = 0 // Sınırsız satır
                            titleLabel.lineBreakMode = .byWordWrapping // Kelimelerden satır sonu
                            titleLabel.adjustsFontSizeToFitWidth = false
                            containerView.addSubview(titleLabel)
                            
                            // Subtitle etiketi - çok satırlı
                            let subtitleLabel = UILabel(frame: CGRect(x: 0, y: actualImageHeight + titleHeight + 10, width: containerView.frame.width - 30, height: subtitleHeight))
                            subtitleLabel.text = message
                            subtitleLabel.textColor = UIColor(hex: textColor)
                            subtitleLabel.textAlignment = .center
                            subtitleLabel.font = UIFont.systemFont(ofSize: 14)
                            subtitleLabel.numberOfLines = 0 // Sınırsız satır
                            subtitleLabel.lineBreakMode = .byWordWrapping // Kelimelerden satır sonu
                            subtitleLabel.adjustsFontSizeToFitWidth = false
                            containerView.addSubview(subtitleLabel)

                            // Custom view'ı alert'e ekle
                            alert.customSubview = containerView
                            
                            // Empty title ve subtitle ile göster (gerçek içerik custom view'da)
                            self.currentAlert = alert.showInfo("", subTitle: "", animationStyle: animationStyleEnum)
        }
        else if alertType == "CUSTOM_IMAGE_TYPE" {
           // Önce butonları ekle
            if showCancelButton {
                alert.addButton(cancelButtonText, backgroundColor: UIColor(hex: cancelButtonColor), textColor: UIColor(hex: cancelButtonTextColor), action: {
                    callback("cancel", nil)
                    alert.dismiss(animated: true)
                    self.currentAlert = nil
                })
            }

            if showConfirmButton {
                alert.addButton(confirmButtonText, backgroundColor: UIColor(hex: confirmButtonColor), textColor: UIColor(hex: confirmButtonTextColor), action: {
                    callback("confirm", nil)
                    alert.dismiss(animated: true)
                    self.currentAlert = nil
                })
            }
                            let actualImageHeight = CGFloat(50)
                            
                            // Ekstra alan hesapla (title ve subtitle için)
                            let titleHeight: CGFloat = 30 // Başlık için minimum yükseklik
                            let subtitleHeight: CGFloat = 50 // Alt başlık için minimum yükseklik
                            let containerHeight = actualImageHeight + titleHeight + subtitleHeight + 10 // Ekstra boşluk için

                            // Container view, tüm alert genişliğinde
                            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: containerHeight))
                            
                            // local image
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width - 10, height: 50))
                            imageView.image = UIImage(named: imageLocalName!)
                            containerView.addSubview(imageView)

                            // Title etiketi - çok satırlı
                            let titleLabel = UILabel(frame: CGRect(x: 0, y: actualImageHeight + 10, width: containerView.frame.width - 30, height: titleHeight))
                            titleLabel.text = title
                            titleLabel.textColor = UIColor(hex: textColor)
                            titleLabel.textAlignment = .center
                            titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
                            titleLabel.numberOfLines = 0 // Sınırsız satır
                            titleLabel.lineBreakMode = .byWordWrapping // Kelimelerden satır sonu
                            titleLabel.adjustsFontSizeToFitWidth = false
                            containerView.addSubview(titleLabel)
                            
                            // Subtitle etiketi - çok satırlı
                            let subtitleLabel = UILabel(frame: CGRect(x: 0, y: actualImageHeight + titleHeight + 10, width: containerView.frame.width - 30, height: subtitleHeight))
                            subtitleLabel.text = message
                            subtitleLabel.textColor = UIColor(hex: textColor)
                            subtitleLabel.textAlignment = .center
                            subtitleLabel.font = UIFont.systemFont(ofSize: 14)
                            subtitleLabel.numberOfLines = 0 // Sınırsız satır
                            subtitleLabel.lineBreakMode = .byWordWrapping // Kelimelerden satır sonu
                            subtitleLabel.adjustsFontSizeToFitWidth = false
                            containerView.addSubview(subtitleLabel)

                            // Custom view'ı alert'e ekle
                            alert.customSubview = containerView
                            
                            // Empty title ve subtitle ile göster (gerçek içerik custom view'da)
                            self.currentAlert = alert.showInfo("", subTitle: "", animationStyle: animationStyleEnum)
        }
         else {
            if showCancelButton && alertTypeEnum != SCLAlertViewStyle.edit {    
                alert.addButton(cancelButtonText, backgroundColor: UIColor(hex: cancelButtonColor), textColor: UIColor(hex: cancelButtonTextColor), action: {
                    callback("cancel", nil)
                    alert.dismiss(animated: true)
                    self.currentAlert = nil
                })
            }

            if showConfirmButton && alertTypeEnum != SCLAlertViewStyle.edit {
                alert.addButton(confirmButtonText, backgroundColor: UIColor(hex: confirmButtonColor), textColor: UIColor(hex: confirmButtonTextColor), action: {
                    callback("confirm", nil)
                    alert.dismiss(animated: true)
                    self.currentAlert = nil
                })
            }

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
                            callback("cancel", txt.text)
                            alert.dismiss(animated: true)
                            self.currentAlert = nil
                        })
                    }
                    if showConfirmButton {
                        alert.addButton(confirmButtonText, backgroundColor: UIColor(hex: confirmButtonColor), textColor: UIColor(hex: confirmButtonTextColor), action: {
                            callback("confirm", txt.text)
                            alert.dismiss(animated: true)
                            self.currentAlert = nil
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
    }

    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Error loading image from URL: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }

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
