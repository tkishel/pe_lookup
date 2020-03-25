# pe_lookup

#### Table of Contents

1. [Description - What the module does and why it is useful](#description)
1. [Setup - Getting started with this module](#setup)
1. [Usage - Command parameters and how to use them](#usage)
1. [Reference - How the module works and how to use its output](#reference)
1. [Limitations - Supported infrastructures and versions](#limitations)

## Description

This module provides a Puppet command `puppet pe lookup` that outputs a class parameter defined in Hiera and/or the Classifier.

## Setup

Install this module on the Primary Master.

## Usage

Run the `puppet pe lookup --param CLASS_PARAMETER` command as root on the Primary Master.

#### Parameters

##### `--param`

String. The class parameter to lookup.

##### `--node`

String. The node to lookup. Defaults to the node where the command is run.

##### `--pe_environment`

String. The environment of the node to lookup. Defaults to 'production'.

## Reference

This command uses code used by `puppet infrastructure recover_configuration`.

### Output

```shell
[root@pe-master ~] puppet pe lookup --param puppet_enterprise::profile::console::delayed_job_workers
# Node: pe-master.puppetdebug.vlan
# Setting: puppet_enterprise::profile::console::delayed_job_workers

# Setting found in Hiera:

---
puppet_enterprise::profile::console::delayed_job_workers: 1


# Setting found in the Classifier:

{
  "puppet_enterprise::profile::console::delayed_job_workers": 2
}
```

## Limitations

### Version Support

Support is limited to the following versions:

* PE 2018.x.x
* PE 2019.x.x
