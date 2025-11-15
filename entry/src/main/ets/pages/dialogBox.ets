function displayDialogOrNot(key:string[],text:string):boolean{
  if (key.length === 0) {
    return false;
  }

  // 转义特殊字符并组合成正则表达式
  const escapedKeys = key.map(k => k.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
  const pattern = new RegExp(escapedKeys.join('|'));

  return pattern.test(text);
}

export let key: string[] = ["什么", "吗","啥"]; // 示例关键词数组,以后也有机会开放自定义;也有可能简单改一下识别问号



//从这往下是我从开发者联盟里面的实例代码复制的,还没好好看

@CustomDialog
struct CustomDialogExample {
  controller?: CustomDialogController;
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }
  build() {
    Column() {
      Text('该做出选择了')
        .margin(20)
        .width('80%')
      Button('好呀好呀')
        .onClick(() => {
          if (this.controller != undefined) {
            this.controller.close();
          }
        })
        .margin(20)
        .width('80%')
      Button('不了')
        .onClick(() => {
          if (this.controller != undefined) {
            this.controller.close();
          }
        })
        .margin(20)
        .width('80%')
    }
  }
}


@Entry
@Component
export struct CustomDialogUser {
  @StorageLink('generatedText') displayText: string = '';

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: ()=> { this.onCancel(); },
      confirm: ()=> { this.onAccept(); }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      console.info(`reason= ${dismissDialogAction.reason}`);
      console.info('dialog onWillDismiss')
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: 20,
    width: 300,
    height: 220,
    borderWidth: 1,
    borderStyle: BorderStyle.Dashed,//使用borderStyle属性，需要和borderWidth属性一起使用
    borderColor: Color.Pink,//使用borderColor属性，需要和borderWidth属性一起使用
    backgroundColor: Color.Transparent,
    shadow: ({ radius: 20, color: Color.Pink, offsetX: 50, offsetY: 0}),
  })
  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null; // 将dialogController置空
  }

  onCancel() {
    console.info('Callback when the first button is clicked');
  }

  onAccept() {
    console.info('Callback when the second button is clicked');
  }

  existApp() {
    console.info('Click the callback in the blank area');
  }

  //this.dialogController.open()

  build() {
    Column() {
      if ( displayDialogOrNot(key,this.displayText) ){    //判断什么时候展示选择框
        Text('')
          .opacity(0)
          .onAppear(()=>{
            if (this.dialogController){
              this.dialogController.open()
            }
          })    //在onappear 中回调，展示对话框
      }
    }.width('100%').margin({ top: 5 })
  }
}

