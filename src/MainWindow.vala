/*
* Copyright (c) 2020 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
namespace IconPreviewer {
    public class MainWindow : Hdy.ApplicationWindow {
        // Widgets
        public Gtk.Grid main_grid;
        public Hdy.HeaderBar titlebar;
        public Gtk.Application app { get; construct; }
        
        // Defaults to Icon Previewer Icon and Name and RDNN
        // changes when opening an icon.
        public string app_id = "com.github.lainsce.icon-previewer";
        public string app_name = "Icon Previewer";
        public string app_icon = "com.github.lainsce.icon-previewer";

        public MainWindow (Gtk.Application application) {
            GLib.Object (
                application: application,
                app: application,
                icon_name: "com.github.lainsce.icon-previewer",
                title: ("Icon Previewer")
            );

            key_press_event.connect ((e) => {
                uint keycode = e.hardware_keycode;

                if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                    if (match_keycode (Gdk.Key.q, keycode)) {
                        this.destroy ();
                    }
                }
                return false;
            });

            if (IconPreviewer.Application.gsettings.get_boolean("dark-mode")) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
            } else {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
            }

            if (IconPreviewer.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                IconPreviewer.Application.gsettings.set_boolean("dark-mode", true);
            } else if (IconPreviewer.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.NO_PREFERENCE) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                IconPreviewer.Application.gsettings.set_boolean("dark-mode", false);
            }

            IconPreviewer.Application.grsettings.notify["prefers-color-scheme"].connect (() => {
                 if (IconPreviewer.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK) {
                     Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                     IconPreviewer.Application.gsettings.set_boolean("dark-mode", true);
                 } else if (IconPreviewer.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.NO_PREFERENCE) {
                     Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                     IconPreviewer.Application.gsettings.set_boolean("dark-mode", false);
                 }
            });
        }

        construct {
            Hdy.init ();

            int x = IconPreviewer.Application.gsettings.get_int("window-x");
            int y = IconPreviewer.Application.gsettings.get_int("window-y");
            int h = IconPreviewer.Application.gsettings.get_int("window-height");
            int w = IconPreviewer.Application.gsettings.get_int("window-width");
            if (x != -1 && y != -1) {
                this.move (x, y);
            }
            if (w != 0 && h != 0) {
                this.resize (w, h);
            }

            IconPreviewer.Application.gsettings.changed.connect (() => {
                if (IconPreviewer.Application.gsettings.get_boolean("dark-mode")) {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                } else {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                }
            });

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/icon-previewer/app.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            // Ensure use of elementary theme, font and icons, accent color doesn't matter
            Gtk.Settings.get_default().set_property("gtk-theme-name", "io.elementary.stylesheet.blueberry");
            Gtk.Settings.get_default().set_property("gtk-icon-theme-name", "elementary");
            Gtk.Settings.get_default().set_property("gtk-font-name", "Inter 9");

            titlebar = new Hdy.HeaderBar ();
            titlebar.show_close_button = true;
            titlebar.has_subtitle = false;
            titlebar.title = "Icon Previewer";
            titlebar.set_show_close_button (true);
            titlebar.hexpand = true;
            titlebar.set_decoration_layout ("close:maximize");
            
            var open_file_button = new Gtk.Button.from_icon_name ("document-open", Gtk.IconSize.LARGE_TOOLBAR);
            open_file_button.clicked.connect (() => {
                // TODO: open a .svg just for its name.
            });
            titlebar.pack_start (open_file_button);
            
            var export_file_button = new Gtk.Button.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
            export_file_button.clicked.connect (() => {
                // TODO: export a .svg sized 128px.
            });

            var menu_grid = new Gtk.Grid ();
            menu_grid.margin = 6;
            menu_grid.row_spacing = 6;
            menu_grid.column_spacing = 12;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.show_all ();

            var menu = new Gtk.Popover (null);
            menu.add (menu_grid);

            var menu_button = new Gtk.MenuButton ();
            menu_button.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR));
            menu_button.has_tooltip = true;
            menu_button.tooltip_text = (_("Settings"));
            menu_button.popover = menu;
            titlebar.pack_end (menu_button);
            titlebar.pack_end (export_file_button);
            
            var icon_a = new Gtk.Image.from_icon_name ("accessories-calculator", Gtk.IconSize.DIALOG);
            icon_a.pixel_size = 96;
            var icon_b = new Gtk.Image.from_icon_name ("accessories-text-editor", Gtk.IconSize.DIALOG);
            icon_b.pixel_size = 96;
            var icon_c = new Gtk.Image.from_icon_name ("accessories-camera", Gtk.IconSize.DIALOG);
            icon_c.pixel_size = 96;
            var icon_d = new Gtk.Image.from_icon_name ("internet-chat", Gtk.IconSize.DIALOG);
            icon_d.pixel_size = 96;
            var icon_e = new Gtk.Image.from_icon_name (app_icon, Gtk.IconSize.DIALOG);
            icon_e.pixel_size = 96;
            icon_e.get_style_context ().add_class ("accented-dark");
            var icon_f = new Gtk.Image.from_icon_name ("multimedia-video-player", Gtk.IconSize.DIALOG);
            icon_f.pixel_size = 96;
            
            var icon_g = new Gtk.Image.from_icon_name ("accessories-calculator", Gtk.IconSize.DIALOG);
            icon_g.pixel_size = 96;
            var icon_h = new Gtk.Image.from_icon_name ("accessories-text-editor", Gtk.IconSize.DIALOG);
            icon_h.pixel_size = 96;
            var icon_i = new Gtk.Image.from_icon_name ("accessories-camera", Gtk.IconSize.DIALOG);
            icon_i.pixel_size = 96;
            var icon_j = new Gtk.Image.from_icon_name ("internet-chat", Gtk.IconSize.DIALOG);
            icon_j.pixel_size = 96;
            var icon_k = new Gtk.Image.from_icon_name (app_icon, Gtk.IconSize.DIALOG);
            icon_k.pixel_size = 96;
            icon_k.get_style_context ().add_class ("accented");
            var icon_l = new Gtk.Image.from_icon_name ("multimedia-video-player", Gtk.IconSize.DIALOG);
            icon_l.pixel_size = 96;
            
            var icon_16 = new Gtk.Image.from_icon_name (app_icon, Gtk.IconSize.DIALOG);
            icon_16.pixel_size = 16;
            var icon_24 = new Gtk.Image.from_icon_name (app_icon, Gtk.IconSize.DIALOG);
            icon_24.pixel_size = 24;
            var icon_32 = new Gtk.Image.from_icon_name (app_icon, Gtk.IconSize.DIALOG);
            icon_32.pixel_size = 32;
            var icon_48 = new Gtk.Image.from_icon_name (app_icon, Gtk.IconSize.DIALOG);
            icon_48.pixel_size = 48;
            var icon_64 = new Gtk.Image.from_icon_name (app_icon, Gtk.IconSize.DIALOG);
            icon_64.pixel_size = 64;
            var icon_128 = new Gtk.Image.from_icon_name (app_icon, Gtk.IconSize.DIALOG);
            icon_128.pixel_size = 128;
            icon_128.margin_end = 12;
            
            var icon_grid = new Gtk.Grid ();
            icon_grid.get_style_context ().add_class ("ip-grid");
            icon_grid.row_homogeneous = true;
            icon_grid.column_homogeneous = true;
            icon_grid.margin = 12;
            icon_grid.attach (icon_a, 0, 0, 1, 1);
            icon_grid.attach (icon_b, 1, 0, 1, 1);
            icon_grid.attach (icon_c, 2, 0, 1, 1);
            icon_grid.attach (icon_g, 3, 0, 1, 1);
            icon_grid.attach (icon_h, 4, 0, 1, 1);
            icon_grid.attach (icon_i, 5, 0, 1, 1);
            icon_grid.attach (icon_d, 0, 1, 1, 1);
            icon_grid.attach (icon_e, 1, 1, 1, 1);
            icon_grid.attach (icon_f, 2, 1, 1, 1);
            icon_grid.attach (icon_j, 3, 1, 1, 1);
            icon_grid.attach (icon_k, 4, 1, 1, 1);
            icon_grid.attach (icon_l, 5, 1, 1, 1);
            
            var label_a = new Gtk.Label ("16px");
            var label_b = new Gtk.Label ("24px");
            var label_c = new Gtk.Label ("32px");
            var label_d = new Gtk.Label ("48px");
            var label_e = new Gtk.Label ("64px");
            var label_f = new Gtk.Label ("128px");
            
            var label_app = new Gtk.Label (app_name);
            label_app.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            label_app.margin_start = 6;
            var label_id = new Gtk.Label (app_id);
            label_id.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
            label_id.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            
            var app_label_grid = new Gtk.Grid ();
            app_label_grid.margin = 6;
            app_label_grid.column_spacing = 6;
            app_label_grid.valign = Gtk.Align.CENTER;
            app_label_grid.attach (label_app, 0, 0, 1, 1);
            app_label_grid.attach (label_id, 1, 0, 1, 1);
            
            var app_icon_grid = new Gtk.Grid ();
            app_icon_grid.row_homogeneous = true;
            app_icon_grid.column_homogeneous = true;
            app_icon_grid.halign = Gtk.Align.CENTER;
            app_icon_grid.attach (icon_16, 0, 0, 1, 1);
            app_icon_grid.attach (icon_24, 1, 0, 1, 1);
            app_icon_grid.attach (icon_32, 2, 0, 1, 1);
            app_icon_grid.attach (icon_48, 3, 0, 1, 1);
            app_icon_grid.attach (icon_64, 4, 0, 1, 1);
            app_icon_grid.attach (icon_128, 5, 0, 1, 1);
            app_icon_grid.attach (label_a, 0, 1, 1, 1);
            app_icon_grid.attach (label_b, 1, 1, 1, 1);
            app_icon_grid.attach (label_c, 2, 1, 1, 1);
            app_icon_grid.attach (label_d, 3, 1, 1, 1);
            app_icon_grid.attach (label_e, 4, 1, 1, 1);
            app_icon_grid.attach (label_f, 5, 1, 1, 1);

            main_grid = new Gtk.Grid ();
            main_grid.attach (titlebar, 0, 0, 1, 1);
            main_grid.attach (icon_grid, 0, 1, 1, 1);
            main_grid.attach (app_label_grid, 0, 2, 1, 1);
            main_grid.attach (app_icon_grid, 0, 3, 1, 1);
            main_grid.show_all ();

            this.add (main_grid);
            this.set_size_request (360, 500);
            this.show_all ();
        }

        #if VALA_0_42
        protected bool match_keycode (uint keyval, uint code) {
        #else
        protected bool match_keycode (int keyval, uint code) {
        #endif
            Gdk.KeymapKey [] keys;
            Gdk.Keymap keymap = Gdk.Keymap.get_for_display (Gdk.Display.get_default ());
            if (keymap.get_entries_for_keyval (keyval, out keys)) {
                foreach (var key in keys) {
                    if (code == key.keycode)
                        return true;
                    }
                }

            return false;
        }

        public override bool delete_event (Gdk.EventAny event) {
            int x, y, w, h;
            get_position (out x, out y);
            get_size (out w, out h);

            IconPreviewer.Application.gsettings.set_int("window-x", x);
            IconPreviewer.Application.gsettings.set_int("window-y", y);
            IconPreviewer.Application.gsettings.set_int("window-width", w);
            IconPreviewer.Application.gsettings.set_int("window-height", h);

            return false;
        }
    }
}