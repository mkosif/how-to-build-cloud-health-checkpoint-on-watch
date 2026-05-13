import { HealthCheckpointPlain } from '../models/HealthCheckpoint';
import { CloudDatabaseService } from '../services/CloudDatabaseService';
import { DEMO_USER_ID, MockHealthDataService } from '../services/MockHealthDataService';
import { WatchCard, StatusPill } from '../components/WatchCard';
import { AddCheckpoint } from './AddCheckpoint';
import { History } from './History';
import { Analysis } from './Analysis';
import { Reports } from './Reports';

@Builder
function pageMap(name: string) {
  if (name === 'AddCheckpoint') {
    AddCheckpoint();
  } else if (name === 'History') {
    History();
  } else if (name === 'Analysis') {
    Analysis();
  } else if (name === 'Reports') {
    Reports();
  }
}

@Entry
@Component
struct Index {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();
  @State latest: HealthCheckpointPlain | null = null;
  @State cloudTone: string = 'idle';
  @State cloudLabel: string = 'idle';
  @State errorMsg: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  onPageShow(): void {
    this.refresh();
  }

  async refresh(): Promise<void> {
    this.cloudTone = 'busy';
    this.cloudLabel = 'syncing';
    try {
      const rows = await CloudDatabaseService.get().recentCheckpoints(DEMO_USER_ID, 1);
      if (rows.length > 0) {
        this.latest = rows[0];
      } else {
        this.latest = MockHealthDataService.generateToday();
      }
      this.cloudTone = 'ok';
      this.cloudLabel = 'ready';
      this.errorMsg = '';
    } catch (e) {
      this.cloudTone = 'err';
      this.cloudLabel = 'offline';
      this.errorMsg = (e as Error).message;
      if (this.latest === null) {
        this.latest = MockHealthDataService.generateToday();
      }
    }
  }

  @Builder
  metric(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold);
      Text(label)
        .fontSize(9)
        .fontColor('#9AA0A6');
    }
    .alignItems(HorizontalAlign.Center);
  }

  build() {
    Navigation(this.pathStack) {
      Scroll() {
        Column({ space: 8 }) {
          Row() {
            Text('Health Checkpoint')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1);
            StatusPill({ label: this.cloudLabel, tone: this.cloudTone });
          }
          .width('100%')
          .alignItems(VerticalAlign.Center);

          WatchCard({ title: 'TODAY' }) {
            if (this.latest !== null) {
              Row() {
                this.metric('Steps', `${this.latest.steps}`);
                this.metric('HR', `${this.latest.heartRate}`);
                this.metric('Sleep', `${this.latest.sleepScore}`);
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween);
              Text(this.latest.checkpointDate)
                .fontSize(10)
                .fontColor('#9AA0A6')
                .margin({ top: 4 });
            } else {
              Text('no data')
                .fontSize(12)
                .fontColor('#9AA0A6');
            }
          }

          Button('Add Checkpoint')
            .fontSize(12)
            .width('100%')
            .height(36)
            .backgroundColor('#1A73E8')
            .onClick(() => {
              this.pathStack.pushPathByName('AddCheckpoint', null);
            });

          Button('History')
            .fontSize(12)
            .width('100%')
            .height(36)
            .backgroundColor('#2A2D31')
            .onClick(() => {
              this.pathStack.pushPathByName('History', null);
            });

          Button('Weekly Analysis')
            .fontSize(12)
            .width('100%')
            .height(36)
            .backgroundColor('#2A2D31')
            .onClick(() => {
              this.pathStack.pushPathByName('Analysis', null);
            });

          Button('Reports')
            .fontSize(12)
            .width('100%')
            .height(36)
            .backgroundColor('#2A2D31')
            .onClick(() => {
              this.pathStack.pushPathByName('Reports', null);
            });

          if (this.errorMsg.length > 0) {
            Text(this.errorMsg)
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
      .scrollBar(BarState.Off);
    }
    .navDestination(pageMap)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor('#000000');
  }
}
