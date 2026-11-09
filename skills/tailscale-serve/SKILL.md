---
name: tailscale-serve
description: Use when starting a web project, development server, or local service for the user to access, or when asked to serve, preview, or share it over the tailnet. Skip when the user explicitly requests another hosting method.
---

# Tailscale Serve

When running a project or service for me, expose it privately through Tailscale Serve on a random available port. Keep the app and Serve running after handoff, preserve other services' mappings, and return the working tailnet URL. Prefer HTTPS for web apps. Use public Funnel only if I explicitly request it.
