import { pp } from './DisplayUtil';
import ArcView from './ArcView';
import ArcColors from './ArcColors';
import { Logger } from '@hw-agconnect/hmcore';

/**
 * 角-度
 * 一个完整的圆周角等于360度
 */
export type ANGLE_DEGREE = number;

/**
 * 角-弧度
 * 一个完整的圆周角等于2π弧度
 */
export type ANGLE_RADIAN = number;

export interface Coordinate {
  xPx: number,
  yPx: number,
}

/**
 * 直角三角形
 */
export interface RightTriangle {
  // 直角三角形 斜边
  hypotenusePx: number,

  // 直角三角形 邻边
  adjacentSidePx: number,

  // 直角三角形 对边
  oppositeSidePx: number,
}

@Preview
@Component
export default struct ArcProgressView {
  private TAG: string = '[Mqtt](ArcProgressView)';
  @State
  private isDebug: boolean = true;
  @State
  private maxAngleDegree: ANGLE_DEGREE = 320; // 最大角度 度
  @State
  private curAngleDegree: ANGLE_DEGREE = 260; // 当前角度 度 [minAngleDegree, maxAngleDegree]
  @Prop
  private widthVp: number = pp(256); // 整个画布的宽 外圆直径 vp
  @Prop
  private heightVp: number = pp(256); // 整个画布的高 外圆直径 vp

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
    }
    .width(this.widthVp)
    .height(this.widthVp)
    .onClick(() => {
      this.isDebug = !this.isDebug;
    })
  }
}
