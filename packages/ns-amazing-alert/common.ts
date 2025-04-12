import { Observable } from '@nativescript/core';

export interface NsAmazingAlertShowOptions {
  title: string;
  message: string;
  confirmButtonText?: string;
  cancelButtonText?: string;
  input?: {
    placeholder?: string;
    defaultValue?: string;
    ios?: {
      inputBorderColor?: string;
    };
  };
  android?: {
    alertType?: 'NORMAL_TYPE' | 'SUCCESS_TYPE' | 'ERROR_TYPE' | 'WARNING_TYPE' | 'PROGRESS_TYPE' | 'CUSTOM_IMAGE_TYPE' | 'URL_IMAGE_TYPE' | 'INPUT_TYPE';
    progressBarColor?: string;
    titleGravity?: 'CENTER' | 'START' | 'END';
    messageGravity?: 'CENTER' | 'START' | 'END';
    titleColor?: number | string;
    messageColor?: number | string;
    isAutoDarkMode?: boolean;
    darkModeTheme?: {
      titleColor?: number;
      messageColor?: number;
      confirmButtonColorOrDrawableOrResource?: number | string;
      cancelButtonColorOrDrawableOrResource?: number | string;
    };
    isConfirmButtonVisible?: boolean;
    isCancelButtonVisible?: boolean;
    isConfirmButtonClickCloseDialog?: boolean;
    isCancelButtonClickCloseDialog?: boolean;
    confirmButtonColorOrDrawableOrResource?: number | string;
    cancelButtonColorOrDrawableOrResource?: number | string;
    imageDrawableOrURL?: number | string;
    imageDisplayType?: 'IMAGE_BIG' | 'IMAGE_CIRCLE';
  };
  ios?: {
    alertType?: 'SUCCESS_TYPE' | 'ERROR_TYPE' | 'NOTICE_TYPE' | 'WARNING_TYPE' | 'INFO_TYPE' | 'INPUT_TYPE';
    showCancelButton?: boolean;
    showConfirmButton?: boolean;
    showCircularIcon?: boolean;
    buttonsLayout?: 'vertical' | 'horizontal';
    animationStyle?: 'noAnimation' | 'topToBottom' | 'bottomToTop' | 'leftToRight' | 'rightToLeft';
    isAutoDarkMode?: boolean;
    darkModeTheme?: {
      textColor?: string;
      contentViewColor?: string;
      contentViewBorderColor?: string;
      cancelButtonColor?: string;
      confirmButtonColor?: string;
      cancelButtonTextColor?: string;
      confirmButtonTextColor?: string;
    };
    textColor?: string;
    cancelButtonColor?: string;
    confirmButtonColor?: string;
    cancelButtonTextColor?: string;
    confirmButtonTextColor?: string;
    contentViewColor?: string;
    contentViewBorderColor?: string;
    hideWhenBackgroundViewIsTapped?: boolean;
  };
  callback?: (result: 'confirm' | 'cancel', inputValue?: string) => void;
}

export class NsAmazingAlertCommon extends Observable {}
