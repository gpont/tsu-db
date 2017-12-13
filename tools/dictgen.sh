#!/bin/bash

~/Applications/SQL*Port/sqlplus -s gpont@localhost << ! > sqlplus.dict
set head off pages 0 linesize 150 echo off feedback off verify off heading off
select object_name from all_objects where object_type in (
    'TABLE', 'VIEW', 'PACKAGE', 'PROCEDURE', 'FUNCTION'
);
!
