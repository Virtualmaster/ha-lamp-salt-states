lsyncd:
  pkg:
    - installed
  service.running:
   - name: lsyncd

/etc/lsyncd.conf:
    file:
        - managed
        - source: salt://lsync/etc/lsyncd.conf
        - template: jinja
        - mode: 644
        - require:
            - pkg: lsyncd
        - defaults:
            sync_folders:
              {%- if pillar['lsync-syncs'] %}
              {%- for sync in pillar['lsync-syncs'] %}
              - engine: {{ sync.engine }}
                source_folder: {{ sync.source_folder }}
                target_folder: {{ sync.target_folder }}
                target_host: {{ sync.target_host }}
              {%- endfor %}
              {%- endif %}
