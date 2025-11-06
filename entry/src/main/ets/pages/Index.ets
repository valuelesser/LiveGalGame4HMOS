import { cameraAbility } from './cameraAbility'
import { audioToText } from './audioToText'
import { CustomDialogUser } from './dialogBox';


AppStorage.SetOrCreate<string>('generatedText', '');

@Entry
@Component
struct Index {


  build() {
    Stack(){
      cameraAbility()
      audioToText()
      CustomDialogUser()
    }
  }
}