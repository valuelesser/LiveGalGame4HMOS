import { cameraAbility } from './cameraAbility'
import { audioToText } from './audioToText'

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