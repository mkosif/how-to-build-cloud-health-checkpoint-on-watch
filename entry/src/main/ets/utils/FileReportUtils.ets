import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { HealthCheckpointPlain } from '../models/HealthCheckpoint';

export class FileReportUtils {
  static exportFileName(): string {
    return 'checkpoints.json';
  }

  static reportFileName(): string {
    return 'weekly-summary.pdf';
  }

  static exportLocalPath(ctx: common.Context): string {
    return `${ctx.filesDir}/${FileReportUtils.exportFileName()}`;
  }

  static reportLocalPath(ctx: common.Context): string {
    return `${ctx.filesDir}/${FileReportUtils.reportFileName()}`;
  }

  static async writeExportJson(ctx: common.Context, checkpoints: HealthCheckpointPlain[]): Promise<string> {
    const path = FileReportUtils.exportLocalPath(ctx);
    const payload = JSON.stringify({
      exportedAt: Date.now(),
      count: checkpoints.length,
      checkpoints,
    });
    let file: fileIo.File | null = null;
    try {
      file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(file.fd, payload);
      return path;
    } finally {
      if (file !== null) {
        fileIo.closeSync(file);
      }
    }
  }

  static async exists(path: string): Promise<boolean> {
    try {
      await fileIo.access(path);
      return true;
    } catch (_e) {
      return false;
    }
  }

  static async sizeOf(path: string): Promise<number> {
    try {
      const stat = await fileIo.stat(path);
      return stat.size;
    } catch (_e) {
      return 0;
    }
  }
}
