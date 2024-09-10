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
  private TAG: string = '[ArcView](ArcProgressView)';
  @Prop
  public isDebug: boolean = false;
  @Prop
  public enableGesture: boolean = true;
  @Prop
  public enableButtonPlus: boolean = true;
  @Prop
  public enableButtonMinus: boolean = true;
  @Prop
  public buttonMinusBG: Resource = $r('app.media.button_bg');
  @Prop
  public buttonMinusIcon: Resource = $r('app.media.icon_minus');
  @Prop
  public buttonPlusBG: Resource = $r('app.media.button_bg');
  @Prop
  public buttonPlusIcon: Resource = $r('app.media.icon_plus');
  @Prop
  public enableIndicator: boolean = true;
  public onButtonClicked: ((isMinusButtonClicked: boolean, angleDegree: ANGLE_DEGREE) => void) | undefined;
  public onTouchChanged: ((isTouching: boolean, event: GestureEvent) => void) | undefined;
  /**
   * angleDegree 四舍五入取整
   */
  public onAngleDegreeChanged: ((angleDegree: ANGLE_DEGREE) => void) | undefined;
  @Prop
  public bgColors: Array<[string, number]> = [
    ["#80FFFFFF", 0.00],
    ["#80FFFFFF", 1.00],
  ]
  @Prop
  public arcOuterColors: Array<[string, number]> = ArcColors.arcOuterColors;
  @Prop
  public arcInnerColors: Array<[string, number]> = ArcColors.arcInnerColors;
  @Prop
  public steps: number = 10;
  @Prop
  public bgColor: string = '#BED7F2';
  @Prop
  public maxAngleDegree: ANGLE_DEGREE = 320; // 最大角度 度
  @Watch('onCurAngleDegreeChanged')
  /**
   * 四舍五入取整
   */
  @Link
  public curAngleDegree: ANGLE_DEGREE; // = 320 / 10 * 5; // 当前角度 度 [minAngleDegree, maxAngleDegree]
  @Prop
  public widthVp: number = pp(256); // 整个画布的宽 外圆直径 vp
  @Prop
  public heightVp: number = pp(256); // 整个画布的高 外圆直径 vp
  @Prop
  public buttonSize: number = pp(34)
  private gestureEventAngleDegree: ANGLE_DEGREE | null = null;
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
  private _arcViewUtilForIndicator: ArcViewUtil | undefined = undefined;
  private arcViewUtilForIndicator = (): ArcViewUtil => {
    if (!this._arcViewUtilForIndicator) {
      this._arcViewUtilForIndicator = new ArcViewUtil(
        this.isDebug,
        this.maxAngleDegree,
        this.widthVp,
        this.heightVp,
        pp(32)
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
    let arcViewUtil = this.arcViewUtil();
    return arcViewUtil.degreeToCoordinate((arcViewUtil.innerRadiusPx() + arcViewUtil.outerRadiusPx()) / 2,
      arcViewUtil.minAngleDegree);
  }
  private plusButtonCenterCoordinate = () => {
    let arcViewUtil = this.arcViewUtil();
    return arcViewUtil.degreeToCoordinate((arcViewUtil.innerRadiusPx() + arcViewUtil.outerRadiusPx()) / 2,
      arcViewUtil.maxAngleDegree);
  }

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
        strokeWidthVp: pp(30 + 1 + 0.5),
        colors: this.bgColors,
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.maxAngleDegree,
        widthVp: this.widthVp + pp(1),
        heightVp: this.heightVp + pp(1)
      })
      ArcView({
        isDebug: this.isDebug,
        strokeWidthVp: pp(8),
        colors: this.arcOuterColors,
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.curAngleDegree,
        widthVp: this.widthVp,
        heightVp: this.heightVp
      })
      ArcView({
        isDebug: this.isDebug,
        strokeWidthVp: pp(30 - 8),
        colors: this.arcInnerColors,
        maxAngleDegree: this.maxAngleDegree,
        curAngleDegree: this.curAngleDegree,
        widthVp: this.widthVp - pp(8 * 2),
        heightVp: this.heightVp - pp(8 * 2)
      })
      if (this.enableIndicator) {
        ArcView({
          isDebug: this.isDebug,
          strokeWidthVp: this.arcViewUtilForIndicator().strokeWidthVp,
          colors: [["#00000000", 0.00], ["#00000000", 1.00]],
          enableOriginAngle: true,
          disableClip: true,
          maxAngleDegree: this.arcViewUtilForIndicator().maxAngleDegree,
          curAngleDegree: this.curAngleDegree,
          widthVp: this.widthVp - pp(30 * 2),
          heightVp: this.heightVp - pp(30 * 2),
          gaugeIndicatorOptions: { icon: $r("app.media.icon_indicator"), space: 5 },
        })
      }
      if (this.enableButtonMinus) {
        Stack({ alignContent: Alignment.Center }) {
          Image(this.buttonMinusBG).width(this.buttonSize).height(this.buttonSize)
          Image(this.buttonMinusIcon).width(pp(20)).height(pp(20))
        }.offset({
          x: px2vp(this.minusButtonCenterCoordinate().xPx) - this.widthVp / 2,
          y: px2vp(this.minusButtonCenterCoordinate().yPx) - this.heightVp / 2
        }).onClick(() => {
          Logger.info(this.TAG, 'minus clicked');
          this.onMinusButtonClicked();
        })
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.90 })
      }
      if (this.enableButtonPlus) {
        Stack({ alignContent: Alignment.Center }) {
          Image(this.buttonPlusBG).width(this.buttonSize).height(this.buttonSize)
          Image(this.buttonPlusIcon).width(pp(20)).height(pp(20))
        }.offset({
          x: px2vp(this.plusButtonCenterCoordinate().xPx) - this.widthVp / 2,
          y: px2vp(this.plusButtonCenterCoordinate().yPx) - this.heightVp / 2
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