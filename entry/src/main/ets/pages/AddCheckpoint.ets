import { HealthCheckpointPlain, validateCheckpoint, clonePlain } from '../models/HealthCheckpoint';
import { CloudDatabaseService } from '../services/CloudDatabaseService';
import { DEMO_USER_ID, MockHealthDataService } from '../services/MockHealthDataService';
import { WatchCard, StatusPill } from '../components/WatchCard';

@Component
export struct AddCheckpoint {
  @Consume('pathStack') pathStack: NavPathStack;
  @State draft: HealthCheckpointPlain = MockHealthDataService.generateToday();
  @State tone: string = 'idle';
  @State label: string = 'idle';
  @State msg: string = '';

  private setSteps(delta: number): void {
    const next = clonePlain(this.draft);
    next.steps = Math.max(0, this.draft.steps + delta);
    this.draft = next;
  }

  private setHr(delta: number): void {
    const next = clonePlain(this.draft);
    next.heartRate = Math.max(30, Math.min(220, this.draft.heartRate + delta));
    this.draft = next;
  }

  private setSleep(delta: number): void {
    const next = clonePlain(this.draft);
    next.sleepScore = Math.max(0, Math.min(100, this.draft.sleepScore + delta));
    this.draft = next;
  }

  async saveDraft(): Promise<void> {
    const v = validateCheckpoint(this.draft);
    if (!v.ok) {
      this.tone = 'err';
      this.label = 'invalid';
      this.msg = v.reason;
      return;
    }
    this.tone = 'busy';
    this.label = 'saving';
    this.msg = '';
    try {
      const count = await CloudDatabaseService.get().upsert(this.draft);
      this.tone = 'ok';
      this.label = 'saved';
      this.msg = `upsert ok (${count})`;
    } catch (e) {
      this.tone = 'err';
      this.label = 'failed';
      this.msg = (e as Error).message;
    }
  }

  @Builder
  stepper(label: string, value: string, onDec: () => void, onInc: () => void) {
    Row() {
      Text(label)
        .fontSize(11)
        .fontColor('#9AA0A6')
        .width(48);
      Button('-')
        .fontSize(14)
        .width(28)
        .height(28)
        .backgroundColor('#2A2D31')
        .onClick(onDec);
      Text(value)
        .fontSize(13)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center);
      Button('+')
        .fontSize(14)
        .width(28)
        .height(28)
        .backgroundColor('#2A2D31')
        .onClick(onInc);
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 8 }) {
          Row() {
            Text('Add Checkpoint')
              .fontSize(13)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1);
            StatusPill({ label: this.label, tone: this.tone });
          }
          .width('100%');

          WatchCard({ title: this.draft.checkpointDate }) {
            this.stepper('Steps', `${this.draft.steps}`,
              () => {
                this.setSteps(-500);
              },
              () => {
                this.setSteps(500);
              });
            this.stepper('HR', `${this.draft.heartRate}`,
              () => {
                this.setHr(-1);
              },
              () => {
                this.setHr(1);
              });
            this.stepper('Sleep', `${this.draft.sleepScore}`,
              () => {
                this.setSleep(-1);
              },
              () => {
                this.setSleep(1);
              });
          }

          Button('Re-mock today')
            .fontSize(11)
            .width('100%')
            .height(32)
            .backgroundColor('#2A2D31')
            .onClick(() => {
              this.draft = MockHealthDataService.generateToday(DEMO_USER_ID);
              this.tone = 'idle';
              this.label = 'idle';
              this.msg = '';
            });

          Button('Save to Cloud DB')
            .fontSize(12)
            .width('100%')
            .height(36)
            .backgroundColor('#1A73E8')
            .onClick(() => {
              this.saveDraft();
            });

          Button('Back')
            .fontSize(11)
            .width('100%')
            .height(30)
            .backgroundColor('#2A2D31')
            .onClick(() => {
              this.pathStack.pop();
            });

          if (this.msg.length > 0) {
            Text(this.msg)
              .fontSize(9)
              .fontColor(this.tone === 'err' ? '#E5484D' : '#9AA0A6')
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
    .hideTitleBar(true)
    .backgroundColor('#000000');
  }
}
