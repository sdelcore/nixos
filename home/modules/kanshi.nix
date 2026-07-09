{pkgs, ...}: {
  # Install kanshi via home-manager module
  home.packages = with pkgs; [
    kanshi
  ];

  # Manage kanshi services via Home-manager
  services.kanshi = {
    enable = true;
    systemdTarget = "";
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
          }
        ];
      }
      {
        profile.name = "home-laptop";
        profile.outputs = [
          {
            criteria = "Dell Inc. DELL S3423DWC 6KQ26Y3";
            position = "1920,0";
            mode = "3440x1440@59.97Hz";
            status = "enable";
          }
          {
            criteria = "HP Inc. HP E24 G4 CN42051QKF";
            status = "enable";
            position = "0,0";
          }
          {
            criteria = "HP Inc. HP E24 G4 CN42051PMS";
            status = "enable";
            position = "5360,0";
          }
          {
            criteria = "eDP-1";
            scale = 1.0;
            status = "disable";
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "home-desktop";
        profile.outputs = [
          {
            criteria = "Dell Inc. DELL S3423DWC 6KQ26Y3";
            status = "enable";
            position = "1920,0";
            mode = "3440x1440@99.98Hz";
          }
          {
            criteria = "HP Inc. HP E24 G4 CN42051QKF";
            status = "enable";
            position = "0,0";
          }
          {
            criteria = "HP Inc. HP E24 G4 CN42051PMS";
            status = "enable";
            position = "5360,0";
          }
        ];
      }
      
    ];
  };
}
