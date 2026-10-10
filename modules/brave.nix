{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.brave ];

  environment.etc."brave/policies/managed/privacy.json".text = builtins.toJSON {
    # Brave features
    BraveRewardsDisabled = true;
    BraveWalletDisabled = true;
    BraveVPNDisabled = true;
    BraveAIChatEnabled = false;
    BraveP3AEnabled = false;
    BraveStatsPingEnabled = false;

    # General privacy
    MetricsReportingEnabled = false;
    BlockThirdPartyCookies = true;
    WebRtcIPHandlingPolicy = "disable_non_proxied_udp";
    # DefaultJavaScriptJitSetting = 2; #temp disable issue with nitrokey
    PasswordManagerEnabled = false;   # Bitwarden handles this

    # Extensions
    ExtensionSettings = {
      "nngceckbapebfimnlniiiahkandclblb" = {   # Bitwarden
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
        toolbar_pin = "force_pinned";
      };
      "dphilobhebphkdjbpfohgikllaljmgbn" = {   # SimpleLogin
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
        toolbar_pin = "force_pinned";
      };
    };
  };
}
