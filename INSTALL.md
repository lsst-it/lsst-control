# Testing foreman

This is a rough guide for applying the code base on an existing Foreman 3.8/3.9
installation on AlmaLinux 8.

This works by introducing a nother site, called `test`. The idea is to have
test systems that are isolated from the rest of the LSST infrastructure. For
example IPA isn't managed and no real route53 keys are provided.

## Setup the VM

We use Hetzner for cloud instances to test setups:

```
hcloud server create --image=alma-8 --name=$host --type=cpx41 --ssh-key='bastelfreak'
hcloud server set-rdns $host --ip=95.217.179.41 --hostname=$host
hcloud server set-rdns $host --ip=2a01:4f9:c012:acee::1 --hostname=$host
```

(Now also add matching A/AAAA records to make this easier)

```
ssh-keygen -f ~/.ssh/known_hosts -R $host
ssh-keyscan $host >> ~/.ssh/known_hosts
```

## Patching

```
sed --in-place 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
echo 'if [ $TERM == "alacritty" ]; then export TERM=xterm-256color; fi' > /etc/profile.d/terminal.sh
LC_ALL=en_US.UTF-8 dnf -y update
LC_ALL=en_US.UTF-8 dnf -y install vim glibc-all-langpacks git bash-completion epel-release
crb enable
sync
reboot
```

### Make vim less shitty

also this provides a persistent undo history in case I derp in config files

```
mkdir -p ~/.vim/{backupdir,undodir}
wget https://gist.githubusercontent.com/bastelfreak/a3cfa50db2a7be92c47f246f8f22ca5c/raw/dab14889680d4a8bbcb83580185ca2e5040d5947/vla.vimrc -O ~/.vimrc
```

### Helpful tools

Those are helpful during testing

```
dnf -y install htop tig jq
```

## install Puppet + Foreman

```
dnf -y install https://yum.puppet.com/puppet7-release-el-8.noarch.rpm
dnf -y install https://yum.theforeman.org/releases/3.8/el8/x86_64/foreman-release.rpm
dnf -y module enable foreman:el8
dnf -y install foreman-installer
foreman-installer --enable-foreman-plugin-puppetdb
dnf -y install puppetdb puppetdb-termini postgresql-contrib
```

Output from the installer should be like this:

```
[root@lsst ~]# foreman-installer --enable-foreman-plugin-puppetdb
2024-02-11 18:57:31 [NOTICE] [root] Loading installer configuration. This will take some time.
2024-02-11 18:57:33 [NOTICE] [root] Running installer with log based terminal output at level NOTICE.
2024-02-11 18:57:33 [NOTICE] [root] Use -l to set the terminal output log level to ERROR, WARN, NOTICE, INFO, or DEBUG. See --full-help for definitions.
2024-02-11 18:57:35 [NOTICE] [configure] Starting system configuration.
2024-02-11 18:58:30 [NOTICE] [configure] 250 configuration steps out of 1244 steps complete.
2024-02-11 18:58:39 [NOTICE] [configure] 500 configuration steps out of 1247 steps complete.
2024-02-11 18:58:45 [NOTICE] [configure] 750 configuration steps out of 1272 steps complete.
2024-02-11 18:58:56 [NOTICE] [configure] 1000 configuration steps out of 1272 steps complete.
2024-02-11 19:00:12 [NOTICE] [configure] 1250 configuration steps out of 1272 steps complete.
2024-02-11 19:00:15 [NOTICE] [configure] System configuration has finished.
Executing: foreman-rake upgrade:run
  Success!
  * Foreman is running at https://foreman
      Initial credentials are admin / s2hYUi7oEksKxaNM
  * Foreman Proxy is running at https://foreman

The full log is at /var/log/foreman-installer/foreman.log
[root@lsst ~]#
```

### Configure r10k

# Install r10k + control-repo

First we want to stop puppet so it doesn't make unexpected changes in the
background after code got deployed.

```
systemctl disable --now puppet
```

Now install r10k

```
source /etc/profile.d/puppet-agent.sh
# required if we're on Puppet 7, which contains Ruby 2.7. newer faraday wants ruby 3
puppet resource package faraday ensure=2.8.1 provider=puppet_gem
puppet resource package r10k ensure=installed provider=puppet_gem
ln -s /opt/puppetlabs/puppet/bin/r10k /usr/local/bin/
```

configure r10k

