import { router } from '@kit.ArkUI';
import { CloudDatabaseService } from '../services/CloudDatabaseService';
import { CloudFunctionService } from '../services/CloudFunctionService';
import { DEMO_USER_ID } from '../services/MockHealthDataService';
import { WeeklyAnalysisResult, emptyAnalysisResult } from '../models/WeeklyAnalysisResult';
import { WatchCard, StatusPill } from '../components/WatchCard';

@Entry
@Component
struct Analysis {
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
    .width('100%');
  }

  build() {
    Scroll() {
      Column({ space: 8 }) {
        Row() {
          Text('Weekly Analysis')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1);
          StatusPill({ label: this.label, tone: this.tone });
        }
        .width('100%');

        if (this.hasResult) {
          WatchCard({ title: 'AVERAGES' }) {
            this.avgRow('Steps', this.result.weeklyAverageSteps);
            this.avgRow('HR', this.result.weeklyAverageHeartRate);
            this.avgRow('Sleep', this.result.weeklyAverageSleepScore);
          }

          WatchCard({ title: 'SUMMARY' }) {
            Text(this.result.summary.length > 0 ? this.result.summary : '—')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .maxLines(6);
          }

          if (this.result.anomalies.length > 0) {
            WatchCard({ title: 'ANOMALIES' }) {
              ForEach(this.result.anomalies, (a: string) => {
                Text(`• ${a}`)
                  .fontSize(10)
                  .fontColor('#F2A93B')
                  .maxLines(3)
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
              .maxLines(4);
          }
        }

        Button('Run analysis')
          .fontSize(12)
          .width('100%')
          .height(36)
          .backgroundColor('#1A73E8')
          .onClick(() => this.run());

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
