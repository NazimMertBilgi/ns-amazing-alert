import { Component, NgZone } from '@angular/core';
import { DemoSharedNsAmazingAlert } from '@demo/shared';
import {} from '@nazimmertbilgi/ns-amazing-alert';

@Component({
  selector: 'demo-ns-amazing-alert',
  templateUrl: 'ns-amazing-alert.component.html',
})
export class NsAmazingAlertComponent {
  demoShared: DemoSharedNsAmazingAlert;

  constructor(private _ngZone: NgZone) {}

  ngOnInit() {
    this.demoShared = new DemoSharedNsAmazingAlert();
  }
}
