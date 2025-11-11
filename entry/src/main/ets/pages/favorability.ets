
@Entry
@Component
export struct Favorability {
  @State progressValue: number = 60
  @StorageLink('generatedText') @Watch('onChange')  generatedText: string = '';
  private timerID: number = -1 // 定时器标识
  @State difficult:number = 0.5

  onChange(){
    this.progressValue += 1/this.difficult // 有变化好感度加5
  }

  // 启动计时
  startTimer() {
    this.timerID = setInterval(() => {
      if (this.progressValue < 100) {
        this.progressValue -= 1 // 每秒增加-1
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

  private colorSelect(progressValue:number):Color{
    if (progressValue >= 80){
      return Color.Red
    }else if (progressValue >= 40){
      return Color.Pink
    }else {
      return Color.Blue
    }
  }

  aboutToAppear(): void {
    this.startTimer()
  }

  build() {
    Column() {
      Progress({ value: this.progressValue, total: 100 })
        .width(20)  // 控制进度条宽度
        .height(200) // 控制进度条高度
        .rotate({ angle: 180 }) // 旋转组件实现纵向显示
        .backgroundColor('#0x317AE7')
        .color(this.colorSelect(this.progressValue))
        .borderRadius(20)
        .margin({
          left: 20
        })

        .style({
          strokeWidth:20,
          shadow:true,

        })

    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)   // 主轴（垂直方向）顶部对齐
    .alignItems(HorizontalAlign.Start)   //交叉轴方向
  }
}