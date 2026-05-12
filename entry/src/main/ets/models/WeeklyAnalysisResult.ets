export interface WeeklyAnalysisResult {
  trend: string;
  weeklyAverageSteps: number;
  weeklyAverageHeartRate: number;
  weeklyAverageSleepScore: number;
  anomalies: string[];
  summary: string;
}

export function emptyAnalysisResult(): WeeklyAnalysisResult {
  return {
    trend: 'unknown',
    weeklyAverageSteps: 0,
    weeklyAverageHeartRate: 0,
    weeklyAverageSleepScore: 0,
    anomalies: [],
    summary: '',
  };
}
