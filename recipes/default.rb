#
# Cookbook Name:: elasticsearch
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory "#{node['es']['root_src_work']}" do
    owner "root"
    action :create
    not_if "ls #{node['es']['root_src_work']}"
end

execute "wget_es" do
    user "root"
    cwd "#{node['es']['root_src_work']}"
    command "wget https://download.elasticsearch.org/elasticsearch/elasticsearch/#{node['es']['rpm_name']}"
    not_if "ls #{node['es']['root_src_work']}/#{node['es']['rpm_name']}"
    notifies :run, "execute[install_es]"
end

# expand "ulimits -n" using "limits_expand" recipe, need to append "metadeta.rb" too
#include_recipe "limits_expand"

execute "es_chkconfig_on" do
    command "chkconfig elasticsearch on"
    action :nothing
end

execute "install_es" do
    user "root"
    cwd "#{node['es']['root_src_work']}"
    command "rpm -ivh #{node['es']['rpm_name']}"
    not_if "ls #{node['es']['service_script']}"
    notifies :run, "execute[es_chkconfig_on]"
end

node['es']['plugin_repo_and_info'].each do |repo, info|
    execute "install_plugin_#{repo}" do
        user "root"
        command "#{node['es']['prefix']}/bin/plugin -install #{repo} #{info['opt']}"
        not_if "ls #{node['es']['prefix']}/plugins/#{info['name']}"
    end
end

service "elasticsearch" do
    action :restart
end

# modified iptables
service "iptables" do
    supports :restart => true, :status => true
    action :nothing
end

node['es']['tcp_accept_port_and_ips'].each do |port, ip_list|
    ip_list.each do |ip|
        execute "add_accept_rule_#{ip}_#{port}" do
            user "root"
            command "iptables -t filter -I INPUT -p tcp -s #{ip} --dport #{port} -j ACCEPT"
            not_if "grep #{ip} #{node['es']['iptables_rule_file']} | grep #{port}"
        end
    end
end

execute "save_iptables" do
    user "root"
    command "#{node['es']['iptables_script']} save"
    notifies :restart, "service[iptables]", :immediately
end

