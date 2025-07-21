dependencies = [dependency('gtk4'), dependency('json-c'), dependency('webkitgtk-6.0')]

gtk_layer_shell = dependency('gtk-layer-shell-0', required: get_option('layershell'))
if gtk_layer_shell.found()
	dependencies += gtk_layer_shell
	add_project_arguments('-DLAYER_SHELL', language : 'c')
endif

executable(
		'gtkgreet',
		[
			'main.cpp',
			'proto.c',
			'config.cpp',
			'actions.c',
			'window.c',
			'gtkgreet.cpp'
		],
		dependencies: dependencies,
		install: true)
