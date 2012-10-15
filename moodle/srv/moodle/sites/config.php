<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = '{%- if database_engine == "mysql" %}mysqli{%- endif %}{%- if database_engine == "pgsql" %}pgsql{%- endif %}';
$CFG->dblibrary = 'native';
$CFG->dbhost    = '{{ database_host }}';
$CFG->dbname    = '{{ database_name }}';
$CFG->dbuser    = '{{ database_user }}';
$CFG->dbpass    = '{{ database_password }}';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbsocket' => '',
);

$CFG->wwwroot   = 'http://{{ vhost_name }}';
$CFG->dataroot  = '{{ filesystem_root }}';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

$CFG->passwordsaltmain = '0:%ZPidr)CNfX(R.EVRcS4~Q/CbP';

require_once(dirname(__FILE__) . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!