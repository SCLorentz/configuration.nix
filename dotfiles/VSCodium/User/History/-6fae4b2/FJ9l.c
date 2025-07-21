#define _POSIX_C_SOURCE 200809L

#include <time.h>
#include <assert.h>

#include <glib/gi18n.h>

#include <gtk/gtk.h>
#include <gtk/gtkentry.h>
#include <gtk/gtkeditable.h>
#include <gtk/gtkcustomlayout.h>
#include <gtk/gtksnapshot.h>
#include <webkitgtk-6.0/webkit/webkit.h>

#include "proto.h"
#include "window.h"
#include "gtkgreet.h"
#include "actions.h"
#include "config.h"

static void window_set_focus(struct Window *win, struct Window *old);

#ifdef LAYER_SHELL
#include <gtk-layer-shell.h>

    static void window_set_focus_layer_shell(struct Window *win, struct Window *old)
    {
        if (old != NULL) gtk_layer_set_keyboard_interactivity(GTK_WINDOW(old->window), FALSE);
        gtk_layer_set_keyboard_interactivity(GTK_WINDOW(win->window), TRUE);
    }

    static gboolean window_enter_notify(GtkWidget *widget, gpointer data) {
        struct Window *win = gtkgreet_window_by_widget(gtkgreet, widget);
        gtkgreet_focus_window(gtkgreet, win);
        return FALSE;
    }

    static void window_setup_layershell(struct Window *ctx)
    {
        // ! gtk_widget_add_events(ctx->window, GDK_ENTER_NOTIFY);
        /* todo:
        GtkEventController* controller = gtk_event_controller_motion_new();
        g_signal_connect(controller, "enter", G_CALLBACK(on_enter), ctx);
        gtk_widget_add_controller(ctx->window, controller);*/

        /*if (ctx->enter_notify_handler > 0) {
            g_signal_handler_disconnect(ctx->window, ctx->enter_notify_handler);
            ctx->enter_notify_handler = 0;
        }
        ctx->enter_notify_handler = g_signal_connect(ctx->window, "enter-notify-event", G_CALLBACK(window_enter_notify), NULL);*/

        gtk_layer_init_for_window(GTK_WINDOW(ctx->window));
        gtk_layer_set_layer(GTK_WINDOW(ctx->window), GTK_LAYER_SHELL_LAYER_TOP);
        gtk_layer_set_monitor(GTK_WINDOW(ctx->window), ctx->monitor);
        gtk_layer_auto_exclusive_zone_enable(GTK_WINDOW(ctx->window));
        gtk_layer_set_anchor(GTK_WINDOW(ctx->window), GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
        gtk_layer_set_anchor(GTK_WINDOW(ctx->window), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
        gtk_layer_set_anchor(GTK_WINDOW(ctx->window), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
        gtk_layer_set_anchor(GTK_WINDOW(ctx->window), GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
    }

#endif

void window_update_clock(struct Window *ctx)
{
    char time[48];
    int size = 96000;
    if (gtkgreet->focused_window == NULL || ctx == gtkgreet->focused_window)
        size = 32000;
    g_snprintf(time, 48, "<span size='%d'>%s</span>", size, gtkgreet->time);
    g_assert(GTK_IS_LABEL(ctx->clock_label));
    gtk_label_set_markup((GtkLabel*)ctx->clock_label, time);
}

void on_visibility_icon_press(GtkWidget *widget, gpointer data)
{
    gboolean visible = gtk_entry_get_visibility(GTK_ENTRY(widget));

    if (visible) {
        gtk_entry_set_visibility(GTK_ENTRY(widget), FALSE);
        gtk_entry_set_icon_from_icon_name(GTK_ENTRY(widget), GTK_ENTRY_ICON_SECONDARY, "view-reveal-symbolic");
    }
    else {
        gtk_entry_set_visibility(GTK_ENTRY(widget), TRUE);
        gtk_entry_set_icon_from_icon_name(GTK_ENTRY(widget), GTK_ENTRY_ICON_SECONDARY, "view-conceal-symbolic");
    }
}

void window_setup_question(struct Window *ctx, enum QuestionType type, char* question, char* error)
{
    if (gtkgreet->focused_window != NULL && ctx != gtkgreet->focused_window) return;

    // TODO organize this pls

    ctx->input_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    GtkWidget *question_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 5);
    gtk_widget_set_halign(question_box, GTK_ALIGN_END);

    GtkWidget *button_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 5);
    gtk_widget_set_halign(button_box, GTK_ALIGN_END);
    gtk_box_append(GTK_BOX(ctx->input_box), button_box);

    GtkWidget *label = gtk_label_new(question);
    gtk_widget_set_halign(label, GTK_ALIGN_END);
    gtk_box_append(GTK_BOX(question_box), label);

    ctx->input_field = gtk_entry_new();
    gtk_widget_set_name(ctx->input_field, "input-field");

    GtkWidget *continue_button = gtk_button_new_with_label(_("Log in"));
    g_signal_connect(continue_button, "clicked", G_CALLBACK(action_answer_question), ctx);
    gtk_widget_add_css_class(continue_button, "suggested-action");
    gtk_widget_set_halign(continue_button, GTK_ALIGN_END);

    GListStore *store = g_list_store_new(GTK_TYPE_STRING_OBJECT);
    config_update_command_selector(G_LIST_MODEL(store));

    ctx->command_selector = gtk_drop_down_new(G_LIST_MODEL(store), NULL);
    gtk_drop_down_set_selected(GTK_DROP_DOWN(ctx->command_selector), 0);

    gtk_widget_set_tooltip_text(ctx->command_selector, _("Command to run on login"));
    g_signal_connect(ctx->command_selector, "notify::selected", G_CALLBACK(action_answer_question), ctx);

    gtk_box_append(GTK_BOX(button_box), continue_button);
    gtk_box_append(GTK_BOX(ctx->input_box), question_box);
    gtk_box_append(GTK_BOX(ctx->body), ctx->input_box);
    gtk_box_append(GTK_BOX(ctx->input_box), ctx->command_selector);

    switch (type)
    {
        case QuestionTypeInitial:
        case QuestionTypeVisible:
        case QuestionTypeSecret: {
            if (type == QuestionTypeSecret)
            {
                gtk_entry_set_input_purpose(GTK_ENTRY(ctx->input_field), GTK_INPUT_PURPOSE_PASSWORD);
                gtk_entry_set_visibility(GTK_ENTRY(ctx->input_field), FALSE);
                gtk_entry_set_icon_from_icon_name(GTK_ENTRY(GTK_ENTRY(ctx->input_field)), GTK_ENTRY_ICON_SECONDARY, "view-reveal-symbolic");
                gtk_entry_set_icon_activatable(GTK_ENTRY(ctx->input_field), GTK_ENTRY_ICON_SECONDARY, TRUE);
                g_signal_connect(ctx->input_field, "icon-press", G_CALLBACK(on_visibility_icon_press), NULL);
            }
            g_signal_connect(ctx->input_field, "activate", G_CALLBACK(action_answer_question), ctx);
            gtk_widget_set_size_request(ctx->input_field, 384, -1);
            gtk_widget_set_halign(ctx->input_field, GTK_ALIGN_END);
            gtk_box_append(GTK_BOX(question_box), ctx->input_field);
            break;
        }
        case QuestionTypeInfo:
        case QuestionTypeError: {
            GtkWidget *label = gtk_label_new(question);
            gtk_widget_set_halign(label, GTK_ALIGN_END);
            gtk_box_append(GTK_BOX(question_box), label);
            break;
        }
    }

    if (error != NULL) {
        GtkWidget *label = gtk_label_new(error);
        char err[128];
        snprintf(err, 128, "<span color=\"red\">%s</span>", error);

        g_assert(GTK_IS_LABEL(label));
        gtk_label_set_markup((GtkLabel*)label, err);
        gtk_widget_set_halign(label, GTK_ALIGN_END);
        gtk_box_append(GTK_BOX(button_box), label);
    }

    switch (type) {
        case QuestionTypeVisible:
        case QuestionTypeSecret:
        case QuestionTypeInfo:
        case QuestionTypeError: {
            GtkWidget *cancel_button = gtk_button_new_with_label(_("Cancel"));
            gtk_widget_set_halign(cancel_button, GTK_ALIGN_END);
            gtk_box_append(GTK_BOX(button_box), cancel_button);
            g_signal_connect(cancel_button, "clicked", G_CALLBACK(action_cancel_question), ctx);
            break;
        }
        case QuestionTypeInitial:
            break;
    }

    gtk_widget_set_visible(ctx->window, TRUE);

    if (ctx->input_field != NULL) gtk_widget_grab_focus(ctx->input_field);
}

static void window_empty(struct Window *ctx)
{
    if (ctx->revealer != NULL) {
        gtk_box_remove(GTK_BOX(ctx->window_box), ctx->revealer);
        ctx->revealer = NULL;
    }

    ctx->window_box = NULL;
    ctx->clock_label = NULL;
    ctx->body = NULL;
    ctx->input_box = NULL;
    ctx->input_field = NULL;
    ctx->command_selector = NULL;
}

static void window_setup(struct Window *ctx) 
{
    // Create general structure if it is missing
    if (ctx->revealer == NULL)
    {
        ctx->revealer = gtk_revealer_new();
        // g_object_set(revealer, "margin-start", 20, "margin-end", 20, NULL); <-- using CSS instead
        gtk_widget_add_css_class(ctx->revealer, "rv");
        gtk_widget_set_valign(ctx->revealer, GTK_ALIGN_CENTER);
        gtk_box_append(GTK_BOX(ctx->window_box), ctx->revealer);
        gtk_revealer_set_transition_type(GTK_REVEALER(ctx->revealer), GTK_REVEALER_TRANSITION_TYPE_NONE);
        gtk_revealer_set_reveal_child(GTK_REVEALER(ctx->revealer), FALSE);
        gtk_revealer_set_transition_duration(GTK_REVEALER(ctx->revealer), 750);
    }

    // Update input area if necessary
    if (gtkgreet->focused_window == ctx || gtkgreet->focused_window == NULL) {
        if (ctx->body == NULL)
        {
            ctx->body = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
            gtk_widget_set_halign(ctx->body, GTK_ALIGN_CENTER);
            gtk_widget_set_name(ctx->body, "body");
            gtk_widget_set_size_request(ctx->body, 384, -1);
            gtk_box_append(GTK_BOX(ctx->window_box), ctx->body);
            window_update_clock(ctx);
        }
        window_setup_question(ctx, gtkgreet->question_type, gtkgreet->question, gtkgreet->error);
    }
    else if (ctx->body != NULL) {
        gtk_box_remove(GTK_BOX(ctx->window_box), ctx->body);
        ctx->body = NULL;
        ctx->input_box = NULL;
        ctx->input_field = NULL;
        ctx->command_selector = NULL;
        window_update_clock(ctx);
    }

    if (ctx->revealer != NULL) {
        gtk_revealer_set_transition_type(GTK_REVEALER(ctx->revealer), GTK_REVEALER_TRANSITION_TYPE_CROSSFADE);
        gtk_revealer_set_reveal_child(GTK_REVEALER(ctx->revealer), TRUE);
    }

    ctx->question_cnt = gtkgreet->question_cnt;
}

static void window_destroy_notify(GtkWidget *widget, gpointer data)
{
    window_empty(gtkgreet_window_by_widget(gtkgreet, widget));
    gtkgreet_remove_window_by_widget(gtkgreet, widget);
}

static void window_set_focus(struct Window *win, struct Window *old)
{
    assert(win != NULL);
    //window_setup(win);

    if (old != NULL && old != win)
    {
        if (old->input_field != NULL && win->input_field != NULL)
        {
            // Get previous cursor position
            gint cursor_pos = 0;
            g_object_get(GTK_ENTRY(old->input_field), "cursor-position", &cursor_pos, NULL);

            // Move content
            //gtk_editable_set_text(GTK_EDITABLE(win->input_field), gtk_editable_get_text(GTK_EDITABLE(old->input_field)));
            //gtk_editable_set_text(GTK_EDITABLE(old->input_field), "");

            // Update new cursor position
            g_signal_emit_by_name(GTK_ENTRY(win->input_field), "move-cursor", GTK_MOVEMENT_BUFFER_ENDS, -1, FALSE);
            g_signal_emit_by_name(GTK_ENTRY(win->input_field), "move-cursor", GTK_MOVEMENT_LOGICAL_POSITIONS, cursor_pos, FALSE);
        }
        if (old->command_selector != NULL && win->command_selector != NULL)
        {
            int index = gtk_drop_down_get_selected(GTK_DROP_DOWN(old->command_selector));
            gtk_drop_down_set_selected(GTK_DROP_DOWN(win->command_selector), index);
        }
        
        window_setup(old);
        gtk_widget_set_visible(old->window, TRUE);
    }
    gtk_widget_set_visible(win->window, TRUE);
}

void window_swap_focus(struct Window *win, struct Window *old)
{
    #ifdef LAYER_SHELL
        if (gtkgreet->use_layer_shell) window_set_focus_layer_shell(win, old);
    #endif
        window_set_focus(win, old);
}

void window_configure(struct Window *w)
{
    #ifdef LAYER_SHELL
        if (gtkgreet->use_layer_shell)
            window_setup_layershell(w);
    #endif
        window_setup(w);
        gtk_widget_set_visible(w->window, TRUE);
}

static void draw_bg(GtkDrawingArea *area, cairo_t *cr, int width, int height, gpointer user_data)
{
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_rectangle(cr, 0, 0, width, height);
    cairo_fill(cr);
}

struct Window *create_window(GdkMonitor *monitor)
{
    struct Window *w = calloc(1, sizeof(struct Window));
    if (w == NULL) {
        // C++ cerr << "failed to allocate Window instance\n";
        fprintf(stderr, "failed to allocate Window instance\n");
        exit(1);
    }
    w->monitor = monitor;
    g_array_append_val(gtkgreet->windows, w);

    w->window = gtk_application_window_new(gtkgreet->app);
    g_signal_connect(w->window, "destroy", G_CALLBACK(window_destroy_notify), NULL);
    gtk_window_set_title(GTK_WINDOW(w->window), "GTK-Greeter");
    gtk_window_set_default_size(GTK_WINDOW(w->window), 200, 200);

    w->window_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
    gtk_widget_set_hexpand(w->window_box, TRUE);
    gtk_widget_set_vexpand(w->window_box, TRUE);
    gtk_window_set_child(GTK_WINDOW(w->window), w->window_box);

    w->clock_label = gtk_label_new(NULL);
    gtk_widget_set_name(w->clock_label, "clock");
    gtk_widget_set_halign(w->clock_label, GTK_ALIGN_CENTER);
    gtk_widget_set_valign(w->clock_label, GTK_ALIGN_START);
    gtk_box_append(GTK_BOX(w->window_box), w->clock_label);
    window_update_clock(w);

    if (gtkgreet->background != NULL)
    {
        GtkWidget *bg = gtk_drawing_area_new();
        gtk_widget_set_hexpand(bg, TRUE);
        gtk_widget_set_vexpand(bg, TRUE);
        gtk_drawing_area_set_draw_func(GTK_DRAWING_AREA(bg), draw_bg, NULL, NULL);

        gtk_box_prepend(GTK_BOX(w->window_box), bg);
    }
    return w;
}
