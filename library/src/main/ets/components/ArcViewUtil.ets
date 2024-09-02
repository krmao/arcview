import { Logger } from '@hw-agconnect/hmcore';
import { pp } from './DisplayUtil';

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

export default class ArcViewUtil {
  private TAG: string = '[ArcView](ArcViewUtil)';
  public isDebug: boolean = true;
  public maxAngleDegree: ANGLE_DEGREE = 300;
  // 最大角度 度
  public readonly minAngleDegree: ANGLE_DEGREE = 0;
  // 最小角度 度
  public widthVp: number = pp(256);
  // 整个画布的宽 外圆直径 px
  public heightVp: number = pp(256);
  // 整个画布的高 外圆直径 px
  public strokeWidthVp: number = pp(8);

  constructor(isDebug: boolean, maxAngleDegree: ANGLE_DEGREE , widthVp: number,
    heightVp: number, strokeWidthVp: number) {
    this.isDebug = isDebug;
    this.maxAngleDegree = maxAngleDegree;
    this.widthVp = widthVp;
    this.heightVp = heightVp;
    this.strokeWidthVp = strokeWidthVp;
  }

  // 整个画布的宽 外圆直径 vp
  public widthPx = () => vp2px(this.widthVp);
  // 整个画布的高 外圆直径 vp
  public heightPx = () => vp2px(this.heightVp);
  // 内外圆间距 vp
  public strokeWidthPx = () => vp2px(this.strokeWidthVp);
  // 内外圆间距 px
  public outerRadiusPx = () => (this.heightPx() / 2)
  // 内圆半径 px
  public innerRadiusPx = () => this.outerRadiusPx() - this.strokeWidthPx();
  // 内圆半径 px
  public centerXPx = () => this.widthPx() / 2;
  public centerYPx = () => this.heightPx() / 2;
  public offsetBetweenXAxisAndMinAngleDegree =
    () => 90 - ((360 - this.maxAngleDegree) / 2)
  // maxAngleDegree >= 180 时 起点与X轴的夹角
  public offsetBetweenYAxisAndMinAngleDegree =
    () => 180 - ((360 - this.maxAngleDegree) / 2)
  // maxAngleDegree < 180 时 起点与Y轴的夹角
  //region 这两种方式都可以用, 取决于渐变颜色从哪里开始, 这里视觉稿是从 0度开始到360度结束, 然后裁剪显示, 保持高保证
  // gauge 默认 从开始绘制的地方开始渐变到结束绘制的地方结束渐变, 一共7种颜色, 删除收尾两种颜色也能接近视觉稿
  // private startAngleDegreeForGauge = () => (360 - this.maxAngleDegree) / 2 + 180 // 保持 Gauge 开角垂直向下
  // private endAngleDegreeForGauge = () => -(360 - this.maxAngleDegree) / 2 + 180 // 保持 Gauge 开角垂直向下
  public startAngleDegreeForGauge = () => 0 + 180
  // 保持 Gauge 开角垂直向下
  public endAngleDegreeForGauge = () => -0 + 180
  // 保持 Gauge 开角垂直向下
  //endregion
  public degreeToRadian = (degree: ANGLE_DEGREE): ANGLE_RADIAN => degree * (Math.PI / 180)
  // 度转弧度
  // private radianToDegree = (radian: ANGLE_RADIAN): ANGLE_DEGREE => radian / (Math.PI / 180) // 弧度转度
  public degreeToRightTriangle = (degree: ANGLE_DEGREE, hypotenusePx: number): RightTriangle => {
    let radian = this.degreeToRadian(degree);
    let adjacentSidePx = hypotenusePx * Math.cos(radian);
    let oppositeSidePx = hypotenusePx * Math.sin(radian);
    return {
      hypotenusePx, adjacentSidePx, oppositeSidePx
    }
  }
  public degreeToCoordinate = (radiusPx: number, degree: ANGLE_DEGREE): Coordinate => {
    let xPx = 0;
    let yPx = 0;
    let maxAngleDegree = this.maxAngleDegree;
    let rightTriangle: RightTriangle | undefined;
    let centerXpx = this.centerXPx();
    let centerYpx = this.centerYPx();

    if (this.isDebug) {
      Logger.info(this.TAG, '----------------------------------------')
      Logger.info(this.TAG, 'radiusPx: ' + radiusPx)
      Logger.info(this.TAG, 'degree: ' + degree)
      Logger.info(this.TAG, 'maxAngleDegree: ' + this.maxAngleDegree)
    }
    if (maxAngleDegree >= 180) {
      let offsetBetweenXAxisAndMinAngleDegree = this.offsetBetweenXAxisAndMinAngleDegree();
      if (this.isDebug) {
        Logger.info(this.TAG, 'offsetBetweenXAxisAndMinAngleDegree: ' + offsetBetweenXAxisAndMinAngleDegree)
      }

      if (degree >= 0 && degree <= offsetBetweenXAxisAndMinAngleDegree) {
        // 左下角
        if (this.isDebug) {
          Logger.info(this.TAG, '>= 180 左下角')
        }
        rightTriangle = this.degreeToRightTriangle(offsetBetweenXAxisAndMinAngleDegree - degree, radiusPx);
        xPx = centerXpx - rightTriangle.adjacentSidePx;
        yPx = centerYpx + rightTriangle.oppositeSidePx;
      } else if (degree > offsetBetweenXAxisAndMinAngleDegree && degree <= offsetBetweenXAxisAndMinAngleDegree + 90) {
        // 左上角
        if (this.isDebug) {
          Logger.info(this.TAG, '>= 180 左上角')
        }
        rightTriangle = this.degreeToRightTriangle(degree - offsetBetweenXAxisAndMinAngleDegree, radiusPx);
        xPx = centerXpx - rightTriangle.adjacentSidePx;
        yPx = centerYpx - rightTriangle.oppositeSidePx;
      } else if (degree > offsetBetweenXAxisAndMinAngleDegree + 90 &&
        degree <= offsetBetweenXAxisAndMinAngleDegree + 180) {
        // 右上角
        if (this.isDebug) {
          Logger.info(this.TAG, '>= 180 右上角')
        }
        rightTriangle =
          this.degreeToRightTriangle((90 - (degree - (offsetBetweenXAxisAndMinAngleDegree + 90))), radiusPx);
        xPx = centerXpx + rightTriangle.adjacentSidePx;
        yPx = centerYpx - rightTriangle.oppositeSidePx;
      } else if (degree > offsetBetweenXAxisAndMinAngleDegree + 180 && degree <= maxAngleDegree) {
        if (maxAngleDegree === 360) {
          // 右下角 经过测试, 小数点后最多5位 第6位不生效, 360度时收尾重合, 则圆画不出来, 所以这里减小 0.00001 度
          if (this.isDebug) {
            Logger.info(this.TAG, '>= 180 === 360 右下角')
          }
          rightTriangle =
            this.degreeToRightTriangle((degree - 0.00001) - (offsetBetweenXAxisAndMinAngleDegree + 180), radiusPx);
          xPx = centerXpx + rightTriangle.adjacentSidePx;
          yPx = centerYpx + rightTriangle.oppositeSidePx;
        } else {
          // 右下角
          if (this.isDebug) {
            Logger.info(this.TAG, '>= 180 右下角')
          }
          rightTriangle = this.degreeToRightTriangle(degree - (offsetBetweenXAxisAndMinAngleDegree + 180), radiusPx);
          xPx = centerXpx + rightTriangle.adjacentSidePx;
          yPx = centerYpx + rightTriangle.oppositeSidePx;
        }
      } else {
        if (this.isDebug) {
          Logger.info(this.TAG, '>= 180 other')
        }
      }
    } else {
      let offsetBetweenYAxisAndMinAngleDegree = this.offsetBetweenYAxisAndMinAngleDegree();
      if (this.isDebug) {
        Logger.info(this.TAG, 'offsetBetweenYAxisAndMinAngleDegree: ' + offsetBetweenYAxisAndMinAngleDegree)
      }

      if (degree >= 0 && degree <= offsetBetweenYAxisAndMinAngleDegree) {
        // 左上角
        if (this.isDebug) {
          Logger.info(this.TAG, '< 180 左上角')
        }
        rightTriangle = this.degreeToRightTriangle(offsetBetweenYAxisAndMinAngleDegree - degree, radiusPx);
        xPx = centerXpx - rightTriangle.oppositeSidePx;
        yPx = centerYpx - rightTriangle.adjacentSidePx;
      } else if (degree > offsetBetweenYAxisAndMinAngleDegree && degree <= maxAngleDegree) {
        // 右上角
        if (this.isDebug) {
          Logger.info(this.TAG, '< 180 右上角')
        }
        rightTriangle = this.degreeToRightTriangle(degree - offsetBetweenYAxisAndMinAngleDegree, radiusPx);
        xPx = centerXpx + rightTriangle.oppositeSidePx;
        yPx = centerYpx - rightTriangle.adjacentSidePx;
      } else {
        if (this.isDebug) {
          Logger.info(this.TAG, '< 180 other')
        }
      }
    }

    if (this.isDebug) {
      Logger.info(this.TAG, 'xPx: ' + xPx)
      Logger.info(this.TAG, 'yPx: ' + yPx)
      Logger.info(this.TAG,
        'rightTriangle: (' + rightTriangle?.hypotenusePx + ', ' + rightTriangle?.adjacentSidePx + ', ' +
          rightTriangle?.oppositeSidePx + ')')
      Logger.info(this.TAG, 'widthPx: ' + this.widthPx())
      Logger.info(this.TAG, 'heightPx: ' + this.heightPx())
      Logger.info(this.TAG, 'centerXpx: ' + centerXpx)
      Logger.info(this.TAG, 'centerYpx: ' + centerYpx)
      Logger.info(this.TAG, 'centerYpx: ' + centerYpx)
      Logger.info(this.TAG, '----------------------------------------')
    }
    return {
      xPx, yPx
    }
  }
  public degreeToOuterCircleCoordinate = (degree: ANGLE_DEGREE): Coordinate => {
    return this.degreeToCoordinate(this.outerRadiusPx(), degree)
  }
  public degreeToInnerCircleCoordinate = (degree: ANGLE_DEGREE): Coordinate => {
    return this.degreeToCoordinate(this.innerRadiusPx(), degree)
  }
}