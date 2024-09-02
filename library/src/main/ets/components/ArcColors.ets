export default class ArcColors {
  public static readonly arcInnerColors: Array<[
    string,
    number
  ]> = [
    ["#662F6CE0", 0.00],
    ["#66FF7A05", 0.04],
    ["#66FFBD00", 0.17],
    ["#6629CC6A", 0.40],
    ["#6629CC6A", 0.60],
    ["#6616BFE0", 0.90],
    ["#662F6CE0", 1.00],
  ]
  public static readonly arcOuterColors: Array<[
    string,
    number
  ]> = [
    ["#2F6CE0", 0.00],
    ["#FF7A05", 0.04],
    ["#FFBD00", 0.17],
    ["#29CC6A", 0.40],
    ["#29CC6A", 0.60],
    ["#16BFE0", 0.90],
    ["#2F6CE0", 1.00],
  ]

  public static colorsToStops(colors: Array<[string, number]>): ColorStop[] {
    return colors.map((item) => {
      return {
        color: item[0], offset: item[1]
      } as ColorStop;
    });
  }

  public static colorsToLinearGradient(colors: Array<[string, number]>): LinearGradient {
    return new LinearGradient(ArcColors.colorsToStops(colors))
  }

  public static colorsToCanvasGradient(colors: Array<[string, number]>, canvasGradient: CanvasGradient): CanvasGradient {
    colors.forEach((item) => {
      canvasGradient.addColorStop(item[1], item[0]);
    })
    return canvasGradient
  }
}
