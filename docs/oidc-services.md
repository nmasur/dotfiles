# OIDC Service Analysis & Setup Requirements

This document analyzes the services defined in this repository (specifically within `platforms/nixos/modules/nmasur/presets/services/` and related server profiles like `flame` and `swan`), evaluates their OpenID Connect (OIDC) compatibility, and details the requirements for configuring OIDC logins.

---

## Identity Provider Context: Pocket ID

The configuration already includes a central self-hosted identity provider: **Pocket ID** (`platforms/nixos/modules/nmasur/presets/services/pocket-id/pocket-id.nix`), hosted on the communications server (`flame`) behind Caddy at **`https://auth.masu.rs`**.

Pocket ID is an OpenID Connect (OIDC) provider with WebAuthn/Passkey support. It exposes the following standard OIDC endpoints:
- **Issuer URL:** `https://auth.masu.rs`
- **Discovery Endpoint:** `https://auth.masu.rs/.well-known/openid-configuration`
- **Authorization Endpoint:** `https://auth.masu.rs/authorize`
- **Token Endpoint:** `https://auth.masu.rs/api/oidc/token`
- **Userinfo Endpoint:** `https://auth.masu.rs/api/oidc/userinfo`
- **JWKS Endpoint:** `https://auth.masu.rs/.well-known/jwks.json`

---

## 1. Service Compatibility Breakdown

### Tier 1: First-Class / Native OIDC Support

These services support OpenID Connect natively without requiring external authentication proxies or custom code:

| Service | Hostname | OIDC Support Level | Configuration Method |
| :--- | :--- | :--- | :--- |
| **Immich** | `photos.masu.rs` | Native core feature | NixOS config (`services.immich.settings.oauth`) |
| **Gitea** | `git.masu.rs` | Native core feature | NixOS config / CLI or Web UI |
| **Nextcloud** | `cloud.masu.rs` | Native (official `user_oidc` app) | Nextcloud app + `nextcloud-occ user_oidc:provider` |
| **Grafana** | `metrics.masu.rs` | Native (Generic OAuth) | NixOS config (`services.grafana.settings."auth.generic_oauth"`) |
| **Paperless-ngx** | `paper.masu.rs` | Native (`django-allauth`) | NixOS env vars (`PAPERLESS_SOCIALACCOUNT_PROVIDERS`) |
| **Mealie** | `cooking.masu.rs` | Native core feature | NixOS config (`services.mealie.settings` + `credentialsFile`) |
| **Karakeep / Hoarder** | `keep.masu.rs` | Native (NextAuth OIDC) | NixOS env vars (`OAUTH_WELLKNOWN_URL`, etc.) |
| **Audiobookshelf** | `read.masu.rs` | Native core feature (v2.3+) | Web UI (Settings → Authentication) |
| **Actual Budget** | `money.masu.rs` | Native core feature (v24.3+) | NixOS config (`services.actual.settings.openId`) |

---

### Tier 2: OIDC via Plugins or Reverse Proxy Header Auth

These services do not have generic OIDC in their core web UI, but can support single sign-on through plugins or reverse proxy headers (`Remote-User` / `X-Forwarded-User`):

| Service | Hostname | Strategy | Notes |
| :--- | :--- | :--- | :--- |
| **Jellyfin** | `stream.masu.rs` | `jellyfin-plugin-sso` | Web clients work well; TV and native apps typically rely on Quick Connect. |
| **Calibre-Web** | `books.masu.rs` | Reverse proxy header auth | Set `services.calibre-web.options.reverseProxyAuth.enable = true` behind an authenticating reverse proxy. |
| **File Browser** | `files.masu.rs` | Reverse proxy header auth | Set `auth.method = "proxy"` and `auth.header = "X-Forwarded-User"` behind an authenticating reverse proxy. |
| **Navidrome** | `music.masu.rs` | Reverse proxy header auth | Supports `ReverseProxyUserHeader` for web UI; Subsonic API clients (Feishin, etc.) still require native user passwords. |
| **Stalwart** | `contacts.masu.rs` | OIDC Directory / SASL OAuth | Stalwart supports OIDC directories, but CardDAV/CalDAV clients usually require HTTP Basic Auth or application passwords. |

---

### Tier 3: Incompatible or No Native OIDC Support

- **Vaultwarden (`vault.masu.rs`):** Incompatible for vault decryption. Vaultwarden uses client-side zero-knowledge encryption where vault keys are derived from the user's master password. Bitwarden Enterprise SSO relies on a proprietary Key Connector that Vaultwarden does not implement.
- **n8n (`n8n.masu.rs`):** SAML/OIDC SSO is an **Enterprise / commercial-only feature**; it is disabled in the free self-hosted Community edition.
- **The Arr Stack (`download.masu.rs`):** Radarr, Sonarr, Lidarr, Readarr, Prowlarr, Bazarr, and Sabnzbd only support API keys, Basic Auth, or Forms.
- **Transmission (`transmission.masu.rs`):** BitTorrent daemon; supports only HTTP Basic Auth / RPC whitelist.
- **Uptime Kuma (`status.masu.rs`), ntfy (`ntfy.masu.rs`), The Lounge (`irc.masu.rs`), Pgweb (`pg.masu.rs`), Mathesar (`mathesar.masu.rs`), Hister (`hister.masu.rs`):** No native generic OIDC login mechanism.
- **Infrastructure / Daemon Services:** PostgreSQL, InfluxDB, bind, avahi, cloudflared, wireguard, litestream (no user web UI).

