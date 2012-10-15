/etc/salt/minion:
    file:
        - managed
        - source: salt://salt-minion/etc/salt/minion
        - user: root
        - group: root
        - template: jinja
        - defaults:
            salt_master: {{ pillar['salt-master'] }}
