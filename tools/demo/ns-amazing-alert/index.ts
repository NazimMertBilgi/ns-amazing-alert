import { Utils } from '@nativescript/core';
import { DemoSharedBase } from '../utils';
import { NsAmazingAlert } from '@nazimmertbilgi/ns-amazing-alert';

export class DemoSharedNsAmazingAlert extends DemoSharedBase {
  alert: NsAmazingAlert;
  constructor() {
    super();
    this.alert = new NsAmazingAlert();
  }

  showAlert() {
    if (__ANDROID__) {
      // custom title color
      // App_Resources/Android/src/main/res/drawable-{dpi}/custom_title_color.xml
      const customTitleColor = Utils.android.getCurrentActivity().getResources().getIdentifier('custom_title_color', 'drawable', Utils.android.getCurrentActivity().getPackageName());
      //const customMessageColor = Utils.android.getCurrentActivity().getResources().getIdentifier('custom_message_color', 'drawable', Utils.android.getCurrentActivity().getPackageName());

      const alert = this.alert.show({
        title: 'Hello',
        message: 'World',

        confirmButtonText: 'Confirm',
        cancelButtonText: 'Cancel',
        input: {
          placeholder: 'Write message',
          defaultValue: 'Hello',
        },
        android: {
          alertType: 'INPUT_TYPE',
          titleColor: android.R.color.black,
          messageColor: android.R.color.black,
          isAutoDarkMode: true,
          darkModeTheme: {
            titleColor: android.R.color.white,
            messageColor: android.R.color.white,
          },

          isConfirmButtonVisible: true,
          isCancelButtonVisible: true,
          isConfirmButtonClickCloseDialog: true,
          isCancelButtonClickCloseDialog: true,
          imageDrawableOrURL: 'https://avatars.githubusercontent.com/u/13032201?s=400&u=76e2be557bcecf2cfd22e48bb6a1ca2239f46336&v=4',
          imageDisplayType: 'IMAGE_CIRCLE',
        },
        callback: (result, inputValue) => {
          if (result === 'confirm') {
            console.log('result: confirm, inputValue:', inputValue);
          } else if (result === 'cancel') {
            console.log('result: cancel, inputValue:', inputValue);
          }
        },
      });

      //setTimeout(() => {
      //  alert.close();
      //}, 2000);
    } else {
      const alert = this.alert.show({
        title: 'Hello',
        message: 'World',
        confirmButtonText: 'Confirm',
        cancelButtonText: 'Cancel',
        input: {
          placeholder: 'Write message',
          defaultValue: 'Hello',
        },
        ios: {
          alertType: 'INFO_TYPE',
          isAutoDarkMode: true,
          darkModeTheme: {
            textColor: '#FFFFFF',
            contentViewColor: '#000000',
            contentViewBorderColor: '#000000',
            confirmButtonTextColor: '#FFFFFF',
            cancelButtonTextColor: '#FFFFFF',
          },
        },
        callback: (result, inputValue) => {
          if (result === 'confirm') {
            console.log('result: confirm, inputValue:', inputValue);
          } else if (result === 'cancel') {
            console.log('result: cancel, inputValue:', inputValue);
          }
        },
      });

      // setTimeout(() => {
      //   alert.close();
      // }, 2000);
    }
  }
}
