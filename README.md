vagrant_scala_env
=================

Vagrant environment that provisions scala, sbt, matlab compiler runtime, mongodb and redis. It also clones a repo.

Setup:

1. ensure agent sharing is setup on the host: https://help.github.com/articles/using-ssh-agent-forwarding
2. Download vagrant (www.vagrantup.com)
3. Update Vagrantfile with own settings
4. gem install berkshelf
5. `vagrant plugin install vagrant-berkshelf --plugin-version '>= 2.0.1'`
6. `vagrant plugin install vagrant-omnibus`
7. `vagrant plugin install vagrant-vbguest`
8. `vagrant up` (read vagrant docs for other commands)

Notes:
- If you encounter issues with cleanup (cookbook path not set) excecute: rm ./.vagrant/machines/<machinename>/berkshelf then execute `vagrant reload`
- Use NFS for shared folders as VirtualBox shared folders are exceptionally slow

