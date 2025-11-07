






@Entry
@Component
struct Favorability {
  @State progressValue: number = 60
  @StorageLink('generatedText') generatedText: string = '';

  private timerID: number = -1 // 定时器标识

  // 启动计时
  startTimer() {
    this.timerID = setInterval(() => {
      if (this.progressValue < 100) {
        this.progressValue -= 1 // 每秒增加1%
      } else {
        this.clearTimer() // 达到100%后停止
      }
    }, 1000)
  }

  // 清除计时器
  clearTimer() {
    if (this.timerID !== -1) {
      clearInterval(this.timerID)
      this.timerID = -1
    }
  }


  build() {
    Column() {
      Progress({ value: this.progressValue, total: 100 })
        .width(20)  // 控制进度条宽度
        .height(200) // 控制进度条高度
        .rotate({ angle: 180 }) // 旋转组件实现纵向显示
        .backgroundColor(Color.Pink)
        .color(Color.Red)
        .borderRadius(20)


      Button('开始计时')
        .onClick(() => this.startTimer())
        .margin(10)

      Button('暂停计时')
        .onClick(() => this.clearTimer())
        .margin(10)

    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}