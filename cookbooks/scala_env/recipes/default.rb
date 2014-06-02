include_recipe "git"
include_recipe "ssh_known_hosts"
include_recipe "java::default" # install java
include_recipe "java_ext::jce" # install cryptographic extentions
include_recipe "chef-sbt::default" # install sbt
include_recipe "mongodb::10gen_repo" # set the mongodb repo to 10gen
include_recipe "mongodb::default" # install mongodb
include_recipe "redisio::install" # install redis
include_recipe "redisio::enable" # enable redis startup

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

# download and extract MCR
bash "download and extract MCR" do
     user "vagrant"
     cwd "/var/chef/cache"
     code <<-EOH
       wget http://www.mathworks.com/supportfiles/MCR_Runtime/R2012a/MCR_R2012a_glnxa64_installer.zip
       unzip MCR_R2012a_glnxa64_installer.zip -d MCR_R2012a_glnxa64_installer
       chmod 755 MCR_R2012a_glnxa64_installer/installer_input.txt
       echo "agreeToLicense=yes" >> MCR_R2012a_glnxa64_installer/installer_input.txt       
       echo "export LD_LIBRARY_PATH=/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/bin/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/sys/java/jre/glnxa64/jre/lib/amd64/server:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/sys/java/jre/glnxa64/jre/lib/amd64:${LD_LIBRARY_PATH}" >> /home/vagrant/.profile
     EOH
     not_if "test -d /var/chef/cache/MCR_R2012a_glnxa64_installer"
end

execute "install MCR" do
  user "root"
  command "./install -mode silent -installputFile installer_input.txt"
  cwd "/var/chef/cache/MCR_R2012a_glnxa64_installer"
  not_if do FileTest.directory?('/usr/local/MATLAB') end
end

# install MCR deps
['libx11-6', 'libxau6', 'libxdmcp6', 'libxext6', 'libxi6', 'libxmu6', 'libxp6', 'libxt6', 'libxtst6'].each do |lib|
    apt_package "install MCR deps - "+lib do
      package_name lib
      action :install
    end
end 

# install tig
apt_package "install tig" do
  package_name "tig"
  action :install
end