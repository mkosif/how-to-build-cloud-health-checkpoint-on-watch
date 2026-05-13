import { cloudDatabase } from '@kit.CloudFoundationKit';

export class HealthCheckpoint extends cloudDatabase.DatabaseObject {
  public id: string = '';
  public userId: string = '';
  public checkpointDate: string = '';
  public steps: number = 0;
  public heartRate: number = 0;
  public sleepScore: number = 0;
  public createdAt: number = 0;
  public reportPath: string = '';

  naturalbase_ClassName(): string {
    return 'HealthCheckpoint';
  }

  static fromPlain(plain: HealthCheckpointPlain): HealthCheckpoint {
    const obj = new HealthCheckpoint();
    obj.id = plain.id;
    obj.userId = plain.userId;
    obj.checkpointDate = plain.checkpointDate;
    obj.steps = plain.steps;
    obj.heartRate = plain.heartRate;
    obj.sleepScore = plain.sleepScore;
    obj.createdAt = plain.createdAt;
    obj.reportPath = plain.reportPath;
    return obj;
  }

  toPlain(): HealthCheckpointPlain {
    const out: HealthCheckpointPlain = {
      id: this.id,
      userId: this.userId,
      checkpointDate: this.checkpointDate,
      steps: this.steps,
      heartRate: this.heartRate,
      sleepScore: this.sleepScore,
      createdAt: this.createdAt,
      reportPath: this.reportPath
    };
    return out;
  }
}

export interface HealthCheckpointPlain {
  id: string;
  userId: string;
  checkpointDate: string;
  steps: number;
  heartRate: number;
  sleepScore: number;
  createdAt: number;
  reportPath: string;
}

export interface CheckpointValidation {
  ok: boolean;
  reason: string;
}

export function validateCheckpoint(c: HealthCheckpointPlain): CheckpointValidation {
  if (!c.checkpointDate || c.checkpointDate.length !== 10) {
    const r: CheckpointValidation = { ok: false, reason: 'checkpointDate must be YYYY-MM-DD' };
    return r;
  }
  if (c.steps < 0 || c.steps > 100000) {
    const r: CheckpointValidation = { ok: false, reason: 'steps must be 0..100000' };
    return r;
  }
  if (c.heartRate < 30 || c.heartRate > 220) {
    const r: CheckpointValidation = { ok: false, reason: 'heartRate must be 30..220' };
    return r;
  }
  if (c.sleepScore < 0 || c.sleepScore > 100) {
    const r: CheckpointValidation = { ok: false, reason: 'sleepScore must be 0..100' };
    return r;
  }
  const ok: CheckpointValidation = { ok: true, reason: '' };
  return ok;
}

export function clonePlain(c: HealthCheckpointPlain): HealthCheckpointPlain {
  const out: HealthCheckpointPlain = {
    id: c.id,
    userId: c.userId,
    checkpointDate: c.checkpointDate,
    steps: c.steps,
    heartRate: c.heartRate,
    sleepScore: c.sleepScore,
    createdAt: c.createdAt,
    reportPath: c.reportPath
  };
  return out;
}