---

## 2. General Setup Requirements

Configuring OIDC requires setup across four layers:

### A. Pocket ID Setup
For each service, an OIDC client application must be registered in the Pocket ID admin interface:
1. **Client ID:** A unique identifier slug (e.g. `gitea`, `immich`, `paperless`).
2. **Client Secret:** A cryptographically secure random token.
3. **Redirect URIs / Callback URLs:** The exact target URLs the service exposes for authorization code callbacks.
4. **Scopes:** Usually `openid`, `profile`, and `email`.

### B. Secrets Management (agenix)
All client secrets should be encrypted with `agenix` under the respective service directory:
- Example: `platforms/nixos/modules/nmasur/presets/services/<service>/<service>-oidc.age`
- Defined in NixOS under `config.secrets.<service>-oidc` with appropriate owner/group permissions.

### C. Network & Reverse Proxy (Caddy)
1. **Back-Channel Connectivity:** When a user logs in, the service backend makes a server-to-server HTTPS call to `https://auth.masu.rs/api/oidc/token` to exchange the authorization code for tokens. Services hosted on `swan` (NAS) must be able to resolve and reach `auth.masu.rs` over HTTPS.
2. **Proxy Headers:** Caddy's `reverse_proxy` handles `X-Forwarded-Proto`, `X-Forwarded-Host`, and `X-Forwarded-For` by default. Services should have reverse proxy trust enabled (e.g., `trusted_proxies = ["127.0.0.1"]`) so generated redirect URIs preserve the `https://` scheme.

---

## 3. Detailed Setup Requirements for Tier 1 Services

### 1. Immich (`photos.masu.rs`)
- **Pocket ID Redirect URIs:**
  - Web: `https://photos.masu.rs/auth/login`
  - Mobile: `app.immich:///oauth-callback`
- **Setup in `immich/immich.nix`:**
  ```nix
  services.immich.settings.oauth = {
    enabled = true;
    issuerUrl = "https://${hostnames.auth}";
    clientId = "1f4e0f8d-6cee-4d67-8d53-74bf6c18ae09";
    clientSecret._secret = config.secrets.immich-oidc-secret.dest;
    scope = "openid profile email";
    autoRegister = true;
    buttonText = "Login with Pocket ID";
  };
  ```

### 2. Gitea (`git.masu.rs`)
- **Pocket ID Redirect URI:** `https://git.masu.rs/user/oauth2/pocket-id/callback`
- **Setup in Gitea:**
  Can be configured in the Web UI under **Site Administration → Authentication Sources** or via CLI:
  ```bash
  gitea admin auth add-oauth \
    --name "Pocket ID" \
    --provider openidConnect \
    --key "<client_id>" \
    --secret "<client_secret>" \
    --auto-discover-url "https://auth.masu.rs/.well-known/openid-configuration"
  ```
  - Optional: Enable automatic account linking by matching email.

### 3. Nextcloud (`cloud.masu.rs`)
- **Pocket ID Redirect URI:** `https://cloud.masu.rs/apps/user_oidc/code`
- **Setup in `nextcloud/nextcloud.nix`:**
  ```nix
  secrets.nextcloud-oidc-secret = {
    source = ./nextcloud-oidc-secret.age;
    dest = "${config.secretsDirectory}/nextcloud-oidc-secret";
    owner = "nextcloud";
    group = "nextcloud";
    permissions = "0440";
  };
  systemd.services.nextcloud-oidc-secret-secret = {
    requiredBy = [ "nextcloud-setup.service" ];
    before = [ "nextcloud-setup.service" ];
  };

  services.nextcloud = {
    settings.overwriteprotocol = "https";
    extraApps = {
      user_oidc = config.services.nextcloud.package.packages.apps.user_oidc;
    };
  };

  systemd.services.nextcloud-setup = {
    after = [ "nextcloud-oidc-secret-secret.service" ];
    postStart = ''
      ${config.services.nextcloud.occ}/bin/nextcloud-occ user_oidc:provider pocket-id \
        --clientid="c8a32c58-a781-4f14-9070-f498fdfda438" \
        --clientsecret-file="${config.secrets.nextcloud-oidc-secret.dest}" \
        --discoveryuri="https://${hostnames.auth}/.well-known/openid-configuration" \
        --scope="openid profile email" \
        --mapping-uid="preferred_username" \
        --unique-uid=0
    '';
  };
  ```

