# Manage OpenBSD with Ansible

This repo is a quick start way to begin configuration management with Ansible
of OpenBSD on Ubiquiti EdgeRouter Lite (ERL 3) and/or USG, assuming these:

- Ansible is installed on your local machine.
- On ERL/USG:

  - You have installed the latest release (6.3 at time of writing) of OpenBSD.
  - *root* user has password set.
  - A user called *ubnt* exists.
  - Network and remote access through ssh on interface cnmac0 (eth0 port on ERL or wan1 on USG) is working.

- Network

  - IPv4 and IPv6 are functioning and desired at the edge of the network (cable modem in my case).
  - You want to override the MAC address of cnmac0 to something else. I wanted to do it so I could swap in multiple gateway devices without needing to contact my service provider.

# ssh Config

Configure ssh client config on your local machine. Use *./ssh_config.example*
as needed to configure your *~/.ssh/config* file.

Modify the IP addresses of your hosts.

*erl-setup* is a temporary host since it's provided by your existing network's
DHCP on cnmac0 during initial setup on a fresh install of OpenBSD. After setup
we'll use *erl-admin*, which uses the internal IP provided by DHCP from ERL to
your machine when it's connected on cnmac1 or cnmac2 interfaces.

Same is the case with *usg-setup* and *usg-admin*.

Why do I differentiate between erl and usg? I have one device of each type and
use two different IP subnets. I run one device in production at all times. Then
I can run the other device as I work on it while still having internet access
through the production network. I can easily swap them as needed. All I have to
do is make sure all devices re-IP when I do so.

Since I rebuild ERL many times I use **highly insecure** ssh settings. You may
want to use more secure settings for *CheckHostIP*, *StrictHostKeyChecking*,
and *UserKnownHostsFile*, especially when using production boxes.

Copy ssh key to remote machine, using one or more of the following examples as
needed.

    $ ssh-copy-id -i ~/.ssh/id_rsa erl-setup
    $ ssh-copy-id -i ~/.ssh/id_rsa erl-admin
    $ ssh-copy-id -i ~/.ssh/id_rsa usg-setup
    $ ssh-copy-id -i ~/.ssh/id_rsa usg-admin

# Ansible Config

Review my settings in *ansible.cfg* and *hosts* files in this repo. Edit them
as desired.

# Bootstrap

Installing Python 3 is required before the playbook can run. This is done
outside of a playbook because I like it that way. I have not tried running
this in a playbook.

Install Python 3.

    $ ansible --module-name raw --args "/usr/sbin/pkg_add -U -I -x python%3" --become ubnts

# Playbook

Look at the example playbook and modify vars as needed before running it.

    $ ansible-playbook play-example.yml

If your assumptions are different from mine then read all the templates in
various roles and modify them as desired.

Finally, reboot the device.

    $ ssh erl-setup
    erl$ su -
    # reboot

    $ ssh usg-setup
    usg$ su -
    # reboot

Once the router is working as expected you can use *erl-admin* and/or
*usg-admin* thereafter.

# Makefile

If you have ``make`` installed, you can use the provided *Makefile*. Modify it as
needed before continuing.

Bootstrap your ERL and/or USG.

    $ make erl-setup
    $ make usg-setup

Run your playbook.

    $ make erl
    $ make usg

# Test the Configuration

Once the router setup is complete, you may want to test that it's configured
correctly. Below are some ways to test a macOS client after it's connected to
the router.

## IPv6 address is assigned

    ifconfig en0 | grep inet6

## Find IPv6 gateways

    netstat -rn | grep default | grep '%en0'

## Find all IPv6 link-local addresses

    ping6 -c3 -n -I en0 ff02::1

Source: https://serverfault.com/a/648143


## Find all DNS servers (IPv4 and IPv6)

    scutil --dns
