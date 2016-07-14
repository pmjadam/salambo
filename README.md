# salambo
Salambo is an smb client for plsql. It allows to manage files through shared folders directly in plsql thanks to the SMB / CIFS protocol.

The following features are implemented in the smb package:
+ Basic APIs: create, drop, read, write, move, copy files ; list, create, drop a directory.
+ Advanced APIs: list the network neighborhood of a host, list the shares, get security properties of a file, etc.
+ utl_file compatibility: all API used with local files thanks to utl_file can now be used on the same way with network shared smb files thanks to the smb package.

Requirements: Oracle 10g or above.

[Web site](http://pmjadam.free.fr//salambo/index.html)
