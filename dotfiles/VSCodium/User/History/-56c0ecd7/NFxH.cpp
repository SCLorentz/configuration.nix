#define _POSIX_C_SOURCE 200809L

#include <time.h>
#include <assert.h>

#include <glib/gi18n.h>
#include <gtk/gtk.h>
#include <gtk/gtkentry.h>
#include <gtk/gtkcustomlayout.h>
#include <gtk/gtksnapshot.h>

#include <string>
#include <iostream>

//#include "actions.h"
#include "proto.h"
#include "gtkgreet.h"
#include "window.h"

using namespace std;

extern "C" {

static void handle_response(struct response resp, int start_req)
{
    switch (resp.response_type)
    {
        case response_type_success: {
            if (start_req) exit(0);
            struct request req = {
                request_type_start_session,
                { { 0 } }
            };
            strncpy(req.body.request_start_session.cmd, gtkgreet->selected_command, 127);
            handle_response(roundtrip(req), 1);
            break;
        }
        case response_type_auth_message: {
            if (start_req)
            {
                struct request req = {
                    request_type_cancel_session,
                    { { 0 } }
                };
                roundtrip(req);

                string error = "Unexpected auth question";
                gtkgreet_setup_question(gtkgreet, QuestionTypeInitial, gtkgreet_get_initial_question(), _(error.c_str()));
                break;
            }

            gtkgreet_setup_question(gtkgreet,
                (enum QuestionType)resp.body.response_auth_message.auth_message_type,
                resp.body.response_auth_message.auth_message,
                NULL);
            break;
        }
        case response_type_roundtrip_error:
        case response_type_error: {
            struct request req = {
                request_type_cancel_session,
                { { 0 } }
            };
            roundtrip(req);

            string error = "Login failed";
            if (resp.response_type != response_type_error && resp.body.response_error.error_type != error_type_auth)
                error = resp.body.response_error.description;

            gtkgreet_setup_question(gtkgreet, QuestionTypeInitial, gtkgreet_get_initial_question(), _(error.c_str()));
            break;
        }
    }
}

void action_answer_question([[maybe_unused]] GtkWidget *widget, gpointer data)
{
    Window *ctx = static_cast<Window *>(data);
    switch (gtkgreet->question_type)
    {
        case QuestionTypeInitial: {
            if (gtkgreet->selected_command)
            {
                free(gtkgreet->selected_command);
                gtkgreet->selected_command = NULL;
            }
            //const char *text = gtk_editable_get_text(GTK_EDITABLE(ctx->command_selector)); <-- GTK_DROPDOW not GTK_EDITABLE
            //gtkgreet->selected_command = g_strdup(text);

            struct request req = {
                request_type_create_session,
                { { 0 } }
            };
            
            const string input = gtk_editable_get_text(GTK_EDITABLE(ctx->input_field));

            if (ctx->input_field != NULL)
                strncpy(req.body.request_create_session.username, input.c_str(), 127);
            
            handle_response(roundtrip(req), 0);
            break;
        }
        case QuestionTypeSecret:
        case QuestionTypeVisible: {
            struct request req = {
                request_type_post_auth_message_response,
                { { 0 } }
            };
            if (ctx->input_field != NULL)
                strncpy(req.body.request_post_auth_message_response.response, gtk_editable_get_text(GTK_EDITABLE(ctx->input_field)), 127);
            handle_response(roundtrip(req), 0);
            break;
        }
        case QuestionTypeInfo:
        case QuestionTypeError: {
            struct request req = {
                request_type_post_auth_message_response,
                { { 0 } }
            };
            req.body.request_post_auth_message_response.response[0] = '\0';
            handle_response(roundtrip(req), 0);
            break;
        }
    }
}

void action_cancel_question([[maybe_unused]] GtkWidget *widget, [[maybe_unused]] gpointer data)
{
    struct request req = {
        request_type_cancel_session,
        { { 0 } }
    };
    struct response resp = roundtrip(req);

    if (resp.response_type != response_type_success) exit(1);
    gtkgreet_setup_question(gtkgreet, QuestionTypeInitial, gtkgreet_get_initial_question(), NULL);
}

}