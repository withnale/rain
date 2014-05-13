# The Rain Model

Whilst it's possible to work with rain without a model, that's where the real power comes in.

For reference, there is a default model in etc/testdata/test-model which is used by the acceptance tests. This may be a good starting point to understanding how the model system works..

## The Rain Model directory

By default rain will look for a model directory called 'rain-model' on the same level as rain directory. The expectation is that this directory will be under version control.

This will contain the toplevel definition file for the models, zones and environments and will be the search path for models.

An example rain.yaml file might look like this:

```yaml
:zones:
  :vdc-zone1:
    :vcloud:
      :org: '12-34-5-678901'
      :vdc: 'INSERT_VDC_NAME_HERE'

:envs:
  :test01:
    :model: model01
    :zone: vdc-zone1
```

In this example a zone (aka VCloud VDC) has been defined and then an environment has been defined and associated with this zone. In addition the environment 'test01' has been associated with the model 'model01' which defines the expected end-state for the environment.

In addition you will probably need to define some defaults for your VCloud provider. 

```yaml
:providers:
  :vcloud:
    :host: 'api.YOUR_VCLOUD_PROVIDER.com'
```

## Model Layout

The model used the vcloud-tools model as a starting point, which is mainly composed of YAML files. It uses the following structure:

* network - a set of XML files (network/*.xml) each uniquely defining a VCloud network
* servers - a set of YAML files (servers/*.yaml) which contain YAML fragments for each server
* firewall - a set of YAML files (firewall/*.yaml) which contain YAML fragment to define the firewall
* nat - a set of YAML files (nat/*.yaml) which contain YAML fragment to define the NAT rules

The YAML files have been deliberately treated as a set of files to allow you to segregate rules into sets.

When each of the above files are loaded, rain searches for any variables referenced and replaces them with values defined from rain.yaml. A more complete rain.yaml might look like this:

```yaml
:zones:
  :vdc-zone1:
    :vcloud:
      :org: '12-34-5-678901'
      :vdc: 'INSERT_VDC_NAME_HERE'
    :variables:
      :public_1: 1.2.3.4
      :public_2: 1.2.3.5

:envs:
  :test01:
    :model: model01
    :zone: vdc-zone1
    :variables:
      :ip_prefix: 10.0.3
```

A fragment of a server.yaml file that utilised this might read:

```yaml
vapps:
  -
    name: jump.%{envname}
    vm:
      hardware_config:
        memory: 2048
        cpu: 1
      network_connections:
        -
          name: admin
          ip_address: %{ip_prefix}1.10
```

This allows the model to be abstracted and reused across multiple environments/zones. Further examples of this can be seen in the example model data.

