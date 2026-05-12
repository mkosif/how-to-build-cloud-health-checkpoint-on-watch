@Component
export struct WatchCard {
  @Prop title: string = '';
  @BuilderParam body: () => void;

  build() {
    Column() {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(12)
          .fontColor('#9AA0A6')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 });
      }
      this.body();
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(10)
    .backgroundColor('#111418')
    .borderRadius(14);
  }
}

@Component
export struct StatusPill {
  @Prop label: string = '';
  @Prop tone: string = 'idle';

  private toneColor(): string {
    if (this.tone === 'ok') {
      return '#2BB673';
    }
    if (this.tone === 'busy') {
      return '#F2A93B';
    }
    if (this.tone === 'err') {
      return '#E5484D';
    }
    return '#5F6368';
  }

  build() {
    Text(this.label)
      .fontSize(10)
      .fontColor('#FFFFFF')
      .backgroundColor(this.toneColor())
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      .borderRadius(8);
  }
}
