import { ANGLE_DEGREE, ArcProgressView, pp } from '@codesdancing/arcview';
import { Logger } from '@hw-agconnect/hmcore';

@Entry
@Component
struct Index {
  private TAG: string = '[ArcView](Index)';
  @State message: string = 'Hello World';
  @State
  public isDebug: boolean = true;
  @State
  public enableIndicator: boolean = true;
  @State
  public steps: number = 10;
  @State
  public bgColor: string = '#BED7F2';
  @State
  public maxAngleDegree: ANGLE_DEGREE = 320; // 最大角度 度
  @Watch('onCurAngleDegreeChanged')
  @State
  public curAngleDegree: ANGLE_DEGREE = 320 / 10 * 5; // 当前角度 度 [minAngleDegree, maxAngleDegree]
  @State
  public widthVp: number = pp(256); // 整个画布的宽 外圆直径 vp
  @State
  public heightVp: number = pp(256); // 整个画布的高 外圆直径 vp

  public onCurAngleDegreeChanged() {
    Logger.info(this.TAG, 'onCurAngleDegreeChanged curAngleDegree=' + this.curAngleDegree);
  }

  build() {
    Scroll() {
      Column() {
        Text('ARCVIEW').margin(pp(32)).fontSize(40).fontWeight(700)

        ArcProgressView({
          isDebug: this.isDebug,
          enableIndicator: this.enableIndicator,
          steps: this.steps,
          bgColor: this.bgColor,
          maxAngleDegree: this.maxAngleDegree,
          curAngleDegree: this.curAngleDegree,
          widthVp: this.widthVp,
          heightVp: this.heightVp,
        })
          .margin(pp(32))
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            this.isDebug = !this.isDebug;
          })
      }
      .padding({ top: pp(80) })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height(1200)
    }
    .height('100%')
    .width('100%')
  }
}