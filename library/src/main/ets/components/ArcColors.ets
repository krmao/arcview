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

  public static colorsToCanvasGradient(colors: Array<[string, number]>,
    canvasGradient: CanvasGradient): CanvasGradient {
    colors.forEach((item) => {
      canvasGradient.addColorStop(item[1], item[0]);
    })
    return canvasGradient
  }
}
