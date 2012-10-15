openssh-server:
  pkg:
    - installed
  service.running:
   - name: ssh

{%- if pillar['ssh-root-keys'] %}
ssh_root_keys:
  ssh_auth:
    - present
    - user: root
    - names:
      {%- for key in pillar['ssh-root-keys'] %}
      - {{ key.key }}
      {%- endfor %}
{%- endif %}
