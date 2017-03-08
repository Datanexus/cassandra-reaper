# dn-cassandra-reaper
Playbooks/Roles used to deploy Cassandra Reaper

# Installation
To install Cassandra Reaper using the `site.yml` playbook in this repository, first clone the contents of this repository to a local directory using a command like the following:

```bash
$ git clone --recursive https://github.com/Datanexus/dn-cassandra-reaper
```

That command will pull down the repository and it's submodules (currently the only dependency embedded as a submodule is the dependency on the `https://github.com/Datanexus/common-roles` repository).

# Using this role to deploy Cassandra Reaper
The `site.yml` file at the top-level of this repository pulls in a set of default values for the parameters that are needed to deploy an instance of Cassandra Reaper to a node from the `vars/reaper.yml` file.

This default configuration defines default values for all of the parameters needed to deploy an instance of Cassandra Reaper to a node, including defining reasonable defaults for the URL that the distribution should be downloaded from, the directory that the gzipped tarfile containing the The distribution should be unpacked into, and the packages that must be installed on the node for Cassandra Reaper to run.  To deploy Cassandra Reaper to a node the IP address "192.168.34.12" using the role in this repository, one would simply run a command that looks like this:

```bash
$ export REAPER_ADDR="192.168.34.12"
$ ansible-playbook -i "${REAPER_ADDR}," -e "{ host_inventory: ['${REAPER_ADDR}']}" site.yml
```

This will download the distribution from the main Cassandra Reaper download site onto the host with an IP address of 192.168.34.12, unpack the gzipped tarfile that it downlaoded form that site into the `/opt/cassandra-reaper` directory on that host, and install/configure the Cassandra Reaper server locally on that host.

The download site is can be slow, so in our experience it has been a much better option to download the gzipped tarfile containing the Cassandra Reaper distribution from that site once, then post it on a local webserver (one that is only available internally) and download it from the nodes we are setting up as Cassandra Reaper servers from that internal web server.  This can be accomplished by also including a definition for the `reaper_url` parameter in the extra variables that are passed into the Ansible playbook run.  In that case, the command shown above ends up looking something like this:

```bash
$ export REAPER_URL="https://10.0.2.2/fusion-3.0.0.tar.gz"
$ export REAPER_ADDR="192.168.34.12"
$ ansible-playbook -i "${REAPER_ADDR}," -e "{ host_inventory: ['${REAPER_ADDR}'] \
    reaper_url: '${REAPER_URL}'}" site.yml
```

(assuming that the file is available directly from a web-server that is accessible from the Cassandra Reaper server we are building via the IP address 10.0.2.2).  The path that the Cassandra Reaper distribution is unpacked into can also be overriden on the command-line in a similar fashion (using the `reaper_dir` variable) if the default values shown in the `vars/reaper.yml` file (above) proves to be problematic.

# Assumptions
It is assumed that this playbook will be run on a recent (systemd-based) version of RHEL or CentOS (RHEL-7.x or CentOS-7.x, for example); no support is provided for other distributions (and the `site.xml` playbook will not run successfully).  The examples shown above also assume that some (shared-key?) mechanism has been used to provide access to the Kafka host from the Ansible host that the ansible-playbook is being run on (if not, then additional arguments might be required to authenticate with that host from the Ansible host that are not shown in the example `ansible-playbook` commands shown above).

# Deployment via vagrant
A Vagrantfile is included in this repository that can be used to deploy Cassandra Reaper to a VM using the `vagrant` command.  From the top-level directory of this repository a command like the following will (by default) deploy Cassandra Reaper to a CentOS 7 virtual machine running under VirtualBox (assuming that both vagrant and VirtualBox are installed locally, of course):

```bash
$ vagrant -s="192.168.34.12" up
```

Note that the `-s` (or the corresponding `--solr-list`) flag must be used to pass an IP address into the Vagrantfile (this IP address will be used as the IP address of the Cassandra Reaper server that is created by the vagrant command shown above).

## Additional vagrant deployment options
While the `vagrant up` command that is shown above can be used to easily deploy Cassandra Reaper to a node, the Vagrantfile included in this distribution also supports separating out the creation of the virtual machine from the provisioning of that virtual machine using the Ansible playbook contained in this repository's `site.yml` file. To create a virtual machine without provisioning it, simply run a command that looks something like this:

```bash
$ vagrant -s="192.168.34.12" up --no-provision
```

This will create a virtual machine with the appropriate IP address ("192.168.34.12"), but will skip the process of provisioning that VM with an instance of Cassandra Reaper using the playbook in the `site.yml` file.  To provision that machine with a Cassandra Reaper instance, you would simply run the following command:

```bash
$ vagrant -s="192.168.34.12" provision
```

That command will attach to the named instance (the VM at "192.168.34.12") and run the playbook in this repository's `site.yml` file on that node (resulting in the deployment of an instance the Cassandra Reaper distribution to that node).

It should also be noted here that while the commands shown above will install Cassandra Reaper with a reasonable default configuration from a standard location, there are two additional command-line parameters that can be used to override the default values that are embedded in the `vars/reaper.yml` file that is included as part of this repository:  the `-u` (or corresponding `--url`) flag and the `-p` (or corresponding `--path`) flag.  The `-u` flag can be used to override the default URL that is used to download the Cassandra Reaper distribution (which points back to the Cassandra Reaper GitHub page), while the `-p` flag can be used to override the default path (`/opt/cassandra-reaper`) that that the Cassandra Reaper gzipped tarfile is unpacked into during the provisioning process.

As an example of how these options might be used, the following command will download the gzipped tarfile containing the Cassandra Reaper distribution from a local web server, rather than downloading it from the main Cassandra Reaper distribution site and unpack the downladed gzipped tarfile into the `/opt/cassandra-reaper` directory when provisioning the VM with an IP address of `192.168.34.12` with an instance of the Cassandra Reaper distribution:

```bash
$ vagrant -k="192.168.34.12" -p="/opt/cassandra-reaper" -u="https://10.0.2.2/cassandra-reaper-0.3.0.tar.gz" provision
```

Obviously, this option could prove to be quite useful in situations were we are deploying the distribution from a datacenter environment (where access to the internet may be restricted, or even unavailable).

## Default configuration

The default configuration provided is found in `templates/reaper.yaml`. It uses a pre-existing Cassandra cluster to store its state in. To specify where this Cassandra cluster is and the name of it add the options `--cassandra-seeds="10.10.0.1,10.10.0.2" --cassandra-cluster-name="MyCluster"`.