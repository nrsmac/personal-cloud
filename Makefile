standup:
	tofu apply -auto-approve
	./wait_for_hosts.sh
install-k3s:
	cd k3s-ansible && ansible-playbook playbooks/site.yml -i inventory.yml
teardown:
	tofu destroy -auto-approve