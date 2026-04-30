import { NextResponse, type NextRequest } from 'next/server';
import { updateSession } from '@/lib/supabase/middleware';

// Paths that authenticated users should NOT see — bounce them to /
// (the root page redirects to the role-appropriate dashboard).
const AUTH_PATHS = ['/login', '/forgot-password', '/reset-password'];

// Path prefixes that require authentication. Role-specific access is
// enforced inside each layout, not here.
const PROTECTED_PREFIXES = ['/admin', '/instructor', '/learn'];

function matchesAny(pathname: string, candidates: string[]): boolean {
  return candidates.some(
    (c) => pathname === c || pathname.startsWith(c + '/'),
  );
}

export async function middleware(request: NextRequest) {
  const { response, user } = await updateSession(request);
  const pathname = request.nextUrl.pathname;

  // Authenticated user trying to view an auth page → send them home.
  if (user && matchesAny(pathname, AUTH_PATHS)) {
    const url = request.nextUrl.clone();
    url.pathname = '/';
    url.search = '';
    return NextResponse.redirect(url);
  }

  // Unauthenticated user trying to access a protected area → /login.
  if (!user && matchesAny(pathname, PROTECTED_PREFIXES)) {
    const url = request.nextUrl.clone();
    url.pathname = '/login';
    url.search = '';
    return NextResponse.redirect(url);
  }

  return response;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static  (build assets)
     * - _next/image   (image optimizer)
     * - favicon.ico
     * - any image extension
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
