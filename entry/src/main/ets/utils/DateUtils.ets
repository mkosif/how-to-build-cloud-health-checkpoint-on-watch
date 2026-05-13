const MS_PER_DAY = 86400000;

export class DateUtils {
  static formatYmd(date: Date): string {
    const y = date.getFullYear();
    const m = (date.getMonth() + 1).toString().padStart(2, '0');
    const d = date.getDate().toString().padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  static todayYmd(): string {
    const today = new Date();
    return DateUtils.formatYmd(today);
  }

  static daysAgoYmd(days: number): string {
    const baseMs = Date.now();
    const cursor = new Date(baseMs - days * MS_PER_DAY);
    return DateUtils.formatYmd(cursor);
  }

  static lastNDays(n: number): string[] {
    const out: string[] = [];
    const baseMs = Date.now();
    const cursor = new Date(baseMs);
    for (let i = n - 1; i >= 0; i--) {
      cursor.setTime(baseMs - i * MS_PER_DAY);
      out.push(DateUtils.formatYmd(cursor));
    }
    return out;
  }
}
