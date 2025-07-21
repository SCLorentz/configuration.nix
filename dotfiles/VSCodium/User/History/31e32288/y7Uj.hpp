#ifndef _WINDOW_H
#define _WINDOW_H

#include <gtk/gtk.h>
#include <memory>

// Defined in gtkgreet.h
enum QuestionType;

class Window {
public:
    GdkMonitor *monitor;

    GtkWidget *window;
    GtkWidget *revealer;
    GtkWidget *window_box;
    GtkWidget *body;
    GtkWidget *input_box;
    GtkWidget *input_field;
    GtkWidget *command_selector;
    GtkWidget *clock_label;

#ifdef LAYER_SHELL
    gulong enter_notify_handler;
#endif

    int question_cnt;

    Window(GdkMonitor *monitor) : monitor(monitor), question_cnt(0) {}
};

std::unique_ptr<Window> create_window(GdkMonitor *monitor);
void window_configure(Window *win);
void window_setup_question(Window *ctx, QuestionType type, char* question, char* error);
void window_update_clock(Window *ctx);
void window_swap_focus(Window *win, Window *old);

#endif