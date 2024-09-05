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
import display from '@ohos.display';

let displayInfo: display.Display | undefined = undefined;

export const getDisplay = (): display.Display | undefined => {
  if (!displayInfo) {
    try {
      displayInfo = display.getDefaultDisplaySync();
    } catch (exception) {
      console.error('Failed to obtain the default display object. Code: ' + JSON.stringify(exception));
    }
  }
  return displayInfo;
}

/**
 * @return 宽和高中较小的那一个
 */
export const getDisplayWidth = (): number | undefined => {
  let displayInfo: display.Display | undefined = getDisplay();
  let deviceWidthPx = displayInfo?.width;
  let deviceHeightPx = displayInfo?.height;
  if (!deviceWidthPx || !deviceHeightPx) {
    return undefined;
  }
  return Math.min(deviceWidthPx, deviceHeightPx);
}

export const screenWidth = (): number | undefined => {
  return getDisplay()?.width || 0;
}

export const screenWidthVp = (): number => {
  return px2vp(screenWidth());
}

export const screenHeight = (): number | undefined => {
  return getDisplay()?.height || 0;
}

export const screenHeightVp = (): number => {
  return px2vp(screenHeight());
}

export type CustomPPFunction = (px: number, designWidthPx: number) => number;

let __customPP: CustomPPFunction | undefined = undefined;

/**
 * 自定义 pp
 */
export const setCustomPP = (customPP: CustomPPFunction | undefined) => {
  __customPP = customPP;
}

/**
 * pxToVp == pp
 *
 * @param px 视觉稿标注 px
 * @param designWidthPx 视觉稿屏幕宽度 px, 默认 375px
 */
export const pp = (px: number, designWidthPx: number = 375): number => {
  if (!!__customPP) {
    return __customPP(px, designWidthPx)
  }
  let displayWidth: number | undefined = getDisplayWidth();
  return !displayWidth ? px : px2vp(px / (designWidthPx / displayWidth));
}
