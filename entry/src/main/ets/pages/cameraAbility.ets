//这个页面没啥好看的,也是复制下来的,然后做了一点修改,使其横屏占满全屏,注释懒得写了,因为整活感觉也没有在这一页整活的必要
// 以后可能会加根据好感度不同添加不同的滤镜
//以后在考虑的,(现在还不会)

import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import display from '@ohos.display';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';


@Entry
@Component
export struct cameraAbility {
  private displayObj = display.getDefaultDisplaySync();
  private xComponentCtl: XComponentController = new XComponentController();
  private xComponentSurfaceId: string = '';
  @State imageWidth: number = this.displayObj.height;
  @State imageHeight: number = this.displayObj.width;
  private cameraManager: camera.CameraManager | undefined = undefined;
  private cameras: Array<camera.CameraDevice> | Array<camera.CameraDevice> = [];
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private session: camera.VideoSession | undefined = undefined;
  private uiContext: UIContext = this.getUIContext();
  private context: Context | undefined = this.uiContext?.getHostContext() ;
  private cameraPermission: Permissions = 'ohos.permission.CAMERA'; // 申请权限相关问题可参考本篇开头的申请相关权限文档
  @State isShow: boolean = false;
  isPlaying: boolean = false;


  private windowClass: window.Window | undefined = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync()




  async requestPermissionsFn(): Promise<void> {
    let atManager = abilityAccessCtrl.createAtManager();
    if (this.context) {
      let res = await atManager.requestPermissionsFromUser(this.context, [this.cameraPermission]);
      for (let i = 0; i < res.permissions.length; i++) {
        if (this.cameraPermission.toString() === res.permissions[i] && res.authResults[i] === 0) {
          this.isShow = true;
        }
      }
    }
  }

  aboutToAppear(): void {

    this.requestPermissionsFn();
  }



  onPageShow(): void {
    console.info('onPageShow');

    if (this.xComponentSurfaceId !== '') {
      this.initCamera();
    }
  }

  onPageHide(): void {
    console.info('onPageHide');
    this.releaseCamera();
  }

  build() {
    Stack(){
      Row(){
          if (this.isShow) {
            XComponent({
              id: 'componentId',
              type: XComponentType.SURFACE,
              controller: this.xComponentCtl
            })
              .rotate({  // 关键旋转配置
                angleZ: 270,  // Z轴旋转270°
                centerX: '50%', // 旋转中心X坐标为组件宽度50%
                centerY: '50%'  // 旋转中心Y坐标为组件高度50%
              })
              .onLoad(async () => {
                console.info('onLoad is called');
                this.xComponentSurfaceId = this.xComponentCtl.getXComponentSurfaceId(); // 获取组件surfaceId。
                // 初始化相机，组件实时渲染每帧预览流数据。
                this.initCamera()
              })
              .width(this.uiContext.px2vp(this.displayObj.width))
              .height(this.uiContext.px2vp(this.displayObj.height))

        }
        // .width('100%')
        // .height('100%')
      }
      // .width('100%')
      // .height('100%')
    }
    .zIndex(1)
    .alignContent(Alignment.Center)
    .width('100%')
    .height('100%')
  }


  // 初始化相机。
  async initCamera(): Promise<void> {
    console.info(`initCamera previewOutput xComponentSurfaceId:${this.xComponentSurfaceId}`);
    try {
      // 获取相机管理器实例。
      this.cameraManager = camera.getCameraManager(this.context);
      if (!this.cameraManager) {
        console.error('initCamera getCameraManager');
        return;
      }
      // 获取当前设备支持的相机device列表。
      this.cameras = this.cameraManager.getSupportedCameras();
      if (!this.cameras) {
        console.error('initCamera getSupportedCameras');
      }
      // 选择一个相机device，创建cameraInput输出对象。
      this.cameraInput = this.cameraManager.createCameraInput(this.cameras[0]);
      if (!this.cameraInput) {
        console.error('initCamera createCameraInput');
        return;
      }
      // 打开相机。
      await this.cameraInput.open();
      // 获取相机device支持的profile。
      let capability: camera.CameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(this.cameras[0], camera.SceneMode.NORMAL_VIDEO);
      if (!capability || capability.previewProfiles.length === 0) {
        console.error('capability is null || []');
        this.releaseCamera();
        return;
      }
      let minRatioDiff : number = 0.1;
      let surfaceRatio : number = this.imageWidth / this.imageHeight; // 最接近16:9宽高比。
      let previewProfile: camera.Profile = capability.previewProfiles[0];
      // 应用开发者根据实际业务需求选择一个支持的预览流previewProfile。
      // 此处以选择CAMERA_FORMAT_YUV_420_SP（NV21）格式、满足限定条件分辨率的预览流previewProfile为例。
      for (let index = 0; index < capability.previewProfiles.length; index++) {
        const tempProfile = capability.previewProfiles[index];
        let tempRatio = tempProfile.size.width >= tempProfile.size.height ?
          tempProfile.size.width / tempProfile.size.height : tempProfile.size.height / tempProfile.size.width;
        let currentRatio = Math.abs(tempRatio - surfaceRatio);
        if (currentRatio <= minRatioDiff && tempProfile.format == camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP) {
          previewProfile = tempProfile;
          break;
        }
      }
      this.imageWidth = previewProfile.size.width; // 更新xComponent组件的宽。
      this.imageHeight = previewProfile.size.height; // 更新xComponent组件的高。
      console.info(`initCamera imageWidth:${this.imageWidth} imageHeight:${this.imageHeight}`);

      // 使用xComponentSurfaceId创建预览。
      this.previewOutput = this.cameraManager.createPreviewOutput(previewProfile, this.xComponentSurfaceId);
      if (!this.previewOutput) {
        console.error('initCamera createPreviewOutput');
        this.releaseCamera();
        return;
      }
      // 创建录像模式相机会话。
      let session = this.cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO);
      if (!session) {
        console.error('session is null');
        this.releaseCamera();
        return;
      }
      this.session = session as camera.VideoSession;
      // 开始配置会话。
      this.session.beginConfig();
      // 添加相机设备输入。
      this.session.addInput(this.cameraInput);
      // 添加预览流输出。
      this.session.addOutput(this.previewOutput);
      // 提交会话配置。
      await this.session.commitConfig();
      // 开始启动已配置的输入输出流。
      await this.session.start();
    } catch (error) {
      console.error(`initCamera fail: ${JSON.stringify(error)}`);
      this.releaseCamera();
    }
  }

  // 释放相机。
  async releaseCamera(): Promise<void> {
    console.info('releaseCamera');
    // 停止当前会话。
    await this.session?.stop().catch((e: BusinessError) => {console.error('Failed to stop session: ', e)});
    // 释放相机输入流。
    await this.cameraInput?.close().catch((e: BusinessError) => {console.error('Failed to close the camera: ', e)});
    // 释放预览输出流。
    await this.previewOutput?.release().catch((e: BusinessError) => {console.error('Failed to stop the preview stream: ', e)});
    // 释放会话。
    await this.session?.release().catch((e: BusinessError) => {console.error('Failed to release session: ', e)});
  }
}