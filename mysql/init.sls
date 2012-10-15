python-mysqldb:
    pkg:
        - installed

/etc/mysql/my.cnf:
    file:
        - managed
        - source: salt://mysql/etc/mysql/my.cnf
        - template: jinja
        - mode: 644
        - require:
            - pkg: mysql-server-{{ pillar['mysql-version'] }}
        - defaults:
            mysql_replication: {{ pillar['mysql-replication'] }}
            mysql_host_ip: {{ pillar['mysql-bind-ip'] }}

mysql-server-{{ pillar['mysql-version'] }}:
  pkg:
    - installed
  service.running:
   - name: mysql
   - watch:
     - pkg: python-mysqldb
     - file: /etc/mysql/my.cnf

{%- for db in pillar['mysql-databases'] %}
{{ db.database }}_database:
  mysql_database.present:
    - name: {{ db.database }}
  mysql_user.present:
    - name: {{ db.user }}
    - host: '%'
    - password: "{{ db.password }}"
  mysql_grants.present:
    - database: {{ db.database }}.*
    - user: {{ db.user }}
    - host: '%'
    - grant: ALL PRIVILEGES
  require:
    - pkg: python-mysqldb
    - service: mysql
{{ db.database }}_database_unicode:
  module.run:
  - name: mysql.query
  - database: mysql
  - query: "ALTER DATABASE {{ db.database }} DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
{#
{{ db.database }}_database_create:
  module.run:
  - name: mysql.query
  - database: {{ db.database }}
  - query: "CREATE DATABASE IF NOT EXISTS {{ db.database }} DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
{{ db.database }}_database_grants:
  module.run:
  - name: mysql.query
  - database: {{ db.database }}
  - query: "GRANT ALL PRIVILEGES ON {{ db.database }}.* TO {{ db.user }} @'%' IDENTIFIED BY '{{ db.password }}';"
#}
{%- endfor %}

{%- if pillar['mysql-replication'] %}
/etc/mysql/conf.d/mysqld_replication.cnf:
    file:
        - managed
        - source: salt://mysql/etc/mysql/conf.d/mysqld_replication.cnf
        - template: jinja
        - mode: 644
        - require:
            - pkg: mysql-server-{{ pillar['mysql-version'] }}
        - defaults:
            mysql_replication_server_id: {{ pillar['mysql-replication-server-id'] }}
            mysql_replication_offset: {{ pillar['mysql-replication-offset'] }}
            mysql_replication_master_host: {{ pillar['mysql-replication-master']['host'] }}
            mysql_replication_master_user: {{ pillar['mysql-replication-master']['user'] }}
            mysql_replication_master_password: {{ pillar['mysql-replication-master']['password'] }}

replication_user_create:
  module.run:
  - name: mysql.query
  - database: mysql
  - query: "INSERT INTO user (Host, User, Password, Select_priv, Reload_priv, Super_priv, Repl_slave_priv) VALUES ('{{ pillar['mysql-replication-slave']['host'] }}', '{{ pillar['mysql-replication-slave']['user'] }}', password('{{ pillar['mysql-replication-slave']['password'] }}'), 'Y', 'Y', 'Y', 'Y'); FLUSH PRIVILEGES;"
{#
replication_refresh:
  module.run:
  - name: mysql.query
  - database: mysql
  - query: "stop slave; CHANGE MASTER TO MASTER_HOST='{{ pillar['mysql-replication-master']['host'] }}', MASTER_USER='{{ pillar['mysql-replication-master']['user'] }}', MASTER_PASSWORD='{{ pillar['mysql-replication-master']['password'] }}'; start slave;"
#}
{%- endif %}
