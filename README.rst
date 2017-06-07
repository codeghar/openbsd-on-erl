Manage OpenBSD on EdgeRouter Lite with Ansible
==============================================

Introduction
------------

This repo is a quick start way to begin configuration management with Ansible
of OpenBSD on Ubiquiti EdgeRouter Lite (ERL), assuming these:

* Ansible is installed on your local machine.
* On ERL:

  * You have installed the latest release (6.1 at time of writing) of OpenBSD.
  * *root* user has password set.
  * A user called *ubnt* exists.
  * Network and remote access through SSH on eth0 (cnmac0) is working.

* Network

  * IPv4 and IPv6 are functioning and desired at the edge of the network (cable modem in my case).
  * You want to override the MAC address of eth0 (cnmac0) to something else. I wanted to do it so I could swap in multiple gateway devices without needing to contact my service provider.

SSH Config
----------

Configure SSH client config on your local machine. Add this to
*~/.ssh/config*. Modify as needed.

::

    Host erl-admin-dynamic
        HostName 10.10.10.73
        Port 22
        User ubnt
        AddressFamily inet
        CheckHostIP no
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        IdentityFile ~/.ssh/id_rsa

    Host erl-admin
        HostName 192.168.1.1
        Port 22
        User ubnt
        AddressFamily inet
        CheckHostIP no
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        IdentityFile ~/.ssh/id_rsa

*erl-admin-dynamic* is a temporary host since it's provided by your
existing network's DHCP. After setup we'll use *erl-admin*.

Since I rebuild ERL many times I use **highly insecure** SSH
settings. You may want to use more secure settings for *CheckHostIP*,
*StrictHostKeyChecking*, and *UserKnownHostsFile*, especially when using
production boxes.

Copy SSH key to remote machine.

::

    $ ssh-copy-id -i ~/.ssh/id_rsa erl-admin-dynamic
    $ ssh-copy-id -i ~/.ssh/id_rsa erl-admin

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

    $ ansible --module-name raw --args "/usr/sbin/pkg_add -U -I -x python%2.7" --become --become-method=su --ask-become-pass erl-admin-dynamic


Playbook
--------

Look at the example playbook and modify vars as needed before running it.

::

    $ ansible-playbook --ask-become-pass --limit erl-admin-dynamic play-example.yml

If your assumptions are different from mine then read all the templates in
various roles and modify them as desired.

Finally, reboot ERL3.

::

    $ ssh erl-admin-dynamic
    erl$ su -
    # reboot

Once ERL3 is working as expected you can remove *erl-admin-dynamic*
from SSH config and use *erl-admin* thereafter.
