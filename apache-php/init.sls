apache2:
  pkg:
    - installed
  service.running:
   - name: apache2

apache2-php-packages:
    pkg:
        - installed
        - names:
            - libapache2-mod-php5

a2enmod rewrite:
    cmd:
        - run
        - require:
            - service: apache2

{%- if pillar['apache-php-hosts'] %}
{%- for host in pillar['apache-php-hosts'] %}
/etc/apache2/sites-enabled/{{ host['config-name'] }}:
    file:
        - managed
        - source: salt://apache-php/etc/apache2/sites/{{ host['app-env'] }}.vhost
        - template: jinja
        - mode: 644
        - require:
            - pkg: apache2
        - defaults:
            config_name: "{{ host['config-name'] }}"
            app_name: "{{ host['app-name'] }}"
            app_env: "{{ host['app-env'] }}"
            host_name: "{{ host['host-name'] }}"
            {%- if host['host-alias'] %}
            host_alias: "{{ host['host-alias']|join(' ') }}"
            {%- endif %}
{%- endfor %}
{%- endif %}