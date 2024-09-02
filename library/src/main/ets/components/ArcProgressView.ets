import { pp } from './DisplayUtil';
import ArcView from './ArcView';
import ArcColors from './ArcColors';
import { Logger } from '@hw-agconnect/hmcore';
import ArcViewUtil, { ANGLE_DEGREE } from './ArcViewUtil';

@Preview
@Component
export default struct ArcProgressView {
  private TAG: string = '[ArcView](ArcProgressView)';
  @Prop
  private isDebug: boolean = true;
  @Prop
  private steps: number = 10;
  @Prop
  private maxAngleDegree: ANGLE_DEGREE = 320; // 最大角度 度
  @State
  private curAngleDegree: ANGLE_DEGREE = 260; // 当前角度 度 [minAngleDegree, maxAngleDegree]
  @Prop
  private widthVp: number = pp(256); // 整个画布的宽 外圆直径 vp
  @Prop
  private heightVp: number = pp(256); // 整个画布的高 外圆直径 vp
  public buttonSize: number = pp(34)
  private _arcViewUtil: ArcViewUtil | undefined = undefined;
  private arcViewUtil = (): ArcViewUtil => {
    if (!this._arcViewUtil) {
      this._arcViewUtil = new ArcViewUtil(
        this.isDebug,
        this.maxAngleDegree,
        this.widthVp,
        this.heightVp,
        this.buttonSize
      );
    }
    return this._arcViewUtil;
  };
  private onMinusButtonClicked = () => {
    let arcViewUtil = this.arcViewUtil();
    if (this.steps <= 0 || arcViewUtil.maxAngleDegree <= arcViewUtil.minAngleDegree) {
      return
    }
    let oneStepDegree = (arcViewUtil.maxAngleDegree - arcViewUtil.minAngleDegree) / this.steps;
    let nextDegree = this.curAngleDegree - oneStepDegree;
    if (nextDegree < arcViewUtil.minAngleDegree) {
      this.curAngleDegree = arcViewUtil.minAngleDegree;
    } else {
      this.curAngleDegree = nextDegree;
    }
  }
  private onPlusButtonClicked = () => {
    let arcViewUtil = this.arcViewUtil();
    if (this.steps <= 0 || arcViewUtil.maxAngleDegree <= arcViewUtil.minAngleDegree) {
      return
    }
    let oneStepDegree = (arcViewUtil.maxAngleDegree - arcViewUtil.minAngleDegree) / this.steps;
    let nextDegree = this.curAngleDegree + oneStepDegree;
    if (nextDegree > arcViewUtil.maxAngleDegree) {
      this.curAngleDegree = this.maxAngleDegree;
    } else {
      this.curAngleDegree = nextDegree;
    }
  }
  private minusButtonCenterCoordinate = () => {
    let arcViewUtil = this.arcViewUtil();
    return arcViewUtil.degreeToCoordinate((arcViewUtil.innerRadiusPx() + arcViewUtil.outerRadiusPx()) / 2,
      arcViewUtil.minAngleDegree);
  }
  private plusButtonCenterCoordinate = () => {
    let arcViewUtil = this.arcViewUtil();
    return arcViewUtil.degreeToCoordinate((arcViewUtil.innerRadiusPx() + arcViewUtil.outerRadiusPx()) / 2,
      arcViewUtil.maxAngleDegree);
  }

  aboutToAppear(): void {
    Logger.info(this.TAG, 'aboutToAppear');
  }

  onDidBuild(): void {
    Logger.info(this.TAG, 'onDidBuild');
  }

  aboutToDisappear(): void {
    Logger.info(this.TAG, 'aboutToDisappear');
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      ArcView({
        isDebug: this.isDebug,
        strokeWidthVp: pp(30 + 1 + 0.5),
        colors: [
          ["#80FFFFFF", 0.00],
          ["#80FFFFFF", 1.00],
        ],
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.maxAngleDegree,
        widthVp: this.widthVp + pp(1),
        heightVp: this.heightVp + pp(1)
      })
      ArcView({
        isDebug: this.isDebug,
        strokeWidthVp: pp(8),
        colors: ArcColors.arcOuterColors,
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.curAngleDegree,
        widthVp: this.widthVp,
        heightVp: this.heightVp
      })
      ArcView({
        isDebug: this.isDebug,
        strokeWidthVp: pp(30 - 8),
        colors: ArcColors.arcInnerColors,
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.curAngleDegree,
        widthVp: this.widthVp - pp(8 * 2),
        heightVp: this.heightVp - pp(8 * 2)
      })
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.button_bg'))
          .width(this.buttonSize)
          .height(this.buttonSize)
        Image($r('app.media.icon_minus'))
          .width(pp(20))
          .height(pp(20))
      }.offset({
        x: px2vp(this.minusButtonCenterCoordinate().xPx) - this.widthVp / 2,
        y: px2vp(this.minusButtonCenterCoordinate().yPx) - this.heightVp / 2
      }).onClick(() => {
        Logger.info(this.TAG, 'minus clicked');
        this.onMinusButtonClicked();
      })

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.button_bg'))
          .width(this.buttonSize)
          .height(this.buttonSize)
        Image($r('app.media.icon_plus'))
          .width(pp(20))
          .height(pp(20))
      }.offset({
        x: px2vp(this.plusButtonCenterCoordinate().xPx) - this.widthVp / 2,
        y: px2vp(this.plusButtonCenterCoordinate().yPx) - this.heightVp / 2
      }).onClick(() => {
        Logger.info(this.TAG, 'plus clicked');
        this.onPlusButtonClicked();
      })
    }
    .backgroundColor('#BED7F2')
    .width(this.widthVp)
    .height(this.widthVp)
    .onClick(() => {
      this.isDebug = !this.isDebug;
    })
  }
}