```
mkdir -p /etc/puppetlabs/r10k
cat > /etc/puppetlabs/r10k/r10k.yaml << EOF
---
pool_size: 8
deploy:
  generate_types: true
  purge_levels:
  - deployment
  exclude_spec: true
  incremental: true
:postrun: []
:cachedir: /opt/puppetlabs/puppet/cache/r10k
:sources:
  puppet:
    basedir: /etc/puppetlabs/code/environments
    remote: https://github.com/bastelfreak/lsst-control
EOF
```

deploy the code

```
r10k deploy environment production bastelfreak --modules --verbose --color
```

## Configure PuppetDB

Setup the database and user

```
su --login postgres --command 'createuser --no-createdb --no-createrole --no-superuser puppetdb'
su --login postgres --command 'createuser --no-createdb --no-createrole --no-superuser puppetdb_read'
su --login postgres --command 'createdb --encoding UTF8 --owner postgres puppetdb'
su --login postgres --command "psql puppetdb --command 'revoke create on schema public from public'"
su --login postgres --command "psql puppetdb --command 'grant create on schema public to puppetdb'"
su --login postgres --command "psql puppetdb --command 'alter default privileges for user puppetdb in schema public grant select on tables to puppetdb_read'"
su --login postgres --command "psql puppetdb --command 'alter default privileges for user puppetdb in schema public grant usage on sequences to puppetdb_read'"
su --login postgres --command "psql puppetdb --command 'alter default privileges for user puppetdb in schema public grant execute on functions to puppetdb_read'"
su --login postgres --command "psql puppetdb --command 'create extension pg_trgm'"
su --login postgres --command "psql puppetdb --command \"ALTER USER puppetdb WITH PASSWORD 'PASSWORD'\""
su --login postgres --command "psql puppetdb --command \"ALTER USER puppetdb_read WITH PASSWORD 'PASSWORD'\""
```

Tell PuppetDB to use the database

```
echo '[database]' > /etc/puppetlabs/puppetdb/conf.d/database.ini
echo 'subname = //127.0.0.1:5432/puppetdb' >> /etc/puppetlabs/puppetdb/conf.d/database.ini
echo 'username = puppetdb' >> /etc/puppetlabs/puppetdb/conf.d/database.ini
echo 'password = PASSWORD' >> /etc/puppetlabs/puppetdb/conf.d/database.ini
echo '[read-database]' >> /etc/puppetlabs/puppetdb/conf.d/database.ini
echo 'subname = //127.0.0.1:5432/puppetdb' >> /etc/puppetlabs/puppetdb/conf.d/database.ini
echo 'username = puppetdb_read' >> /etc/puppetlabs/puppetdb/conf.d/database.ini
echo 'password = PASSWORD' >> /etc/puppetlabs/puppetdb/conf.d/database.ini
```

Start PuppetDB

```
systemctl enable --now puppetdb
```

Update Puppetserver to talk to PuppetDB
```
puppet config set --section server storeconfigs true
puppet config set --section main reports foreman,puppetdb
echo -e "[main]\nserver_urls = https://$(hostname -f):8081/\nsoft_write_failure = true" > /etc/puppetlabs/puppet/puppetdb.conf
systemctl restart puppetserver
```

## configure node in foreman

We need to ensure foreman knows the environment `bastelfreak` before we can
assign it

* login at https://foreman/
* got to https://foreman/foreman_puppet/environments, import new environments

We need to set the environment in foreman

* login at https://foreman/
* select the node, click edit
    * should bring you to https://foreman/hosts/foreman/edit
* At environment, select `bastelfreak`
* save

We need to set the role and site

* login at https://foreman/
* At https://foreman/hosts/foreman/edit, go to `Parameters`
* Select `Add Parameter`
* Name=site, Value=test; save
* Repeat: Name=role, Value=foreman; save


At the moment a full puppet run doesn't succeed, but we can apply the following tags:

```
puppet agent -t --tags accounts,prometheus,chrony,yumrepo,auditd,tftp,convenience,debugutils,rsyslog,discovery,puppetserver,host,irqbalance,ssh,lldpd,sysstat,r10k,webhook,timezone,selinux,yum,docker,firewall,foreman_envsync,resolv_conf,sudo,postgresql_conf,udevd,reboot.target
```

Due to this we miss some migrations:

```
systemctl restart foreman
foreman-rake db:migrate
```

Then we can reboot:

```
sync; reboot
```

## Rebuilding the instance

```
hcloud server rebuild $host --image=alma-8
ssh-keygen -f ~/.ssh/known_hosts -R $host
ssh-keyscan $host >> ~/.ssh/known_hosts
```

## Final updates

**update**: After a bit of playing with Hiera, Puppet now succeeds within two
runs. The `foreman_config_entry` resources only work on the second run, maybe
because they have a missing dependency to one of the foreman packages.
