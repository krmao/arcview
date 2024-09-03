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


/**
 * pxToVp == pp
 *
 * @param px 视觉稿标注 px
 * @param designWidthPx 视觉稿屏幕宽度 px, 默认 375px
 */
export const pp = (px: number, designWidthPx: number = 375): number => {
  let displayWidth: number | undefined = getDisplayWidth();
  return !displayWidth ? px : px2vp(px / (designWidthPx / displayWidth));
}

export const statusBarHeightVp = (): number => {
  return AppStorage.get<number>('statusBarHeight') || 0;
}

export const naviBarHeightVp = (): number => {
  return AppStorage.get<number>('naviIndicatorHeight') || 0;
}

/**
 * 多个相同名称的页面情况下, 取栈顶参数
 * @param navPathStack
 * @param name
 * @returns
 */
export function getTopStackParam<T>(navPathStack: NavPathStack | undefined,
  name: string | undefined): T | undefined {
  if (!navPathStack || !name?.length) {
    return undefined;
  }
  let params: Array<T> | undefined = navPathStack.getParamByName(name) as Array<T>;
  return !!params?.length ? params[params.length-1] : undefined
}

/**
 * NavDestination#onReady
 * @param navDestinationContext
 * @returns
 */
export function getStackOnNavDestinationReady(navDestinationContext: NavDestinationContext): NavPathStack | undefined {
  return navDestinationContext.pathStack
}

/**
 * NavDestination#onReady
 * @param navDestinationContext
 * @returns
 */
export function getParamOnNavDestinationReady<T>(navDestinationContext: NavDestinationContext): T | undefined {
  return navDestinationContext.pathInfo.param as T
}
