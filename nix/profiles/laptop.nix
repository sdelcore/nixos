{ ... }: {
  services.logind.settings.Login = {
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
