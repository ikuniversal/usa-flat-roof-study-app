import { createClient } from '@/lib/supabase/server';
import { GlossarySearch } from '@/components/glossary-search';
import type { GlossaryTerm } from '@/types/database';

export default async function GlossaryPage() {
  const supabase = createClient();
  const { data: terms } = await supabase
    .from('glossary_terms')
    .select('*')
    .order('term', { ascending: true })
    .returns<GlossaryTerm[]>();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Glossary
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          {terms?.length ?? 0} term{terms?.length === 1 ? '' : 's'}.
        </p>
      </div>
      {!terms || terms.length === 0 ? (
        <p className="rounded-lg border border-slate-200 bg-white px-5 py-4 text-sm italic text-slate-500">
          No glossary terms have been loaded yet.
        </p>
      ) : (
        <GlossarySearch terms={terms} />
      )}
    </div>
  );
}
