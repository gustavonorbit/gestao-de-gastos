// Centralized feature flags for quick product toggles.
//
// IMPORTANT: This file is intentionally minimal. Set `isBackupEnabled` to true
// in the future (e.g. during a VIP rollout) to re-expose backup-related UI
// without touching multiple files. Do NOT implement or change backup logic
// here — this is only a visibility flag.

/// Toggle to show/hide backup UI across the app.
///
/// Default: false for the MVP (backup reserved for Plano VIP).
const bool isBackupEnabled = false;

/// Toggle to show/hide donation (PIX) UI across the app.
///
/// Default: false for the MVP (donation area intentionally hidden).
/// To re-enable in the future, set this to `true` or wire it to a server
/// controlled feature flag for gradual rollouts.
const bool isDonationEnabled = false;
