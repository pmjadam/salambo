#Quick Start. Creating a text file.

# Quick Start #
First step: connect to the oracle schema where you want to use Salambo and "play" the SMB.sql package.
```
[oracle@ora01 ~]$ sqlplus scott/tiger @SMB.sql

SQL*Plus: Release 11.2.0.1.0 Production on Sat Oct 20 13:04:16 2012

Copyright (c) 1982, 2009, Oracle. All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options


Package created.


Package body created.

SQL>
```
Second step: connect as sysdba to the sys schema, and grantes network access to the schema. This step is not useful with 10g database.
```
SQL> connect / as sysdba
Connected.
SQL> exec scott.smb.grant_network_access('SCOTT');

PL/SQL procedure successfully completed.

SQL>
```
Third step: uses Salambo to create a hello.txt file into an smb share directory.
```
SQL> connect scott/tiger
Connected.
SQL> set serveroutput on
SQL> DECLARE
  2      vUrl VARCHAR2(255):='smb://ADAM;pierre:mirabelle@192.168.0.10/share01/hello.txt';
  3      vErr SMB.ERRSTR;
  4  BEGIN
  5      SMB.WRITE_FILE(vUrl, SMB.ENCODE_TEXT('hello world!', NULL, NULL, NULL, vErr), vErr);
  6      DBMS_OUTPUT.PUT_LINE('WRITE_FILE=>' || vErr);
  7  END;
  8  /
WRITE_FILE=>

PL/SQL procedure successfully completed.

SQL>
```
Use this syntax to access a file:

smb://domain;login:password@host[:port]/share[/folder[/subfolder]/file]

default port is 445 (you can also try 139)

And finally, a file should have been created...

If something go wrong, probably the URL is not correct:

  * Unreachable Host: host is wrong, or down, or a firewall block the port...
  * Access denied. (STATUS\_LOGON\_FAILURE): the login or the passwword is wrong
  * Invalid server name in Tree Connect. (STATUS\_BAD\_NETWORK\_NAME): the share folder is wrong

Documentation can be found here http://pmjadam.free.fr/salambo/doc.html