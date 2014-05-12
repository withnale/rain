# Example Model Commands 

There are four main rain subcommands for working with the environment: network, servers, firewall and nat. As much as possible there is commonality in the way each of these are invoked:

Once you have created your first model, there are a number of commands you can run. NB: In these examples, it is assumed an environment called test01 exists. A sample environment exists in 'etc/testdata/test-model'.

## Model commands

The model commands show the desired state for a given environment:

```bash
host% rain network model test01

host% rain server model test01

host% rain firewall model test01

host% rain nat model test01

```


## Show commands

The show commands however, show the actual live state of the environment


```bash
host% rain network show test01

host% rain server show test01

host% rain firewall show test01

host% rain nat show test01

```


## Diff commands

The diff commands will effectively merge the two above commands and show a context diff between what *should* be in the environment and what actually is.


```bash
host% rain network diff test01

host% rain server diff test01

host% rain firewall diff test01

host% rain nat diff test01

```

## Updating Firewall and NAT rules

Firewall and NAT rules are both implemented as Edge Gateway Services and so are very similar to manage. To create or update either of these use the following syntax:

```bash
host% rain firewall create test01

host% rain nat create test01

```



## Working with Servers

There are a number of additional verbs explicitly associated with servers

* create
* poweron
* poweroff
* delete

By default rain will try to apply these rules for all servers defined in the model. If you want to limit the scope of the command or you wish to reference a server that is not defined in the model, you can specify it with the -s/--server parameter.

```bash
host% rain server poweron -s jump-01.test01 test01

host% rain server poweroff -s jump-01.test01 test01
```

These can be used individually as above or they can be chained together using the 'action' verb. Typically, the two examples below are often used: the first to powercycle the server, and the second to delete the server completely are replace it.

```bash
host% rain server action -A poweroff,poweron -s jump-01.test01 test01

host% rain server action -A poweroff,delete,create,poweron -s jump-01.test01 test01
```

NB: These have been left deliberately as long commands to type to avoid writing these destructive commands by mistake.
