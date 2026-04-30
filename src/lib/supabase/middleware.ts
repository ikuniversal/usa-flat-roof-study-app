import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

// URL prefixes that authenticated users should NOT see — bounce them
// to / (the root page resolves the role-specific home).
const AUTH_PATHS = ['/login', '/forgot-password', '/reset-password'];

// URL prefixes that require authentication. `/` is included so the
// root page can trust that anyone reaching it is signed in (its
// only job is the role-based redirect to /admin, /instructor, or
// /learn — it must never redirect to /login itself or it would
// fight middleware and create a loop). Role-specific filtering
// happens inside each route-group layout, not here.
const PROTECTED_PREFIXES = ['/', '/admin', '/instructor', '/learn'];

function matchesAny(pathname: string, candidates: string[]): boolean {
  return candidates.some(
    (c) => pathname === c || pathname.startsWith(c + '/'),
  );
}

// Refreshes the Supabase session AND enforces gross URL-level auth
// rules. The caller MUST return whatever this returns, as-is — the
// returned response always carries any rotated auth cookies, whether
// it's a passthrough or a redirect.
//
// Why redirect logic lives here, not in the calling middleware:
// `NextResponse.redirect(url)` constructs a fresh response with NO
// cookies on it. If the caller built a redirect after this function
// returned, any auth-token rotation that just happened (Supabase
// writes the new tokens onto `supabaseResponse` via the setAll
// callback) would be silently dropped. The browser would keep using
// the now-invalidated old refresh token, getUser() on the next
// request would return null, the middleware would redirect to
// /login, the cookies would rotate again, and the user would loop —
// ERR_TOO_MANY_REDIRECTS.
//
// The fix per the @supabase/ssr Next.js docs: copy supabase's
// cookies onto every outgoing response, including redirects.
export async function updateSession(
  request: NextRequest,
): Promise<NextResponse> {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value),
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // IMPORTANT: do not run logic between createServerClient and
  // getUser — it must touch the auth cookie on every request.
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const pathname = request.nextUrl.pathname;

  // Authenticated user trying to view an auth page → bounce to /,
  // where the root page resolves their role-specific home.
  if (user && matchesAny(pathname, AUTH_PATHS)) {
    return buildRedirect(request, supabaseResponse, '/');
  }

  // Unauthenticated user trying to access a protected area → /login.
  if (!user && matchesAny(pathname, PROTECTED_PREFIXES)) {
    return buildRedirect(request, supabaseResponse, '/login');
  }

  // Default: passthrough. Carries any cookies that getUser() rotated.
  return supabaseResponse;
}

// Builds a redirect response that carries every cookie Supabase wrote
// to `supabaseResponse` during getUser(). Without this cookie copy,
// rotated auth tokens never reach the browser and the user gets
// stuck in a redirect loop.
function buildRedirect(
  request: NextRequest,
  supabaseResponse: NextResponse,
  pathname: string,
): NextResponse {
  const url = request.nextUrl.clone();
  url.pathname = pathname;
  url.search = '';
  const redirect = NextResponse.redirect(url);
  for (const cookie of supabaseResponse.cookies.getAll()) {
    redirect.cookies.set(cookie);
  }
  return redirect;
}
