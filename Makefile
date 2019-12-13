.PHONY: usage
usage:
	@echo make init
	@echo make example-setup
	@echo make example
	@echo make erl-setup
	@echo make erl
	@echo make usg-setup
	@echo make usg

.PHONY: init
init:
	pipenv install

.PHONY: example-setup
example-setup:
	ssh-copy-id -i ~/.ssh/id_rsa example-setup
	pipenv run ansible --module-name raw --args "python3 --version || /usr/sbin/pkg_add -U -I -x python%3" --become example-init
	# https://stackoverflow.com/a/40866911
	pipenv run ansible-playbook play-sensitive-erl.yml --extra-vars "host_group=example-init"

.PHONY: example
example:
	pipenv run ansible-playbook play-example.yml --extra-vars "host_group=example"

.PHONY: erl-setup
erl-setup:
	ssh-copy-id -i ~/.ssh/id_rsa erl-setup
	pipenv run ansible --module-name raw --args "python3 --version || /usr/sbin/pkg_add -U -I -x python-3.7.4" --become erls-init
	# https://stackoverflow.com/a/40866911
	pipenv run ansible-playbook play-sensitive-erl.yml --extra-vars "host_group=erls-init"

.PHONY: erl
erl:
	pipenv run ansible-playbook play-sensitive-erl.yml --extra-vars "host_group=erls"

.PHONY: usg-setup
usg-setup:
	ssh-copy-id -i ~/.ssh/id_rsa usg-setup
	pipenv run ansible --module-name raw --args "/usr/sbin/pkg_add -U -I -x python%3" --become usgs-init
	# https://stackoverflow.com/a/40866911
	pipenv run ansible-playbook play-sensitive-usg.yml --extra-vars "host_group=usgs-init"

.PHONY: usg
usg:
	pipenv run ansible-playbook play-sensitive-usg.yml --extra-vars "host_group=usgs"
