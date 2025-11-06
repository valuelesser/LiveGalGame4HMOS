import { cameraAbility } from './cameraAbility'
import { audioToText } from './audioToText'


AppStorage.SetOrCreate<string>('generatedText', '');

@Entry
@Component
struct Index {


  build() {
    Stack(){
      cameraAbility()
      audioToText()
    }
  }
}