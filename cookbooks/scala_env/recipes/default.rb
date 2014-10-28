include_recipe "git"
include_recipe "ssh_known_hosts"
include_recipe "java::default" # install java
include_recipe "java_ext::jce" # install cryptographic extentions
include_recipe "chef-sbt::default" # install sbt
include_recipe "mongodb::10gen_repo" # set the mongodb repo to 10gen
include_recipe "mongodb::default" # install mongodb
include_recipe "redisio::default" # install redis
include_recipe "redisio::enable" # enable redis startup
include_recipe "nodejs"

# install nfs (required for nfs sharing instead of shared folders)
['nfs-common', 'portmap'].each do |lib|
    apt_package "install NFS - "+lib do
      package_name lib
      action :install
    end
end 

# add source repo to known hosts
ssh_known_hosts_entry node[:source_repo][:domain]

# clone source
git node[:source_repo][:destination] do
  repository node[:source_repo][:clone_url]
  revision node[:source_repo][:branch]
  action :sync
end

# set the git global identity
bash "set git global email address" do   
   user "vagrant"
   group "vagrant"
   code <<-EOH
    echo "[user]" >> /home/vagrant/.gitconfig
    echo "  email = #{node[:git][:global_email_address]}" >> /home/vagrant/.gitconfig
    echo "  name = #{node[:git][:global_name]}" >> /home/vagrant/.gitconfig
    EOH
end

# create directories for sbt repo settings
['/home/vagrant/.sbt', '/home/vagrant/.sbt/0.13'].each do |dir|
    directory dir do
      action :create  
      owner "vagrant"
      group "vagrant"
    end
end

# create sbt repo settings
template "repo.sbt" do
  path "/home/vagrant/.sbt/0.13/repo.sbt"
  source "repo.sbt.erb"
  owner "vagrant"
  group "vagrant"
  mode "0644"
end

# install tig
apt_package "install tig" do
  package_name "tig"
  action :install
end

# install software properties (for apt-add-repository)
['software-properties-common', 'python-software-properties'].each do |lib|
    apt_package "install properties - "+lib do
      package_name lib
      action :install
    end
end 

# add fish shell repo
execute "add fish shell repo" do
  user "root"
  group "root"
  command "apt-add-repository ppa:fish-shell/release-2"
end

# install fish shell
apt_package "install fish shell" do
  package_name "fish"
  action :install
end

# make fish shell the default shell for vagrant user
execute "make fish shell the default shell" do
  user "root"
  group "root"
  command "chsh -s /usr/bin/fish vagrant"
end

