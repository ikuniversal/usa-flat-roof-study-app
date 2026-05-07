// Compute current and longest consecutive-day reading streaks from a
// list of `read_at` timestamps (one per completed reading_progress row).
// "Day" is interpreted in the user's locale (UTC isn't right for a
// streak — we want "did I read today?" by their wall clock). The
// caller passes timestamps already filtered to completed=true rows.
//
// Returns:
//   currentStreak: consecutive days ending at today (or yesterday if
//                  the user hasn't read yet today). 0 if no reads in
//                  the last day.
//   longestStreak: longest run anywhere in history.
//   lastReadAt:    most recent read_at, or null if no reads.
export type StreakStats = {
  currentStreak: number;
  longestStreak: number;
  lastReadAt: Date | null;
};

function dayKey(d: Date): string {
  // YYYY-MM-DD in local time.
  const y = d.getFullYear();
  const m = (d.getMonth() + 1).toString().padStart(2, '0');
  const day = d.getDate().toString().padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function addDays(key: string, n: number): string {
  const [y, m, d] = key.split('-').map(Number);
  const dt = new Date(y, m - 1, d);
  dt.setDate(dt.getDate() + n);
  return dayKey(dt);
}

export function computeStreak(readTimestamps: (string | null | undefined)[]): StreakStats {
  const dates = readTimestamps
    .filter((t): t is string => typeof t === 'string')
    .map((t) => new Date(t))
    .filter((d) => !Number.isNaN(d.getTime()));

  if (dates.length === 0) {
    return { currentStreak: 0, longestStreak: 0, lastReadAt: null };
  }

  const days = new Set(dates.map((d) => dayKey(d)));
  const today = dayKey(new Date());
  const yesterday = addDays(today, -1);

  // Find current streak ending at today or yesterday (give 1-day grace).
  let cursor: string | null = null;
  if (days.has(today)) cursor = today;
  else if (days.has(yesterday)) cursor = yesterday;

  let currentStreak = 0;
  while (cursor && days.has(cursor)) {
    currentStreak += 1;
    cursor = addDays(cursor, -1);
  }

  // Find longest streak by scanning sorted unique day keys.
  const sortedDays = Array.from(days).sort();
  let longestStreak = 1;
  let runStart = sortedDays[0];
  let runLen = 1;
  for (let i = 1; i < sortedDays.length; i++) {
    const d = sortedDays[i];
    if (d === addDays(sortedDays[i - 1], 1)) {
      runLen += 1;
    } else {
      if (runLen > longestStreak) longestStreak = runLen;
      runStart = d;
      runLen = 1;
    }
  }
  if (runLen > longestStreak) longestStreak = runLen;
  void runStart;

  const lastReadAt = dates.reduce(
    (latest, d) => (d > latest ? d : latest),
    dates[0],
  );

  return { currentStreak, longestStreak, lastReadAt };
}
