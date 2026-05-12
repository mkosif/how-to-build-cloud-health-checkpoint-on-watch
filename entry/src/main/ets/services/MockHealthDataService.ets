import { HealthCheckpointPlain } from '../models/HealthCheckpoint';
import { DateUtils } from '../utils/DateUtils';

export const DEMO_USER_ID = 'demo-watch-user';

interface RandState {
  s: number;
}

function seedFromDate(ymd: string): number {
  let h = 2166136261;
  for (let i = 0; i < ymd.length; i++) {
    h ^= ymd.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

function nextRand(state: RandState): number {
  state.s = (state.s * 1664525 + 1013904223) >>> 0;
  return state.s / 0xffffffff;
}

function rangeInt(state: RandState, min: number, max: number): number {
  return Math.floor(nextRand(state) * (max - min + 1)) + min;
}

export class MockHealthDataService {
  static generateFor(date: string, userId: string = DEMO_USER_ID): HealthCheckpointPlain {
    const state: RandState = { s: seedFromDate(date) };
    const steps = rangeInt(state, 3500, 11500);
    const heartRate = rangeInt(state, 58, 96);
    const sleepScore = rangeInt(state, 55, 95);
    const out: HealthCheckpointPlain = {
      id: `${userId}-${date}`,
      userId,
      checkpointDate: date,
      steps,
      heartRate,
      sleepScore,
      createdAt: Date.now(),
      reportPath: '',
    };
    return out;
  }

  static generateToday(userId: string = DEMO_USER_ID): HealthCheckpointPlain {
    return MockHealthDataService.generateFor(DateUtils.todayYmd(), userId);
  }

  static generateLastWeek(userId: string = DEMO_USER_ID): HealthCheckpointPlain[] {
    return DateUtils.lastNDays(7).map((d: string) => MockHealthDataService.generateFor(d, userId));
  }
}
