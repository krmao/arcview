import { ArcProgressView, pp } from '@codesdancing/arcview';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Scroll() {
      Column() {
        Text('ARCVIEW').margin(pp(32)).fontSize(40).fontWeight(700)

        ArcProgressView()
          .margin(pp(32))
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
      }
      .padding({ top: pp(80) })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height(1200)
    }
    .height('100%')
    .width('100%')
  }
}