#ifndef _AUTH_QUESTION_H
#define _AUTH_QUESTION_H

#include <gtk/gtk.h>

#ifdef __cplusplus
extern "C" {
#endif

void action_answer_question(GtkWidget *widget, gpointer data);
void action_cancel_question(GtkWidget *widget, gpointer data);

#ifdef __cplusplus
}
#endif

#endif
