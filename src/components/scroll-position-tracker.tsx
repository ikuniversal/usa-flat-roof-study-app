'use client';

import { useEffect, useRef } from 'react';
import { saveSectionPosition } from '@/app/actions/reading';

// Restores the user's last scroll position on mount and saves the
// new position (debounced) as they scroll. Renders nothing.
//
// Behavior notes:
// - Restore is one-shot per mount, with a 60-second freshness window
//   so a user who comes back days later doesn't get teleported into
//   the middle of a section they've forgotten.
// - Save is debounced to 1.2s of scroll-idle so we're not hammering
//   the DB on every wheel event.
// - We also save on `pagehide` (the spec's replacement for unload
//   that fires reliably on iOS) so the last position is captured
//   even if the user closes the tab mid-scroll.
export function ScrollPositionTracker({
  sectionId,
  initialPosition,
  initialPositionUpdatedAt,
}: {
  sectionId: string;
  initialPosition: number;
  initialPositionUpdatedAt: string | null;
}) {
  const lastSaved = useRef<number>(initialPosition);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Restore on mount.
  useEffect(() => {
    if (initialPosition <= 0) return;
    if (initialPositionUpdatedAt) {
      const ageMs = Date.now() - new Date(initialPositionUpdatedAt).getTime();
      const oneDayMs = 24 * 60 * 60 * 1000;
      // Skip restore if we don't actually trust the timestamp or the
      // saved position is old enough that the user probably wants to
      // start from the top again.
      if (Number.isFinite(ageMs) && ageMs > oneDayMs) return;
    }
    // Defer to next paint so the markdown body has laid out.
    requestAnimationFrame(() => {
      window.scrollTo({ top: initialPosition, behavior: 'instant' as ScrollBehavior });
    });
  }, [initialPosition, initialPositionUpdatedAt]);

  // Save on scroll (debounced) + on pagehide.
  useEffect(() => {
    function flush() {
      const y = Math.max(0, Math.round(window.scrollY));
      if (Math.abs(y - lastSaved.current) < 32) return;
      lastSaved.current = y;
      // Fire-and-forget; failures are non-fatal.
      void saveSectionPosition(sectionId, y);
    }

    function onScroll() {
      if (timer.current) clearTimeout(timer.current);
      timer.current = setTimeout(flush, 1200);
    }

    function onPageHide() {
      if (timer.current) clearTimeout(timer.current);
      flush();
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('pagehide', onPageHide);
    return () => {
      window.removeEventListener('scroll', onScroll);
      window.removeEventListener('pagehide', onPageHide);
      if (timer.current) clearTimeout(timer.current);
    };
  }, [sectionId]);

  return null;
}
