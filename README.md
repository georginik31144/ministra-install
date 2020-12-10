# Ministra Middleware Auto Installation Script

This script is designed for installing Ministra 5.6.1 on a clean Ubuntu 16.04 system.

It is based on the instructions from the link below:

https://wiki.infomir.eu/eng/ministra-tv-platform/ministra-installation-guide/ministra-tv-platform-installation

WHAT TO DO IF PHING EXECUTION FAILS ON UBUNTU 16.04
https://wiki.infomir.eu/eng/ministra-tv-platform/ministra-installation-guide/faq/what-to-do-if-phing-execution-fails-on-ubuntu-16-04
File to patch:

build.xml 

Before executing ministra-install.sh, make sure of the following:
- The ministra-<version>.zip file is in the same directory as this script
- The script has execute permissions (chmod +x install.sh)
- The run script ./install.sh
There are still many tweaks to be made, such as changing from the hard coded username/password for the stalker user.

