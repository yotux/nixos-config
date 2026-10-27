# modules/facebook-browser.nix
# Facebook-only Firefox: locked-down policies + bubblewrap sandbox.
# Launch with: facebook
#
# Import it from your configuration:  imports = [ ./modules/facebook-browser.nix ];
{ pkgs, ... }:

let
  # Firefox with its own policies, independent of your main Firefox.
  fbFirefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    # The Preferences policy only accepts an allowlist of pref names and
    # silently drops the rest, so these go through autoconfig instead.
    extraPrefs = ''
      lockPref("privacy.resistFingerprinting", true);
      lockPref("geo.enabled", false);
      lockPref("browser.send_pings", false);
    '';

    extraPolicies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableFormHistory = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false; # use your external password manager
      HttpsOnlyMode = "force_enabled";

      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };

      # Keep the login cookie, clear everything else on exit.
      SanitizeOnShutdown = {
        Cache = true;
        History = true;
        FormData = true;
        Downloads = true;
        Cookies = false;
        Sessions = false;
        Locked = true;
      };

      # Block permission prompts entirely. Remove Camera/Microphone
      # lines if you need Messenger calls.
      Permissions = {
        Camera = { BlockNewRequests = true; Locked = true; };
        Microphone = { BlockNewRequests = true; Locked = true; };
        Location = { BlockNewRequests = true; Locked = true; };
        Notifications = { BlockNewRequests = true; Locked = true; };
      };

      Preferences = {
        "network.cookie.cookieBehavior" = { Value = 5; Status = "locked"; };
        "media.peerconnection.enabled" = { Value = false; Status = "locked"; };
        "network.dns.disablePrefetch" = { Value = true; Status = "locked"; };
        "network.prefetch-next" = { Value = false; Status = "locked"; };
        "dom.battery.enabled" = { Value = false; Status = "locked"; };
      };

      ExtensionSettings = {
        "*".installation_mode = "blocked"; # nothing but what's listed below
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # Keeps outbound links from Facebook out of the logged-in session.
        "@contain-facebook" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/facebook-container/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  # Bubblewrap launcher: fake $HOME, no D-Bus, no access to your real files.
  facebook = pkgs.writeShellApplication {
    name = "facebook";
    runtimeInputs = [ pkgs.bubblewrap ];
    text = ''
      profile="$HOME/.local/share/fb-browser"
      runtime="$XDG_RUNTIME_DIR"
      wayland="''${WAYLAND_DISPLAY:-wayland-0}"
      mkdir -p "$profile"

      args=(
        --unshare-all
        --share-net            # network stays on; everything else is unshared
        --die-with-parent
        --new-session

        # Read-only system bits Firefox needs
        --ro-bind /nix /nix
        --ro-bind /etc/resolv.conf /etc/resolv.conf
        --ro-bind /etc/hosts /etc/hosts
        --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf
        --ro-bind /etc/ssl /etc/ssl
        --ro-bind /etc/fonts /etc/fonts
        # Certificate trust: NixOS Firefox reads system trust via p11-kit
        --ro-bind-try /etc/static /etc/static
        --ro-bind-try /etc/pki /etc/pki
        --ro-bind-try /etc/pkcs11 /etc/pkcs11
        --ro-bind-try /etc/ca-bundle.crt /etc/ca-bundle.crt
        --ro-bind /etc/passwd /etc/passwd
        --ro-bind /etc/group /etc/group
        --ro-bind-try /run/current-system/sw/share/X11/fonts /run/current-system/sw/share/X11/fonts

        # GPU acceleration (falls back to software rendering if this fails)
        --dev /dev
        --dev-bind-try /dev/dri /dev/dri
        --ro-bind-try /sys/dev/char /sys/dev/char
        --ro-bind-try /sys/devices /sys/devices
        --ro-bind-try /run/opengl-driver /run/opengl-driver

        --proc /proc
        --tmpfs /tmp

        # Fake home: the browser only ever sees this directory
        --bind "$profile" "$HOME"

        # Display + audio sockets only, no D-Bus
        --perms 0700 --dir "$runtime"
        --bind-try "$runtime/$wayland" "$runtime/$wayland"
        --bind-try "$runtime/pulse/native" "$runtime/pulse/native"
        --bind-try "$runtime/pipewire-0" "$runtime/pipewire-0"

        --clearenv
        --setenv HOME "$HOME"
        --setenv PATH /run/current-system/sw/bin
        --setenv XDG_RUNTIME_DIR "$runtime"
        --setenv WAYLAND_DISPLAY "$wayland"
        --setenv MOZ_ENABLE_WAYLAND 1
        --setenv LANG "''${LANG:-en_US.UTF-8}"
      )

      # `facebook --shell` drops into the same sandbox with a shell, for debugging
      if [ "''${1:-}" = "--shell" ]; then
        exec bwrap "''${args[@]}" \
          --setenv PATH "${pkgs.coreutils}/bin:${pkgs.curl}/bin" \
          ${pkgs.bashInteractive}/bin/bash
      fi

      exec bwrap "''${args[@]}" ${fbFirefox}/bin/firefox "$@"
    '';
  };
in
{
  environment.systemPackages = [
    facebook
    (pkgs.makeDesktopItem {
      name = "facebook";
      desktopName = "Facebook (sandboxed)";
      exec = "facebook";
      icon = "firefox";
      categories = [ "Network" ];
    })
  ];
}
