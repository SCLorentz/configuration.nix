#define SAFE_LABEL(widget) ({ \
    g_assert(GTK_IS_LABEL(widget)); \
    GTK_LABEL(widget); \
})