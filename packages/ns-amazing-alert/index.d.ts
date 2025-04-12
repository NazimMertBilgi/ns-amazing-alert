import { NsAmazingAlertCommon, NsAmazingAlertShowOptions } from './common';

export declare class NsAmazingAlert extends NsAmazingAlertCommon {
  show(options: NsAmazingAlertShowOptions): { close: () => void };
  //
  close(): void;
}
