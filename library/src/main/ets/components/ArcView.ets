import { pp } from './DisplayUtil';
import valueUtil from './ValueUtil';
import { Logger } from '@hw-agconnect/hmcore';
import { PathShape } from '@kit.ArkUI';
import ArcColors from './ArcColors';

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
export default struct ArcView {
  private TAG: string = '[Mqtt](ArcView)';
  //region prop
  @Watch('onIsDebugChanged')
  @Prop
  public isDebug: boolean = true;
  private debugCircleColor: string = valueUtil.randomColor();
  /**
   * @Prop 不支持传递 LinearGradient, 渐变色不生效, 装饰变量时会进行深拷贝, 在拷贝的过程中除了基本类型、Map、Set、Date、Array外, 都会丢失类型
   */
  @Prop
  public colors: Array<[string, number]> = [["#2F6CE0", 0.00], ["#2F6CE0", 1.00]]
  @Prop
  public maxAngleDegree: ANGLE_DEGREE = 300; // 最大角度 度
  private readonly minAngleDegree: ANGLE_DEGREE = 0; // 最小角度 度
  @Prop
  public curAngleDegree: ANGLE_DEGREE = 150; // 当前角度 度 [minAngleDegree, maxAngleDegree]
  @Require
  @Prop
  public widthVp: number = pp(256); // 整个画布的宽 外圆直径 vp
  private widthPx = () => vp2px(this.widthVp); // 整个画布的宽 外圆直径 px
  @Require
  @Prop
  public heightVp: number = pp(256); // 整个画布的高 外圆直径 vp
  private heightPx = () => vp2px(this.heightVp); // 整个画布的高 外圆直径 px
  @Prop
  public strokeWidthVp: number = pp(8); // 内外圆间距 vp
  private strokeWidthPx = () => vp2px(this.strokeWidthVp); // 内外圆间距 px
  private outerRadiusPx = () => (this.heightPx() / 2) // 内圆半径 px
  private innerRadiusPx = () => this.outerRadiusPx() - this.strokeWidthPx(); // 内圆半径 px
  private centerXPx = () => this.widthPx() / 2;
  private centerYPx = () => this.heightPx() / 2;
  private offsetBetweenXAxisAndMinAngleDegree =
    () => 90 - ((360 - this.maxAngleDegree) / 2) // maxAngleDegree >= 180 时 起点与X轴的夹角
  private offsetBetweenYAxisAndMinAngleDegree =
    () => 180 - ((360 - this.maxAngleDegree) / 2) // maxAngleDegree < 180 时 起点与Y轴的夹角
  //region 这两种方式都可以用, 取决于渐变颜色从哪里开始, 这里视觉稿是从 0度开始到360度结束, 然后裁剪显示, 保持高保证
  // gauge 默认 从开始绘制的地方开始渐变到结束绘制的地方结束渐变, 一共7种颜色, 删除收尾两种颜色也能接近视觉稿
  // private startAngleDegreeForGauge = () => (360 - this.maxAngleDegree) / 2 + 180 // 保持 Gauge 开角垂直向下
  // private endAngleDegreeForGauge = () => -(360 - this.maxAngleDegree) / 2 + 180 // 保持 Gauge 开角垂直向下
  private startAngleDegreeForGauge = () => 0 + 180 // 保持 Gauge 开角垂直向下
  private endAngleDegreeForGauge = () => -0 + 180 // 保持 Gauge 开角垂直向下
  //endregion
  private degreeToRadian = (degree: ANGLE_DEGREE): ANGLE_RADIAN => degree * (Math.PI / 180) // 度转弧度
  // private radianToDegree = (radian: ANGLE_RADIAN): ANGLE_DEGREE => radian / (Math.PI / 180) // 弧度转度
  private degreeToRightTriangle = (degree: ANGLE_DEGREE, hypotenusePx: number): RightTriangle => {
    let radian = this.degreeToRadian(degree);
    let adjacentSidePx = hypotenusePx * Math.cos(radian);
    let oppositeSidePx = hypotenusePx * Math.sin(radian);
    return { hypotenusePx, adjacentSidePx, oppositeSidePx }
  }
  private degreeToCoordinate = (radiusPx: number, degree: ANGLE_DEGREE): Coordinate => {
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
      Logger.info(this.TAG, 'curAngleDegree: ' + this.curAngleDegree)
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

    return { xPx, yPx }
  }
  private degreeToOuterCircleCoordinate = (degree: ANGLE_DEGREE): Coordinate => {
    return this.degreeToCoordinate(this.outerRadiusPx(), degree)
  }
  private degreeToInnerCircleCoordinate = (degree: ANGLE_DEGREE): Coordinate => {
    return this.degreeToCoordinate(this.innerRadiusPx(), degree)
  }
  private clipOuterStartCoordinate = () => this.degreeToOuterCircleCoordinate(this.minAngleDegree);
  private clipInnerStartCoordinate = () => this.degreeToInnerCircleCoordinate(this.minAngleDegree);
  private clipInnerEndCoordinate = () => this.degreeToInnerCircleCoordinate(this.curAngleDegree);
  private clipOuterEndCoordinate = () => this.degreeToOuterCircleCoordinate(this.curAngleDegree);
  // private
  //endregion
  //region clip path shape
  private getClipPathShapeCommands = (): string => {
    let outerRadiusPx = this.outerRadiusPx(); // 外圆半径
    let innerRadiusPx = this.innerRadiusPx(); // 内圆半径
    let largeArcFlag = this.curAngleDegree > 180 ? 1 : 0; // 大弧标志位
    let clipOuterStartCoordinate = this.clipOuterStartCoordinate(); // 左侧外圆起点
    let clipOuterEndCoordinate = this.clipOuterEndCoordinate(); // 右侧外圆终点
    let clipInnerEndCoordinate = this.clipInnerEndCoordinate(); // 右侧内圆起点
    let clipInnerStartCoordinate = this.clipInnerStartCoordinate(); // 左侧内圆终点
    if (this.isDebug) {
      this.clearCanvas();
      this.drawCoordinate(clipOuterStartCoordinate, "0");
      this.drawCoordinate(clipOuterEndCoordinate, "1");
      this.drawCoordinate(clipInnerEndCoordinate, "2");
      this.drawCoordinate(clipInnerStartCoordinate, "3");
    }
    let outerArcPath =
      `M${clipOuterStartCoordinate.xPx} ${clipOuterStartCoordinate.yPx} A${outerRadiusPx} ${outerRadiusPx} 0 ${largeArcFlag} 1 ${clipOuterEndCoordinate.xPx} ${clipOuterEndCoordinate.yPx}`;
    let innerArcPath =
      `L${clipInnerEndCoordinate.xPx} ${clipInnerEndCoordinate.yPx}  A${innerRadiusPx} ${innerRadiusPx} 0 ${largeArcFlag} 0 ${clipInnerStartCoordinate.xPx} ${clipInnerStartCoordinate.yPx}`;
    let closePath = `L${clipOuterStartCoordinate.xPx} ${clipOuterStartCoordinate.yPx} Z`;
    return `${outerArcPath} ${innerArcPath} ${closePath}`;
  }
  @State
  private clipPathShape: PathShape = new PathShape({ commands: this.getClipPathShapeCommands() });
  private updateClipShapePath = () => {
    this.clipPathShape.commands(this.getClipPathShapeCommands())
  }
  //endregion
  private canvasRenderingContext2D: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(new RenderingContextSettings(true));

