import { type NextRequest } from 'next/server';
import { updateSession } from '@/lib/supabase/middleware';

// Thin wrapper. All session-refresh and URL-level auth rules live
// inside `updateSession`, which returns a NextResponse already
// carrying any rotated Supabase cookies. We must not wrap it in
// another NextResponse — that would drop those cookies and re-create
// the redirect loop.
export async function middleware(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static  (build assets)
     * - _next/image   (image optimizer)
     * - favicon.ico
     * - any image extension
     *
     * Route groups like (admin)/(auth)/(learn) are NOT in URL paths
     * (Next.js strips the parens), so the matcher already covers
     * /admin, /login, etc. without listing each route group.
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
