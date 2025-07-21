#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <gtk/gtk.h>
#include <fstream>
#include <string>

#include "gtkgreet.h"
//#include "config.h"

using namespace std;

extern "C" int config_update_command_selector(GtkWidget *combobox)
{
    int entries = 0;
    if (gtkgreet->command != NULL) {
        gtk_combo_box_text_append((GtkComboBoxText*)combobox, NULL, gtkgreet->command);
    	entries++;
    }

    string line;
    ifstream fp("/etc/greetd/environments");
    if (!fp) return entries;

    while(getline(fp, line))
    {
        //size_t len = line.length();
        if (!line.empty() && line.back() == '\n')
            line.pop_back();
        if (gtkgreet->command != NULL && string(gtkgreet->command) == line)
        	continue;

        gtk_combo_box_text_append((GtkComboBoxText*)combobox, NULL, line.c_str());
        entries++;
    }

    fp.close();
    return entries;
}