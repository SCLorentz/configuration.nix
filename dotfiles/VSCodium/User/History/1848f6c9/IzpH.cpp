#define _POSIX_C_SOURCE 200809L

#include <gtk/gtk.h>
#include <glib/gi18n.h>
#include <iterator>

#include "window.h"
#include "gtkgreet.h"

extern "C" {

struct Window* gtkgreet_window_by_widget(struct GtkGreet *gtkgreet, GtkWidget *window)
{
    for (guint idx = 0; idx < gtkgreet->windows->len; idx++)
    {
        struct Window *ctx = g_array_index(gtkgreet->windows, struct Window*, idx);
        if (ctx->window == window)
            return ctx;
    }
    return NULL;
}

struct Window* gtkgreet_window_by_monitor(struct GtkGreet *gtkgreet, GdkMonitor *monitor)
{
    for (guint idx = 0; idx < gtkgreet->windows->len; idx++) {
        struct Window *ctx = g_array_index(gtkgreet->windows, struct Window*, idx);
        if (ctx->monitor == monitor)
            return ctx;
    }
    return NULL;
}

void gtkgreet_remove_window_by_widget(struct GtkGreet *gtkgreet, GtkWidget *widget)
{
    for (guint idx = 0; idx < gtkgreet->windows->len; idx++)
    {
        struct Window *ctx = g_array_index(gtkgreet->windows, struct Window*, idx);
        if (ctx->window == widget)
        {
            if (gtkgreet->focused_window)
                gtkgreet->focused_window = NULL;
            free(ctx);
            g_array_remove_index_fast(gtkgreet->windows, idx);
            return;
        }
    }
}

void gtkgreet_focus_window(struct GtkGreet *gtkgreet, struct Window* win)
{
    struct Window *old = gtkgreet->focused_window;
    gtkgreet->focused_window = win;

    window_swap_focus(win, old);
    for (guint idx = 0; idx < gtkgreet->windows->len; idx++) {
        struct Window *ctx = g_array_index(gtkgreet->windows, struct Window*, idx);
        window_configure(ctx);
    }
}

void gtkgreet_setup_question(struct GtkGreet *gtkgreet, enum QuestionType type, char* question, char* error)
{
    if (gtkgreet->question != NULL) {
        free(gtkgreet->question);
        gtkgreet->question = NULL;
    }
    if (gtkgreet->error != NULL) {
        free(gtkgreet->error);
        gtkgreet->error = NULL;
    }
    gtkgreet->question_type = type;
    if (question != NULL)
        gtkgreet->question = strdup(question);
    if (error != NULL)
        gtkgreet->error = strdup(error);
    gtkgreet->question_cnt += 1;
    for (guint idx = 0; idx < gtkgreet->windows->len; idx++) {
        struct Window *ctx = g_array_index(gtkgreet->windows, struct Window*, idx);
        window_configure(ctx);
    }
}

void gtkgreet_update_clocks(struct GtkGreet *gtkgreet)
{
    time_t now = time(nullptr);
    struct tm *now_tm = localtime(&now);
    if (now_tm == NULL)
        return;

    //string time_str = std::format("{:02}:{:02}", now_tm->tm_hour, now_tm->tm_min);
    
    snprintf(gtkgreet->time, 8, "%s", time_str.c_str());
    for (guint idx = 0; idx < gtkgreet->windows->len; idx++) {
        struct Window *ctx = g_array_index(gtkgreet->windows, struct Window*, idx);
        window_update_clock(ctx);
    }
}

static int gtkgreet_update_clocks_handler(gpointer data)
{
    struct GtkGreet *gtkgreet = (struct GtkGreet*)data;
    gtkgreet_update_clocks(gtkgreet);
    return TRUE;
}

struct GtkGreet* create_gtkgreet()
{
    gtkgreet = new GtkGreet();

    gtkgreet->app = gtk_application_new("wtf.kl.gtkgreet", G_APPLICATION_DEFAULT_FLAGS);
    gtkgreet->windows = g_array_new(FALSE, TRUE, sizeof(struct Window*));
    gtkgreet->question_cnt = 1;
    return gtkgreet;
}

void gtkgreet_activate(struct GtkGreet *gtkgreet)
{
    gtkgreet->draw_clock_source = g_timeout_add_seconds(5, gtkgreet_update_clocks_handler, gtkgreet);
    gtkgreet_setup_question(gtkgreet, QuestionTypeInitial, gtkgreet_get_initial_question(), NULL);
    gtkgreet_update_clocks(gtkgreet);
}

void gtkgreet_destroy(struct GtkGreet *gtkgreet)
{
    if (gtkgreet->question != NULL) {
        free(gtkgreet->question);
        gtkgreet->question = NULL;
    }
    if (gtkgreet->error != NULL) {
        free(gtkgreet->error);
        gtkgreet->error = NULL;
    }

    g_object_unref(gtkgreet->app);
    g_array_unref(gtkgreet->windows);

    if (gtkgreet->draw_clock_source > 0) {
        g_source_remove(gtkgreet->draw_clock_source);
        gtkgreet->draw_clock_source = 0;
    }
    free(gtkgreet);
}

char* gtkgreet_get_initial_question() { return _("Username:"); }

}