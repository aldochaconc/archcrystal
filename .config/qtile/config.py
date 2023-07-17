from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
import subprocess
import os

mod = "mod4"
terminal = "urxvt"

colors = {
    "background": "#101010",
    "text": "#67F0FF",
}
keys = [
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "r", lazy.spawn("rofi -show run")),
    Key([mod], "t", lazy.window.toggle_floating()),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "space",  lazy.widget["keyboardlayout"].next_keyboard()),
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle view",),
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("/usr/bin/pulseaudio-ctl up")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("/usr/bin/pulseaudio-ctl down")),
    Key([], "XF86AudioMute", lazy.spawn("/usr/bin/pulseaudio-ctl mute")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -dec 10")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight -inc 10")),

]

groups = [Group(i) for i in "123456"]

for i in groups:
    keys.extend(
        [
            Key([mod], i.name, lazy.group[i.name].toscreen(),
                desc="Switch to {}".format(i.name),),
            Key([mod, "shift"], i.name, lazy.window.togroup(
                i.name, switch_group=True), desc="{}".format(i.name),),
        ]
    )

layouts = [
    layout.Columns(border_focus_stack=["#1e272c", "#0f1416"], border_width=1),
    layout.Max(),
]

widget_defaults = dict(
    font="Hack",
    fontsize=12,
    padding=10,
    foreground=colors["text"],
    background=colors["background"],
)

extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.Spacer(length=10),
                widget.Clock(
                    format=" %H:%M %a %d %m %Y",
                ),
                widget.GroupBox(
                    highlight_method="block",
                    disable_drag=True,

                ),
                widget.Prompt(),
                widget.WindowName(
                    format="{name}",
                    max_chars=50,

                ),
                widget.CPU(
                    fmt="{}",
                    update_interval=5,
                ),
                widget.Memory(
                    measure_mem='M',
                    format='ram/{MemUsed: .0f}{mm}:{MemTotal: .0f}{mm}',
                    update_interval=5,
                ),
                widget.ThermalSensor(
                    format="temp/{temp:.0f}°C",
                    foreground_alert="ff0000",
                    update_interval=5,
                ),
                widget.Net(
                    interface="wlo1",
                    format="network/{down} ↓↑{up}",
                    disconnected_message="No Wifi",
                ),
                widget.Bluetooth(
                    hci='/dev_14_85_09_C2_4C_F3',
                    fmt='bt/{}',
                ),
                widget.Volume(
                    device="pulse",
                    fmt="vol/{}",
                ),
                widget.KeyboardLayout(
                    configured_keyboards=['us', 'es'],
                    display_map={'us': 'xbk/US', 'es': 'xbk/ES'},
                ),
                widget.Battery(
                    energy_now_file='charge_now',
                    energy_full_file='charge_full',
                    power_now_file='current_now',
                    update_delay=5,
                    fmt='bat/{}'
                ),
                widget.Systray(
                    icon_size=14,
                ),
                widget.Spacer(length=10),
            ],
            24,
            opacity=0.6,
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="Nitrogen"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "LG3D"
