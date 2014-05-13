# Welcome to Rain

Rain is a tool designed to make it easier to work with VCloudDirector environments. 

More specifically, the main design goals are:

1. To remove the need to use the VCloudDirector GUI for which there are not words to convey my disgust. The aim is that all tasks should be achievable from a command line, and so templates, servers, networks, firewall and nat rules should all be possible.
1. To be able to define a model that defines an environment and then assert this model and highlight differences between the model and live.
1. To have the model be agnositic to the VDC it is associated with, so that multiple versions of the same configuration can be achieved without modification to the model. This is achieved using basic parameter substitution during the model loading process.

The documentation for this project is a work in progress. 


