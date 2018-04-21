Manage OpenBSD with Ansible
===========================

Introduction
------------

This repo is a quick start way to begin configuration management with Ansible
of OpenBSD on Ubiquiti EdgeRouter Lite (ERL 3) and/or USG, assuming these:

* Ansible is installed on your local machine.
* On ERL/USG:

  * You have installed the latest release (6.3 at time of writing) of OpenBSD.
  * *root* user has password set.
  * A user called *ubnt* exists.
  * Network and remote access through ssh on interface cnmac0 (eth0 port on ERL or wan1 on USG) is working.

* Network

  * IPv4 and IPv6 are functioning and desired at the edge of the network (cable modem in my case).
  * You want to override the MAC address of cnmac0 to something else. I wanted to do it so I could swap in multiple gateway devices without needing to contact my service provider.

ssh Config
----------

Configure ssh client config on your local machine. Use *./ssh_config.example*
as needed to configure your *~/.ssh/config* file.

Modify the IP addresses of your hosts.

*erl-setup* is a temporary host since it's provided by your existing network's
DHCP on cnmac0 during initial setup on a fresh install of OpenBSD. After setup
we'll use *erl-admin*, which uses the internal IP provided by DHCP from ERL to
your machine when it's connected on cnmac1 or cnmac2 interfaces.

Same is the case with *usg-setup* and *usg-admin*.

Since I rebuild ERL many times I use **highly insecure** ssh settings. You may
want to use more secure settings for *CheckHostIP*, *StrictHostKeyChecking*,
and *UserKnownHostsFile*, especially when using production boxes.

Copy ssh key to remote machine, using one or more of the following examples as
needed.

::

    $ ssh-copy-id -i ~/.ssh/id_rsa erl-setup
    $ ssh-copy-id -i ~/.ssh/id_rsa erl-admin
    $ ssh-copy-id -i ~/.ssh/id_rsa usg-setup
    $ ssh-copy-id -i ~/.ssh/id_rsa usg-admin

Ansible Config
--------------

Review my settings in *ansible.cfg* and *hosts* files in this repo. Edit them
as desired.

Bootstrap
---------

Installing Python 2.7 is required before the playbook can run. This is done
outside of a playbook because I like it that way. I have not tried running
this in a playbook.

Install Python2.7.

::

    $ ansible --module-name raw --args "/usr/sbin/pkg_add -U -I -x python%2.7" --become ubnts

Playbook
--------

Look at the example playbook and modify vars as needed before running it.

::

    $ ansible-playbook play-example.yml

If your assumptions are different from mine then read all the templates in
various roles and modify them as desired.

Finally, reboot the device.

::

    $ ssh erl-setup
    erl$ su -
    # reboot

    $ ssh usg-setup
    usg$ su -
    # reboot

Once the router is working as expected you can remove *erl-setup* and/or
*usg-setup* from *~/.ssh/config* and use *erl-admin* and/or *usg-admin* thereafter.

Makefile
--------

If you have `make` installed, you can use the provided *Makefile*. Modify it as
needed before continuing.

Bootstrap your ERL and/or USG.

::

    $ make init

Run your playbook.

::

    $ make ansible
