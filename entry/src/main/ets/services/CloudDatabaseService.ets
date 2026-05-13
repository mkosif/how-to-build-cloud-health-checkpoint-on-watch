import { cloudDatabase } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { HealthCheckpoint, HealthCheckpointPlain } from '../models/HealthCheckpoint';

export const ZONE_NAME = 'HealthCheckpointZone';

export class CloudDatabaseService {
  private static instance: CloudDatabaseService | null = null;
  private zone: cloudDatabase.DatabaseZone | null = null;
  private initialized: boolean = false;

  static get(): CloudDatabaseService {
    if (CloudDatabaseService.instance === null) {
      CloudDatabaseService.instance = new CloudDatabaseService();
    }
    return CloudDatabaseService.instance;
  }

  async init(): Promise<void> {
    if (this.initialized) {
      return;
    }
    try {
      this.zone = cloudDatabase.zone(ZONE_NAME);
      this.initialized = true;
    } catch (e) {
      const err = e as BusinessError;
      throw new Error(`zone init failed: ${err.code} ${err.message}`);
    }
  }

  async upsert(plain: HealthCheckpointPlain): Promise<number> {
    await this.init();
    if (this.zone === null) {
      throw new Error('zone not ready');
    }
    const obj = HealthCheckpoint.fromPlain(plain);
    return await this.zone.upsert(obj);
  }

  async recentCheckpoints(userId: string, limit: number = 7): Promise<HealthCheckpointPlain[]> {
    await this.init();
    if (this.zone === null) {
      throw new Error('zone not ready');
    }
    const query = new cloudDatabase.DatabaseQuery<HealthCheckpoint>(HealthCheckpoint)
      .equalTo('userId', userId)
      .orderByDesc('checkpointDate')
      .limit(limit);
    const rows: HealthCheckpoint[] = await this.zone.query(query);
    return rows.map((r: HealthCheckpoint) => r.toPlain());
  }

  async deleteAllForUser(userId: string): Promise<number> {
    await this.init();
    if (this.zone === null) {
      throw new Error('zone not ready');
    }
    const query = new cloudDatabase.DatabaseQuery<HealthCheckpoint>(HealthCheckpoint)
      .equalTo('userId', userId);
    const rows: HealthCheckpoint[] = await this.zone.query(query);
    if (rows.length === 0) {
      return 0;
    }
    return await this.zone.delete(rows);
  }

  isReady(): boolean {
    return this.initialized;
  }
}
