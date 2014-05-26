## Developer Notes


### Tests

At present there are not many tests defined. The ones that are present are cucumber based and focused on acceptance testing the model subcommands. I would like to be able to mock the live tests somewhat, but do not really have that much experience with how to do this with fog.mock or equivalent. 

Since the internal code is still evolving I have shied away from implementing rspec code level checks. Some areas are starting to to feel more final and so I will be adding these in time, however I am more focused on coverage of acceptance level checks first.

### Command Suite

Over the lifetime of this project I have tried numerous different command suite gems including Thor, gli and methadone. I've been frustrated with all of them in different ways to the extent that I stopped working on the project for a period.

I basically wanted something lightweight that provided a simple method for making a n-depth command suite application which still allowed me to work with OptionParser directly. 

In the end I wrote my own code and you can find it in lib/rain/commands/cmd_base.rb. It makes use of self.inherited to generate the command suite tree based on the subclass hierarchy. It's not as clean as I would like right now, but I am in the process of converting this to a mixin (and possibly a gem) to make it easier to reuse in other applications.

### Dynamic Loading

I was keen to support multiple different models simultaneously, to allow me to improve the model syntax over time. The original model definition is pretty much driven by the underlying API calls and so there was a lot of duplication present in the XML/YAML. Gradually I have been trying to simpify this and in the future I'd like to create a DSL implementation as well as static YAML.

To achieve this, I worked on dynamically loading implementations and making them pluggable from the rainrc configuration. Below is the default model implementation.

```yaml
:modellers:
  :default:
     :firewall: 'Rain::Modellers::Yaml::Firewall'
     :nat:      'Rain::Modellers::Yaml::Nat'
     :network:  'Rain::Modellers::Xml::Network'
     :server:   'Rain::Modellers::Yaml::Server'
```

In this way, I can gradually introduce different models as desired. The dynamic loading code is implemented in lib/rain/util/dynamic_create.rb.

At present there has been little work done to abstract the data structures between the model implementations so in most cases rain is using a data structure similar to the YAML representation internally.

### Exception Handling

I've made extensive use of custom exception classes to pass back error conditions between methods and these are all defined in lib/rain/errors.rb. In addition to this, the toplevel rescue block will format a valid error message from I18N string tables using a lookup key and a set of key/value pairs passed to the exception. Most of this code was lifted from an early version of the vagrant exception handling.

