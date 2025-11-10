import { cameraAbility } from './cameraAbility'
import { audioToText } from './audioToText'
import { CustomDialogUser } from './dialogBox';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';


AppStorage.SetOrCreate<string>('generatedText', '');

@Entry
@Component
struct Index {
  private uiContext: UIContext = this.getUIContext();
  private context: Context | undefined = this.uiContext?.getHostContext() ;
  private windowClass: window.Window | undefined = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync()

  aboutToAppear(): void {
    if (this.windowClass){

      this.windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE)
      this.windowClass.setWindowLayoutFullScreen(true);
      this.windowClass.setWindowSystemBarEnable([]);
    }

  }


  build() {
    Stack(){
      cameraAbility()
        .zIndex(0)
      audioToText()
      CustomDialogUser()
    }
  }
}