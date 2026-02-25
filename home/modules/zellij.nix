{zjstatus, ...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
  };

  # Local config (Ctrl+g)
  xdg.configFile."zellij/config.kdl".text = ''
    theme "catppuccin-macchiato"
    default_mode "normal"
    default_layout "default"
    show_startup_tips false
    keybinds {
      unbind "Ctrl q"
      locked {
        bind "Ctrl g" { SwitchToMode "normal"; }
      }
      shared_except "locked" {
        bind "Ctrl g" { SwitchToMode "locked"; }
        bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
        bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
        bind "Alt j" "Alt Down" { MoveFocus "Down"; }
        bind "Alt k" "Alt Up" { MoveFocus "Up"; }
        bind "Alt [" { PreviousSwapLayout; }
        bind "Alt ]" { NextSwapLayout; }
        bind "Alt n" { NewPane; }
        bind "Alt f" { ToggleFloatingPanes; }
      }
    }
  '';

  # zjstatus layout (simple style, catppuccin macchiato colors)
  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
        pane split_direction="vertical" {
            pane
        }

        pane size=1 borderless=true {
            plugin location="file://${zjstatus}/bin/zjstatus.wasm" {
                hide_frame_for_single_pane "true"

                format_left  "{mode}#[fg=#89B4FA,bg=#181825,bold] {session}#[bg=#181825] {tabs}"
                format_right "{datetime}"
                format_space "#[bg=#181825]"

                mode_normal          "#[bg=#89B4FA] "
                mode_locked          "#[bg=#6C7086] "
                mode_tmux            "#[bg=#ffc387] "
                mode_default_to_mode "tmux"

                tab_normal               "#[fg=#6C7086,bg=#181825] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                tab_active               "#[fg=#9399B2,bg=#181825,bold,italic] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                tab_fullscreen_indicator "□ "
                tab_sync_indicator       "  "
                tab_floating_indicator   "󰉈 "

                datetime          "#[fg=#9399B2,bg=#181825] {format} "
                datetime_format   "%a, %d %b %H:%M"
                datetime_timezone "America/Toronto"
            }
        }
    }
  '';
}