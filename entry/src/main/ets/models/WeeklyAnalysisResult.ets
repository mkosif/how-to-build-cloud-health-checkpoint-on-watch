export interface WeeklyAnalysisResult {
  trend: string;
  weeklyAverageSteps: number;
  weeklyAverageHeartRate: number;
  weeklyAverageSleepScore: number;
  anomalies: string[];
  summary: string;
}

export function emptyAnalysisResult(): WeeklyAnalysisResult {
  const r: WeeklyAnalysisResult = {
    trend: 'unknown',
    weeklyAverageSteps: 0,
    weeklyAverageHeartRate: 0,
    weeklyAverageSleepScore: 0,
    anomalies: [],
    summary: ''
  };
  return r;
}
