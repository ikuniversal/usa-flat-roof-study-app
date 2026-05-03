import { createClient } from '@/lib/supabase/server';
import type { Checklist, ChecklistSection } from '@/types/database';

function renderItem(item: unknown, key: number): React.ReactNode {
  if (item && typeof item === 'object' && 'text' in item) {
    const text = (item as { text: unknown }).text;
    if (typeof text === 'string') {
      return (
        <li key={key} className="flex items-start gap-2 text-sm text-slate-800">
          <span aria-hidden className="mt-1 text-slate-400">
            ☐
          </span>
          <span>{text}</span>
        </li>
      );
    }
  }
  if (typeof item === 'string') {
    return (
      <li key={key} className="flex items-start gap-2 text-sm text-slate-800">
        <span aria-hidden className="mt-1 text-slate-400">
          ☐
        </span>
        <span>{item}</span>
      </li>
    );
  }
  return (
    <li key={key} className="text-xs font-mono text-slate-500">
      {JSON.stringify(item)}
    </li>
  );
}

export default async function ChecklistsPage() {
  const supabase = createClient();

  const { data: checklists } = await supabase
    .from('checklists')
    .select('*')
    .order('display_order', { ascending: true })
    .returns<Checklist[]>();

  const { data: sections } = await supabase
    .from('checklist_sections')
    .select('*')
    .order('display_order', { ascending: true })
    .returns<ChecklistSection[]>();

  const sectionsByChecklist = new Map<string, ChecklistSection[]>();
  for (const s of sections ?? []) {
    if (!s.checklist_id) continue;
    const arr = sectionsByChecklist.get(s.checklist_id) ?? [];
    arr.push(s);
    sectionsByChecklist.set(s.checklist_id, arr);
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Inspection checklists
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          {checklists?.length ?? 0} checklist
          {checklists?.length === 1 ? '' : 's'}.
        </p>
      </div>

      {!checklists || checklists.length === 0 ? (
        <p className="rounded-lg border border-slate-200 bg-white px-5 py-4 text-sm italic text-slate-500">
          No checklists have been loaded yet.
        </p>
      ) : (
        <div className="space-y-6">
          {checklists.map((cl) => {
            const clSections = sectionsByChecklist.get(cl.id) ?? [];
            return (
              <section
                key={cl.id}
                className="rounded-lg border border-slate-200 bg-white shadow-sm"
              >
                <header className="border-b border-slate-200 px-5 py-3">
                  <h2 className="text-base font-semibold text-slate-900">
                    {cl.checklist_number}. {cl.title}
                  </h2>
                  {cl.use_when ? (
                    <p className="mt-1 text-xs text-slate-500">
                      Use when: {cl.use_when}
                    </p>
                  ) : null}
                </header>
                {clSections.length === 0 ? (
                  <p className="px-5 py-4 text-sm italic text-slate-500">
                    No sections in this checklist yet.
                  </p>
                ) : (
                  <div className="space-y-4 px-5 py-4">
                    {clSections.map((s) => (
                      <div key={s.id}>
                        <h3 className="mb-2 text-sm font-semibold text-slate-900">
                          {s.section_title}
                        </h3>
                        <ul className="space-y-1">
                          {(s.items_json ?? []).map((item, idx) =>
                            renderItem(item, idx),
                          )}
                        </ul>
                      </div>
                    ))}
                  </div>
                )}
              </section>
            );
          })}
        </div>
      )}
    </div>
  );
}
