## arcview

> [https://github.com/krmao/arcview](https://github.com/krmao/arcview)

### install

```shell
ohpm install arcview
```

### usage

- ArcProgressView
    ```typescript
    import { ArcProgressView, pp } from '@codesdancing/arcview';
    
    ArcProgressView()
    ```
    - options
      ```typescript
        private isDebug: boolean = true;
        private steps: number = 10;
        private bgColor: string = '#BED7F2';
        private maxAngleDegree: ANGLE_DEGREE = 320; // 最大角度 度
        private curAngleDegree: ANGLE_DEGREE = 320 / 10 * 5; // 当前角度 度 [minAngleDegree, maxAngleDegree]
        private widthVp: number = pp(256); // 整个画布的宽 外圆直径 vp
        private heightVp: number = pp(256); // 整个画布的高 外圆直径 vp
      ```

- ArcView
    ```typescript
    import { ArcProgressView, ArcView, pp } from '@codesdancing/arcview';
    
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
        gaugeValue: this.gaugeValue,
        gaugeMin: this.gaugeMin,
        gaugeMax: this.gaugeMax,
      })
    ```

### features

- gauge with fixed gradient clip

### preview

- ![preview.gif](library%2Fpriview%2Fpreview.gif)