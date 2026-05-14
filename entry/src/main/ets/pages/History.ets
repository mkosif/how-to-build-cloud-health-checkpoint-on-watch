import { HealthCheckpointPlain } from '../models/HealthCheckpoint';
import { CloudDatabaseService } from '../services/CloudDatabaseService';
import { DEMO_USER_ID, MockHealthDataService } from '../services/MockHealthDataService';
import { WatchCard, StatusPill } from '../components/WatchCard';

@Component
export struct History {
  @Consume('pathStack') pathStack: NavPathStack;
  @State rows: HealthCheckpointPlain[] = [];
  @State tone: string = 'idle';
  @State label: string = 'idle';
  @State msg: string = '';

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.tone = 'busy';
    this.label = 'loading';
    this.msg = '';
    try {
      const rows = await CloudDatabaseService.get().recentCheckpoints(DEMO_USER_ID, 7);
      this.rows = rows;
      this.tone = 'ok';
      this.label = `${rows.length} rows`;
    } catch (e) {
      this.tone = 'err';
      this.label = 'failed';
      this.msg = (e as Error).message;
    }
  }

  async seedMockWeek(): Promise<void> {
    this.tone = 'busy';
    this.label = 'seeding';
    try {
      const all = MockHealthDataService.generateLastWeek(DEMO_USER_ID);
      const svc = CloudDatabaseService.get();
      for (const c of all) {
        await svc.upsert(c);
      }
      await this.load();
    } catch (e) {
      this.tone = 'err';
      this.label = 'failed';
      this.msg = (e as Error).message;
    }
  }

  @Builder
  rowItem(item: HealthCheckpointPlain) {
    Row() {
      Text(item.checkpointDate.substring(5))
        .fontSize(11)
        .fontColor('#9AA0A6')
        .width(42);
      Text(`${item.steps}`)
        .fontSize(11)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .textAlign(TextAlign.Center);
      Text(`${item.heartRate}`)
        .fontSize(11)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .textAlign(TextAlign.Center);
      Text(`${item.sleepScore}`)
        .fontSize(11)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 });
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 8 }) {
          Row() {
            StatusPill({ label: this.label, tone: this.tone });
          }
          .width('100%')
          .justifyContent(FlexAlign.Center);

          Text('History')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%');

          WatchCard({ title: 'DATE  STEPS  HR  SLP' }) {
            if (this.rows.length === 0) {
              Text('no rows yet')
                .fontSize(11)
                .fontColor('#9AA0A6');
            } else {
              ForEach(this.rows, (item: HealthCheckpointPlain) => {
                this.rowItem(item);
              }, (item: HealthCheckpointPlain) => item.id);
            }
          }

          Button() {
            Text('Reload')
              .fontSize(12)
              .fontColor('#FFFFFF');
          }
          .width('100%')
          .height(36)
          .backgroundColor('#2A2D31')
          .onClick(() => {
            this.load();
          });

          Button() {
            Text('Seed mock 7d')
              .fontSize(13)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium);
          }
          .width('100%')
          .height(40)
          .backgroundColor('#1A73E8')
          .onClick(() => {
            this.seedMockWeek();
          });

          Button() {
            Text('Back')
              .fontSize(12)
              .fontColor('#FFFFFF');
          }
          .width('100%')
          .height(34)
          .backgroundColor('#2A2D31')
          .onClick(() => {
            this.pathStack.pop();
          });

          if (this.msg.length > 0) {
            Text(this.msg)
              .fontSize(9)
              .fontColor('#E5484D')
              .maxLines(4)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%');
          }
        }
        .width('100%')
        .padding({ top: 40, bottom: 60, left: 32, right: 32 });
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);
    }
    .hideTitleBar(true)
    .backgroundColor('#000000');
  }
}