### 4. Grafana (`metrics.masu.rs`)
- **Pocket ID Redirect URI:** `https://metrics.masu.rs/login/generic_oauth`
- **Setup in `grafana/grafana.nix`:**
  ```nix
  services.grafana.settings = {
    auth.oauth_allow_insecure_email_lookup = true;
    "auth.generic_oauth" = {
      enabled = true;
      name = "Pocket ID";
      allow_sign_up = true;
      client_id = "85d879ed-1a86-4984-b33d-43806500ef98";
      client_secret = "$__file{${config.secrets.grafana-oidc-secret.dest}}";
      scopes = "openid profile email";
      auth_url = "https://${hostnames.auth}/authorize";
      token_url = "https://${hostnames.auth}/api/oidc/token";
      api_url = "https://${hostnames.auth}/api/oidc/userinfo";
      login_attribute_path = "preferred_username";
      skip_org_role_sync = true;
    };
  };
  ```

### 5. Paperless-ngx (`paper.masu.rs`)
- **Pocket ID Redirect URI:** `https://paper.masu.rs/accounts/oidc/pocket-id/login/callback/`
- **Setup in `paperless/paperless.nix`:**
  ```nix
  services.paperless.settings = {
    PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
    PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
  };
  # Configured via environmentFile to pass the client secret, enable PKCE, and link by email:
  # PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
  #   openid_connect = {
  #     APPS = [
  #       {
  #         provider_id = "pocket-id";
  #         name = "Pocket ID";
  #         client_id = "e6ff7fce-8e67-4c66-8f32-5ec3db4740a9";
  #         secret = "...";
  #         settings = {
  #           server_url = "https://auth.masu.rs";
  #           token_auth_method = "client_secret_basic";
  #           oauth_pkce_enabled = true;
  #           email_authentication = true;
  #           verified_email = true;
  #         };
  #       }
  #     ];
  #   };
  # };
  ```

### 6. Mealie (`cooking.masu.rs`)
- **Pocket ID Redirect URI:** `https://cooking.masu.rs/login`
- **Setup in `mealie/mealie.nix`:**
  ```nix
  services.mealie = {
    credentialsFile = config.secrets.mealie-oidc-secret.dest;
    settings = {
      OIDC_AUTH_ENABLED = "true";
      OIDC_SIGNUP_ENABLED = "true";
      OIDC_CONFIGURATION_URL = "https://${hostnames.auth}/.well-known/openid-configuration";
      OIDC_CLIENT_ID = "040925ed-b39e-4442-b8e8-369c948c0cd2";
      OIDC_PROVIDER_NAME = "Pocket ID";
      OIDC_USER_CLAIM = "email";
    };
  };
  ```

### 7. Karakeep / Hoarder (`keep.masu.rs`)
- **Pocket ID Redirect URI:** `https://keep.masu.rs/api/auth/callback/custom`
- **Setup in `karakeep.nix`:**
  ```nix
  services.karakeep.extraEnvironment = {
    OAUTH_WELLKNOWN_URL = "https://auth.masu.rs/.well-known/openid-configuration";
    OAUTH_CLIENT_ID = "hoarder";
    OAUTH_CLIENT_SECRET = "...";
    OAUTH_PROVIDER_NAME = "Pocket ID";
    OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
  };
  ```

### 8. Audiobookshelf (`read.masu.rs`)
- **Pocket ID Redirect URIs:**
  - Web: `https://read.masu.rs/auth/openid/callback`
  - Mobile: `audiobookshelf://oauth`
- **Setup in Audiobookshelf:**
  Configured in the Web UI (**Settings → Authentication → OpenID Connect**):
  - Issuer URL: `https://auth.masu.rs`
  - Client ID & Client Secret
  - Match user by email or username

### 9. Actual Budget (`money.masu.rs`)
- **Pocket ID Redirect URI:** `https://money.masu.rs/openid/callback`
- **Setup in `actualbudget/actualbudget.nix`:**
  ```nix
  services.actual.settings = {
    loginMethod = "openid";
    openId = {
      discoveryURL = "https://${hostnames.auth}/.well-known/openid-configuration";
      client_id = "92afe9f8-7ef6-42ab-8a06-701df3c7179d";
      client_secret._secret = config.secrets.actualbudget-oidc-secret.dest;
      server_hostname = "https://${hostnames.budget}";
      authMethod = "openid";
    };
  };
  ```
  *Note:* The optional end-to-end budget encryption password remains separate from the server authentication.

---

## 4. Forward Auth Architecture for Remaining Services

For services without native OIDC support (such as Calibre-Web, File Browser, Uptime Kuma, and the Arr stack), you can implement **Forward Auth via Caddy**:

1. Deploy an authenticating proxy (such as **OAuth2-Proxy** or **Authelia**) configured with Pocket ID as its OIDC provider.
2. Configure Caddy routes using the `forward_auth` directive to verify user sessions with the proxy before forwarding requests to the target service.
3. For services supporting reverse proxy authentication (Calibre-Web and File Browser), Caddy injects identity headers (e.g. `Remote-User: noah` or `X-Forwarded-User: noah`), enabling seamless single sign-on without requiring separate logins.
