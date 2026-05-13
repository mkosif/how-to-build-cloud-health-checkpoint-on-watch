import { common } from '@kit.AbilityKit';
import { CloudDatabaseService } from '../services/CloudDatabaseService';
import { CloudStorageService } from '../services/CloudStorageService';
import { DEMO_USER_ID } from '../services/MockHealthDataService';
import { FileReportUtils } from '../utils/FileReportUtils';
import { WatchCard, StatusPill } from '../components/WatchCard';

@Component
export struct Reports {
  @Consume('pathStack') pathStack: NavPathStack;
  @State tone: string = 'idle';
  @State label: string = 'idle';
  @State exportPath: string = '';
  @State remoteExportPath: string = '';
  @State reportPath: string = '';
  @State reportSize: number = 0;
  @State msg: string = '';

  private ctx(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  async uploadExport(): Promise<void> {
    this.tone = 'busy';
    this.label = 'exporting';
    this.msg = '';
    try {
      const rows = await CloudDatabaseService.get().recentCheckpoints(DEMO_USER_ID, 7);
      if (rows.length === 0) {
        this.tone = 'err';
        this.label = 'no data';
        this.msg = 'Seed checkpoints in History first';
        return;
      }
      const local = await FileReportUtils.writeExportJson(this.ctx(), rows);
      this.exportPath = local;
      this.label = 'uploading';
      const remote = await CloudStorageService.get().uploadExport(this.ctx(), DEMO_USER_ID, local);
      this.remoteExportPath = remote;
      this.tone = 'ok';
      this.label = 'uploaded';
    } catch (e) {
      this.tone = 'err';
      this.label = 'failed';
      this.msg = (e as Error).message;
    }
  }

  async downloadReport(): Promise<void> {
    this.tone = 'busy';
    this.label = 'downloading';
    this.msg = '';
    try {
      const local = FileReportUtils.reportLocalPath(this.ctx());
      await CloudStorageService.get().downloadReport(this.ctx(), DEMO_USER_ID, local);
      this.reportPath = local;
      this.reportSize = await FileReportUtils.sizeOf(local);
      this.tone = 'ok';
      this.label = 'downloaded';
    } catch (e) {
      this.tone = 'err';
      this.label = 'failed';
      this.msg = (e as Error).message;
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 8 }) {
          Row() {
            Text('Reports')
              .fontSize(13)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1);
            StatusPill({ label: this.label, tone: this.tone });
          }
          .width('100%');

          WatchCard({ title: 'EXPORT (uploadFile)' }) {
            Text(this.exportPath.length > 0 ? this.exportPath : '- not exported yet')
              .fontSize(9)
              .fontColor('#9AA0A6')
              .maxLines(2)
              .width('100%');
            if (this.remoteExportPath.length > 0) {
              Text(`cloud: ${this.remoteExportPath}`)
                .fontSize(9)
                .fontColor('#2BB673')
                .maxLines(2)
                .width('100%')
                .margin({ top: 2 });
            }
          }

          WatchCard({ title: 'REPORT (downloadFile)' }) {
            Text(this.reportPath.length > 0 ? this.reportPath : '- not downloaded yet')
              .fontSize(9)
              .fontColor('#9AA0A6')
              .maxLines(2)
              .width('100%');
            if (this.reportSize > 0) {
              Text(`size: ${this.reportSize} bytes`)
                .fontSize(9)
                .fontColor('#2BB673')
                .margin({ top: 2 });
            }
          }

          Button('Upload export')
            .fontSize(12)
            .width('100%')
            .height(34)
            .backgroundColor('#1A73E8')
            .onClick(() => {
              this.uploadExport();
            });

          Button('Download report')
            .fontSize(12)
            .width('100%')
            .height(34)
            .backgroundColor('#1A73E8')
            .onClick(() => {
              this.downloadReport();
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
    .hideTitleBar(true)
    .backgroundColor('#000000');
  }
}
