import { ANGLE_DEGREE, ArcColors, ArcProgressView, pp } from '@codesdancing/arcview';
import { Logger } from '@hw-agconnect/hmcore';

@Entry
@Component
struct Index {
  private TAG: string = '[ArcView](Index)';
  @State message: string = 'Hello World';
  @State
  public isDebug: boolean = true;
  public enableGesture: boolean = true;
  public enableIndicator: boolean = true;
  public steps: number = 10;
  public bgColor: string = '#BED7F2';
  public maxAngleDegree: ANGLE_DEGREE = 320; // 最大角度 度
  @Watch('onCurAngleDegreeChanged')
  @State
  public curAngleDegree: ANGLE_DEGREE = 320 / 10 * 5; // 当前角度 度 [minAngleDegree, maxAngleDegree]
  public widthVp: number = pp(256); // 整个画布的宽 外圆直径 vp
  public heightVp: number = pp(256); // 整个画布的高 外圆直径 vp
  public bgColors: Array<[string, number]> = [
    ["#80FFFFFF", 0.00],
    ["#80FFFFFF", 1.00],
  ]
  public arcOuterColors: Array<[string, number]> = ArcColors.arcOuterColors;
  public arcInnerColors: Array<[string, number]> = ArcColors.arcInnerColors;

  public onCurAngleDegreeChanged() {
    Logger.info(this.TAG, 'onCurAngleDegreeChanged curAngleDegree=' + this.curAngleDegree);
  }

  build() {
    Scroll() {
      Column() {
        Text('ARCVIEW').margin(pp(32)).fontSize(40).fontWeight(700)

        ArcProgressView({
          isDebug: this.isDebug,
          enableGesture: this.enableGesture,
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