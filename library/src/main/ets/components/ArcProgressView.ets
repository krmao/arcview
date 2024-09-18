/**
 * Copyright (c) 2024 kr.mao Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { pp } from './DisplayUtil';
import ArcView from './ArcView';
import ArcColors from './ArcColors';
import { Logger } from '@hw-agconnect/hmcore';
import ArcViewUtil, { ANGLE_DEGREE } from './ArcViewUtil';

@Preview
@Component
export default struct ArcProgressView {
  //region props and listeners
  @Prop
  public isDebug: boolean = false;
  @Prop
  public steps: number = 15;
  @Prop
  public bgColor: string = '#BED7F2';
  @Prop
  public maxAngleDegree: ANGLE_DEGREE = 220; // 最大角度 度
  @Watch('onCurAngleDegreeChanged')
  @Link
  public curAngleDegree: ANGLE_DEGREE; // = 280 / 10 * 5; // 当前角度 度 [minAngleDegree, maxAngleDegree] 四舍五入取整
  @Prop
  public enableGesture: boolean = true;
  @Prop
  public widthVp: number = pp(280); // 整个画布的宽 外圆直径 vp
  @Prop
  public heightVp: number = pp(280); // 整个画布的高 外圆直径 vp
  @Prop
  public arcBgStrokeWidthVp: number = pp(50 + 1 + 0.5);
  @Prop
  public arcOuterStrokeWidthVp: number = pp(20);
  @Prop
  public arcInnerStrokeWidthVp: number = pp(30);
  @Prop
  public arcIndicatorStrokeWidthVp: number = pp(42);
  @Prop
  public arcBgWidthVp: number = this.widthVp;
  @Prop
  public arcOuterWidthVp: number = this.arcBgWidthVp - pp(1 * 2);
  @Prop
  public arcInnerWidthVp: number = this.arcBgWidthVp - pp(1 * 2) - this.arcOuterStrokeWidthVp * 2;
  @Prop
  public arcIndicatorWidthVp: number = this.arcBgWidthVp - pp(1 * 2 + 4);
  @Prop
  public arcIndicatorGaugeOptions: GaugeIndicatorOptions | null = { icon: $r("app.media.arcview_icon_indicator"), space: 5 };
  @Prop
  public arcBgColors: Array<[string, number]> = [["#CCd0dae4", 0.00], ["#CCd0dae4", 1.00]]
  @Prop
  public arcOuterColors: Array<[string, number]> = ArcColors.arcOuterColors;
  @Prop
  public arcInnerColors: Array<[string, number]> = ArcColors.arcInnerColors;
  @Prop
  public enableIndicator: boolean = true;
  @Prop
  public arcIndicatorColors: Array<[string, number]> = [["#00000000", 0.00], ["#00000000", 1.00]];
  @Prop
  public buttonPlusEnable: boolean = true;
  @Prop
  public buttonMinusEnable: boolean = true;
  @Prop
  public buttonBgSize: number = this.arcBgStrokeWidthVp + pp(5)
  @Prop
  public buttonIconSize: number = this.arcBgStrokeWidthVp + pp(5)
  @Prop
  public buttonMinusBG: Resource = $r("app.media.arcview_button_bg");
  @Prop
  public buttonMinusIcon: Resource = $r("app.media.arcview_icon_minus");
  @Prop
  public buttonPlusBG: Resource = $r("app.media.arcview_button_bg");
  @Prop
  public buttonPlusIcon: Resource = $r("app.media.arcview_icon_plus");
  @Prop
  public buttonMinusOffsetX: number | undefined = undefined;
  @Prop
  public buttonMinusOffsetY: number | undefined = undefined;
  @Prop
  public buttonPlusOffsetX: number | undefined = undefined;
  @Prop
  public buttonPlusOffsetY: number | undefined = undefined;
  public onAngleDegreeChanged: ((angleDegree: ANGLE_DEGREE) => void) | undefined; // angleDegree 四舍五入取整
  public onButtonClicked: ((isMinusButtonClicked: boolean, angleDegree: ANGLE_DEGREE) => void) | undefined;
  public onTouchChanged: ((isTouching: boolean, event: GestureEvent) => void) | undefined;
  //endregion

  //region utils
  private TAG: string = '[ArcView](ArcProgressView)';
  private gestureEventAngleDegree: ANGLE_DEGREE | null = null;
  private _arcViewUtil: ArcViewUtil | undefined = undefined;
  private arcViewUtil = (): ArcViewUtil => {
    if (!this._arcViewUtil) {
      this._arcViewUtil = new ArcViewUtil(
        this.isDebug,
        this.maxAngleDegree,
        this.widthVp,
        this.heightVp,
        this.arcBgStrokeWidthVp
      );
    }
    return this._arcViewUtil;
  };
  private _arcViewButtonUtil: ArcViewUtil | undefined = undefined;
  private arcViewButtonUtil = (): ArcViewUtil => {
    if (!this._arcViewButtonUtil) {
      this._arcViewButtonUtil = new ArcViewUtil(
        this.isDebug,
        this.maxAngleDegree,
        this.arcOuterWidthVp,
        this.arcOuterWidthVp,
        this.buttonBgSize
      );
    }
    return this._arcViewButtonUtil;
  };
  private _arcViewUtilForIndicator: ArcViewUtil | undefined = undefined;
  private arcViewUtilForIndicator = (): ArcViewUtil => {
    if (!this._arcViewUtilForIndicator) {
      this._arcViewUtilForIndicator = new ArcViewUtil(
        this.isDebug,
        this.maxAngleDegree,
        this.arcIndicatorWidthVp,
        this.arcIndicatorWidthVp,
        this.arcIndicatorStrokeWidthVp
      );
    }
    return this._arcViewUtilForIndicator;
  };
  private onMinusButtonClicked = () => {
    let arcViewUtil = this.arcViewUtil();
    if (this.steps <= 0 || arcViewUtil.maxAngleDegree <= arcViewUtil.minAngleDegree) {
      return
    }
    let oneStepDegree = (arcViewUtil.maxAngleDegree - arcViewUtil.minAngleDegree) / this.steps;
    let nextDegree = this.curAngleDegree - oneStepDegree;
    if (nextDegree < arcViewUtil.minAngleDegree) {
      this.setCurAngleDegree(arcViewUtil.minAngleDegree);
    } else {
      this.setCurAngleDegree(nextDegree);
    }
    this.onButtonClicked?.(true, this.curAngleDegree);
  }
  private onPlusButtonClicked = () => {
    let arcViewUtil = this.arcViewUtil();
    if (this.steps <= 0 || arcViewUtil.maxAngleDegree <= arcViewUtil.minAngleDegree) {
      return
    }
    let oneStepDegree = (arcViewUtil.maxAngleDegree - arcViewUtil.minAngleDegree) / this.steps;
    let nextDegree = this.curAngleDegree + oneStepDegree;
    if (nextDegree > arcViewUtil.maxAngleDegree) {
      this.setCurAngleDegree(this.maxAngleDegree);
    } else {
      this.setCurAngleDegree(nextDegree);
    }
    this.onButtonClicked?.(false, this.curAngleDegree);
  }
  private minusButtonCenterCoordinate = () => {
    let arcViewButtonUtil = this.arcViewButtonUtil();
    return arcViewButtonUtil.degreeToCoordinate((arcViewButtonUtil.innerRadiusPx() +
    arcViewButtonUtil.outerRadiusPx()) / 2,
      arcViewButtonUtil.minAngleDegree);
  }
  private plusButtonCenterCoordinate = () => {
    let arcViewButtonUtil = this.arcViewButtonUtil();
    return arcViewButtonUtil.degreeToCoordinate((arcViewButtonUtil.innerRadiusPx() +
    arcViewButtonUtil.outerRadiusPx()) / 2,
      arcViewButtonUtil.maxAngleDegree);
  }

  //endregion

  private setCurAngleDegree(curAngleDegree: ANGLE_DEGREE) {
    //region 四舍五入取整
    let angleDegree = Math.round(curAngleDegree);
    angleDegree = Math.min(angleDegree, this.maxAngleDegree);
    angleDegree = Math.max(angleDegree, 0);
    //endregion
    this.curAngleDegree = angleDegree;
    this.onAngleDegreeChanged?.(angleDegree)
  }

  public onCurAngleDegreeChanged() {
    Logger.info(this.TAG, 'onCurAngleDegreeChanged curAngleDegree=' + this.curAngleDegree);
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
        strokeWidthVp: this.arcBgStrokeWidthVp,
        colors: this.arcBgColors,
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.maxAngleDegree,
        widthVp: this.arcBgWidthVp,
        heightVp: this.arcBgWidthVp
      })
      ArcView({
        isDebug: this.isDebug,
        strokeWidthVp: this.arcOuterStrokeWidthVp,
        colors: this.arcOuterColors,
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.curAngleDegree,
        widthVp: this.arcOuterWidthVp,
        heightVp: this.arcOuterWidthVp
      })
      ArcView({
        isDebug: this.isDebug,
        strokeWidthVp: this.arcInnerStrokeWidthVp,
        colors: this.arcInnerColors,
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.curAngleDegree,
        widthVp: this.arcInnerWidthVp,
        heightVp: this.arcInnerWidthVp
      })
      if (this.enableIndicator) {
        ArcView({
          isDebug: this.isDebug,
          strokeWidthVp: this.arcViewUtilForIndicator().strokeWidthVp,
          colors: this.arcIndicatorColors,
          enableOriginAngle: true,
          disableClip: true,
          maxAngleDegree: this.arcViewUtilForIndicator().maxAngleDegree,
          curAngleDegree: this.curAngleDegree,
          widthVp: this.arcIndicatorWidthVp,
          heightVp: this.arcIndicatorWidthVp,
          gaugeIndicatorOptions: this.arcIndicatorGaugeOptions,
        })
      }
      if (this.buttonMinusEnable) {
        Stack({ alignContent: Alignment.Center }) {
          Image(this.buttonMinusBG).width(this.buttonBgSize).height(this.buttonBgSize)
          Image(this.buttonMinusIcon).width(this.buttonIconSize).height(this.buttonIconSize)
        }.offset({
          x: px2vp(this.minusButtonCenterCoordinate().xPx) - this.widthVp / 2 + (this.buttonMinusOffsetX ?? 0),
          y: px2vp(this.minusButtonCenterCoordinate().yPx) - this.heightVp / 2 + (this.buttonMinusOffsetY ?? 0),
        }).onClick(() => {
          Logger.info(this.TAG, 'minus clicked');
          this.onMinusButtonClicked();
        })
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.90 })
      }
      if (this.buttonPlusEnable) {
        Stack({ alignContent: Alignment.Center }) {
          Image(this.buttonPlusBG).width(this.buttonBgSize).height(this.buttonBgSize)
          Image(this.buttonPlusIcon).width(this.buttonIconSize).height(this.buttonIconSize)
        }.offset({
          x: px2vp(this.plusButtonCenterCoordinate().xPx) - this.widthVp / 2 + (this.buttonPlusOffsetX ?? 0),
          y: px2vp(this.plusButtonCenterCoordinate().yPx) - this.heightVp / 2 + (this.buttonPlusOffsetY ?? 0)
        }).onClick(() => {
          Logger.info(this.TAG, 'plus clicked');
          this.onPlusButtonClicked();
        })
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.90 })
      }
    }
    .backgroundColor(this.bgColor)
    .width(this.widthVp)
    .height(this.widthVp)
    .gesture(
      PanGesture()
        .tag("PanGesture")
        .onActionStart((event: GestureEvent) => {
          Logger.info(this.TAG, 'onActionStart');
          this.onTouchChanged?.(true, event)
        })
        .onActionUpdate((event: GestureEvent) => {
          this.onTouchChanged?.(true, event)
          if (event) {
            let fingerList: FingerInfo[] = event.fingerList;
            if (!!fingerList.length) {
              let finger = fingerList[0];
              let xPx = vp2px(finger.localX);
              let yPx = vp2px(finger.localY);
              Logger.info(this.TAG, 'onActionUpdate xPx=' + xPx + ', yPx=' + yPx);
              this.getGestureEventAngleDegreeAndUpdateCurrentDegree(xPx, yPx, false)
            }
          }
        })
        .onActionEnd((event: GestureEvent) => {
          this.onTouchChanged?.(false, event)
          Logger.info(this.TAG, 'onActionEnd');
          this.gestureEventAngleDegree = null;
        })
    )
    .onGestureJudgeBegin((gestureInfo: GestureInfo, event: BaseGestureEvent) => {
      Logger.info(this.TAG, 'onGestureJudgeBegin');
      if (!this.enableGesture) {
        return GestureJudgeResult.REJECT;
      }
      if (gestureInfo.type === GestureControl.GestureType.PAN_GESTURE && gestureInfo.tag === 'PanGesture') {
        let fingerList: FingerInfo[] = event.fingerList;
        if (!!fingerList.length) {
          let finger = fingerList[0];
          let xPx = vp2px(finger.localX);
          let yPx = vp2px(finger.localY);
          let gestureEventAngleDegree: ANGLE_DEGREE | null =
            this.getGestureEventAngleDegreeAndUpdateCurrentDegree(xPx, yPx, true)
          return gestureEventAngleDegree !== null ? GestureJudgeResult.CONTINUE : GestureJudgeResult.REJECT;
        }
      } else if (gestureInfo.type === GestureControl.GestureType.CLICK) {
        return GestureJudgeResult.CONTINUE;
      }
      return GestureJudgeResult.REJECT;
    })
  }

  private getGestureEventAngleDegreeAndUpdateCurrentDegree(xPx: number, yPx: number,
    outsideReturnNull: boolean): ANGLE_DEGREE | null {
    let arcViewUtil = this.arcViewUtil();
    let centerXpx: number = arcViewUtil.centerXPx();
    let centerYPx: number = arcViewUtil.centerYPx();
    let innerRadiusPx: number = arcViewUtil.innerRadiusPx();
    let outerRadiusPx: number = arcViewUtil.outerRadiusPx();
    let startAngle: number = arcViewUtil.minAngleDegree;
    let endAngle: number = arcViewUtil.maxAngleDegree;
    let offsetBetweenPositiveXAxisAndStart = arcViewUtil.offsetBetweenPositiveXAxisAndStart();

    let gestureEventAngleDegree: ANGLE_DEGREE | null =
      ArcViewUtil.getGestureEventAngleDegree(xPx, yPx, centerXpx, centerYPx, innerRadiusPx, outerRadiusPx,
        startAngle,
        endAngle, offsetBetweenPositiveXAxisAndStart, outsideReturnNull);
    if (gestureEventAngleDegree !== null) {
      if (this.gestureEventAngleDegree !== null) {
        let angleOffset = gestureEventAngleDegree - this.gestureEventAngleDegree;
        if (Math.abs(angleOffset) <= 20) {
          let nextDegree = this.curAngleDegree += angleOffset;
          if (nextDegree > arcViewUtil.maxAngleDegree) {
            this.setCurAngleDegree(arcViewUtil.maxAngleDegree);
          } else if (nextDegree < arcViewUtil.minAngleDegree) {
            this.setCurAngleDegree(arcViewUtil.minAngleDegree);
          } else {
            this.setCurAngleDegree(nextDegree);
          }
        }
        Logger.info(this.TAG,
          'getGestureEventAngleDegreeAndUpdateCurrentDegree angleOffset=' + angleOffset + ', curAngleDegree=' +
          this.curAngleDegree);
      }
      this.gestureEventAngleDegree = gestureEventAngleDegree;
    }
    return gestureEventAngleDegree;
  }
}