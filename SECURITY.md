# Security Policy & OWASP MASVS Compliance Guide

This document outlines the security architecture, threat model, data storage policies, and key rotation procedures implemented in this base template, strictly aligned with the **OWASP Mobile Application Security Verification Standard (MASVS)**.

---

## 1. Threat Model Summary

| Threat Vector | Potential Impact | Architecture Mitigation |
| :--- | :--- | :--- |
| **Reverse Engineering & Decompilation** | Extraction of hardcoded API secrets or signing keys | Zero secrets in client code. Configuration injected via `--dart-define-from-file`. Production symbols split via `--split-debug-info`. |
| **Man-In-The-Middle (MITM) Attacks** | Interception of in-transit credentials and session data | HTTPS strictly enforced via `SecurityInterceptor` & Android Manifest. SPKI SHA-256 certificate pinning via custom `HttpClientAdapter`. |
| **Token Theft from Disk** | Long-term session hijacking via unauthorized file reading | Access tokens retained **IN-MEMORY ONLY** (RAM). Refresh tokens stored in hardware-backed secure storage. |
| **Stale Keychain Credential Hijacking** | Access to old user sessions on re-installed iOS apps | First-launch detection flag in `SharedPreferences` wipes stale Keychain data on fresh install. |
| **Shoulder Surfing & Screen Recording** | Exposure of credentials in app switcher or screen recording | `SecureScreen` blurs view when app transitions to background. `SecureTextField` disables clipboard/suggestions. |
| **Device Compromise (Root / Jailbreak)** | Bypassing OS sandbox, memory inspection via Frida/Xposed | `DeviceIntegrityService` enforces configurable policy (`allow | warn | blockApp`) per build flavor. |

---

## 2. Data Storage Policy: What is Stored Where

| Data Classification | Storage Location | Protection Mechanism | Wiped on Logout / Tamper |
| :--- | :--- | :--- | :--- |
| **OAuth Access Token** | RAM (Memory Only) | Never persisted to disk; garbage collected on session end | Yes (Immediate) |
| **OAuth Refresh Token** | iOS Keychain / Android Keystore | Hardware-backed AES-256 / RSA Keystore (`first_unlock_this_device`) | Yes (`SecurityService.wipeAll`) |
| **Database Encryption Key** | iOS Keychain / Android Keystore | Hardware-backed SecureStorage (256-bit CSPRNG key) | Yes |
| **Domain Entities & Caches** | SQLite via sqflite | App-private database file (SQLCipher encryption ready) | Yes |
| **UI Preferences (Theme/Locale)** | `SharedPreferences` | Unencrypted OS preferences (Non-sensitive display settings) | No (Preserved) |

---

## 3. OWASP MASVS Verification Checklist

| MASVS Domain | Requirement | Template Implementation Status | Details |
| :--- | :--- | :---: | :--- |
| **MASVS-STORAGE-1** | System credential storage | **PASSED** | Hardware-backed Keystore/Keychain via `SecureTokenStorage` |
| **MASVS-STORAGE-2** | Memory credential policy | **PASSED** | Access token is strictly held in RAM; never written to storage |
| **MASVS-NETWORK-1** | Secure channels (TLS) | **PASSED** | Cleartext traffic disabled; HTTPS required by `SecurityInterceptor` |
| **MASVS-NETWORK-2** | Certificate verification | **PASSED** | Dual SPKI SHA-256 certificate pinning adapter; bad certs rejected |
| **MASVS-RESILIENCE-1** | Root / Jailbreak check | **PASSED** | `DeviceIntegrityService` with policy matrix per flavor |
| **MASVS-AUTH-1** | Biometric & PIN lock | **PASSED** | `AppLockService` with background auto-lock and re-auth guard |
| **MASVS-PRIVACY-1** | Redacting diagnostic logs | **PASSED** | `RedactingLogger` masks Bearer tokens, emails, cards, passwords |
| **MASVS-PRIVACY-2** | Screen recording protection | **PASSED** | `SecureScreen` blurs on app-switcher; clipboard auto-clear utility |

---

## 4. Key & Certificate Pin Rotation Procedures

### Rotating SPKI Certificate Pins
To prevent app downtime during TLS certificate renewal:
1. Generate the SPKI SHA-256 fingerprint for the **current** certificate and the **next (backup)** certificate:
   ```bash
   openssl s_client -connect api.example.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
   ```
2. Update `PRIMARY_CERT_PIN` and `BACKUP_CERT_PIN` in `env/staging.json` and `env/prod.json`.
3. Deploy the application update **before** the backend server switches TLS certificates.

---

## 5. Security Incident Response Steps

When a token leak or tampering incident is reported:
1. **Trigger Global Revocation**: Server invalidates all active refresh tokens for the compromised user or version.
2. **Client Emergency Wipe**: In-app tampering detection or refresh rejection triggers `SecurityService.wipeAll()`:
   - Purges in-memory state.
   - Clears iOS Keychain and Android Keystore.
   - Deletes local SQLite databases and caches.
   - Forcibly redirects navigation stack to `/login`.
3. **Audit Redacted Logs**: Review Talker diagnostic logs (guaranteed free of PII by `RedactingLogger`).

---

## 6. The "Never Do This" List

- **NEVER** store access tokens, passwords, PINs, or private keys in `SharedPreferences`.
- **NEVER** return `true` inside `badCertificateCallback`.
- **NEVER** disable HTTPS or allow cleartext network traffic in production builds.
- **NEVER** hardcode secret credentials or third-party client secrets in source code files.
- **NEVER** log raw HTTP headers or query parameters without sanitization through `RedactingLogger`.
