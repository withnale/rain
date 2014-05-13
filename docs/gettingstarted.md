

# Getting Started 

## Creating a rainrc file

Before you can achieve very much you must create a .rainrc file in your home directory. This provides a place to store user specific values. For now lets just set the default parameters for our vcloud provider, and create a basic zone definition.

```yaml
:providers:
  :vcloud:
    :username: 'YOUR_USERNAME'
    :password: 'YOUR_PASSWORD'
    :host: 'api.YOUR_VCLOUD_PROVIDER.com'


:zones:
  :pootle:
    :vcloud:
      :org: 'YOUR_ORG_ID'
      :vdc: 'YOUR_VDC_NAME'
```

The above has created a zone called 'pootle'. You can now interrogate this zone to determine what is already deployed.

```bash
host% rain zone list
name                           provider 
pootle                         YOUR_VDC_NAME
```

And you can interrogate the live servers to see what is currently configured within this zone...

```bash
host% rain env show pootle

Showing Network for vdc-old-prod-enc
/work/code/rain-model/rain.yaml]
Showing live data for zone vdc-old-prod-enc
network              displayname          type         address              gateway              no range 
edgegw1              edgegw1              uplink       172.26.3.195/27      172.26.3.193             
edgegw1              edgegw1              uplink       192.168.91.114/29    192.168.91.113       3  192.168.91.114-116 

Showing Server for vdc-old-prod-enc
name                 status               role                 mem    cpu network         address 

Showing Firewall for pootle
       proto source-ip            port   srange    dest-ip              drange description

Showing NAT for pootle
type   proto  origin               port     dest                 port  
SNAT   Any    10.200.0.0/16        Any      192.168.91.114       Any   
DNAT   tcp    192.168.91.114       22       10.200.0.2           22    
```

This example shows working with rain without a model. In this mode you can stop and restart servers and query an environment, but to perform more advanced functions a model is required. 


 

