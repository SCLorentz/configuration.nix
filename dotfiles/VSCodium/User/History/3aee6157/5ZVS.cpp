#define _POSIX_C_SOURCE 200809L

#include <assert.h>
#include <gtk/gtk.h>

#include "window.h"
#include "gtkgreet.h"

#include <glib/gi18n.h>
#include <locale.h>
#include <string>
#include <vector>

struct GtkGreet *gtkgreet = NULL;

static char* command = NULL;
static char* background = NULL;
static char* style = NULL;

#ifdef LAYER_SHELL
static gboolean use_layer_shell = FALSE;
#endif

using namespace std;

static GOptionEntry entries[] =
{
    #ifdef LAYER_SHELL
    { "layer-shell", 'l', 0, G_OPTION_ARG_NONE, &use_layer_shell, "Use layer shell", NULL},
    #endif
    { "command", 'c', 0, G_OPTION_ARG_STRING, &command, "Command to run", "sway"},
    { "background", 'b', 0, G_OPTION_ARG_STRING, &background, "Background image to use", NULL},
    { "style", 's', 0, G_OPTION_ARG_FILENAME, &style, "CSS style to use", NULL },
    { NULL, 0, 0, G_OPTION_ARG_NONE, NULL, NULL, NULL}
};

#ifdef LAYER_SHELL
    static void reload_outputs()
    {
        GdkDisplay *display = gdk_display_get_default();

        // Make note of all existing windows
        GArray *dead_windows = g_array_new(FALSE, TRUE, sizeof(struct Window*));
        for (guint idx = 0; idx < gtkgreet->windows->len; idx++)
        {
            struct Window *ctx = g_array_index(gtkgreet->windows, struct Window*, idx);
            g_array_append_val(dead_windows, ctx);
        }

        // Go through all monitors
        GListModel *monitors = gdk_display_get_monitors(display);
        guint n_monitors = g_list_model_get_n_items(monitors);

        for (guint i = 0; i < n_monitors; i++)
        {
            GdkMonitor* monitor = static_cast<GdkMonitor*>(g_list_model_get_item(monitors, i));
            struct Window *w = gtkgreet_window_by_monitor(gtkgreet, monitor);

            if (w != NULL)
            {
                // We already have this monitor, remove from dead_windows list
                for (guint ydx = 0; ydx < dead_windows->len; ydx++)
                {
                    if (w == g_array_index(dead_windows, struct Window*, ydx)) {
                        g_array_remove_index_fast(dead_windows, ydx);
                        break;
                    }
                }
            }
            else create_window(monitor);

            g_object_unref(monitor);
        }

        // Remove all windows left behind
        for (guint idx = 0; idx < dead_windows->len; idx++)
        {
            vector<Window*> dead_windows;
            Window* w = dead_windows[idx];
            gtk_window_close(GTK_WINDOW(w->window));
            if (gtkgreet->focused_window == w)
                gtkgreet->focused_window = NULL;
        }

        for (guint idx = 0; idx < gtkgreet->windows->len; idx++)
        {
            struct Window *win = g_array_index(gtkgreet->windows, struct Window*, idx);
            window_configure(win);
        }

        g_array_unref(dead_windows);
    }

    static void monitors_changed(GdkDisplay *display, GdkMonitor *monitor) { reload_outputs(); }

    static gboolean setup_layer_shell()
    {
        if (gtkgreet->use_layer_shell)
        {
            reload_outputs();
            GdkDisplay *display = gdk_display_get_default();
            g_signal_connect(display, "monitor-added", G_CALLBACK(monitors_changed), NULL);
            g_signal_connect(display, "monitor-removed", G_CALLBACK(monitors_changed), NULL);
            return TRUE;
        }
        else return FALSE;
    }
#else
    static gboolean setup_layer_shell() { return FALSE; }
#endif

static void activate([[maybe_unused]] GtkApplication *app, [[maybe_unused]] gpointer user_data)
{
    gtkgreet_activate(gtkgreet);
    if (!setup_layer_shell())
    {
        struct Window *win = create_window(NULL);
        gtkgreet_focus_window(gtkgreet, win);
        //window_configure(win);
    }
}

[[maybe_unused]] static void attach_custom_style(const string path)
{
    g_print("applying custom style %s", path.c_str());
    GtkCssProvider *provider = gtk_css_provider_new();

    gtk_css_provider_load_from_path(provider, path.c_str());

    GdkDisplay *display = gdk_display_get_default();
    gtk_style_context_add_provider_for_display(display, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

    g_object_unref(provider);
}

int main(int argc, char **argv)
{
    setlocale(LC_ALL, "");
    bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
    textdomain(GETTEXT_PACKAGE);

    GError *error = NULL;
    GOptionContext *option_context = g_option_context_new("- GTK-based greeter for greetd");
    g_option_context_add_main_entries(option_context, entries, NULL);

    if (!g_option_context_parse(option_context, &argc, &argv, &error))
    {
        g_print("option parsing failed: %s\n", error->message);
        exit(1);
    }

    gtkgreet = create_gtkgreet();

    #ifdef LAYER_SHELL
    gtkgreet->use_layer_shell = use_layer_shell;
    #endif
    gtkgreet->command = command;

    if (background != NULL)
    {
        gtkgreet->background = gdk_pixbuf_new_from_file(background, &error);
        if (gtkgreet->background == NULL)
            g_print("background loading failed: %s\n", error->message);
    }

    g_signal_connect(gtkgreet->app, "activate", G_CALLBACK(activate), NULL);
    int status = g_application_run(G_APPLICATION(gtkgreet->app), argc, argv);

    if (style != NULL)
    {
        string path = style;
        attach_custom_style(path);
    }

    gtkgreet_destroy(gtkgreet);

    return status;
}
