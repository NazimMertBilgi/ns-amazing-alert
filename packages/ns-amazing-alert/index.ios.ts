import { NsAmazingAlertCommon, NsAmazingAlertShowOptions } from './common';
import { Application } from '@nativescript/core';

// Swift tarafında tanımlanan bildirim adı
const ALERT_BUTTON_TAPPED_NOTIFICATION = 'NsAmazingAlertButtonTapped';

// Swift tarafında tanımlanan NsAmazingAlertSwift sınıfının bir örneğini tutmak için değişken
let nsAmazingAlertSwiftInstance: any = null;

export class NsAmazingAlert extends NsAmazingAlertCommon {
  show(options: NsAmazingAlertShowOptions): { close: () => void } {
    // --- Tema Değişikliği Dinleyicisi ---
    let systemAppearanceListener: (args: { newValue: 'light' | 'dark' }) => void;

    // Önceki alert açıksa kapat (isteğe bağlı)
    if (nsAmazingAlertSwiftInstance) {
      nsAmazingAlertSwiftInstance.close();
      nsAmazingAlertSwiftInstance = null;
    }

    const autoDarkMode = options.ios?.isAutoDarkMode ?? false;
    let darkMode = false;

    darkMode = Application.systemAppearance() === 'dark';
    systemAppearanceListener = (args: { newValue: 'light' | 'dark' }) => {
      darkMode = args.newValue === 'dark';
    };
    Application.on(Application.systemAppearanceChangedEvent, systemAppearanceListener);

    // Native Swift sınıfını oluştur
    //@ts-ignore NsAmazingAlertSwift global olarak tanımlı varsayılıyor
    nsAmazingAlertSwiftInstance = new NsAmazingAlertSwift();

    // Callback fonksiyonunu hazırla
    const callbackWrapper = (result: string, inputValue: string | null) => {
      if (options.callback) {
        options.callback(result as 'confirm' | 'cancel', inputValue ?? undefined);
      }
      // Callback çağrıldıktan sonra instance'ı temizle
      nsAmazingAlertSwiftInstance = null;
    };

    // Native Swift metodunu çağır
    nsAmazingAlertSwiftInstance.showAlertWithAllJsonCallback(
      {
        title: options.title || '',
        message: options.message || '',
        textColor: darkMode ? options.ios?.darkModeTheme?.textColor : options.ios?.textColor,
        contentViewColor: darkMode ? options.ios?.darkModeTheme?.contentViewColor : options.ios?.contentViewColor,
        contentViewBorderColor: darkMode ? options.ios?.darkModeTheme?.contentViewBorderColor : options.ios?.contentViewBorderColor,
        confirmButtonText: options.confirmButtonText || 'Confirm',
        cancelButtonText: options.cancelButtonText || 'Cancel',
        confirmButtonColor: darkMode ? options.ios?.darkModeTheme?.confirmButtonColor : options.ios?.confirmButtonColor,
        cancelButtonColor: darkMode ? options.ios?.darkModeTheme?.cancelButtonColor : options.ios?.cancelButtonColor,
        confirmButtonTextColor: darkMode ? options.ios?.darkModeTheme?.confirmButtonTextColor : options.ios?.confirmButtonTextColor,
        cancelButtonTextColor: darkMode ? options.ios?.darkModeTheme?.cancelButtonTextColor : options.ios?.cancelButtonTextColor,
        showCircularIcon: options.ios?.showCircularIcon !== undefined ? options.ios.showCircularIcon : true,
        showConfirmButton: options.ios?.showConfirmButton !== undefined ? options.ios.showConfirmButton : true,
        showCancelButton: options.ios?.showCancelButton !== undefined ? options.ios.showCancelButton : true,
        hideWhenBackgroundViewIsTapped: options.ios?.hideWhenBackgroundViewIsTapped !== undefined ? options.ios.hideWhenBackgroundViewIsTapped : false,
        input: options.input,
        alertType: options.ios?.alertType || 'SUCCESS_TYPE',
        animationStyle: options.ios?.animationStyle || 'topToBottom',
        buttonsLayout: options.ios?.buttonsLayout || 'horizontal', // Swift tarafında varsayılan horizontal oldu
      },
      callbackWrapper
    );

    // Kapatma fonksiyonunu içeren bir nesne döndür
    return {
      close: () => {
        if (nsAmazingAlertSwiftInstance) {
          nsAmazingAlertSwiftInstance.close();
          nsAmazingAlertSwiftInstance = null;
        }
      },
    };
  }
}
