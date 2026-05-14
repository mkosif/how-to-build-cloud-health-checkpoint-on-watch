import { CloudDatabaseService } from '../services/CloudDatabaseService';
import { CloudFunctionService } from '../services/CloudFunctionService';
import { DEMO_USER_ID } from '../services/MockHealthDataService';
import { WeeklyAnalysisResult, emptyAnalysisResult } from '../models/WeeklyAnalysisResult';
import { WatchCard, StatusPill } from '../components/WatchCard';

@Component
export struct Analysis {
  @Consume('pathStack') pathStack: NavPathStack;
  @State result: WeeklyAnalysisResult = emptyAnalysisResult();
  @State hasResult: boolean = false;
  @State tone: string = 'idle';
  @State label: string = 'idle';
  @State msg: string = '';

  async run(): Promise<void> {
    this.tone = 'busy';
    this.label = 'analyzing';
    this.msg = '';
    try {
      const checkpoints = await CloudDatabaseService.get().recentCheckpoints(DEMO_USER_ID, 7);
      if (checkpoints.length === 0) {
        this.tone = 'err';
        this.label = 'no data';
        this.msg = 'Seed checkpoints in History first';
        return;
      }
      const res = await CloudFunctionService.get().analyzeWeekly(DEMO_USER_ID, checkpoints);
      this.result = res;
      this.hasResult = true;
      this.tone = 'ok';
      this.label = res.trend;
    } catch (e) {
      this.tone = 'err';
      this.label = 'failed';
      this.msg = (e as Error).message;
    }
  }

  @Builder
  avgRow(label: string, value: number) {
    Row() {
      Text(label)
        .fontSize(11)
        .fontColor('#9AA0A6')
        .layoutWeight(1);
      Text(`${value}`)
        .fontSize(12)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold);
    }
    .width('100%')
    .padding({ top: 2, bottom: 2 });
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

          Text('Weekly Analysis')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%');

          if (this.hasResult) {
            WatchCard({ title: 'AVERAGES' }) {
              this.avgRow('Steps', this.result.weeklyAverageSteps);
              this.avgRow('HR', this.result.weeklyAverageHeartRate);
              this.avgRow('Sleep', this.result.weeklyAverageSleepScore);
            }

            WatchCard({ title: 'SUMMARY' }) {
              Text(this.result.summary.length > 0 ? this.result.summary : '-')
                .fontSize(11)
                .fontColor('#FFFFFF')
                .maxLines(8)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }

            if (this.result.anomalies.length > 0) {
              WatchCard({ title: 'ANOMALIES' }) {
                ForEach(this.result.anomalies, (a: string) => {
                  Text(`* ${a}`)
                    .fontSize(10)
                    .fontColor('#F2A93B')
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                    .margin({ top: 2 });
                }, (a: string) => a);
              }
            }
          } else {
            WatchCard({ title: 'CLOUD FUNCTION' }) {
              Text('Invokes analyzeWeeklyHealth with the last 7 checkpoints from Cloud DB.')
                .fontSize(10)
                .fontColor('#9AA0A6')
                .maxLines(6);
            }
          }

          Button() {
            Text('Run analysis')
              .fontSize(13)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium);
          }
          .width('100%')
          .height(40)
          .backgroundColor('#1A73E8')
          .onClick(() => {
            this.run();
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
