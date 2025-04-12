import { Application, Utils } from '@nativescript/core';
import { NsAmazingAlertCommon, NsAmazingAlertShowOptions } from './common';

export class NsAmazingAlert extends NsAmazingAlertCommon {
  show(options: NsAmazingAlertShowOptions): { close: () => void } {
    // --- Tema Değişikliği Dinleyicisi ---
    let systemAppearanceListener: (args: { newValue: 'light' | 'dark' }) => void;

    const activity = Utils.android.getCurrentActivity();
    //@ts-ignore
    const KAlertDialog = com.developer.kalert.KAlertDialog;

    const alertType = KAlertDialog[options.android?.alertType ?? 'NORMAL_TYPE'];
    const autoDarkMode = options.android?.isAutoDarkMode ?? false;
    let darkMode = false;

    //@ts-ignore
    const pDialog = new KAlertDialog(activity, alertType, autoDarkMode);

    if (autoDarkMode) {
      darkMode = Application.systemAppearance() === 'dark';
      systemAppearanceListener = (args: { newValue: 'light' | 'dark' }) => {
        pDialog.setTitleColor((args.newValue === 'dark' ? options.android?.darkModeTheme?.titleColor : options.android?.titleColor) ?? android.R.color.black);
        pDialog.setContentColor((args.newValue === 'dark' ? options.android?.darkModeTheme?.messageColor : options.android?.messageColor) ?? android.R.color.black);
        pDialog.confirmButtonColor((args.newValue === 'dark' ? options.android?.darkModeTheme?.confirmButtonColorOrDrawableOrResource : options.android?.confirmButtonColorOrDrawableOrResource) ?? confirm_button_resource);
        pDialog.cancelButtonColor((args.newValue === 'dark' ? options.android?.darkModeTheme?.cancelButtonColorOrDrawableOrResource : options.android?.cancelButtonColorOrDrawableOrResource) ?? cancel_button_resource);
      };
      Application.on(Application.systemAppearanceChangedEvent, systemAppearanceListener);

      // Dinleyiciyi diyalog kapatıldığında kaldır
      //@ts-ignore
      pDialog.setOnDismissListener(
        new android.content.DialogInterface.OnDismissListener({
          onDismiss: () => {
            if (systemAppearanceListener) {
              Application.off(Application.systemAppearanceChangedEvent, systemAppearanceListener);
            }
          },
        })
      );
    }

    pDialog.getProgressHelper().setBarColor(android.graphics.Color.parseColor(options.android?.progressBarColor ?? '#A5DC86'));
    pDialog.setTitleText(options.title);
    pDialog.setTitleTextGravity(android.view.Gravity[options.android?.titleGravity ?? 'CENTER']); //you can specify your own gravity
    pDialog.setContentText(options.message);

    if (options.android?.alertType === 'INPUT_TYPE') {
      pDialog.setInputFieldHint(options.input?.placeholder ?? '');
      pDialog.setInputFieldText(options.input?.defaultValue ?? '');
    }

    if (options.android?.alertType === 'CUSTOM_IMAGE_TYPE' || (options.android?.alertType === 'URL_IMAGE_TYPE' && options.android?.imageDrawableOrURL)) {
      if (typeof options.android?.imageDrawableOrURL === 'number') {
        pDialog.setCustomImage(options.android?.imageDrawableOrURL);
      } else {
        //@ts-ignore
        pDialog.setURLImage(options.android?.imageDrawableOrURL, KAlertDialog[options.android?.imageDisplayType]);
      }
    }

    if (options.android?.messageGravity === 'START') {
      pDialog.setContentTextAlignment(android.view.View.TEXT_ALIGNMENT_VIEW_START, android.view.Gravity.START);
    } else if (options.android?.messageGravity === 'END') {
      pDialog.setContentTextAlignment(android.view.View.TEXT_ALIGNMENT_VIEW_END, android.view.Gravity.END);
    } else {
      pDialog.setContentTextAlignment(android.view.View.TEXT_ALIGNMENT_CENTER, android.view.Gravity.CENTER);
    }

    const confirm_button_resource = activity.getResources().getIdentifier('ns_amazing_alert_confirm_button', 'drawable', activity.getPackageName());
    const cancel_button_resource = activity.getResources().getIdentifier('ns_amazing_alert_cancel_button', 'drawable', activity.getPackageName());

    pDialog.setTitleColor((darkMode ? options.android?.darkModeTheme?.titleColor : options.android?.titleColor) ?? android.R.color.black);
    pDialog.setContentColor((darkMode ? options.android?.darkModeTheme?.messageColor : options.android?.messageColor) ?? android.R.color.black);
    pDialog.confirmButtonColor((darkMode ? options.android?.darkModeTheme?.confirmButtonColorOrDrawableOrResource : options.android?.confirmButtonColorOrDrawableOrResource) ?? confirm_button_resource);
    pDialog.cancelButtonColor((darkMode ? options.android?.darkModeTheme?.cancelButtonColorOrDrawableOrResource : options.android?.cancelButtonColorOrDrawableOrResource) ?? cancel_button_resource);

    //@ts-ignore
    const confirmClickListener = new KAlertDialog.KAlertClickListener({
      onClick: function (dialog) {
        const inputValue = pDialog.getInputText();
        options.callback('confirm', inputValue);
        if (options.android?.isConfirmButtonClickCloseDialog ?? true) {
          dialog.dismissWithAnimation();
        }
      },
    });

    //@ts-ignore
    const cancelClickListener = new KAlertDialog.KAlertClickListener({
      onClick: function (dialog) {
        const inputValue = pDialog.getInputText();
        options.callback('cancel', inputValue);
        if (options.android?.isCancelButtonClickCloseDialog ?? true) {
          dialog.dismissWithAnimation();
        }
      },
    });

    pDialog.showConfirmButton(options.android?.isConfirmButtonVisible ?? false);
    pDialog.showCancelButton(options.android?.isCancelButtonVisible ?? true);

    if (options.android?.isConfirmButtonVisible) {
      pDialog.setConfirmClickListener(options.confirmButtonText ?? 'Close', confirmClickListener);
    }

    if (options.android?.isCancelButtonVisible) {
      pDialog.setCancelClickListener(options.cancelButtonText ?? 'Close', cancelClickListener);
    }

    pDialog.show();

    return {
      close: () => {
        pDialog.dismissWithAnimation();
      },
    };
  }
}
