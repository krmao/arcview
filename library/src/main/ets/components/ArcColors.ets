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
    ["#66D0DAE4", 0.00],
    ["#662A6078", 0.33],
    ["#66B9CD74", 0.66],
    ["#66085438", 1.00],
  ]
  public static readonly arcOuterColors: Array<[
    string,
    number
  ]> = [
    ["#FFD0DAE4", 0.00],
    ["#FF2A6078", 0.33],
    ["#FFB9CD74", 0.66],
    ["#FF085438", 1.00],
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
