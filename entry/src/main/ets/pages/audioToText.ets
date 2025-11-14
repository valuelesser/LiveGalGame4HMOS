import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PromptAction } from '@kit.ArkUI';


const TAG = 'AsrDemo';

let asrEngine: speechRecognizer.SpeechRecognitionEngine;

@Entry
@Component
export struct audioToText {
  //@State createCount: number = 0;
  @State result: boolean = false;
  @State voiceInfo: string = "";
  @State sessionId: string = "123456";
  @State sessionId2: string = "1234567";
  @StorageLink('generatedText') generatedText: string = '';
  @State uiContextAudio: UIContext = this.getUIContext()
  @State promptAction: PromptAction = this.uiContextAudio.getPromptAction();
  @State isPlaying: boolean = false;
  //private mFileCapturer: FileCapturer = new FileCapturer();



  build() {
    Stack() {
      Column(){

        // if (this.isPlaying){
        //   Button() {
        //     Text("退出游戏")
        //       .fontColor(Color.White)
        //       .fontSize(20)
        //   }
        //   .type(ButtonType.Capsule)
        //   .backgroundColor("#0x317AA7")
        //   .width("80%")
        //   .height(50)
        //   .margin(10)
        //   .onClick(() => {
        //     // 释放引擎
        //     try{
        //       asrEngine.shutdown();
        //       this.generatedText = `The engine has been released.`
        //       this.promptAction.showToast({
        //         message: 'shutdown succeeded!',
        //         duration: 2000
        //       });
        //     } catch (err) {
        //       this.generatedText = `Failed to release engine. message: ${err.message}.`
        //       this.promptAction.showToast({
        //         message: 'shutdown failed!',
        //         duration: 2000
        //       });
        //     }
        //   })
        // }
        Column() {
          Text(this.generatedText)
            .fontColor(Color.White)
        }
        .linearGradient({
          angle: 0,                          // 渐变角度（0-360）
          colors: [
            ['#ffff9393', 0],                // 起始颜色
            ['#00ff9393', 1]                 // 终止颜色
          ],
          repeating: false
        })
        .width('100%')
        .constraintSize({ minHeight: 150 })
        //.border({ width: 1, radius: 5 })
        //.backgroundColor("#ffff9393")
        .padding(20)
        .alignItems(HorizontalAlign.Start)
      }
      .height('100%')
      .justifyContent(FlexAlign.End)
      if (!this.isPlaying){
        Column(){
          Image($r('app.media.startPage'))
            .width("100%")
            .onAppear(()=>{
              this.createByCallback()
            })
            .onClick(async () => {
              this.setListener()
              this.startRecording()
              this.isPlaying = true
            })
        }
        .zIndex(1)
        Row(){
          Image($r('app.media._8plus'))
            .height(50)
          Image($r('app.media._12plus'))
            .height(50)
          Image($r('app.media._16plus'))
            .height(50)
        }
        . position({ x: '80%', y: '80%' })
        .zIndex(2)
      }
    }
    .height('100%')

  }


  // 创建引擎，通过callback形式返回
  private createByCallback() {
    // 设置创建引擎参数
    let extraParam: Record<string, Object> = {"locate": "CN", "recognizerMode": "long","maxAudioDuration": 8 * 60 * 60 * 1000};
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam
    };

    // 调用createEngine方法
    speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine:
      speechRecognizer.SpeechRecognitionEngine) => {
      if (!err) {
        console.info(TAG, 'succeeded in creating engine.');
        // 接收创建引擎的实例
        asrEngine = speechRecognitionEngine;
      } else {
        // 无法创建引擎时返回错误码1002200001，原因：语种不支持、模式不支持、初始化超时、资源不存在等导致创建引擎失败
        // 无法创建引擎时返回错误码1002200006，原因：引擎正在忙碌中，一般多个应用同时调用语音识别引擎时触发
        // 无法创建引擎时返回错误码1002200008，原因：引擎已被销毁
        console.error(TAG, `Failed to create engine. Message: ${err.message}.`);
      }
    });
  }

  // 查询语种信息，以callback形式返回
  private queryLanguagesCallback() {
    // 设置查询相关参数
    let languageQuery: speechRecognizer.LanguageQuery = {
      sessionId: this.sessionId
    };
    // 调用listLanguages方法
    asrEngine.listLanguages(languageQuery, (err: BusinessError, languages: Array<string>) => {
      if (!err) {
        // 接收目前支持的语种信息
        console.info(TAG, `succeeded in listing languages, result: ${JSON.stringify(languages)}`);
        this.generatedText = `languages result: ${JSON.stringify(languages)}`
      } else {
        console.error(TAG, `Failed to create engine. Message: ${err.message}.`);
        this.generatedText = `Failed to create engine. Message: ${err.message}.`
      }
    });
  };

  private startListeningForRecording() {
    let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 } //audioInfo参数配置请参考AudioInfo
    let extraParam: Record<string, Object> = {
      "recognitionMode": 0,
      "vadBegin": 2000,
      "vadEnd": 3000,
      "maxAudioDuration": 8 * 60 * 60 * 1000
    }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: audioParam,
      extraParams: extraParam
    }
    console.info(TAG, 'startListening start');
    asrEngine.startListening(recognizerParams);
  };



  // 麦克风语音转文本
  private async startRecording() {
    try {
      this.startListeningForRecording();
    } catch (err) {
      this.generatedText = `Message: ${err.message}.`;
    }
  };

  // 睡眠
  private sleep(ms: number):Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // 设置回调
  private setListener() {
    // 创建回调对象
    let setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart: (sessionId: string, eventMessage: string) => {
        this.generatedText = '';
        console.info(TAG, `onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info(TAG, `onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        console.info(TAG, `onResult, sessionId: ${sessionId} result: ${JSON.stringify(result)}`);
        this.generatedText = result.result;
      },
      // 识别完成回调
      onComplete(sessionId: string, eventMessage: string) {
        console.info(TAG, `onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 错误回调，错误码通过本方法返回
      // 返回错误码1002200002，开始识别失败，重复启动startListening方法时触发
      // 更多错误码请参考错误码参考
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.error(TAG, `onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    }
    // 设置回调
    asrEngine.setListener(setListener);
  };
}