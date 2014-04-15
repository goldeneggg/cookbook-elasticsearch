default['es']['root_src_work'] = "/root/src"
default['es']['version'] = "0.90.7"
default['es']['rpm_name'] = "elasticsearch-#{default['es']['version']}.noarch.rpm"
default['es']['plugin_repo_and_info'] = {
    'mobz/elasticsearch-head' => {
        'name' => 'head',
        'opt' => ''
    },
    'knapsack' => {
        'name' => 'knapsack',
        'opt' => '--url http://bit.ly/17cn710'
    }
}
default['es']['prefix'] = '/usr/share/elasticsearch'
default['es']['service_script'] = "/etc/init.d/elasticsearch"
default['es']['tcp_accept_port_and_ips'] = {
    '9200' => ['192.168.56.0/24']
}
default['es']['iptables_script'] = "/etc/init.d/iptables"
default['es']['iptables_rule_file'] = "/etc/sysconfig/iptables"
