import { ANGLE_DEGREE, ArcColors, ArcProgressView, getDisplayWidth, pp, setCustomPP } from 'arcview';

import { Logger } from '@hw-agconnect/hmcore';

// optional: custom pp
setCustomPP((px: number, designWidthPx: number): number => {
  let displayWidth: number | undefined = getDisplayWidth();
  return !displayWidth ? px : px2vp(px / (designWidthPx / displayWidth));
});

@Entry
@Component
struct Index {
  private TAG: string = '[ArcView](Index)';
  @State
  public isDebug: boolean = true;
  public steps: number = 15;
  public maxAngleDegree: ANGLE_DEGREE = 220;
  @Watch('onCurAngleDegreeChanged')
  @State
  public curAngleDegree: ANGLE_DEGREE = this.maxAngleDegree / this.steps * 5;

  public onCurAngleDegreeChanged() {
    Logger.info(this.TAG, 'onCurAngleDegreeChanged curAngleDegree=' + this.curAngleDegree);
  }

  build() {
    Scroll() {
      Column() {
        Text('ARCVIEW')
          .margin(pp(32))
          .fontSize(50)
          .fontWeight(900)
          .fontStyle(FontStyle.Italic)
          .fontColor('#2a6078')

        ArcProgressView({
          isDebug: this.isDebug,
          steps: 15,
          bgColor: '#0f000000',
          maxAngleDegree: this.maxAngleDegree,
          curAngleDegree: this.curAngleDegree,
          enableGesture: true,
          widthVp: pp(280),
          heightVp: pp(280),
          arcBgStrokeWidthVp: pp(50 + 1 + 0.5),
          arcOuterStrokeWidthVp: pp(20),
          arcInnerStrokeWidthVp: pp(30),
          arcIndicatorStrokeWidthVp: pp(42),
          arcBgWidthVp: pp(280),
          arcOuterWidthVp: pp(280) - pp(1 * 2),
          arcInnerWidthVp: pp(280) - pp(1 * 2) - pp(20) * 2,
          arcIndicatorWidthVp: pp(280) - pp(1 * 2 + 4),
          arcIndicatorGaugeOptions: { icon: $r("app.media.icon_indicator"), space: 5 },
          arcBgColors: [["#CCd0dae4", 0.00], ["#EEd0dae4", 1.00]],
          arcOuterColors: ArcColors.arcOuterColors,
          arcInnerColors: ArcColors.arcInnerColors,
          enableIndicator: true,
          arcIndicatorColors: [["#00000000", 0.00], ["#00000000", 1.00]],
          buttonPlusEnable: true,
          buttonMinusEnable: true,
          buttonBgSize: pp(50 + 1 + 0.5) + pp(5),
          buttonIconSize: pp(25),
          buttonMinusBG: $r('app.media.button_bg'),
          buttonMinusIcon: $r('app.media.icon_minus'),
          buttonPlusBG: $r('app.media.button_bg'),
          buttonPlusIcon: $r('app.media.icon_plus'),
          buttonMinusOffsetX: undefined,
          buttonMinusOffsetY: undefined,
          buttonPlusOffsetX: undefined,
          buttonPlusOffsetY: undefined,
          onButtonClicked: (isMinusButtonClicked: boolean, angleDegree: ANGLE_DEGREE) => {
            Logger.info(this.TAG, 'onButtonClicked isMinus=' + isMinusButtonClicked + ', angleDegree=' + angleDegree);
          },
          onAngleDegreeChanged: (angleDegree: ANGLE_DEGREE) => {
            Logger.info(this.TAG, 'onAngleDegreeChanged angleDegree=' + angleDegree);
          },
          onTouchChanged: (isTouching: boolean, event: GestureEvent) => {
            let fingerInfo = event.fingerList[0];
            let localX = fingerInfo?.localX;
            let localY = fingerInfo?.localY;
            Logger.info(this.TAG, 'onTouchChanged isTouch=' + isTouching + ', event=(' + localX + ',' + localY + ')');
          }
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
      .backgroundColor('#d0dae4')
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