  onIsDebugChanged() {
    if (this.isDebug) {
      this.getClipPathShapeCommands();
    } else {
      this.clearCanvas();
    }
  }

  //region lifecycle
  aboutToAppear(): void {
    Logger.info(this.TAG, 'aboutToAppear');
  }

  onDidBuild(): void {
    Logger.info(this.TAG, 'onDidBuild');
    this.updateClipShapePath();
  }

  aboutToDisappear(): void {
    Logger.info(this.TAG, 'aboutToDisappear');
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Gauge({ value: 50, min: 1, max: 100 })
        .startAngle(this.startAngleDegreeForGauge())
        .endAngle(this.endAngleDegreeForGauge())
        .colors(ArcColors.colorsToLinearGradient(this.colors))
        .width(this.widthVp)
        .height(this.widthVp)
        .strokeWidth(this.strokeWidthVp)
        .trackShadow({ radius: 7, offsetX: 7, offsetY: 7 })
        .description(null)
        .indicator(null)
        .clipShape(this.clipPathShape)
        .backgroundColor(Color.Transparent)

      Canvas(this.canvasRenderingContext2D)
        .width(this.widthVp)
        .height(this.heightVp)
        .backgroundColor(Color.Transparent)
        .onReady(() => {
          this.canvasRenderingContext2D.imageSmoothingEnabled = true; // 抗锯齿
          this.canvasRenderingContext2D.imageSmoothingQuality = 'medium'
          this.getClipPathShapeCommands();
        })
    }
    .width(this.widthVp)
    .height(this.widthVp)
  }

  public widthVp2(widthVp: number) {
    this.widthVp = widthVp;
  }

  private clearCanvas() {
    let context = this.canvasRenderingContext2D;
    if (!context) {
      return;
    }
    context.clearRect(0, 0, context.width, context.height);
  }

  private drawCoordinate(coordinate: Coordinate, text?: string) {
    let context = this.canvasRenderingContext2D;
    if (!context) {
      return;
    }
    Logger.info(this.TAG, text + ': (' + coordinate.xPx + ', ' + coordinate.yPx + ')')
    context.beginPath();
    context.ellipse(px2vp(coordinate.xPx), px2vp(coordinate.yPx), 2, 2, 0, 0, 360);
    if (text?.length) {
      context.fillText(text, px2vp(coordinate.xPx) + 2, px2vp(coordinate.yPx) + 1.5)
    }
    context.fillStyle = this.debugCircleColor;
    context.fill();
  }
}
