.PHONY: init
init:
	ssh-copy-id erl-setup
	ssh-copy-id usg-setup
	pipenv run ansible --module-name raw --args "/usr/sbin/pkg_add -U -I -x python%2.7" --become ubnts

.PHONY: ansible
ansible:
	pipenv run ansible-playbook play-example.yml
