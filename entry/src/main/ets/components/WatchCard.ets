@Component
export struct WatchCard {
  @Prop title: string = '';
  @BuilderParam body: () => void;

  build() {
    Column() {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(11)
          .fontColor('#9AA0A6')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 6 });
      }
      this.body();
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(12)
    .backgroundColor('#111418')
    .borderRadius(16);
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
      .fontWeight(FontWeight.Medium)
      .backgroundColor(this.toneColor())
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .borderRadius(10);
  }
}
