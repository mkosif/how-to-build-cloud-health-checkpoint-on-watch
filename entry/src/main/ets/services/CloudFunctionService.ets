import { cloudFunction } from '@kit.CloudFoundationKit';
import { HealthCheckpointPlain } from '../models/HealthCheckpoint';
import { WeeklyAnalysisResult } from '../models/WeeklyAnalysisResult';

export const ANALYZE_FUNCTION_NAME = 'analyzeWeeklyHealth';

interface AnalyzePayloadCheckpoint {
  checkpointDate: string;
  steps: number;
  heartRate: number;
  sleepScore: number;
}

interface AnalyzePayload {
  userId: string;
  checkpoints: AnalyzePayloadCheckpoint[];
}

interface AnalyzeResponse {
  trend?: string;
  weeklyAverageSteps?: number;
  weeklyAverageHeartRate?: number;
  weeklyAverageSleepScore?: number;
  anomalies?: string[];
  summary?: string;
}

export class CloudFunctionService {
  private static instance: CloudFunctionService | null = null;

  static get(): CloudFunctionService {
    if (CloudFunctionService.instance === null) {
      CloudFunctionService.instance = new CloudFunctionService();
    }
    return CloudFunctionService.instance;
  }

  async analyzeWeekly(
    userId: string,
    checkpoints: HealthCheckpointPlain[]
  ): Promise<WeeklyAnalysisResult> {
    const items: AnalyzePayloadCheckpoint[] = checkpoints.map((c: HealthCheckpointPlain) => {
      const item: AnalyzePayloadCheckpoint = {
        checkpointDate: c.checkpointDate,
        steps: c.steps,
        heartRate: c.heartRate,
        sleepScore: c.sleepScore
      };
      return item;
    });
    const payload: AnalyzePayload = { userId, checkpoints: items };

    const params: cloudFunction.FunctionParams = {
      name: ANALYZE_FUNCTION_NAME,
      version: '$latest',
      timeout: 15000,
      data: payload
    };
    const response: cloudFunction.FunctionResult = await cloudFunction.call(params);

    let parsed: AnalyzeResponse = {};
    const raw: string | Object = response.result;
    if (typeof raw === 'string') {
      parsed = JSON.parse(raw as string) as AnalyzeResponse;
    } else {
      parsed = raw as AnalyzeResponse;
    }

    const out: WeeklyAnalysisResult = {
      trend: parsed.trend ?? 'unknown',
      weeklyAverageSteps: parsed.weeklyAverageSteps ?? 0,
      weeklyAverageHeartRate: parsed.weeklyAverageHeartRate ?? 0,
      weeklyAverageSleepScore: parsed.weeklyAverageSleepScore ?? 0,
      anomalies: parsed.anomalies ?? [],
      summary: parsed.summary ?? ''
    };
    return out;
  }
}
