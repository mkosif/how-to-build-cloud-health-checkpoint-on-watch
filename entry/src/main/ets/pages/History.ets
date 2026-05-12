import { router } from '@kit.ArkUI';
import { HealthCheckpointPlain } from '../models/HealthCheckpoint';
import { CloudDatabaseService } from '../services/CloudDatabaseService';
import { DEMO_USER_ID, MockHealthDataService } from '../services/MockHealthDataService';
import { WatchCard, StatusPill } from '../components/WatchCard';

@Entry
@Component
struct History {
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
        .width(40);
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
    Scroll() {
      Column({ space: 8 }) {
        Row() {
          Text('History')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1);
          StatusPill({ label: this.label, tone: this.tone });
        }
        .width('100%');

        WatchCard({ title: 'DATE / STEPS / HR / SLP' }) {
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

        Button('Reload')
          .fontSize(11)
          .width('100%')
          .height(32)
          .backgroundColor('#2A2D31')
          .onClick(() => this.load());

        Button('Seed mock 7d')
          .fontSize(11)
          .width('100%')
          .height(32)
          .backgroundColor('#1A73E8')
          .onClick(() => this.seedMockWeek());

        Button('Back')
          .fontSize(11)
          .width('100%')
          .height(30)
          .backgroundColor('#2A2D31')
          .onClick(() => router.back());

        if (this.msg.length > 0) {
          Text(this.msg)
            .fontSize(9)
            .fontColor('#E5484D')
            .maxLines(3)
            .width('100%');
        }
      }
      .width('100%')
      .padding(10);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .scrollBar(BarState.Off);
  }
}
