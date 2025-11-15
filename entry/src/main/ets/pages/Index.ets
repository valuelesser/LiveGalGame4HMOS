import { cameraAbility } from './cameraAbility'
import { audioToText } from './audioToText'
import { CustomDialogUser } from './dialogBox';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { Favorability } from './favorability';


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
  }//启动时设置为横屏显示


  build() {
    Stack(){
      cameraAbility()  //展示摄像头拍摄的画面
        .zIndex(0)
      Favorability()  //展示好感度条
      audioToText()      //文本框，启动界面
      CustomDialogUser()   //弹窗
//由代码易得，实际显示界面是由以上三个叠加显示得到的结果
    }
  }
}