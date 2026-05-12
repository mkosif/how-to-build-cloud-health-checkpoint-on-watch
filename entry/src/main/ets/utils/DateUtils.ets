export class DateUtils {
  static formatYmd(date: Date): string {
    const y = date.getFullYear();
    const m = (date.getMonth() + 1).toString().padStart(2, '0');
    const d = date.getDate().toString().padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  static todayYmd(): string {
    return DateUtils.formatYmd(new Date());
  }

  static daysAgoYmd(days: number): string {
    const d = new Date();
    d.setDate(d.getDate() - days);
    return DateUtils.formatYmd(d);
  }

  static lastNDays(n: number): string[] {
    const out: string[] = [];
    for (let i = n - 1; i >= 0; i--) {
      out.push(DateUtils.daysAgoYmd(i));
    }
    return out;
  }
}
