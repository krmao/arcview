import { pp } from './DisplayUtil';
import valueUtil from './ValueUtil';
import { Logger } from '@hw-agconnect/hmcore';
import { PathShape } from '@kit.ArkUI';
import ArcColors from './ArcColors';
import ArcViewUtil, { ANGLE_DEGREE, Coordinate } from './ArcViewUtil';

@Preview
@Component
export default struct ArcView {
  private TAG: string = '[ArcView](ArcView)';
  //region prop
  @Watch('onIsDebugChanged')
  @Prop
  public isDebug: boolean = true;
  @Prop
  public enableOriginAngle: boolean = false;
  @Prop
  public disableClip: boolean = false;
  @Prop
  public gaugeIndicatorOptions: GaugeIndicatorOptions | null = null;
  @Prop
  public gaugeValue: number = 50
  @Prop
  public gaugeMin: number = 0
  @Prop
  public gaugeMax: number = 100
  private debugCircleColor: string = valueUtil.randomColor();
  /**
   * @Prop 不支持传递 LinearGradient, 渐变色不生效, 装饰变量时会进行深拷贝, 在拷贝的过程中除了基本类型、Map、Set、Date、Array外, 都会丢失类型
   */
  @Prop
  public colors: Array<[string, number]> = [["#2F6CE0", 0.00], ["#2F6CE0", 1.00]]
  @Prop
  public maxAngleDegree: ANGLE_DEGREE = 300; // 最大角度 度
  @Watch('onCurAngleDegreeChanged')
  @Prop
  public curAngleDegree: ANGLE_DEGREE = 150; // 当前角度 度 [minAngleDegree, maxAngleDegree]
  @Prop
  public widthVp: number = pp(256); // 整个画布的宽 外圆直径 vp
  @Prop
  public heightVp: number = pp(256); // 整个画布的高 外圆直径 vp
  @Prop
  public strokeWidthVp: number = pp(8); // 内外圆间距 vp
  private _arcViewUtil: ArcViewUtil | undefined = undefined;
  private arcViewUtil = (): ArcViewUtil => {
    if (!this._arcViewUtil) {
      this._arcViewUtil = new ArcViewUtil(
        this.isDebug,
        this.maxAngleDegree,
        this.widthVp,
        this.heightVp,
        this.strokeWidthVp
      );
    }
    return this._arcViewUtil;
  };
  public clipOuterStartCoordinate =
    (): Coordinate => this.arcViewUtil().degreeToOuterCircleCoordinate(this.arcViewUtil().minAngleDegree);
  public clipInnerStartCoordinate =
    (): Coordinate => this.arcViewUtil().degreeToInnerCircleCoordinate(this.arcViewUtil().minAngleDegree);
  public clipInnerEndCoordinate =
    (): Coordinate => this.arcViewUtil().degreeToInnerCircleCoordinate(this.curAngleDegree);
  public clipOuterEndCoordinate =
    (): Coordinate => this.arcViewUtil().degreeToOuterCircleCoordinate(this.curAngleDegree);
  // private
  //endregion
  //region clip path shape
  private getClipPathShapeCommands = (): string => {
    let arcViewUtil = this.arcViewUtil();
    let outerRadiusPx = arcViewUtil.outerRadiusPx(); // 外圆半径
    let innerRadiusPx = arcViewUtil.innerRadiusPx(); // 内圆半径
    let largeArcFlag = this.curAngleDegree > 180 ? 1 : 0; // 大弧标志位
    let clipOuterStartCoordinate: Coordinate = this.clipOuterStartCoordinate(); // 左侧外圆起点
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
  private clipPathShape: PathShape | null = null;
  private updateClipShapePath = () => {
    if (this.disableClip) {
      this.clipPathShape = null;
      this.getClipPathShapeCommands();
    } else {
      this.clipPathShape = new PathShape({ commands: this.getClipPathShapeCommands() });
    }
  }
  //endregion
  private canvasRenderingContext2D: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(new RenderingContextSettings(true));

  onIsDebugChanged() {
    this.arcViewUtil().isDebug = this.isDebug;
    if (this.isDebug) {
      this.getClipPathShapeCommands();
    } else {
      this.clearCanvas();
    }
  }

  onCurAngleDegreeChanged() {
    this.updateClipShapePath();
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
      Gauge({
        value: this.gaugeValue,
        min: this.gaugeMin,
        max: this.gaugeMax
      })
        .startAngle(this.enableOriginAngle ? this.arcViewUtil().startAngleDegreeForGaugeOrigin() :
        this.arcViewUtil().startAngleDegreeForGauge())
        .endAngle(this.enableOriginAngle ? this.arcViewUtil().endAngleDegreeForGaugeOrigin() :
        this.arcViewUtil().endAngleDegreeForGauge())
        .colors(ArcColors.colorsToLinearGradient(this.colors))
        .width(this.widthVp)
        .height(this.widthVp)
        .strokeWidth(this.strokeWidthVp)
        .trackShadow({ radius: 7, offsetX: 7, offsetY: 7 })
        .description(null)
        .indicator(this.gaugeIndicatorOptions)
        .clipShape(this.clipPathShape)
        .backgroundColor(Color.Transparent)

      //region draw debug circle info
      Canvas(this.canvasRenderingContext2D)
        .width(this.widthVp)
        .height(this.heightVp)
        .backgroundColor(Color.Transparent)
        .onReady(() => {
          this.canvasRenderingContext2D.imageSmoothingEnabled = true; // 抗锯齿
          this.canvasRenderingContext2D.imageSmoothingQuality = 'medium'
          this.getClipPathShapeCommands();
        })
      //endregion
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
