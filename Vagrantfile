# (c) 2017 DataNexus Inc.  All Rights Reserved
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'optparse'
require 'resolv'

# monkey-patch that is used to leave unrecognized options in the ARGV
# list so that they can be processed by underlying vagrant command
class OptionParser
  # Like order!, but leave any unrecognized --switches alone
  def order_recognized!(args)
    extra_opts = []
    begin
      order!(args) { |a| extra_opts << a }
    rescue OptionParser::InvalidOption => e
      extra_opts << e.args[0]
      retry
    end
    args[0, 0] = extra_opts
  end
end

options = {}
no_ip_commands = ['version', 'global-status', '--help', '-h']

optparse = OptionParser.new do |opts|
  opts.banner    = "Usage: #{opts.program_name} [options]"
  opts.separator "Options"

  options[:reaper_addr] = nil
  opts.on( '-s', '--reaper-addr IP_ADDR', 'IP_ADDR of the reaper server' ) do |reaper_addr|
    # while parsing, trim an '=' prefix character off the front of the string if it exists
    # (would occur if the value was passed using an option flag like '-s=192.168.1.1')
    options[:reaper_addr] = reaper_addr.gsub(/^=/,'')
  end

  options[:reaper_path] = nil
  opts.on( '-p', '--path REAPER_PATH', 'Path where the distribution should be installed' ) do |reaper_path|
    # while parsing, trim an '=' prefix character off the front of the string if it exists
    # (would occur if the value was passed using an option flag like '-p=/opt/')
    options[:reaper_path] = reaper_path.gsub(/^=/,'')
  end

  options[:reaper_url] = nil
  opts.on( '-u', '--url REAPER_URL', 'URL the distribution should be downloaded from' ) do |reaper_url|
    # while parsing, trim an '=' prefix character off the front of the string if it exists
    # (would occur if the value was passed using an option flag like '-u=http://localhost/tmp.tgz')
    options[:reaper_url] = reaper_url.gsub(/^=/,'')
  end

  opts.on_tail( '-h', '--help', 'Display this screen' ) do
    print opts
    exit
  end

end

begin
  optparse.order_recognized!(ARGV)
rescue SystemExit
  exit
rescue Exception => e
  print "ERROR: could not parse command (#{e.message})\n"
  print optparse
  exit 1
end

# check remaining arguments to see if the command requires
# an IP address (or not)
ip_required = (ARGV & no_ip_commands).empty?

if ip_required && !options[:reaper_addr]
  print "ERROR; server IP address must be supplied for vagrant commands\n"
  print optparse
  exit 1
elsif options[:reaper_addr] && !(options[:reaper_addr] =~ Resolv::IPv4::Regex)
  print "ERROR; input server IP address '#{options[:reaper_addr]}' is not a valid IP address"
  exit 2
end

if options[:reaper_url] && !(options[:reaper_url] =~ URI::regexp)
  print "ERROR; input Solr URL '#{options[:reaper_url]}' is not a valid URL\n"
  exit 3
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
proxy = ENV['http_proxy'] || ""
no_proxy = ENV['no_proxy'] || ""
proxy_username = ENV['proxy_username'] || ""
proxy_password = ENV['proxy_password'] || ""
Vagrant.configure("2") do |config|
  if Vagrant.has_plugin?("vagrant-proxyconf")
    if $proxy
      config.proxy.http               = $proxy
      config.proxy.no_proxy           = "localhost,127.0.0.1"
      config.vm.box_download_insecure = true
      config.vm.box_check_update      = false
    end
    if $no_proxy
      config.proxy.no_proxy           = $no_proxy
    end
    if $proxy_username
      config.proxy.proxy_username     = $proxy_username
    end
    if $proxy_password
      config.proxy.proxy_password     = $proxy_password
    end
  end
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "centos/7"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  #config.vm.network "forwarded_port", guest: "#{options[:reaper_addr]}", host: "#{options[:reaper_addr]}"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "#{options[:reaper_addr]}"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder ".", "/vagrant"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "8192"
  end

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  config.vm.define "#{options[:reaper_addr]}"
  reaper_addr_array = "#{options[:reaper_addr]}".split(/,\w*/)

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "site.yml"
    ansible.extra_vars = {
      proxy_env: {
        http_proxy: proxy,
        no_proxy: no_proxy,
        proxy_username: proxy_username,
        proxy_password: proxy_password
      },
      host_inventory: reaper_addr_array
    }
    # if defined, set the 'extra_vars[:reaper_url]' value to the value that was passed in on
    # the command-line (eg. "https://10.0.2.2/apache-reaper-1.0.2.tar.gz.tar.gz")
    if options[:reaper_url]
      ansible.extra_vars[:reaper_url] = "#{options[:reaper_url]}"
    end
    # if defined, set the 'extra_vars[:reaper_url]' value to the value that was passed in on
    # the command-line (eg. "https://10.0.2.2/zookeeper-3.4.9.tar.gz")
    if options[:zookeeper_url]
      ansible.extra_vars[:zookeeper_url] = "#{options[:zookeeper_url]}"
    end
  end

end
