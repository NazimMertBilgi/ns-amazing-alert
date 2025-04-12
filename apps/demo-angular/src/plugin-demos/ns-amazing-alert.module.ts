import { NgModule, NO_ERRORS_SCHEMA } from '@angular/core';
import { NativeScriptCommonModule, NativeScriptRouterModule } from '@nativescript/angular';
import { NsAmazingAlertComponent } from './ns-amazing-alert.component';

@NgModule({
  imports: [NativeScriptCommonModule, NativeScriptRouterModule.forChild([{ path: '', component: NsAmazingAlertComponent }])],
  declarations: [NsAmazingAlertComponent],
  schemas: [NO_ERRORS_SCHEMA],
})
export class NsAmazingAlertModule {}
