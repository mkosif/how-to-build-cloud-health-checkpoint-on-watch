import { cloudStorage } from '@kit.CloudFoundationKit';
import { common } from '@kit.AbilityKit';

export class CloudStorageService {
  private static instance: CloudStorageService | null = null;

  static get(): CloudStorageService {
    if (CloudStorageService.instance === null) {
      CloudStorageService.instance = new CloudStorageService();
    }
    return CloudStorageService.instance;
  }

  private bucketRef(): cloudStorage.StorageBucket {
    return cloudStorage.bucket();
  }

  exportCloudPath(userId: string): string {
    return `exports/${userId}/checkpoints.json`;
  }

  reportCloudPath(userId: string): string {
    return `reports/${userId}/weekly-summary.pdf`;
  }

  async uploadExport(ctx: common.BaseContext, userId: string, localPath: string): Promise<string> {
    const cloudPath = this.exportCloudPath(userId);
    const params: cloudStorage.UploadParams = { localPath, cloudPath };
    await this.bucketRef().uploadFile(ctx, params);
    return cloudPath;
  }

  async downloadReport(ctx: common.BaseContext, userId: string, localPath: string): Promise<string> {
    const cloudPath = this.reportCloudPath(userId);
    const params: cloudStorage.DownloadParams = { localPath, cloudPath, overwrite: true };
    await this.bucketRef().downloadFile(ctx, params);
    return localPath;
  }
}
