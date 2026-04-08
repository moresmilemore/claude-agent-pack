---
scope: reviewer, coder, architect
load_when: files touching auth, payments, user input, crypto, network boundaries, data mutations
---

# Security Rules

Load this file whenever the task touches authentication, payments, user input, crypto, external network calls, or data mutations.

## Never-Commit List

- Secrets, API keys, tokens, passwords — **ever**
- Private keys, certificates, `.env` files with real values
- Database dumps, real user data
- Files matching `*.key`, `*.pem`, `*secret*`, `*credentials*`

Hardcoded secret in a diff = **CRITICAL**. Stop the review.

## Input Validation

- Trust no input. Validate type, length, format at every boundary.
- Whitelist > blacklist.
- Parameterized queries only. String-concatenated SQL = CRITICAL.
- Escape output by context (HTML, JS, URL, shell).

## Authentication & Authorization

- Authenticate at the boundary; pass identity (not credentials) internally.
- Authorize on **every** request, not just login.
- Sessions: HttpOnly, Secure, SameSite, short-lived, rotated on privilege change.
- Never log tokens, passwords, or PII in plaintext.

## Dependencies

- No new dependencies without explicit approval.
- Check for known CVEs before adding a package.
- Pin versions. Audit lockfile changes.

## Review Flags

- `==` for password comparison → CRITICAL (use constant-time)
- Missing rate limiting on auth → HIGH
- Stack traces leaked to users → MEDIUM
- Overly permissive CORS (`*`) → HIGH
- Missing CSRF on state-changing endpoints → HIGH
- `eval` on user input → CRITICAL
- Regex on untrusted input with ReDoS risk → HIGH
