#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <gtk/gtk.h>
#include <fstream>
#include <string>

#include "gtkgreet.h"

using namespace std;

//extern "C" int config_update_command_selector(GListStore *store)
extern "C" int config_update_command_selector([[maybe_unused]] GListModel *model)
{
    int entries = 0;
    if (gtkgreet->command != NULL)
    {
        g_list_store_append(G_LIST_STORE(model), g_strdup(gtkgreet->command));
    	entries++;
    }

    string line;
    ifstream fp("/etc/nixos/dotfiles/greetd/environments");
    if (!fp) return entries;

    while(getline(fp, line))
    {
        if (!line.empty() && line.back() == '\n') line.pop_back();

        if (gtkgreet->command != NULL && string(gtkgreet->command) == line)
        	continue;

        g_list_store_append(G_LIST_STORE(model), g_strdup(line.c_str()));
        entries++;
    }

    fp.close();
    return entries;
}