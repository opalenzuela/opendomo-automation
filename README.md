opendomo-automation
===================

Automation scripts plugin for [OpenDomoOS2](https://github.com/opalenzuela/opendomo).

The objective of this plugin is to implement the existing features of OpenDomo OS 1.0.0 in the 2.0 version, adapting the scripts to the characteristics of this new base system. The main features are:

1. Scenes
2. Sequences
3. Conditions
4. Custom ports (New!)

How to test it?
===============

This plugin has already a stable version that can be installed from the Manage Plugins option, in the Configuration section. To test the development branch, it's required to be installed via oddevel package. To do so, install oddevel to your OpenDomoOS2 system, and execute the following lines as "admin", from the command line:

    $ plugin_add_from_gh.sh opalenzuela opendomo-automation
    
After a few seconds the plugin will be ready in your system. Please, report any problem found in the [Issues section](https://github.com/opalenzuela/opendomo-automation/issues).
