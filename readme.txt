nagios add service config:
define service{
        use                             generic-service   ;service template
        host_name                       mysql10.4.16.133
        service_description             online_setget
        max_check_attempts              2
        normal_check_interval           5  ;minute
        retry_check_interval            1
        servicegroups                   SQL CHECK
        contact_groups                  mysqladmin
        check_command                   check_mysql_replication!10.4.16.133:3306,10.4.16.134:3307
        }
nagios add commond config:
define command{
        command_name check_mysql_replication
        command_line $USER1$/check_mysql_repl.pl $ARG1$ $ARG2$
        }

master mysql need create database...
dbname="mid_repl";
user="repl_monitor";
pass="monitor_mysql";
table="replication_test";
