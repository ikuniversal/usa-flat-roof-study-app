import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';

// Bootstrap entry for the final exam: finds the unique
// `is_final_exam = true` quiz and forwards to its overview. Falls
// back to a "not yet imported" notice if no exam exists.
export default async function FinalExamRedirectPage() {
  await requireUserWithProfile();
  const supabase = createClient();
  const { data: exam } = await supabase
    .from('quizzes')
    .select('id')
    .eq('is_final_exam', true)
    .limit(1)
    .maybeSingle<{ id: string }>();

  if (exam) {
    redirect(`/learn/quizzes/${exam.id}`);
  }

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
        Final exam
      </h1>
      <p className="rounded-lg border border-amber-200 bg-amber-50 px-5 py-4 text-sm text-amber-900">
        The final exam has not been imported into this database yet. Apply
        the remaining content-import chunks, then return here.
      </p>
      <Link
        href="/learn"
        className="inline-block text-sm text-blue-700 hover:underline"
      >
        Back to table of contents
      </Link>
    </div>
  );
}
