/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE SMB
AUTHID CURRENT_USER
IS
/*<DOC part="SMB (BASIC APIs)">*/

/** 
 *  SMB is a package for accessing files in MS environment
 *  via the CIFS / SMB protocol...
 *  @headcom
 *  @author <A HREF="mailto:pierre@pierre-adam.com">Pierre ADAM</A> 
 */

SUBTYPE ERRSTR IS VARCHAR2(500);
    
TYPE FILE_INFO_T IS RECORD(
    vFileName VARCHAR2(4000),
    vShortFileName VARCHAR2(12),
    bDirectory BOOLEAN,
    nExtFileAttributes NUMBER,
    dCreationTime DATE,
    dLastAccessTime DATE, 
    dLastWriteTime DATE,
    dLastChangeTime DATE,
    nSize NUMBER,
    nAllocationSize NUMBER
    ); 
    
TYPE FILE_INFO_C IS TABLE OF FILE_INFO_T INDEX BY PLS_INTEGER;     

/** Read a file and store its content into a blob
 *  @param  i_vFileLocation  Location of the file to read. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_bContent       If o_vError is null, will take the binary contents of the file
 *  @param  o_vError         Null if the file has been actually read, or a textual error message. 
 */
PROCEDURE READ_FILE(i_vFileLocation IN VARCHAR2,
                    o_bContent OUT BLOB,
                    o_vError OUT ERRSTR);
    
/** Create a File and fill its content with a blob
 *  @param  i_vFileLocation  Location of the file to write. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_bContent       Contents to store on the file
 *  @param  o_vError         Null if the file has been actually written, or a textual error message. 
 */  
PROCEDURE WRITE_FILE(i_vFileLocation IN VARCHAR2,
                     i_bContent IN BLOB,
                     o_vError OUT ERRSTR);

/** Get the list of files and subfolders from a folder
 *  @param  i_vFolderLocation Location of the folder to list. Format: "smb://domain;login:password@host[:port]/share"
 *  @param  o_vError Error
 */
FUNCTION DIR(i_vFolderLocation IN VARCHAR2,
             o_vError OUT ERRSTR) RETURN FILE_INFO_C;   
             
/** Check existence of a directory
 *  @param  i_vFolderLocation Location of the folder to check. Format: "smb://domain;login:password@host[:port]/share"
 *  @param  o_vError : NULL if the directory exists. 
 */
PROCEDURE CHECK_DIR(i_vFolderLocation IN VARCHAR2,
                    o_vError OUT ERRSTR);              
                    
/**  Create a directory
 *  @param  i_vFolderLocation Location of the folder to create. Format: "smb://domain;login:password@host[:port]/share"
 *  @param  o_vError Error
 */                    
PROCEDURE MKDIR(i_vFolderLocation IN VARCHAR2,
                o_vError OUT ERRSTR);  
                
/** Remove a directory
 *  @param  i_vFolderLocation Location of the folder to remove. Format: "smb://domain;login:password@host[:port]/share"
 *  @param  i_bContent if the folder is not empty, will erase its content
 *  @param  o_vError Error
 */                    
PROCEDURE RMDIR(i_vFolderLocation IN VARCHAR2,
                i_bContent IN BOOLEAN:=FALSE,
                o_vError OUT ERRSTR);  
              
/** Rename a file or a directory on a same share
 *  @param  i_vSourceFileLocation Location of the source file (before renaming). Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  i_vDestFileLocation Location of the destination file (after renaming). Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_vError Error
 */
PROCEDURE RENAME_FILE(i_vSourceFileLocation IN VARCHAR2,
                      i_vDestFileLocation IN VARCHAR2, 
                      o_vError OUT ERRSTR);  
                      
/** Make a link to a file or a directory 
 *  @param  i_vSourceFileLocation Location of the source file. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  i_vDestFileLocation Location of the destination file. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_vError Error
 */    
PROCEDURE MKLINK(i_vSourceFileLocation IN VARCHAR2,
                 i_vDestFileLocation IN VARCHAR2,  
                 o_vError OUT ERRSTR);  
  
/** Delete a file
 *  @param  i_vFileLocation  Location of the file to delete. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  i_nLevel Delete the File even if it is : 1 = readonly ; 2 = hidden ; 4 = system (cumulative)
 *  @param  o_vError error
 */                    
PROCEDURE DELETE_FILE(i_vFileLocation IN VARCHAR2,
                      i_nLevel IN PLS_INTEGER:=0, 
                      o_vError OUT ERRSTR);  
                      
/** Copy File
 *  @param  i_vSourceFileLocation Location of the source file (file to copy). Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  i_vDestFileLocation Location of the destination file (after copying). Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_vError error  
 */
PROCEDURE COPY_FILE(i_vSourceFileLocation IN VARCHAR2,
                    i_vDestFileLocation IN VARCHAR2, 
                    o_vError OUT ERRSTR);

/*</DOC>*/
/*<DOC part="SMB (Info APIs)"> --------------------------------------------------------------------------------------------------------------------------------*/

/** 
 *  SMB is a package for accessing files in MS environment
 *  via the CIFS / SMB protocol...
 *  @headcom
 *  @author <A HREF="mailto:pierre@pierre-adam.com">Pierre ADAM</A> 
 */

    
TYPE FILESYSTEM_INFO_T IS RECORD(
    nSerialNumber NUMBER,
    vVolumeLabel VARCHAR2(255),
    dVolumeCreationTime DATE,
    nTotalSpaceInBytes NUMBER,
    nTotalFreeSpaceInBytes NUMBER,
    nDeviceType NUMBER,
    nDeviceCharacteristics NUMBER,
    nFileSystemAttributes NUMBER,
    nMaxFileNameLengthInBytes NUMBER,
    vFileSystemName VARCHAR2(255)
    );    
/** Get Filesystem information
 *  @param  i_vShareLocation Location of a share on the filesystem. Format : "domain;login:password@host/share"
 *  @param  i_xCredential credential
 *  @param  o_vError error
 *  @return filesystem information
 */    
FUNCTION GET_FILESYSTEM_INFO(i_vShareLocation IN VARCHAR2,
                             o_vError OUT ERRSTR) RETURN FILESYSTEM_INFO_T;          
                             
/** Get File Information
 *  @param  i_vFileLocation  Location of the file to get info. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_vError error
 *  @return File_Info_T
 */                             
FUNCTION GET_FILE_INFO(i_vFileLocation IN VARCHAR2,
                       o_vError OUT ERRSTR) RETURN FILE_INFO_T;
               
/** Get file attributes
 *  @param  i_vFileLocation  Location of the file to get attributes. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_bReadOnly Read only file
 *  @param  o_bArchive Archived file
 *  @param  o_bSystem System file
 *  @param  o_bHidden Hidden file
 *  @param  o_bDoNotIndexContent Indexed file without content
 *  @param  o_vError error
 */        
PROCEDURE GET_ATTRIB(i_vFileLocation IN VARCHAR2,
                     o_bReadOnly OUT BOOLEAN,
                     o_bArchive OUT BOOLEAN,
                     o_bSystem OUT BOOLEAN,
                     o_bHidden OUT BOOLEAN,
                     o_bDoNotIndexContent OUT BOOLEAN,
                     o_vError OUT ERRSTR);
                       
/** Set File information
 *  @param  i_vFileLocation  Location of the file to set info. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param i_xFileInfo file info structure
 *  @param o_vError error
 */                    
PROCEDURE SET_FILE_INFO(i_vFileLocation IN VARCHAR2,
                        i_xFileInfo IN FILE_INFO_T, 
                        o_vError OUT ERRSTR);       
                        
/** Set file attributes
 *  @param  i_vFileLocation  Location of the file to set attributes. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  i_bReadOnly Read only file (0 = Unset ; 1 = Set ; NULL = no change)
 *  @param  i_bArchive Archived file (0 = Unset ; 1 = Set ; NULL = no change)
 *  @param  i_bSystem System file (0 = Unset ; 1 = Set ; NULL = no change)
 *  @param  i_bHidden Hidden file (0 = Unset ; 1 = Set ; NULL = no change)
 *  @param  i_bDoNotIndexContent File or directory should not be indexed by a content indexing service. (0 = Unset ; 1 = Set ; NULL = no change)
 *  @param  o_vError error
 */                             
PROCEDURE SET_ATTRIB(i_vFileLocation IN VARCHAR2,
                     i_bReadOnly IN BOOLEAN,
                     i_bArchive IN BOOLEAN,
                     i_bSystem IN BOOLEAN,
                     i_bHidden IN BOOLEAN,
                     i_bDoNotIndexContent IN BOOLEAN,
                     o_vError OUT ERRSTR);                                       
                       
/** Get the SID of the owner of the file
 *  @param  i_vFileLocation  Location of the file. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_vError
 *  @return the SID
 */                           
FUNCTION GET_FILE_OWNER_SID(i_vFileLocation IN VARCHAR2,
                            o_vError OUT ERRSTR) RETURN VARCHAR2;
                            
/** Get the group SID of the file
 *  @param  i_vFileLocation  Location of the file. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_vError
 *  @return the SID
 */                              
FUNCTION GET_FILE_GROUP_SID(i_vFileLocation IN VARCHAR2,
                            o_vError OUT ERRSTR) RETURN VARCHAR2;
                            
/** Get security info for a file
 *  @param  i_vFileLocation  Location of the file. Format: "smb://domain;login:password@host[:port]/share/file"
 *  @param  o_vError
 *  @return a Security_Descriptor structure (XML). 
 */
FUNCTION GET_FILE_SEC_INFO(i_vFileLocation IN VARCHAR2,
                            o_vError OUT ERRSTR) RETURN XMLTYPE;
                        
/** host record
 *  @param  vHostName Name of the host
 *  @param  nMajorVersion OS Major Version
 *  @param  nMinorVersion OS Minor Version
 *  @param  nServerType
 *  @param  vServerComment Server Comment
 */
TYPE HOST_INFO_T IS RECORD(
    vHostName VARCHAR2(255),
    nMajorVersion PLS_INTEGER,
    nMinorVersion PLS_INTEGER,
    nServerType NUMBER,
    vServerComment VARCHAR2(4000),
    vUserName VARCHAR2(255),
    vLanGroup VARCHAR2(255),
    vLogonDomain VARCHAR2(255),
    vOtherDomain VARCHAR2(255),
    nTimeSinceBoot NUMBER,
    tSystemTimestamp TIMESTAMP WITH TIME ZONE
    );
/** Collection of Server Type */    
TYPE HOST_INFO_C IS TABLE OF HOST_INFO_T INDEX BY PLS_INTEGER;  

/** Connected to one of the host, retrieve the list of all connected hosts (network neighbourhood).
 *  @param  i_vServerLocation Location of the server. Format: "smb://domain;login:password@host[:port]"
 *  @param  i_vDomain Specify the domain. All domains if set null. 
 *  @param  o_vError Null if everything is ok, or a textual error message. 
 *  @return the list of server as a HOST_INFO_C collection.  
 */                        
FUNCTION GET_HOST_LIST(i_vServerLocation IN VARCHAR2, 
                       i_vDomain IN VARCHAR2:=NULL, 
                       o_vError OUT ERRSTR) RETURN HOST_INFO_C;
                         
/** Get server info
 *  @param  i_vServerLocation Location of the server. Format: "smb://domain;login:password@host[:port]"
 *  @param  o_vError error
 *  @return HOST_INFO_T structure
 */                         
FUNCTION GET_HOST_INFO(i_vServerLocation IN VARCHAR2, 
                       o_vError OUT ERRSTR) RETURN HOST_INFO_T;                         

TYPE SHARE_INFO_T IS RECORD(
    vShareName VARCHAR2(255),
    nType PLS_INTEGER,
    nCurrentUses PLS_INTEGER,
    nMaxUses PLS_INTEGER,
    vPassword VARCHAR2(255),
    vRemark VARCHAR2(1000),
    vPath VARCHAR2(255)
    );
    
TYPE SHARE_INFO_C IS TABLE OF SHARE_INFO_T INDEX BY PLS_INTEGER;

/** List the shares
 *  @param  i_vServerLocation Location of the server. Format: "smb://domain;login:password@host[:port]"
 *  @param  o_vError error
 *  @return SHARE_INFO_C structure
 */
FUNCTION GET_SHARE_LIST(i_vServerLocation IN VARCHAR2, 
                        o_vError OUT ERRSTR) RETURN SHARE_INFO_C;
   
TYPE USER_INFO_T IS RECORD(
    vUserName VARCHAR2(255),
    vPassword VARCHAR2(255),
    nPasswordAge NUMBER,
    vHomeDir VARCHAR2(1000),
    vComment VARCHAR2(1000),
    nFlags PLS_INTEGER,
    vScriptPath VARCHAR2(1000),
    vLogonServer VARCHAR2(1000),
    nAuthFlags NUMBER,
    vFullName VARCHAR2(1000),
    vUsrComment VARCHAR2(1000),
    vParms VARCHAR2(100),
    vWorkStations VARCHAR2(1000),
    dLastLogon DATE,
    dLastLogOff DATE,
    dAcctExpires DATE,
    nMaxStorage NUMBER,
    nUnitsPerWeek PLS_INTEGER,
    vLogonHours VARCHAR2(200),
    nBadPwCount PLS_INTEGER,
    nNumLogons PLS_INTEGER,
    nCountryCode PLS_INTEGER,
    nCodePage PLS_INTEGER,
    nPriv PLS_INTEGER
    );                    
/** Get User Information. 
 *  @param  i_vServerLocation Location of the server. Format: "smb://domain;login:password@host[:port]"
 *  @param i_vUserName user name
 *  @param o_vError error
 *  @return USER_INFO_T structure
 */
FUNCTION GET_USER_INFO(i_vServerLocation IN VARCHAR2, 
                       i_vUserName IN VARCHAR2, 
                       o_vError OUT ERRSTR) RETURN USER_INFO_T;
  
/*</DOC>*/
/*<DOC part="SMB (HOT Folder)"> --------------------------------------------------------------------------------------------------------------------------------*/

 /** 
 *  SMB is a package for accessing files in MS environment
 *  via the CIFS / SMB protocol...
 *  @headcom
 *  @author <A HREF="mailto:pierre@pierre-adam.com">Pierre ADAM</A> 
 */

TYPE HOT_FOLDER_C IS TABLE OF VARCHAR2(255) INDEX BY PLS_INTEGER;

/** Return the list of hot folder
 *  @param  i_vFolderLocationFilter filter for the hot folder location. Default '%' means no filter.
 *  @return the list of hot folder
 */
FUNCTION GET_HOT_FOLDER_LIST(i_vFolderLocationFilter IN VARCHAR2:='%') RETURN HOT_FOLDER_C;

/** Create a new hot folder
 *  @param  i_vFolderLocation Location for the new hot folder. Format: "smb://domain;login:password@host[:port]/share[/folder]
 *  @param  i_vCallBackProc name of the procedure that will be called when a file is here. It must have the following signature:
 *                          i_vCallBackProc(i_vFileName IN VARCHAR2, o_bOK OUT BOOLEAN);
 *  @param  o_vError NULL if OK. 
 */
PROCEDURE CREATE_HOT_FOLDER(i_vFolderLocation IN VARCHAR2, 
                            i_vCallbackProc IN VARCHAR2, 
                            o_vError OUT ERRSTR);
                            
/** Drop a hot folder
 *  @param  i_vFolderLocation Location of the hot folder to drop. Format: "smb://domain;login:password@host[:port]/share[/folder]
 *  @param  o_vError NULL if OK. 
 */                            
PROCEDURE DROP_HOT_FOLDER(i_vFolderLocation IN VARCHAR2, 
                            o_vError OUT ERRSTR);                            
         
/** internal use. This procedure is called through a job with CREATE_HOT_FOLDER. 
 *  @param  i_vFolderLocation Location of the folder to create. Format: "smb://domain;login:password@host[:port]/share"
 *  @param  i_vCallBackProc name of the procedure that will be called when a file is here. It must have the following signature:
 *                          i_vCallBackProc(i_vFileName IN VARCHAR2, o_bOK OUT BOOLEAN);
 *  @param  o_vError error
 */
PROCEDURE HOT_FOLDER(i_vFolderLocation IN VARCHAR2,
                     i_vCallbackProc IN VARCHAR2, 
                     o_vError OUT ERRSTR);
    
/*</DOC>*/
/*<DOC part="SMB (UTL_FILE compatibility)"> --------------------------------------------------------------------------------------------------------------------------------*/

/** 
 *  SMB is a package for accessing files in MS environment
 *  via the CIFS / SMB protocol...
 *  @headcom
 *  @author <A HREF="mailto:pierre@pierre-adam.com">Pierre ADAM</A> 
 */

/** File handle record
 *  @param  id Identifier of File Handle. 
 *  @param  datatype 1 for CHAR ; 2 for NCHAR. 
 *  @param  byte_mode True when open with 'rb', 'wb', 'ab'
 *  @param  use_smb False if UTL_FILE is used ; True if SMB is used. 
 */    
TYPE file_type IS RECORD(
    id BINARY_INTEGER,
    datatype BINARY_INTEGER,
    byte_mode BOOLEAN,
    use_smb BOOLEAN
    );

charsetmismatch      EXCEPTION; PRAGMA EXCEPTION_INIT(charsetmismatch,     -29298);
invalid_path         EXCEPTION; PRAGMA EXCEPTION_INIT(invalid_path,        -29280);
invalid_mode         EXCEPTION; PRAGMA EXCEPTION_INIT(invalid_mode,        -29281);
invalid_filehandle   EXCEPTION; PRAGMA EXCEPTION_INIT(invalid_filehandle,  -29282);
invalid_operation    EXCEPTION; PRAGMA EXCEPTION_INIT(invalid_operation,   -29283);
read_error           EXCEPTION; PRAGMA EXCEPTION_INIT(read_error,          -29284);
write_error          EXCEPTION; PRAGMA EXCEPTION_INIT(write_error,         -29285);
internal_error       EXCEPTION; PRAGMA EXCEPTION_INIT(internal_error,      -29286);
invalid_maxlinesize  EXCEPTION; PRAGMA EXCEPTION_INIT(invalid_maxlinesize, -29287);
invalid_filename     EXCEPTION; PRAGMA EXCEPTION_INIT(invalid_filename,    -29288);
access_denied        EXCEPTION; PRAGMA EXCEPTION_INIT(access_denied,       -29289);
invalid_offset       EXCEPTION; PRAGMA EXCEPTION_INIT(invalid_offset,      -29290);
delete_failed        EXCEPTION; PRAGMA EXCEPTION_INIT(delete_failed,       -29291);
rename_failed        EXCEPTION; PRAGMA EXCEPTION_INIT(rename_failed,       -29292);
  
/** open file
 *  @param  location directory location of file
 *  @param  filename file name (including extention)
 *  @param  open_mode open mode ('r', 'w', 'a' 'rb', 'wb', 'ab')
 *  @param  max_linesize maximum number of characters per line, including the newline character, for this file.
 *  @return file_type handle to open file     
 *  @Throws invalid_path file location or name was invalid
 *  @Throws invalid_mode the open_mode string was invalid
 *  @Throws invalid_operation file could not be opened as requested
 *  @Throws invalid_maxlinesize specified max_linesize is too large or too small
 *  @Throws access_denied access to the directory object is denied
 */
FUNCTION fopen(location     IN VARCHAR2,
               filename     IN VARCHAR2,
               open_mode    IN VARCHAR2,
               max_linesize IN BINARY_INTEGER DEFAULT NULL) RETURN file_type;

/** open UTF8 text file using nvarchar2
 *  @param  location directory location of file
 *  @param  filename file name (including extention)
 *  @param  open_mode open mode ('r', 'w', 'a' 'rb', 'wb', 'ab')
 *  @param  max_linesize maximum number of characters per line, including the newline character, for this file.
 *  @return file_type handle to open file                     
 */
FUNCTION fopen_nchar(location     IN VARCHAR2,
                     filename     IN VARCHAR2,
                     open_mode    IN VARCHAR2,
                     max_linesize IN BINARY_INTEGER DEFAULT NULL) RETURN file_type;

/** Test if file handle is open
 *  @param file File handle
 *  @return True if file handle is open and valid
 */
FUNCTION is_open(file IN file_type) RETURN BOOLEAN;

/** Close an open file
 *  @param  file Open file handle
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws write_error OS error occured during write operation
 */  
PROCEDURE fclose(file IN OUT file_type);

/** Close every open files for this session
 *  @Throws write_error OS error occured during write operation
 */  
PROCEDURE fclose_all;
  
/** Get (read) a line of text from the file
 *  @param  file file handle (open in read mode)
 *  @param  len input buffer length, default is null, max is 32767
 *  @param  buffer next line of text in file
 *  @Throws no_data_found reached the end of file
 *  @Throws value_error line to long to store in buffer
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for reading, file is open for byte mode access
 *  @Throws read_error OS error occurred during read
 *  @Throws charsetmismatch if the file is open for nchar data
 */
PROCEDURE get_line(file   IN file_type,
                   buffer OUT VARCHAR2,
                   len    IN BINARY_INTEGER DEFAULT NULL);

/** Get (read) a line of nchar data from the file. 
 *  @param  file file handle (open in read mode)
 *  @param  len input buffer length, default is null, max is 32767
 *  @param  buffer next line of text in file
 *  @Throws no_data_found reached the end of file
 *  @Throws value_error line to long to store in buffer
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for reading, file is open for byte mode access
 *  @Throws read_error OS error occurred during read
 *  @Throws charsetmismatch if the file is open for char data
 */
PROCEDURE get_line_nchar(file   IN  file_type,
                         buffer OUT NVARCHAR2,
                         len    IN  BINARY_INTEGER DEFAULT NULL);

/** Put (write) text to file. 
 *  @param  file File handle (open in write/append mode)
 *  @param  buffer Text to write
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending ; file is open for byte mode access
 *  @Throws write_error OS error occured during write operation
 *  @Throws charsetmismatch if the file is open for nchar data.
 */
PROCEDURE put(file   IN file_type,
              buffer IN VARCHAR2);

/** Put (write) nchar data to file. 
 *  @param  file File handle (open in write/append mode)
 *  @param  buffer UTF8 text to write
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending ; file is open for byte mode access
 *  @Throws write_error OS error occured during write operation
 *  @Throws charsetmismatch if the file is open for char data.
 */

PROCEDURE put_nchar(file   IN file_type,
                    buffer IN NVARCHAR2);

/** Write line terminators to file
 *  @param  file File handle (open in write/append mode)
 *  @param  lines Number of newlines to write (default 1)
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending ; file is open for byte mode access
 *  @Throws write_error OS error occured during write operation
 */  
PROCEDURE new_line(file  IN file_type,
                   lines IN NATURAL := 1);

/** Put (write) line to file
 *  @param  file File handle (open in write/append mode)
 *  @param  buffer Text to write
 *  @param  autoflush flush following write, default=no flush   
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation  file is not open for writing/appending ; file is open for byte mode access
 *  @Throws write_error OS error occured during write operation
 *  @Throws charsetmismatch if the file is open for nchar data.
 */    
PROCEDURE put_line(file   IN file_type,
                   buffer IN VARCHAR2,
                   autoflush IN BOOLEAN DEFAULT FALSE);

/** Put (write) line of nchar to file
 *  @param  file File handle (open in write/append mode)
 *  @param  buffer UTF8 Text to write
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation  file is not open for writing/appending ; file is open for byte mode access
 *  @Throws write_error OS error occured during write operation
 *  @Throws charsetmismatch if the file is open for char data.
 */    
PROCEDURE put_line_nchar(file   IN file_type,
                         buffer IN NVARCHAR2);

/** Put (write) formatted text to file.  
 *  Format string special characters: %s - substitute with next argument ; \n - newline
 *  @param  file_type File handle (open in write/append mode)
 *  @param  format Formatting string
 *  @param  arg1 Substitution argument #1
 *  @param  arg2 Substitution argument #2
 *  @param  arg3 Substitution argument #3
 *  @param  arg4 Substitution argument #4
 *  @param  arg5 Substitution argument #5
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending, file is open for byte mode access
 *  @Throws write_error OS error occured during write operation
 *  @Throws charsetmismatch if the file is open for nchar data.
 */
procedure putf(file   IN file_type,
               format IN VARCHAR2,
               arg1   IN VARCHAR2 DEFAULT NULL,
               arg2   IN VARCHAR2 DEFAULT NULL,
               arg3   IN VARCHAR2 DEFAULT NULL,
               arg4   IN VARCHAR2 DEFAULT NULL,
               arg5   IN VARCHAR2 DEFAULT NULL);

/** Put (write) formatted UTF8 text to file.  
 *  Format string special characters: %s - substitute with next argument ; \n - newline
 *  @param  file_type File handle (open in write/append mode)
 *  @param  format Formatting string
 *  @param  arg1 Substitution argument #1
 *  @param  arg2 Substitution argument #2
 *  @param  arg3 Substitution argument #3
 *  @param  arg4 Substitution argument #4
 *  @param  arg5 Substitution argument #5
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending, file is open for byte mode access
 *  @Throws write_error OS error occured during write operation
 *  @Throws charsetmismatch if the file is open for char data.
 */
procedure putf_nchar(file   IN file_type,
                     format IN NVARCHAR2,
                     arg1   IN NVARCHAR2 DEFAULT NULL,
                     arg2   IN NVARCHAR2 DEFAULT NULL,
                     arg3   IN NVARCHAR2 DEFAULT NULL,
                     arg4   IN NVARCHAR2 DEFAULT NULL,
                     arg5   IN NVARCHAR2 DEFAULT NULL);

/** Force physical write of buffered output
 *  @param file File handle (open in write/append mode)
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending
 *  @Throws write_error OS error occured during write operation
 */
PROCEDURE fflush(file IN file_type);

/** Write a raw value to file.
 *  @param file File handle (open in write/append mode)
 *  @param buffer Raw data
 *  @param autoflush Flush following write, default=no flush
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending
 *  @Throws write_error OS error occured during write operation
 */  
PROCEDURE put_raw(file      IN file_type,
                  buffer    IN RAW,
                  autoflush IN BOOLEAN DEFAULT FALSE);

/** Read a raw value from file.
 *  @param file File handle (open in write/append mode)
 *  @param buffer Raw data
 *  @param len Number of bytes to be read
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending
 *  @Throws read_error OS error occured during read operation
 */  
PROCEDURE get_raw(file   IN  file_type,
                  buffer OUT NOCOPY RAW,
                  len    IN  BINARY_INTEGER DEFAULT NULL);

/** Move the file pointer to a specified position within the file.
 *  @param file File handle (open in read mode)
 *  @param absolute_offset Absolute offset to which to seek.
 *  @param relative_offset Relative offset, forward or backwards, to which to seek. 
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_offset file is not open for writing/appending
 *  @Throws invalid_operation file is opened for byte mode access
 */  
PROCEDURE fseek(file            IN OUT file_type,
                absolute_offset IN     BINARY_INTEGER DEFAULT NULL,
                relative_offset IN     BINARY_INTEGER DEFAULT NULL);

/** Delete the specified file from disk.
 *  @param  location directory location of file
 *  @param  filename file name (including extention)
 *  @Throws invalid_path not a valid file handle
 *  @Throws invalid_filename file not found or file name NULL
 *  @Throws access_denied access to the directory object is denied
 *  @Throws remove_failed failed to delete file
 */  
PROCEDURE fremove(location IN VARCHAR2,
                  filename IN VARCHAR2);
                  
/** copy all or part of a file to a new file.
 *  @param  src_location source directory of file
 *  @param  src_filename source file name (including extention)
 *  @param  dest_location destination directory of file
 *  @param  dest_filename destination file name (including extention)
 *  @param  start_line line number from which to begin copying, default is 1 referring to the first line in the file
 *  @param  end_line line number from which to end copying, default is NULL referring to end-of-file
 *  @Throws invalid_path not a valid file handle
 *  @Throws invalid_filename file not found or file name is NULL
 *  @Throws invalid_lineno bad start_line or end_line value
 */    
PROCEDURE fcopy(src_location  IN VARCHAR2,
                src_filename  IN VARCHAR2,
                dest_location IN VARCHAR2,
                dest_filename IN VARCHAR2,
                start_line    IN BINARY_INTEGER DEFAULT 1,
                end_line      IN BINARY_INTEGER DEFAULT NULL);

/** Get file attributes
 *  @param  location directory location of file
 *  @param  filename file name (including extention)
 *  @param  fexists true or false, for exists or doesn't exist. 
 *  @param  file_length length of the file in bytes.
 *  @param  block_size filesystem block size in bytes.
 *  @Throws invalid_path not a valid file handle
 *  @Throws invalid_filename file not found or file name NULL
 *  @Throws access_denied access to the directory object is denied
 */  
PROCEDURE fgetattr(location    IN VARCHAR2,
                   filename    IN VARCHAR2,
                   fexists     OUT BOOLEAN,
                   file_length OUT NUMBER,
                   block_size  OUT BINARY_INTEGER);

/** Return the current position in the file in bytes.
 *  @param  file File handle (open in read mode)
 *  @Throws invalid_filehandle not a valid file handle
 *  @Throws invalid_operation file is not open for writing/appending
 *  @Throws invalid_operation file is open for byte mode access
 */
FUNCTION fgetpos(file IN file_type) RETURN BINARY_INTEGER;

/** Rename a file to a new name.
 *  @param  src_location source directory of file
 *  @param  src_filename source file name (including extention)
 *  @param  dest_location  destination directory of file
 *  @param  dest_filename destination file name (including extention)
 *  @param  overwrite boolean signifying whether to overwrite an existing
 *  @Throws invalid_path not a valid file handle
 *  @Throws invalid_filename file not found or file name NULL
 *  @Throws rename_failed rename of the file failed
 *  @Throws access_denied access to the directory object is denied
 */
PROCEDURE frename(src_location   IN VARCHAR2,
                  src_filename   IN VARCHAR2,
                  dest_location  IN VARCHAR2,
                  dest_filename  IN VARCHAR2,
                  overwrite      IN BOOLEAN DEFAULT FALSE);    

/*</DOC>*/
/*<DOC part="SMB (Administration)"> --------------------------------------------------------------------------------------------------------------------------------*/

/** 
 *  SMB is a package for accessing files in MS environment
 *  via the CIFS / SMB protocol...
 *  @headcom
 *  @author <A HREF="mailto:pierre@pierre-adam.com">Pierre ADAM</A> 
 */

vProjectName CONSTANT VARCHAR2(32):='Salambo';

/** (Oracle 11g or above) Connected with SYSDBA privilege, revoke the network access by dropping ACL
 *  @param i_vACLName Name of the ACL 
 */
PROCEDURE REVOKE_NETWORK_ACCESS(i_vACLName IN VARCHAR2:=vProjectName || '.xml');

/** (Oracle 11g or above) Connected with SYSDBA privilege, grant the network access by creating an ACL
 *  @param i_vSchemaName Grantee and Name of the Schema where this package is used
 *  @param i_vACLName Name of the ACL 
 */
PROCEDURE GRANT_NETWORK_ACCESS(i_vSchemaName IN VARCHAR2, 
                               i_vACLName IN VARCHAR2:=vProjectName || '.xml');
                               
/** Return the version of this package
 *  @return the version as a string (eg "1.0")
 */
FUNCTION GET_VERSION RETURN VARCHAR2;

/*</DOC>*/
/*<DOC part="SMB (Text APIs)"> --------------------------------------------------------------------------------------------------------------------------------*/

FUNCTION DECODE_TEXT(i_bContent IN BLOB, 
                     i_vCharacterSet IN VARCHAR2 DEFAULT NULL,
                     i_vLineSeparator IN  VARCHAR2 DEFAULT NULL, 
                     o_vError OUT ERRSTR) RETURN CLOB;
                     
vCRLF CONSTANT VARCHAR2(2):=CHR(13) || CHR(10);
vCR CONSTANT VARCHAR2(1):=CHR(13);
vLF CONSTANT VARCHAR2(1):=CHR(10);
bom_UTF8 CONSTANT RAW(3):=HexToRaw('EFBBBF');                  
bom_UTF16BE CONSTANT RAW(2):=HexToRaw('FEFF');
bom_UTF16LE CONSTANT RAW(2):=HexToRaw('FFFE');
   
FUNCTION ENCODE_TEXT(i_cContent IN CLOB, 
                     i_vCharacterSet IN VARCHAR2 DEFAULT NULL,
                     i_vLineSeparator IN  VARCHAR2 DEFAULT NULL,
                     i_vBOM IN RAW DEFAULT NULL,
                     o_vError OUT ERRSTR) RETURN BLOB;                     

/*</DOC>*/
FUNCTION NAME_QUERY_REQUEST(i_vName IN VARCHAR2) RETURN VARCHAR2;
FUNCTION DebugRaw(i_rRaw IN RAW) RETURN VARCHAR2;
END SMB;
/
/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE BODY SMB
IS

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- TYPE
-------------------------------------------------------------------------------------------------------------------------------------------------------
SUBTYPE UCHAR IS PLS_INTEGER RANGE 0..255;
SUBTYPE USHORT IS PLS_INTEGER RANGE 0..65535;
SUBTYPE ULONG IS NUMBER(10);

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ORACLE EXCEPTIONS
-------------------------------------------------------------------------------------------------------------------------------------------------------
END_OF_INPUT_REACHED EXCEPTION; PRAGMA EXCEPTION_INIT(END_OF_INPUT_REACHED, -29259);
UNREACHABLE_HOST EXCEPTION; PRAGMA EXCEPTION_INIT(UNREACHABLE_HOST, -29260);
UNKNOWN_HOST EXCEPTION; PRAGMA EXCEPTION_INIT(UNKNOWN_HOST, -29257);
NUM_OVERFLOW EXCEPTION; PRAGMA EXCEPTION_INIT(NUM_OVERFLOW, -1426);
NETWORK_ACCESS_DENIED_BY_ACL EXCEPTION; PRAGMA EXCEPTION_INIT(NETWORK_ACCESS_DENIED_BY_ACL, -24247);
UNKNOWN_NETBIOS_NAME EXCEPTION;
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ERRORS
-------------------------------------------------------------------------------------------------------------------------------------------------------
TYPE ERRSTR_C IS TABLE OF ERRSTR INDEX BY VARCHAR2(8);
TvErrors ERRSTR_C;
err_UNKNOWN_HOST CONSTANT ERRSTR:='Unknown Host';
err_UNKNOWN_NETBIOS_NAME CONSTANT ERRSTR:='Unknown Netbios Name';
err_UNREACHABLE_HOST CONSTANT ERRSTR:='Unreachable Host';
err_SHARES_MISMATCH CONSTANT ERRSTR:='Cannot do this operation through differents shares';
err_SRV_COPYCHUNK_FAIL CONSTANT ERRSTR:='Server Copychunk method fail';
err_CANNOT_CONNECT CONSTANT ERRSTR:='Unexpected error when connecting';
err_NET_ACCESS_DENIED_BY_ACL CONSTANT ERRSTR:='Network access denied by access control list' || CHR(13) || 
                                              'With SYSDBA privilege, execute the following statement:' || CHR(13) || 
                                              'BEGIN ' || SYS_CONTEXT('userenv', 'current_schema') || '.SMB.GRANT_NETWORK_ACCESS(''' || SYS_CONTEXT('userenv', 'current_schema') || '''); END;';
sus_OK CONSTANT ULONG:=0;
sus_MORE_PROCESSING_REQUIRED CONSTANT ULONG:=3221225494;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- CIFS DECLARATION [CIFS.1]
-------------------------------------------------------------------------------------------------------------------------------------------------------

SMB_Magic CONSTANT RAW(4):=HexToRaw('FF534D42'); -- 0xFF + SMB

SUBTYPE SMB_DATE IS USHORT;
SUBTYPE SMB_TIME IS USHORT;
SUBTYPE LARGE_INTEGER IS NUMBER(20); -- 64 bits

SUBTYPE SMB_NMPIPE_STATUS IS USHORT;

SUBTYPE UTIME IS ULONG;

TYPE SMBSTATUS IS RECORD(
    ErrorClass UCHAR,
    Reserved UCHAR,
    ErrorCode USHORT
);
    
SUBTYPE SMB_ERROR IS SMBSTATUS;

SUBTYPE SMB_FILE_ATTRIBUTES IS USHORT;
SUBTYPE SMB_EXT_FILE_ATTR IS ULONG;

SUBTYPE SMB_GEA IS VARCHAR2(1000);
TYPE SMB_GEA_LIST IS TABLE OF SMB_GEA INDEX BY PLS_INTEGER;

TYPE SMB_FEA IS RECORD(
    vAttributeName VARCHAR2(255),
    vAttributeValue VARCHAR2(32000),
    bFileNeedEA BOOLEAN);
    
TYPE SMB_FEA_LIST IS TABLE OF SMB_FEA INDEX BY PLS_INTEGER;

-- Constantes pour SMB_FILE_ATTRIBUTES
SMB_FILE_ATTRIBUTE_NORMAL CONSTANT PLS_INTEGER:=0;
SMB_FILE_ATTRIBUTE_READONLY CONSTANT PLS_INTEGER:=1;
SMB_FILE_ATTRIBUTE_HIDDEN CONSTANT PLS_INTEGER:=2;
SMB_FILE_ATTRIBUTE_SYSTEM CONSTANT PLS_INTEGER:=4;
SMB_FILE_ATTRIBUTE_VOLUME CONSTANT PLS_INTEGER:=8;
SMB_FILE_ATTRIBUTE_DIRECTORY CONSTANT PLS_INTEGER:=16;
SMB_FILE_ATTRIBUTE_ARCHIVE CONSTANT PLS_INTEGER:=32;
SMB_SEARCH_ATTRIBUTE_READONLY CONSTANT PLS_INTEGER:=256;
SMB_SEARCH_ATTRIBUTE_HIDDEN CONSTANT PLS_INTEGER:=512;
SMB_SEARCH_ATTRIBUTE_SYSTEM CONSTANT PLS_INTEGER:=1024;
SMB_SEARCH_ATTRIBUTE_DIRECTORY CONSTANT PLS_INTEGER:=65536;
SMB_SEARCH_ATTRIBUTE_ARCHIVE CONSTANT PLS_INTEGER:=131072;

-- Constantes pour SMB_EXT_FILE_ATTR
ATTR_READONLY CONSTANT ULONG:=1;
ATTR_HIDDEN CONSTANT ULONG:=2;
ATTR_SYSTEM CONSTANT ULONG:=4;
ATTR_DIRECTORY CONSTANT ULONG:=16;
ATTR_ARCHIVE CONSTANT ULONG:=32;
ATTR_NORMAL CONSTANT ULONG:=128;
ATTR_TEMPORARY CONSTANT ULONG:=256;
ATTR_SPARSE CONSTANT ULONG:=512;
ATTR_REPARSE_POINT CONSTANT ULONG:=1024;
ATTR_COMPRESSED CONSTANT ULONG:=2048;
ATTR_OFFLINE CONSTANT ULONG:=4096;
ATTR_NOT_CONTENT_INDEXED CONSTANT ULONG:=8192;
ATTR_ENCRYPTED CONSTANT ULONG:=16384;
POSIX_SEMANTICS CONSTANT ULONG:=16777216;
BACKUP_SEMANTICS CONSTANT ULONG:=33554432;
DELETE_ON_CLOSE CONSTANT ULONG:=67108864;
SEQUENTIAL_SCAN CONSTANT ULONG:=134217728;
RANDOM_ACCESS CONSTANT ULONG:=268435456;
NO_BUFFERING CONSTANT ULONG:=536870912;
WRITE_THROUGH CONSTANT ULONG:=2147483648;

-- Constantes pour SMB_Header.Flags2
SMB_FLAGS2_LONG_NAMES CONSTANT PLS_INTEGER:=1;
SMB_FLAGS2_EAS CONSTANT PLS_INTEGER:=2;
SMB_FLAGS2_SMB_SECUR_SIGNATURE CONSTANT PLS_INTEGER:=4;
SMB_FLAGS2_IS_LONG_NAME CONSTANT PLS_INTEGER:=64;
f2_ExtendedSecurityNegotiation CONSTANT PLS_INTEGER:=2048;
SMB_FLAGS2_DFS CONSTANT PLS_INTEGER:=4096;
SMB_FLAGS2_PAGING_IO CONSTANT PLS_INTEGER:=8192;
SMB_FLAGS2_NT_STATUS CONSTANT PLS_INTEGER:=16384;
SMB_FLAGS2_UNICODE CONSTANT PLS_INTEGER:=32768;
   
TYPE SMB_Header IS RECORD(
   Command UCHAR,
   Status SMB_ERROR,
   Flags UCHAR:=24,
   Flags2 USHORT:=1 + f2_ExtendedSecurityNegotiation, 
   PIDHigh USHORT,
   SecurityFeatures VARCHAR2(8),
   Reserved USHORT,
   TID USHORT,
   PIDLow USHORT,
   UID USHORT,
   MID USHORT
);
    
-- 2.2.2.1 SMB_COM Command Codes
SmbCom_CREATE_DIRECTORY CONSTANT PLS_INTEGER:=0;
SmbCom_DELETE_DIRECTORY CONSTANT PLS_INTEGER:=1;
SmbCom_OPEN CONSTANT PLS_INTEGER:=2;
SmbCom_CREATE CONSTANT PLS_INTEGER:=3;
SmbCom_CLOSE CONSTANT PLS_INTEGER:=4;
SmbCom_FLUSH CONSTANT PLS_INTEGER:=5;
SmbCom_DELETE CONSTANT PLS_INTEGER:=6;
SmbCom_RENAME CONSTANT PLS_INTEGER:=7;
SmbCom_QUERY_INFORMATION CONSTANT PLS_INTEGER:=8;
SmbCom_SET_INFORMATION CONSTANT PLS_INTEGER:=9;
SmbCom_READ CONSTANT PLS_INTEGER:=10;
SmbCom_WRITE CONSTANT PLS_INTEGER:=11;
SmbCom_LOCK_BYTE_RANGE CONSTANT PLS_INTEGER:=12;
SmbCom_UNLOCK_BYTE_RANGE CONSTANT PLS_INTEGER:=13;
SmbCom_CREATE_TEMPORARY CONSTANT PLS_INTEGER:=14;
SmbCom_CREATE_NEW CONSTANT PLS_INTEGER:=15;
SmbCom_CHECK_DIRECTORY CONSTANT PLS_INTEGER:=16;
SmbCom_PROCESS_EXIT CONSTANT PLS_INTEGER:=17;
SmbCom_SEEK CONSTANT PLS_INTEGER:=18;
SmbCom_LOCK_AND_READ CONSTANT PLS_INTEGER:=19;
SmbCom_WRITE_AND_UNLOCK CONSTANT PLS_INTEGER:=20;
SmbCom_READ_RAW CONSTANT PLS_INTEGER:=26;
SmbCom_READ_MPX CONSTANT PLS_INTEGER:=27;
SmbCom_READ_MPX_SECONDARY CONSTANT PLS_INTEGER:=28;
SmbCom_WRITE_RAW CONSTANT PLS_INTEGER:=29;
SmbCom_WRITE_MPX CONSTANT PLS_INTEGER:=30;
SmbCom_WRITE_MPX_SECONDARY CONSTANT PLS_INTEGER:=31;
SmbCom_WRITE_COMPLETE CONSTANT PLS_INTEGER:=32;
SmbCom_QUERY_SERVER CONSTANT PLS_INTEGER:=33;
SmbCom_SET_INFORMATION2 CONSTANT PLS_INTEGER:=34;
SmbCom_QUERY_INFORMATION2 CONSTANT PLS_INTEGER:=35;
SmbCom_LOCKING_ANDX CONSTANT PLS_INTEGER:=36;
SmbCom_TRANSACTION CONSTANT PLS_INTEGER:=37;
SmbCom_TRANSACTION_SECONDARY CONSTANT PLS_INTEGER:=38;
SmbCom_IOCTL CONSTANT PLS_INTEGER:=39;
SmbCom_IOCTL_SECONDARY CONSTANT PLS_INTEGER:=40;
SmbCom_COPY CONSTANT PLS_INTEGER:=41;
SmbCom_MOVE CONSTANT PLS_INTEGER:=42;
SmbCom_ECHO CONSTANT PLS_INTEGER:=43;
SmbCom_WRITE_AND_CLOSE CONSTANT PLS_INTEGER:=44;
SmbCom_OPEN_ANDX CONSTANT PLS_INTEGER:=45;
SmbCom_READ_ANDX CONSTANT PLS_INTEGER:=46;
SmbCom_WRITE_ANDX CONSTANT PLS_INTEGER:=47;
SmbCom_CLOSE_AND_TREE_DISC CONSTANT PLS_INTEGER:=49;
SmbCom_TRANSACTION2 CONSTANT PLS_INTEGER:=50;
SmbCom_TRANSACTION2_SECONDARY CONSTANT PLS_INTEGER:=51;
SmbCom_FIND_CLOSE2 CONSTANT PLS_INTEGER:=52;
SmbCom_FIND_NOTIFY_CLOSE CONSTANT PLS_INTEGER:=53;
SmbCom_TREE_CONNECT CONSTANT PLS_INTEGER:=112;
SmbCom_TREE_DISCONNECT CONSTANT PLS_INTEGER:=113;
SmbCom_NEGOTIATE CONSTANT PLS_INTEGER:=114;
SmbCom_SESSION_SETUP_ANDX CONSTANT PLS_INTEGER:=115;
SmbCom_LOGOFF_ANDX CONSTANT PLS_INTEGER:=116;
SmbCom_TREE_CONNECT_ANDX CONSTANT PLS_INTEGER:=117;
SmbCom_SECURITY_PACKAGE_ANDX CONSTANT PLS_INTEGER:=126;
SmbCom_QUERY_INFORMATION_DISK CONSTANT PLS_INTEGER:=128;
SmbCom_SEARCH CONSTANT PLS_INTEGER:=129;
SmbCom_FIND CONSTANT PLS_INTEGER:=130;
SmbCom_FIND_UNIQUE CONSTANT PLS_INTEGER:=131;
SmbCom_FIND_CLOSE CONSTANT PLS_INTEGER:=132;
SmbCom_NT_TRANSACT CONSTANT PLS_INTEGER:=160;
SmbCom_NT_TRANSACT_SECONDARY CONSTANT PLS_INTEGER:=161;
SmbCom_NT_CREATE_ANDX CONSTANT PLS_INTEGER:=162;
SmbCom_NT_CANCEL CONSTANT PLS_INTEGER:=164;
SmbCom_NT_RENAME CONSTANT PLS_INTEGER:=165;
SmbCom_OPEN_PRINT_FILE CONSTANT PLS_INTEGER:=192;
SmbCom_WRITE_PRINT_FILE CONSTANT PLS_INTEGER:=193;
SmbCom_CLOSE_PRINT_FILE CONSTANT PLS_INTEGER:=194;
SmbCom_GET_PRINT_QUEUE CONSTANT PLS_INTEGER:=195;
SmbCom_READ_BULK CONSTANT PLS_INTEGER:=216;
SmbCom_WRITE_BULK CONSTANT PLS_INTEGER:=217;
SmbCom_WRITE_BULK_DATA CONSTANT PLS_INTEGER:=218;
SmbCom_INVALID CONSTANT PLS_INTEGER:=254;
SmbCom_NO_ANDX_COMMAND CONSTANT PLS_INTEGER:=255;

SmbTrans_SET_NMPIPE_STATE CONSTANT PLS_INTEGER:=1;
SmbTrans_QUERY_NMPIPE_STATE CONSTANT PLS_INTEGER:=33;
SmbTrans_QUERY_NMPIPE_INFO CONSTANT PLS_INTEGER:=34;
SmbTrans_PEEK_NMPIPE CONSTANT PLS_INTEGER:=35;
SmbTrans_TRANSACT_NMPIPE CONSTANT PLS_INTEGER:=38;
SmbTrans_READ_NMPIPE CONSTANT PLS_INTEGER:=54;
SmbTrans_WRITE_NMPIPE CONSTANT PLS_INTEGER:=55;
SmbTrans_WAIT_NMPIPE CONSTANT PLS_INTEGER:=83;
SmbTrans_CALL_NMPIPE CONSTANT PLS_INTEGER:=84;
SmbTrans_MAILSLOT_WRITE CONSTANT PLS_INTEGER:=1;

SmbTr2_TRANS2_FIND_FIRST2 CONSTANT PLS_INTEGER:=1;
SmbTr2_TRANS2_FIND_NEXT2 CONSTANT PLS_INTEGER:=2;
SmbTr2_TRANS2_QUERY_FS_INFO CONSTANT PLS_INTEGER:=3;
SmbTr2_TRANS2_QUERY_PATH_INFO CONSTANT PLS_INTEGER:=5;
SmbTr2_TRANS2_QUERY_FILE_INFO CONSTANT PLS_INTEGER:=7;
SmbTr2_TRANS2_SET_FILE_INFO CONSTANT PLS_INTEGER:=8;
SmbTr2_TRANS2_CREATE_DIRECTORY CONSTANT PLS_INTEGER:=13;

TYPE COPYCHUNK_T IS  RECORD(
    nSourceOffset LARGE_INTEGER, 
    nDestinationOffset LARGE_INTEGER, 
    nCopyLength ULONG);
    
TYPE COPYCHUNK_C IS TABLE OF COPYCHUNK_T INDEX BY PLS_INTEGER;

NTTr_IOCTL CONSTANT PLS_INTEGER:=2;
NTTr_NOTIFY_CHANGE CONSTANT PLS_INTEGER:=4;
NTTr_QUERY_SECURITY_DESC CONSTANT PLS_INTEGER:=6;

-- Constants for NT_TRANSACT_NOTIFY_CHANGE
FILE_ACTION_ADDED CONSTANT PLS_INTEGER:=1;
FILE_ACTION_REMOVED CONSTANT PLS_INTEGER:=2;
FILE_ACTION_MODIFIED CONSTANT PLS_INTEGER:=3;
FILE_ACTION_RENAMED_OLD_NAME CONSTANT PLS_INTEGER:=4;
FILE_ACTION_RENAMED_NEW_NAME CONSTANT PLS_INTEGER:=5;
FILE_ACTION_ADDED_STREAM CONSTANT PLS_INTEGER:=6;
FILE_ACTION_REMOVED_STREAM CONSTANT PLS_INTEGER:=7;
FILE_ACTION_MODIFIED_STREAM CONSTANT PLS_INTEGER:=8;

-- Type for NT_TRANSACT_NOTIFY_CHANGE
TYPE FILE_NOTIFY_INFO_T IS RECORD(
    vFileName VARCHAR2(255),
    nFileAction PLS_INTEGER);
    
TYPE FILE_NOTIFY_INFO_C IS TABLE OF FILE_NOTIFY_INFO_T INDEX BY PLS_INTEGER;

FsctlSrv_REQUEST_RESUME_KEY CONSTANT PLS_INTEGER:=1310840;
FsctlSrv_COPYCHUNK CONSTANT PLS_INTEGER:=1327346;

TransportType_NBT CONSTANT PLS_INTEGER:=0;
TransportType_RAW_TCP CONSTANT PLS_INTEGER:=1;

-- RAP Opcode
NetServerGetInfo CONSTANT USHORT:=13; -- ok
NetServerEnum2 CONSTANT USHORT:=104; -- ok en XP
NetServerEnum3 CONSTANT USHORT:=215; -- ok en XP
NetShareEnum CONSTANT USHORT:=0; -- ok
NetShareGetInfo CONSTANT USHORT:=1;
NetPrintQEnum CONSTANT USHORT:=69;
NetPrintQGetInfo CONSTANT USHORT:=70;
NetPrintJobSetInfo CONSTANT USHORT:=147;
NetPrintJobGetInfo CONSTANT USHORT:=77;
NetPrintJobPause CONSTANT USHORT:=82;
NetPrintJobContinue CONSTANT USHORT:=83;
NetPrintJobDelete CONSTANT USHORT:=81;
NetUserPasswordSet2 CONSTANT USHORT:=115;
NetUserGetInfo CONSTANT USHORT:=56; -- ok
NetRemoteTOD CONSTANT USHORT:=91; -- ok
NetWkstaGetinfo CONSTANT USHORT:=63; -- ok
NetWkstaUserLogon CONSTANT USHORT:=132;
NetWkstaUserLogoff CONSTANT USHORT:=133;

-- Constantes pour NegotiateResponse.capabilities
cap_RawMode CONSTANT ULONG:=1;
cap_MPXMode CONSTANT ULONG:=2;
cap_Unicode CONSTANT ULONG:=4;
cap_LargeFiles CONSTANT ULONG:=8;
cap_NTSMBs CONSTANT ULONG:=16;
cap_RPCRemoteAPIs CONSTANT ULONG:=32;
cap_NTStatusCodes CONSTANT ULONG:=64;
cap_Level2Oplocks CONSTANT ULONG:=128;
cap_LockAndRead CONSTANT ULONG:=256;
cap_NTFind CONSTANT ULONG:=512;
cap_DfsNotSupported CONSTANT ULONG:=4096;
cap_InfoLevelPassThru CONSTANT ULONG:=8192;
cap_LargeReadX CONSTANT ULONG:=16384;
cap_LargeWriteX CONSTANT ULONG:=32768;
cap_UnixExt CONSTANT ULONG:=8388608;
cap_Reserved CONSTANT ULONG:=33554432;
cap_BulkTransfer CONSTANT ULONG:=536870912;
cap_CompressedData CONSTANT ULONG:=1073741824;
cap_ExtendedSecurity CONSTANT ULONG:=2147483648; 

-- SMB-LM21.DOC - 2.1 NegProt Resp SMB
-- modifié d'après Wireshark 1.2.2
TYPE NegotiateResponse IS RECORD(
    protocolIndex USHORT,
    secmode UCHAR,
    maxMpxCount USHORT,
    maxVCS USHORT,
    maxBufferSize ULONG,
    maxRawBuffer ULONG,
    RawMode USHORT,
    sesskey ULONG,
    capabilities ULONG,
    srv_time RAW(8),
    srv_tzone USHORT,
    cryptkeylen UCHAR,
    -- data
    cryptkey RAW(8),
    domain VARCHAR2(100),
    server VARCHAR2(100),
    -- data avec extended security
    guid RAW(16),
    security_blob RAW(1000)
    );
    
TYPE FileOrDirInfo_T IS RECORD(
    vFileName VARCHAR2(4000),
    vShortFileName VARCHAR2(12),
    nFileAttributes SMB_FILE_ATTRIBUTES,
    nExtFileAttributes SMB_EXT_FILE_ATTR,
    dCreationTime DATE,
    dLastAccessTime DATE, 
    dLastWriteTime DATE,
    dLastChangeTime DATE,
    nSize LARGE_INTEGER,
    nAllocationSize LARGE_INTEGER,
    nEASize ULONG,
    TxSmbFeaList SMB_FEA_LIST,
    nNumberOfLinks ULONG,
    bDeletePending BOOLEAN,
    bDirectory BOOLEAN
    );    
    
TYPE FileOrDirInfo_C IS TABLE OF FileOrDirInfo_T  INDEX BY PLS_INTEGER;  

SUBTYPE SID_IDENTIFIER_AUTHORITY_T IS RAW(6);
TYPE SUB_AUTHORITY_C IS VARRAY(15) OF ULONG;

TYPE SID_T IS RECORD(
    nRevision UCHAR,
    nSubAuthorityCount UCHAR,
    xIdentifierAuthority SID_IDENTIFIER_AUTHORITY_T,
    xSubAuthority SUB_AUTHORITY_C
    );

ACCESS_ALLOWED_ACE CONSTANT UCHAR:=0;
ACCESS_DENIED_ACE CONSTANT UCHAR:=1;
SYSTEM_AUDIT_ACE CONSTANT UCHAR:=2;
ACCESS_ALLOWED_OBJECT_ACE CONSTANT UCHAR:=5;
ACCESS_DENIED_OBJECT_ACE CONSTANT UCHAR:=6;
SYSTEM_AUDIT_OBJECT_ACE CONSTANT UCHAR:=7;
ACCESS_ALLOWED_CBACK_ACE CONSTANT UCHAR:=9;
ACCESS_DENIED_CBACK_ACE CONSTANT UCHAR:=10;
ACCESS_ALLOWED_CBACK_OBJ_ACE CONSTANT UCHAR:=11;
ACCESS_DENIED_CBACK_OBJ_ACE CONSTANT UCHAR:=12;
SYSTEM_AUDIT_CBACK_ACE CONSTANT UCHAR:=13;
SYSTEM_AUDIT_CBACK_OBJ_ACE CONSTANT UCHAR:=15;
SYSTEM_MANDATORY_LABEL_ACE CONSTANT UCHAR:=17;
SYSTEM_RESOURCE_ATTRIBUTE_ACE CONSTANT UCHAR:=18;
SYSTEM_SCOPED_POLICY_ID_ACE CONSTANT UCHAR:=19;

OWNER_SECURITY_INFORMATION CONSTANT ULONG:=1;
GROUP_SECURITY_INFORMATION CONSTANT ULONG:=2;
DACL_SECURITY_INFORMATION CONSTANT ULONG:=4;
SACL_SECURITY_INFORMATION CONSTANT ULONG:=8;

TYPE ACE_T IS RECORD(
    nAceType UCHAR,
    nAceFlag UCHAR,
    nMask ULONG,
    xSID SID_T
    );
    
TYPE ACE_C IS TABLE OF ACE_T INDEX BY PLS_INTEGER;

TYPE ACL_T IS RECORD(
    nAclRevision UCHAR,
    nSbz1 UCHAR,
    nAclSize USHORT,
    nAceCount USHORT, 
    nSbz2 UCHAR,
    TxAce ACE_C
    );
    
TYPE SecurityDescriptor_T IS RECORD(
    nRevision UCHAR, 
    nSbz1 UCHAR, 
    nControl USHORT, 
    xOwnerSID SID_T, 
    xGroupSID SID_T,
    xSAcl ACL_T,
    xDAcl ACL_T);  
    
TYPE SHARE_T IS RECORD(
    vDomain VARCHAR2(255), 
    vLogin VARCHAR2(255),
    vPassword VARCHAR2(255), 
    vHost VARCHAR2(255), 
    nPort PLS_INTEGER:=445,
    vShare VARCHAR2(255)
    );    
    
-- Global variable.
TYPE contextRec IS RECORD (
    nTransportType PLS_INTEGER,
    vHost VARCHAR2(1000),
    nPort PLS_INTEGER,
    xSMBHeader SMB_Header,
    xNegotiateResponse NegotiateResponse,
    bConOpen BOOLEAN:=FALSE,
    xCon UTL_TCP.connection,
    vService VARCHAR2(100)
    );
xCtx contextRec;

TYPE FILE_HANDLE_T IS RECORD(
    nFID USHORT,
    xCtx contextRec,
    nWritePosition ULONG,
    nReadPosition ULONG,
    nFileSize ULONG, -- filled in 'r' mode. 
    vOpenMode VARCHAR2(1), -- 'w', 'r', 'a'
    nMaxLineSize PLS_INTEGER
    );
    
TYPE FILE_HANDLE_C IS TABLE OF FILE_HANDLE_T INDEX BY PLS_INTEGER;   

TxFileHandle FILE_HANDLE_C; 

-- Enum for i_vService :
svc_DiskShare CONSTANT VARCHAR2(5):='A:';
svc_PrinterShare CONSTANT VARCHAR2(5):='LPT1:';
svc_NamedPipe CONSTANT VARCHAR2(5):='IPC';
svc_SerialCommDevice CONSTANT VARCHAR2(5):='COMM';
svc_AnyType CONSTANT VARCHAR2(5):='?????';
-- i_nFlags : une combinaison des constantes suivantes. 
SMB_FIND_CLOSE_AFTER_REQUEST CONSTANT USHORT:=1;
SMB_FIND_CLOSE_AT_EOS CONSTANT USHORT:=2;
SMB_FIND_RETURN_RESUME_KEYS CONSTANT USHORT:=4;
SMB_FIND_CONTINUE_FROM_LAST CONSTANT USHORT:=8;
SMB_FIND_WITH_BACKUP_INTENT CONSTANT USHORT:=16;
-- i_nInformationLevel
SMB_INFO_STANDARD CONSTANT USHORT:=1;
SMB_INFO_QUERY_EA_SIZE CONSTANT USHORT:=2;
SMB_INFO_QUERY_EAS_FROM_LIST CONSTANT USHORT:=3;
SMB_FIND_FILE_DIRECTORY_INFO CONSTANT USHORT:=257;
SMB_FIND_FILE_FULL_DIR_INFO CONSTANT USHORT:=258;
SMB_FIND_FILE_NAMES_INFO CONSTANT USHORT:=259;
SMB_FIND_FILE_BOTH_DIR_INFO CONSTANT USHORT:=260;
-- i_nSearchStorageType : l'une ou l'autre des valeurs 
FILE_DIRECTORY_FILE CONSTANT ULONG:=1;
FILE_NON_DIRECTORY_FILE CONSTANT ULONG:=64;

-- nInformationLevel pour TRANS2_QUERY_FS_INFORMATION :
SMB_INFO_ALLOCATION CONSTANT PLS_INTEGER:=1;
SMB_INFO_VOLUME CONSTANT PLS_INTEGER:=2;
SMB_QUERY_FS_VOLUME_INFO CONSTANT PLS_INTEGER:=258;
SMB_QUERY_FS_SIZE_INFO CONSTANT PLS_INTEGER:=259;
SMB_QUERY_FS_DEVICE_INFO CONSTANT PLS_INTEGER:=260;
SMB_QUERY_FS_ATTRIBUTE_INFO CONSTANT PLS_INTEGER:=261;

TYPE FS_INFO_T IS RECORD(
    idFileSystem ULONG,
    SerialNumber ULONG,
    VolumeLabel VARCHAR2(255),
    VolumeCreationTime DATE,
    TotalAllocationUnits LARGE_INTEGER,
    TotalFreeAllocationUnits LARGE_INTEGER,
    SectorsPerAllocationUnit ULONG,
    BytesPerSector ULONG,
    DeviceType ULONG,
    DeviceCharacteristics ULONG,
    FileSystemAttributes ULONG,
    MaxFileNameLengthInBytes ULONG,
    FileSystemName VARCHAR2(255)
    );

-- nInformationLevel pour TRANS2_QUERY_FILE_INFORMATION
-- SMB_INFO_STANDARD CONSTANT USHORT:=1;
-- SMB_INFO_QUERY_EA_SIZE CONSTANT USHORT:=2;
-- SMB_INFO_QUERY_EAS_FROM_LIST CONSTANT USHORT:=3;
SMB_INFO_QUERY_ALL_EAS CONSTANT USHORT:=4;
SMB_INFO_IS_NAME_VALID CONSTANT USHORT:=6;
SMB_QUERY_FILE_BASIC_INFO CONSTANT USHORT:=257;
SMB_QUERY_FILE_STANDARD_INFO CONSTANT USHORT:=258;
SMB_QUERY_FILE_EA_INFO CONSTANT USHORT:=259;
SMB_QUERY_FILE_NAME_INFO CONSTANT USHORT:=260;
SMB_QUERY_FILE_ALL_INFO CONSTANT USHORT:=263;
SMB_QUERY_FILE_ALT_NAME_INFO CONSTANT USHORT:=264;
SMB_QUERY_FILE_STREAM_INFO CONSTANT USHORT:=265;
SMB_QUERY_FILE_COMPRESS_INFO CONSTANT USHORT:=267;    
-- nInformationLevel pour TRANS2_SET_FILE_INFORMATION
-- SMB_INFO_STANDARD CONSTANT USHORT:=1;
SMB_INFO_SET_EAS CONSTANT USHORT:=2;
SMB_SET_FILE_BASIC_INFO CONSTANT USHORT:=257;
SMB_SET_FILE_DISPOSITION_INFO CONSTANT USHORT:=258;
SMB_SET_FILE_ALLOCATION_INFO CONSTANT USHORT:=259;
SMB_SET_FILE_END_OF_FILE_INFO CONSTANT USHORT:=260; 

/** Credential information
 *  @param vDomain Domain name
 *  @param vLogin Login
 *  @param vPassword Password
 */
TYPE CREDENTIAL_T IS RECORD(
    vDomain VARCHAR2(255),
    vLogin VARCHAR2(255),
    vPassword VARCHAR2(255)
    );

/** SPLIT_URL create a SHARE_T structure, and a filename from a full filename and a credential. <br>
 *  the following syntaxes are allowed : <br>
 *  eg. <br>
 *  Syntax 1 (FullFileName doesn't contain the credential). <br>
 *  <code>
 *  i_vFullFileName => '\\Server01:445\Share01\Dir01\File01.txt', <br>
 *  i_xCredential =>  CREDENTIAL('WORKGROUP', 'Administrator', 'password') <br>
 *  </code>
 *  Syntax 2 (FullFileName contains the credential). <br>
 *  <code>
 *  i_vFullFileName => 'smb://WORKGROUP;Administrator:password@Server01:445/Share01/Dir01/File01.txt', <br>
 *  i_xCredential => NULL <br>
 *  </code>
 *  @param  i_vFullFileName Full filename (share, filename. Can also contains credential). 
 *  @param  i_xCredential CREDENTIAL_T structure (domain, login, password)
 *  @param  o_xShare SHARE_T structure (credential + host, port and share)
 *  @param  o_vFileName (filename with path) 
 *  @param  i_bServerName If True the i_vFullFileName parameter is considered as a ServerName. (can avoid to start with \\ ; default IPC$ share is added). 
 */
PROCEDURE SPLIT_URL(i_vFullFileName IN VARCHAR2, 
                    i_xCredential IN CREDENTIAL_T,
                    o_xShare OUT SHARE_T, 
                    o_vFileName OUT VARCHAR2,
                    i_bServerName IN BOOLEAN:=FALSE);
                    
FUNCTION security_blob_negotiate(i_vDomain IN VARCHAR2,
                                 i_vWorkstation IN VARCHAR2) RETURN RAW;

FUNCTION security_blob_authentication(i_rServerChallenge IN RAW,
                                      i_vLogin IN VARCHAR2,
                                      i_vPassword IN VARCHAR2, 
                                      i_vDomain IN VARCHAR2, 
                                      i_vWorkstation IN VARCHAR2) RETURN RAW;
  
FUNCTION UnicodeStringToRaw(i_vString IN VARCHAR2) RETURN RAW;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- UTL DECLARATION [UTL.1]
-------------------------------------------------------------------------------------------------------------------------------------------------------
SUBTYPE U8 IS PLS_INTEGER RANGE 0..255;
SUBTYPE U16LE IS PLS_INTEGER RANGE 0..65535;
SUBTYPE U32LE IS NUMBER(10);
SUBTYPE U16BE IS PLS_INTEGER RANGE 0..65535;
SUBTYPE U32BE IS NUMBER(10);
vDatabaseCharset VARCHAR2(100);
vDatabaseNCharset VARCHAR2(100);
TYPE STR_BY_NUM IS TABLE OF VARCHAR2(32000) INDEX BY PLS_INTEGER;

FUNCTION split(i_vStringToSplit IN VARCHAR2, 
               i_vSeparator IN VARCHAR2) RETURN STR_BY_NUM;

FUNCTION U32LEToRaw(i_nU32LE IN U32LE) RETURN RAW;
FUNCTION U32BEToRaw(i_nU32BE IN U32BE) RETURN RAW;
FUNCTION U16LEToRaw(i_nU16LE IN U16LE) RETURN RAW;
FUNCTION U16BEToRaw(i_nU16BE IN U16BE) RETURN RAW;
FUNCTION U8ToRaw(i_nCHAR IN U8) RETURN RAW;
FUNCTION RawToU32BE(i_rSMBMessage IN OUT NOCOPY RAW,
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U32BE;
FUNCTION RawToU32LE(i_rSMBMessage IN OUT NOCOPY RAW,
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U32LE;
FUNCTION RawToU16LE(i_rSMBMessage IN OUT NOCOPY RAW, 
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U16LE;
FUNCTION RawToU16BE(i_rSMBMessage IN OUT NOCOPY RAW, 
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U16BE;
FUNCTION RawToU8(i_rSMBMessage IN OUT NOCOPY RAW, 
                 io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U8;
                     
PROCEDURE Dbg(i_vString IN VARCHAR2);

FUNCTION RawToFixedLengthString(i_rSMBMessage IN OUT NOCOPY RAW, 
                                io_nPosition IN OUT NOCOPY PLS_INTEGER,
                                i_nLength IN PLS_INTEGER) RETURN VARCHAR2;

FUNCTION get_database_charset RETURN VARCHAR2;
/** Return the main version number (10, 11, ...) of the oracle database
*/
FUNCTION get_oracle_version RETURN PLS_INTEGER;

FUNCTION RAW_SUBSTR(i_rRaw IN RAW, i_nStart IN PLS_INTEGER, i_nLength IN PLS_INTEGER:=NULL) RETURN RAW;
FUNCTION ULONGToRaw(i_nULONG IN ULONG) RETURN RAW;
FUNCTION RawToULONG(i_rSMBMessage IN OUT NOCOPY RAW,
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN ULONG;
FUNCTION RawToLargeInteger(io_rSMBMessage IN OUT NOCOPY RAW,
                           io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN LARGE_INTEGER;
FUNCTION LargeIntegerToRaw(i_nLargeInteger LARGE_INTEGER) RETURN RAW;
FUNCTION USHORTToRaw(i_nUSHORT IN USHORT) RETURN RAW;
FUNCTION RawToUSHORT(i_rSMBMessage IN OUT NOCOPY RAW, 
                     io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN USHORT;
FUNCTION UCHARToRaw(i_nCHAR IN UCHAR) RETURN RAW;
FUNCTION RawToUCHAR(i_rSMBMessage IN OUT NOCOPY RAW, 
                     io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN UCHAR;
FUNCTION BooleanToRaw(i_bValue IN BOOLEAN) RETURN RAW;

FUNCTION MD4(i_rRaw IN RAW) RETURN RAW;

vXMLEncoding VARCHAR2(100);
SUBTYPE DOMDoc IS DBMS_XMLDOM.DOMDOCUMENT;
SUBTYPE DOMNode IS DBMS_XMLDOM.DOMNode;

--FUNCTION DebugRaw(i_rRaw IN RAW) RETURN VARCHAR2;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- NETBIOS DECLARATION [NETBIOS.1]
-------------------------------------------------------------------------------------------------------------------------------------------------------
SUBTYPE U16 IS PLS_INTEGER RANGE 0..65535;
SUBTYPE U32 IS PLS_INTEGER;

SESSION_MESSAGE CONSTANT PLS_INTEGER:=0;
SESSION_REQUEST CONSTANT PLS_INTEGER:=129;
SESSION_RESPONSE_POSITIVE CONSTANT PLS_INTEGER:=130;
SESSION_RESPONSE_NEGATIVE CONSTANT PLS_INTEGER:=131;
SESSION_RESPONSE_RETARGET CONSTANT PLS_INTEGER:=132;   
SESSION_KEEP_ALIVE CONSTANT PLS_INTEGER:=133;

opcode_QUERY CONSTANT UCHAR:=0;
opcode_REGISTRATION CONSTANT UCHAR:=5;
opcode_RELEASE CONSTANT UCHAR:=6;
opcode_WACK CONSTANT UCHAR:=7;
opcode_REFRESH CONSTANT UCHAR:=8;


FUNCTION SESSION_REQUEST_CALL(i_vName IN VARCHAR2) RETURN VARCHAR2;
FUNCTION encodeFirstLevel(i_vName IN VARCHAR2, 
                          i_vScope IN VARCHAR2) RETURN VARCHAR2;
FUNCTION encodeSecondLevel(i_vName IN VARCHAR2) RETURN VARCHAR2;


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ASN1 DECLARATION [ASN1.1]
-------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- http://www.itu.int/ITU-T/studygroups/com17/languages/X.680-0207.pdf
-- http://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf
-- http://www.obj-sys.com/asn1tutorial/node124.html
    
-- Identifier : bit 7-6
tag_Universal CONSTANT PLS_INTEGER:=0;
tag_Application CONSTANT PLS_INTEGER:=64;
tag_Context_specific CONSTANT PLS_INTEGER:=128;                                                                                       
tag_Private CONSTANT PLS_INTEGER:=196;
-- Identifier : bit 5
tag_Primitive CONSTANT PLS_INTEGER:=0;
tag_Constructed CONSTANT PLS_INTEGER:=32;
-- Identifier : tag number
tag_Boolean CONSTANT PLS_INTEGER:=1;
tag_Integer CONSTANT PLS_INTEGER:=2;
tag_BitString CONSTANT PLS_INTEGER:=3;
tag_OctetString CONSTANT PLS_INTEGER:=4;
tag_Null CONSTANT PLS_INTEGER:=5;
tag_ObjectIdentifier CONSTANT PLS_INTEGER:=6;
tag_Enumerate CONSTANT PLS_INTEGER:=10;
tag_Sequence CONSTANT PLS_INTEGER:=16;
-- tag_Context_Specific + tag_Constructed
tag_CSC CONSTANT PLS_INTEGER:=tag_Context_specific + tag_Constructed;

-- Length : infinite from
length_infinite CONSTANT PLS_INTEGER:=128;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- SPNEGO DECLARATION [SPNEGO.1]
-------------------------------------------------------------------------------------------------------------------------------------------------------

SUBTYPE OID IS VARCHAR2(100);
    
OID_SPNEGO OID:='1.3.6.1.5.5.2';
OID_KERBEROS_5_LEGACY OID:='1.2.840.48018.1.2.2';
OID_KERBEROS_5 OID:='1.2.840.113554.1.2.2';
OID_NTLMSSP OID:='1.3.6.1.4.1.311.2.2.10';

SUBTYPE MechType IS OID;
TYPE MechTypeList IS TABLE OF MechType INDEX BY PLS_INTEGER;

FUNCTION OIDToRaw(i_vOID OID) RETURN RAW;

FUNCTION RawToOID(io_rRawOID IN OUT NOCOPY RAW) RETURN OID;

FUNCTION Encode_NegTokenInit(i_TxMechTypeList IN MechTypeList,
                             i_rMechToken IN RAW) RETURN RAW;
                             
-- negState enum
ns_acceptCompleted CONSTANT PLS_INTEGER:=0;
ns_acceptIncomplete CONSTANT PLS_INTEGER:=1;
ns_reject CONSTANT PLS_INTEGER:=2;
ns_requestMic CONSTANT PLS_INTEGER:=3;

TYPE negTokenResp IS RECORD(
    nNegState PLS_INTEGER,
    xSupportedMech MechType,
    rResponseToken RAW(1000));

FUNCTION Decode_negTokenResp(i_rNegTokenResp IN OUT NOCOPY RAW) RETURN negTokenResp;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- NTLM DECLARATION [NTLM.1]
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- http://davenport.sourceforge.net/ntlm.html

vNTLMSSP_SIGNATURE CONSTANT VARCHAR2(8):='NTLMSSP' || CHR(0);

NTLMSSP_NEGOTIATE CONSTANT PLS_INTEGER:=1;
NTLMSSP_CHALLENGE CONSTANT PLS_INTEGER:=2;
NTLMSSP_AUTH CONSTANT PLS_INTEGER:=3;

Negotiate_Unicode CONSTANT ULONG:=1;-- Indicates that Unicode strings are supported for use in security buffer data.
Negotiate_OEM CONSTANT ULONG:=2;-- Indicates that OEM strings are supported for use in security buffer data.
Request_Target CONSTANT ULONG:=4;-- Requests that the server's authentication realm be included in the Type 2 message.
Negotiate_Sign CONSTANT ULONG:=16;-- Specifies that authenticated communication between the client and server should carry a digital signature (message integrity).
Negotiate_Seal CONSTANT ULONG:=32;-- Specifies that authenticated communication between the client and server should be encrypted (message confidentiality).
Negotiate_Datagram_Style CONSTANT ULONG:=64;-- Indicates that datagram authentication is being used.
Negotiate_Lan_Manager_Key CONSTANT ULONG:=128;-- Indicates that the Lan Manager Session Key should be used for signing and sealing authenticated communications.
Negotiate_NTLM CONSTANT ULONG:=512;-- Indicates that NTLM authentication is being used.
Negotiate_Anonymous CONSTANT ULONG:=2048;-- Sent by the client in the Type 3 message to indicate that an anonymous context has been established. This also affects the response fields (as detailed in the "Anonymous Response" section).
Negotiate_Domain_Supplied CONSTANT ULONG:=4096;-- Sent by the client in the Type 1 message to indicate that the name of the domain in which the client workstation has membership is included in the message. This is used by the server to determine whether the client is eligible for local authentication.
Negotiate_Workstation_Supplied CONSTANT ULONG:=8192;-- Sent by the client in the Type 1 message to indicate that the client workstation's name is included in the message. This is used by the server to determine whether the client is eligible for local authentication.
Negotiate_Local_Call CONSTANT ULONG:=16384;-- Sent by the server to indicate that the server and client are on the same machine. Implies that the client may use the established local credentials for authentication instead of calculating a response to the challenge.
Negotiate_Always_Sign CONSTANT ULONG:=32768;-- Indicates that authenticated communication between the client and server should be signed with a "dummy" signature.
Target_Type_Domain CONSTANT ULONG:=65536;-- Sent by the server in the Type 2 message to indicate that the target authentication realm is a domain.
Target_Type_Server CONSTANT ULONG:=131072;-- Sent by the server in the Type 2 message to indicate that the target authentication realm is a server.
Target_Type_Share CONSTANT ULONG:=262144;-- Sent by the server in the Type 2 message to indicate that the target authentication realm is a share. Presumably, this is for share-level authentication. Usage is unclear.
Negotiate_NTLM2_Key CONSTANT ULONG:=524288;-- Indicates that the NTLM2 signing and sealing scheme should be used for protecting authenticated communications. Note that this refers to a particular session security scheme, and is not related to the use of NTLMv2 authentication. This flag can, however, have an effect on the response calculations (as detailed in the "NTLM2 Session Response" section).
Request_Init_Response CONSTANT ULONG:=1048576;-- This flag's usage has not been identified.
Request_Accept_Response CONSTANT ULONG:=2097152;-- This flag's usage has not been identified.
Request_Non_NT_Session_Key CONSTANT ULONG:=4194304;-- This flag's usage has not been identified.
Negotiate_Target_Info CONSTANT ULONG:=8388608;-- Sent by the server in the Type 2 message to indicate that it is including a Target Information block in the message. The Target Information block is used in the calculation of the NTLMv2 response.
Negotiate_128 CONSTANT ULONG:=536870912;-- Indicates that 128-bit encryption is supported.
Negotiate_Key_Exchange CONSTANT ULONG:=1073741824;-- Indicates that the client will provide an encrypted master key in the "Session Key" field of the Type 3 message.
Negotiate_56 CONSTANT ULONG:=2147483648;-- Indicates that 56-bit encryption is supported.

FUNCTION negotiate(i_vDomain IN VARCHAR2,
                   i_vWorkstation IN VARCHAR2) RETURN RAW;

TYPE NTLMMessage IS RECORD(
    nMsgType ULONG,
    vTargetName VARCHAR2(255),
    nFlags ULONG,
    rServerChallenge RAW(8),
    vVersion VARCHAR2(100)
);

FUNCTION decode_challenge(io_rRawMsg2 IN OUT NOCOPY RAW) RETURN NTLMMessage;

FUNCTION authentication(i_rServerChallenge IN RAW,
                        i_vLogin IN VARCHAR2, 
                        i_vPassword IN VARCHAR2,
                        i_vDomain IN VARCHAR2,
                        i_vWorkstation IN VARCHAR2) RETURN RAW;

FUNCTION Response(i_rServerChallenge IN RAW, 
                  i_rHash IN RAW) RETURN RAW;

FUNCTION LM_Hash(i_rServerChallenge IN RAW,
                 i_vPassword IN VARCHAR2) RETURN RAW;

FUNCTION LM_Response(i_rServerChallenge IN RAW,
                     i_vPassword IN VARCHAR2) RETURN RAW;
                     
FUNCTION LM_SessionKey(i_rHash IN RAW) RETURN RAW;
                     
FUNCTION NTLM_Hash(i_rServerChallenge IN RAW,
                   i_vPassword IN VARCHAR2) RETURN RAW;
                   
--FUNCTION NTLMv2_Hash(i_rServerChallenge IN RAW,
--                     i_vLogin IN VARCHAR2, 
--                     i_vPassword IN VARCHAR2, 
--                     i_vDomain IN VARCHAR2) RETURN RAW;                   

FUNCTION NTLM_Response(i_rServerChallenge IN RAW,
                       i_vPassword IN VARCHAR2) RETURN RAW;
                       
FUNCTION NTLM_SessionKey(i_rHash IN RAW) RETURN RAW;
   
-- Put an odd parity to the bit 0.                   
FUNCTION SetOddParity(i_nByte IN PLS_INTEGER) RETURN PLS_INTEGER;
      
-- Add odd parity to generates 8 bytes with a 7 bytes entry (56 bits).                
FUNCTION CreateDESKey(i_rRaw7Bytes IN RAW) RETURN RAW;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- NETBIOS FUNCTION (NETBIOS.2)
-------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION NAME_SERVICE_HEADER(i_nNAME_TRN_ID IN USHORT, 
                             i_nOPCODE IN UCHAR, 
                             i_nNM_FLAGS IN UCHAR, 
                             i_nRCODE IN UCHAR, 
                             i_nQDCOUNT IN USHORT, 
                             i_nANCOUNT IN USHORT,
                             i_nNSCOUNT IN USHORT, 
                             i_nARCOUNT IN USHORT) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CONCAT(
        U16BEToRaw(i_nNAME_TRN_ID), 
   --     U16BEToRaw(BITAND(i_nOPCODE, 15) * 2 + (32 * BITAND(i_nNM_FLAGS, 127)) + (4096 * BITAND(i_nRCODE, 15))),
   -- [A_REVOIR]
    U16BEToRaw(272),
        U16BEToRaw(i_nQDCOUNT), 
        U16BEToRaw(i_nANCOUNT), 
        U16BEToRaw(i_nNSCOUNT), 
        U16BEToRaw(i_nARCOUNT)); 
    
END NAME_SERVICE_HEADER;

/** Send to broadcast a NAME QUERY REQUEST 
 *  @param  i_vName Name to search
 *  @see RFC1002
 */
FUNCTION NAME_QUERY_REQUEST(i_vName IN VARCHAR2) RETURN VARCHAR2
IS
    nTrnID PLS_INTEGER;
    rQuery RAW(32000);
    xCon UTL_TCP.connection;  
    nCnt PLS_INTEGER;  
    rAnswer RAW(32000);
BEGIN
    nTrnID:=13;
    rQuery:=UTL_RAW.CONCAT(
        NAME_SERVICE_HEADER(nTrnID, opcode_QUERY, 64+4, 0, 1, 0, 0, 0), -- HEADER
        UTL_RAW.CAST_TO_RAW(encodeSecondLevel(encodeFirstLevel(i_vName, NULL))), -- QUESTION_NAME
        U16BEToRaw(32), -- NB
        U16BEToRaw(1) -- IN
        );
    --[A_REVOIR]
 --   rAnswer:=UDP.udp_client(rQuery, '192.168.0.10', 137);
    dbg(DebugRaw(rAnswer));
--    xCon:=UTL_TCP.open_connection(remote_host => '192.168.0.18',
--                                  remote_port => 137);
--    nCnt:=UTL_TCP.WRITE_RAW(xCon, rQuery);                                      
--    UTL_TCP.close_connection(xCon);  
    RETURN TO_CHAR(nCnt);          
    
END NAME_QUERY_REQUEST;
                             

FUNCTION encodeFirstLevel(i_vName IN VARCHAR2, 
                          i_vScope IN VARCHAR2) RETURN VARCHAR2
IS
    vName VARCHAR2(16);
    vEncodedName VARCHAR2(1000);
    vHex VARCHAR2(2);
    vPadding VARCHAR2(1);
BEGIN
    vPadding:=' ';
    IF i_vName = '*' THEN
        vPadding:=CHR(0);
    END IF;
    vName:=SUBSTR(RPAD(i_vName, 16, vPadding), 1, 16);
    vEncodedName:=NULL;
    FOR i IN 1..16
    LOOP
        vHex:=RAWTOHEX(UTL_RAW.CAST_TO_RAW(SUBSTR(vName, i, 1)));
        vEncodedName:=vEncodedName || CHR(65 + ASCII(UTL_RAW.CAST_TO_VARCHAR2(SUBSTR(vHex, 1, 1))));
        vEncodedName:=vEncodedName || CHR(65 + ASCII(UTL_RAW.CAST_TO_VARCHAR2(SUBSTR(vHex, 2, 1))));
    END LOOP;
    IF i_vScope IS NOT NULL THEN
        vEncodedName:=vEncodedName || '.' || i_vScope;
    END IF;
    
    RETURN vEncodedName;
END encodeFirstLevel;

FUNCTION encodeSecondLevel(i_vName IN VARCHAR2) RETURN VARCHAR2
IS
    TvName STR_BY_NUM;
    vEncodedName VARCHAR2(1000);
BEGIN
    TvName:=split(i_vName, '.');
    vEncodedName:=NULL;
    FOR i IN 1..TvName.COUNT
    LOOP
        vEncodedName:=vEncodedName || CHR(LENGTH(TvName(i)));
        vEncodedName:=vEncodedName || TvName(i);
    END LOOP;
    vEncodedName:=vEncodedName || CHR(0);
    RETURN vEncodedName;
    
END encodeSecondLevel;

PROCEDURE SESSION_SERVICE_CALL(i_nOpCode IN PLS_INTEGER, 
                               io_rPayload IN OUT NOCOPY RAW,
                               i_bWaitForAnswer IN BOOLEAN,
                               o_nAnswerCode OUT PLS_INTEGER, 
                               o_rAnswer OUT RAW
                               )
IS
    nCnt PLS_INTEGER;
    rBuffer RAW(4);
    nLength PLS_INTEGER;
BEGIN
    nCnt:=UTL_TCP.WRITE_RAW(xCtx.xCon, UTL_RAW.CONCAT(U16BEToRaw(i_nOpCode * 256 + 0), U16BEToRaw(NVL(UTL_RAW.LENGTH(io_rPayload), 0)), io_rPayload));
    IF i_bWaitForAnswer THEN
        BEGIN
            nCnt:=UTL_TCP.READ_RAW(xCtx.xCon, rBuffer, 4);
            o_nAnswerCode:=UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(rBuffer, 1, 1));
            nLength:=UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(rBuffer, 2));
            IF nLength > 0 THEN
                nCnt:=UTL_TCP.READ_RAW(xCtx.xCon, o_rAnswer, nLength);
            ELSE
                o_rAnswer:=NULL;
            END IF;
        EXCEPTION
            WHEN END_OF_INPUT_REACHED THEN
                o_nAnswerCode:=NULL;
                o_rAnswer:=NULL;
                DBMS_OUTPUT.PUT_LINE('END_OF_INPUT_REACHED');
        END;
    ELSE
        o_nAnswerCode:=NULL;
        o_rAnswer:=NULL;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        Dbg('Payload='||DebugRaw(io_rPayload));
        Dbg('remote_host='||xCtx.xCon.remote_host);
        Dbg('remote_port='||TO_CHAR(xCtx.xCon.remote_port));
        Dbg('local_host='||xCtx.xCon.local_host);
        Dbg('local_port='||TO_CHAR(xCtx.xCon.local_port));
        Dbg('TxFileHandle.COUNT='||TO_CHAR(TxFileHandle.COUNT));
        Dbg(dbms_utility.format_call_stack);
        RAISE;

END SESSION_SERVICE_CALL;

FUNCTION SESSION_REQUEST_CALL(i_vName IN VARCHAR2) RETURN VARCHAR2
IS
    vAnswer VARCHAR2(4000);
    rBufferEmi RAW(4000);
    rBufferRec RAW(32000);
    nAnswerCode PLS_INTEGER;
BEGIN
    rBufferEmi:=UTL_RAW.CONCAT(UTL_RAW.CAST_TO_RAW(encodeSecondLevel(encodeFirstLevel(i_vName, NULL))),
                               UTL_RAW.CAST_TO_RAW(encodeSecondLevel(encodeFirstLevel(vProjectName, NULL))));
    SESSION_SERVICE_CALL(SESSION_REQUEST, rBufferEmi, TRUE, nAnswerCode, rBufferRec);
    CASE nAnswerCode
        WHEN SESSION_RESPONSE_POSITIVE THEN
            vAnswer:='OK';
        WHEN SESSION_RESPONSE_NEGATIVE THEN
            vAnswer:='ERR:' || RawToHex(rBufferRec);   
        WHEN SESSION_RESPONSE_RETARGET THEN
            vAnswer:='REDIRECTED'; -- [A_REVOIR]   
        ELSE
            vAnswer:='ERR:UNEXPECTED';
    END CASE;
    RETURN vAnswer;
END SESSION_REQUEST_CALL;                          

PROCEDURE SESSION_MESSAGE_CALL(io_rMessage IN OUT NOCOPY RAW,
                               o_nAnswerCode OUT PLS_INTEGER, 
                               o_rAnswer OUT RAW)
IS
    vAnswer VARCHAR2(4000);
    nAnswerCode PLS_INTEGER;
BEGIN
    SESSION_SERVICE_CALL(SESSION_MESSAGE, io_rMessage, TRUE, o_nAnswerCode, o_rAnswer);
END SESSION_MESSAGE_CALL;     

FUNCTION SESSION_KEEP_ALIVE_CALL RETURN VARCHAR2
IS
    vAnswer VARCHAR2(4000);
    rBufferEmi RAW(4000);
    rBufferRec RAW(4000);
    nAnswerCode PLS_INTEGER;
BEGIN
    rBufferEmi:=NULL;
    SESSION_SERVICE_CALL(SESSION_KEEP_ALIVE, rBufferEmi,FALSE, nAnswerCode, rBufferRec);
    vAnswer:='OK';
    RETURN vAnswer;

END SESSION_KEEP_ALIVE_CALL;  

PROCEDURE SOCKET_CLOSE
IS
BEGIN
    IF xCtx.bConOpen THEN
        UTL_TCP.close_connection(xCtx.xCon);
    END IF;
    xCtx.bConOpen:=FALSE;

EXCEPTION
    WHEN UNREACHABLE_HOST THEN
    xCtx.bConOpen:=FALSE;   
 
END SOCKET_CLOSE;  

/** Equivalent to the 'nbtstat -a hostname' or 'nbtstat -A IP' :
 *  Shall return a netbios name. 
 *  @param i_vHostName : IP address or hostname. 
 *  @return a netbios name
 *  This is a fake : the real nbtstat uses UDP. not possible with PLSQL. <br>
 *  So, we try to guess netbiosname using DNS. 
 */
FUNCTION nbtstat(i_vHostName IN VARCHAR2) RETURN VARCHAR2
IS
    vIPAddr VARCHAR2(255);
    vName VARCHAR2(255);
    bNameResolution BOOLEAN; 
    bReverseNameResolution BOOLEAN;
    vNetbiosName VARCHAR2(16);
BEGIN
    -- Trying name resolution
    bNameResolution:=FALSE;
    BEGIN
        vIPAddr:=UTL_INADDR.GET_HOST_ADDRESS(i_vHostName);
        IF vIPAddr <> i_vHostName THEN
            bNameResolution:=TRUE;
        END IF;
    EXCEPTION
        WHEN UNKNOWN_HOST THEN
        bNameResolution:=FALSE;
    END;
    -- Trying Reverse Name Resolution
    BEGIN
        vName:=UTL_INADDR.GET_HOST_NAME(i_vHostName);
        bReverseNameResolution:=TRUE;
    EXCEPTION
        WHEN UNKNOWN_HOST THEN
        bReverseNameResolution:=FALSE;
    END;
    vNetbiosName:=NULL;
    IF bReverseNameResolution THEN
        IF LENGTH(vName) <= 16 THEN
            vNetBiosName:=UPPER(vName);
        END IF;
    ELSIF bNameResolution THEN
        IF LENGTH(i_vHostName) <= 16 THEN
            vNetBiosName:=UPPER(i_vHostName);
        END IF;
    END IF;
    RETURN vNetBiosName;
    
END nbtstat;

PROCEDURE SOCKET_OPEN(o_vErr OUT VARCHAR2)
IS
    vNetbiosName VARCHAR2(16);
    vAnswer VARCHAR2(100);
BEGIN
    o_vErr:=NULL;
--    IF xCtx.bConOpen THEN
--        SOCKET_CLOSE;
--    END IF;
    xCtx.bConOpen:=TRUE;
    xCtx.xCon:=UTL_TCP.open_connection(remote_host => xCtx.vHost,
                                       remote_port => xCtx.nPort);
    IF xCtx.nTransportType = TransportType_NBT THEN
        vNetbiosName:=nbtstat(xCtx.vHost);
        IF vNetbiosName IS NULL THEN
            RAISE UNKNOWN_NETBIOS_NAME;
        END IF;
        vAnswer:=(SESSION_REQUEST_CALL(vNetbiosName)); 
    END IF;
EXCEPTION
    WHEN UNREACHABLE_HOST THEN
    o_vErr:=err_UNREACHABLE_HOST;     
    
    WHEN UNKNOWN_HOST THEN
    o_vErr:=err_UNKNOWN_HOST;   
    
    WHEN UNKNOWN_NETBIOS_NAME THEN
    o_vErr:=err_UNKNOWN_NETBIOS_NAME;  
    
    WHEN NETWORK_ACCESS_DENIED_BY_ACL THEN
    o_vErr:=err_NET_ACCESS_DENIED_BY_ACL;
    
    WHEN OTHERS THEN
    o_vErr:=err_CANNOT_CONNECT;                        
        
END SOCKET_OPEN;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ASN1 FUNCTION (ASN1.2)
-------------------------------------------------------------------------------------------------------------------------------------------------------



    
-- BER = Basic Encoding Rule
FUNCTION BER_Length(i_nNoLength IN PLS_INTEGER) RETURN RAW
IS
    nNoLength PLS_INTEGER;
BEGIN
    nNoLength:=NVL(i_nNoLength, 0);
    IF nNoLength < 128 THEN
        RETURN U8ToRaw(nNoLength);
    ELSIF nNoLength < 256 THEN
        RETURN UTL_RAW.CONCAT(U8ToRaw(128 + 1), 
                              U8ToRaw(nNoLength));
    ELSIF nNoLength < 65536 THEN
        RETURN UTL_RAW.CONCAT(U8toRaw(128 + 2),
                              U16BEToRaw(nNoLength));
    ELSE
        RETURN NULL; -- not managed.
    END IF;
END BER_Length;

FUNCTION BER_Length(io_rContent IN OUT NOCOPY RAW, 
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN PLS_INTEGER
IS
    nLength PLS_INTEGER;
BEGIN
    nLength:=RawToU8(io_rContent, io_nPosition);
    IF nLength > 127 THEN
        CASE nLength
            WHEN 129 THEN
                nLength:=RawToU8(io_rContent, io_nPosition);
            WHEN 130 THEN
                nLength:=RawToU16BE(io_rContent, io_nPosition);
            ELSE
                FOR i IN 129..nLength
                LOOP
                    nLength:=RawToU8(io_rContent, io_nPosition);
                END LOOP;
                nLength:=NULL; -- not managed...
        END CASE;
    END IF;
    RETURN nLength;
END BER_Length;

FUNCTION BER_Encode(i_nIdentifier IN PLS_INTEGER,
                    i_xContent IN RAW,
                    i_bUseEndOfContent IN BOOLEAN:=FALSE) RETURN RAW
IS
BEGIN
    IF i_bUseEndOfContent THEN
        RETURN UTL_RAW.CONCAT(U8TORAW(i_nIdentifier), -- Identifier 
                              U8TORAW(length_infinite), -- Length (infinite form)
                              i_xContent, -- Content
                              U16BEToRaw(0)); -- En of Contents octets
    ELSE
        RETURN UTL_RAW.CONCAT(U8TORAW(i_nIdentifier), -- Identifier 
                              BER_Length(UTL_RAW.LENGTH(i_xContent)), -- Length (finite form)
                              i_xContent); -- Content
    END IF;                           
                            
END BER_Encode;     

-- 8.2 Encoding of a boolean value 
FUNCTION Boolean_Encode(i_bValue IN BOOLEAN) RETURN RAW
IS
    nValue PLS_INTEGER;
BEGIN
    IF i_bValue THEN
        nValue:=255;
    ELSE
        nValue:=0;
    END IF;
     RETURN BER_Encode(tag_Universal + tag_Primitive + tag_Boolean, U8TORAW(nValue));
END Boolean_Encode;
 
-- 8.6 Encoding of a bitstring value
FUNCTION BitString_Encode(i_xContent IN RAW) RETURN RAW
IS
BEGIN
    RETURN BER_Encode(tag_Universal + tag_Primitive + tag_BitString, i_xContent);
END BitString_Encode;

-- 8.7 Encoding of an octetstring value
FUNCTION OctetString_Encode(i_xContent IN RAW) RETURN RAW
IS
BEGIN
    RETURN BER_Encode(tag_Universal + tag_Primitive + tag_OctetString, i_xContent);
END OctetString_Encode; 

-- 8.8 Encoding of a null value
FUNCTION Null_Encode RETURN RAW
IS
BEGIN
    RETURN BER_Encode(tag_Universal + tag_Primitive + tag_NULL, NULL);
END Null_Encode;

-- 8.9 Encoding of a sequence value
FUNCTION Sequence_Encode(i_xBer1 IN RAW,
                         i_xBer2 IN RAW:=NULL,
                         i_xBer3 IN RAW:=NULL,
                         i_xBer4 IN RAW:=NULL,
                         i_xBer5 IN RAW:=NULL,
                         i_xBer6 IN RAW:=NULL,
                         i_xBer7 IN RAW:=NULL,
                         i_xBer8 IN RAW:=NULL,
                         i_xBer9 IN RAW:=NULL,
                         i_xBer10 IN RAW:=NULL) RETURN RAW
IS
BEGIN 
    RETURN BER_Encode(tag_Universal + tag_Constructed + tag_Sequence, UTL_RAW.CONCAT(i_xBer1, i_xBer2, i_xBer3, i_xBer4, i_xBer5, i_xBer6, i_xBer7, i_xBer8, i_xBer9, i_xBer10));
END Sequence_Encode;

PROCEDURE BER_Decode(io_rContent IN OUT NOCOPY RAW, 
                     io_nStart IN OUT PLS_INTEGER,
                     o_nIdentifier OUT PLS_INTEGER, 
                     o_nLength OUT PLS_INTEGER)
IS
    
BEGIN
    o_nIdentifier:=RawToU8(io_rContent, io_nStart);
    o_nLength:=BER_LENGTH(io_rContent, io_nStart);
END BER_Decode;     
-------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- UTL FUNCTION (UTL.2)
-------------------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE Dbg(i_vString IN VARCHAR2)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(i_vString);
END Dbg;

FUNCTION bool2char(i_bBoolean IN BOOLEAN) RETURN VARCHAR2
IS
BEGIN
    IF i_bBoolean THEN
        RETURN 'true';
    ELSIF NOT(i_bBoolean) THEN
        RETURN 'false';
    ELSE
        RETURN 'null';
    END IF;
END bool2char;

FUNCTION split(i_vStringToSplit IN VARCHAR2, 
               i_vSeparator IN VARCHAR2) RETURN STR_BY_NUM
IS
    vString VARCHAR2(32000);
    TvStrings STR_BY_NUM;
    nPos PLS_INTEGER;
BEGIN
    vString:=i_vStringToSplit;
    LOOP
        EXIT WHEN vString IS NULL;
        nPos:=INSTR(vString, i_vSeparator);
        IF nPos = 0 THEN
            TvStrings(TvStrings.COUNT + 1):=vString;
            vString:=NULL;
        ELSE
            TvStrings(TvStrings.COUNT + 1):=SUBSTR(vString, 1, nPos - 1);
            vString:=SUBSTR(vString, nPos + LENGTH(i_vSeparator));
        END IF;
    END LOOP;
    RETURN TvStrings;
END split;

FUNCTION replace_one(i_vString IN VARCHAR2, 
                     i_vOldPattern IN VARCHAR2, 
                     i_vNewPattern IN VARCHAR2) RETURN VARCHAR2
IS
    nPos PLS_INTEGER;
BEGIN
    nPos:=INSTR(i_vString, i_vOldPattern);
    IF nPos = 0 THEN
        RETURN i_vString;
    ELSE
        RETURN SUBSTR(SUBSTR(i_vString, 1, nPos - 1) || i_vNewPattern || SUBSTR(i_vString, nPos + LENGTH(i_vOldPattern)), 1, 32767);
    END IF;
END replace_one;                     
                     

FUNCTION U32LEToRaw(i_nU32LE IN U32LE) RETURN RAW
IS
BEGIN
    RETURN ULONGToRaw(i_nU32LE);
END U32LEToRaw; 

FUNCTION U32BEToRaw(i_nU32BE IN U32BE) RETURN RAW
IS
    n1 U32BE;
    n2 U32BE;
BEGIN
    n1:=MOD(i_nU32BE, 65536);
    n2:=TRUNC(i_nU32BE / 65536);
    RETURN UTL_RAW.CONCAT(
        U16BEToRaw(n2), 
        U16BEToRaw(n1));
END U32BEToRaw; 

FUNCTION RawToU32BE(i_rSMBMessage IN OUT NOCOPY RAW,
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U32BE
IS                 
    nPosition PLS_INTEGER:=io_nPosition;
    n U32BE;
BEGIN
    io_nPosition:=io_nPosition + 4;
    n:=UTL_RAW.CAST_TO_BINARY_INTEGER(RAW_SUBSTR(i_rSMBMessage, nPosition, 4), UTL_RAW.BIG_ENDIAN);
    IF n < 0 THEN
        n:=n + 4294967296;
    END IF;
    RETURN n;
END RawToU32BE;

FUNCTION RawToU32LE(i_rSMBMessage IN OUT NOCOPY RAW,
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U32LE
IS
BEGIN
    RETURN RawToULONG(i_rSMBMessage, io_nPosition);
END RawToU32LE;

FUNCTION U16LEToRaw(i_nU16LE IN U16LE) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.SUBSTR(UTL_RAW.CAST_FROM_BINARY_INTEGER(NVL(i_nU16LE, 0), UTL_RAW.LITTLE_ENDIAN), 1, 2);
END U16LEToRaw;

FUNCTION U16BEToRaw(i_nU16BE IN U16BE) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.SUBSTR(UTL_RAW.CAST_FROM_BINARY_INTEGER(NVL(i_nU16BE, 0), UTL_RAW.BIG_ENDIAN), -2);
END U16BEToRaw;


FUNCTION RawToU16LE(i_rSMBMessage IN OUT NOCOPY RAW, 
                     io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U16LE
IS
    nPosition PLS_INTEGER:=io_nPosition;
BEGIN
    io_nPosition:=io_nPosition + 2;
    RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(i_rSMBMessage, nPosition, 2), UTL_RAW.LITTLE_ENDIAN);
END RawToU16LE;

FUNCTION RawToU16BE(i_rSMBMessage IN OUT NOCOPY RAW, 
                     io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U16BE
IS
    nPosition PLS_INTEGER:=io_nPosition;
BEGIN
    io_nPosition:=io_nPosition + 2;
    RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(i_rSMBMessage, nPosition, 2), UTL_RAW.BIG_ENDIAN);
END RawToU16BE;         

FUNCTION U8ToRaw(i_nCHAR IN U8) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CAST_TO_RAW(CHR(NVL(i_nCHAR, 0)));
END U8ToRaw;

FUNCTION RawToU8(i_rSMBMessage IN OUT NOCOPY RAW, 
                     io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN U8
IS
    nPosition PLS_INTEGER:=io_nPosition;
BEGIN
    io_nPosition:=io_nPosition + 1;
    RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(i_rSMBMessage, nPosition, 1));
END RawToU8;  

FUNCTION DebugRaw(i_rRaw IN RAW) RETURN VARCHAR2
IS
    nBytesPerRow CONSTANT PLS_INTEGER:=16;
    nNbRow PLS_INTEGER;
    rPieceOfRaw RAW(32);
    nPieceSize PLS_INTEGER;
    nLen PLS_INTEGER;
    vDebug VARCHAR2(32000);
    vLeft VARCHAR2(10);
    vCenter VARCHAR2(1000);
    vRight VARCHAR2(100);
    rChar RAW(1);
    nPad PLS_INTEGER;
    nPad2 PLS_INTEGER;
BEGIN
    vDebug:=NULL;
    nNbRow:=NVL(CEIL(UTL_RAW.LENGTH(i_rRaw) / nBytesPerRow), 0);
    FOR i IN 1..nNbRow
    LOOP
        IF i < nNbRow THEN
            nLen:=nBytesPerRow;
        ELSE
            nLen:=NULL;
        END IF;
        rPieceOfRaw:=UTL_RAW.SUBSTR(i_rRaw, (i - 1) * nBytesPerRow + 1, nLen); 
        IF vDebug IS NOT NULL THEN
            vDebug:=vDebug || CHR(13);
        END IF;
        vCenter:=NULL;
        vRight:=NULL;
        nPieceSize:=UTL_RAW.LENGTH(rPieceOfRaw);
        nPad2:=2;
        FOR j IN 1..nPieceSize
        LOOP
            IF j - 1 = nBytesPerRow / 2 THEN
                vCenter:=vCenter || ' - ';
                nPad2:=0;
                vRight:=vRight || '-';
            ELSIF j > 1 THEN
                vCenter:=vCenter || ' ';
            END IF;
            rChar:=UTL_RAW.SUBSTR(rPieceOfRaw, j, 1);
            vCenter:=vCenter || RawToHex(rChar);
            IF ASCII(UTL_RAW.CAST_TO_VARCHAR2(rChar)) BETWEEN 32 AND 127 THEN
                vRight:=vRight || UTL_RAW.CAST_TO_VARCHAR2(rChar);
            ELSE
                vRight:=vRight || '.';
            END IF;
        END LOOP;
        IF i = nNbRow THEN
            nPad:=nBytesPerRow - nPieceSize;
            IF nPad > 0 THEN
                vCenter:=vCenter || RPAD(' ', (3 * nPad) + nPad2, ' ');
            END IF;
        END IF;
        vLeft:=RawToHex(UTL_RAW.SUBSTR(UTL_RAW.CAST_FROM_BINARY_INTEGER(NVL((i - 1) * nBytesPerRow, 0), UTL_RAW.BIG_ENDIAN), -2));
        vDebug:=vDebug || vLeft || ' - ' || vCenter || ' ' || vRight;
    END LOOP;
    RETURN vDebug;
END DebugRaw;


FUNCTION get_database_charset RETURN VARCHAR2
IS
    
BEGIN
    IF vDatabaseCharset IS NULL THEN
        SELECT value 
        INTO vDatabaseCharset
        FROM nls_database_parameters  
        WHERE parameter = 'NLS_CHARACTERSET';
    END IF;
    RETURN vDatabaseCharset;
END get_database_charset;

FUNCTION get_database_n_charset RETURN VARCHAR2
IS
    
BEGIN
    IF vDatabaseNCharset IS NULL THEN
        SELECT value 
        INTO vDatabaseNCharset
        FROM nls_database_parameters  
        WHERE parameter = 'NLS_NCHAR_CHARACTERSET';
    END IF;
    RETURN vDatabaseNCharset;
END get_database_n_charset;

FUNCTION get_oracle_version RETURN PLS_INTEGER
IS
    nVersion PLS_INTEGER;
    vVersion VARCHAR2(100);
    vCompatibility VARCHAR2(100);
BEGIN   
    DBMS_UTILITY.DB_VERSION (vVersion, vCompatibility);
    nVersion:=TO_NUMBER(SUBSTR(vVersion, 1, INSTR(vVersion, '.') - 1));
    RETURN nVersion;
END get_oracle_version;

/** Set or unset a bit into a raw value 
 *   @param  io_rValue value into which the bit will be set or unset
 *   @param  i_rBitMask bit mask : 1 = bit0 ; 2 = bit1 ; 4 = bit2 ; etc.
 *   @param  i_bValue : true = set ; false = unset ; null = do not change
 */
PROCEDURE SET_BIT(io_rValue IN OUT NOCOPY RAW, i_rBitMask IN RAW, i_bValue IN BOOLEAN)
IS
BEGIN
    CASE i_bValue
        WHEN TRUE THEN
            io_rValue:=UTL_RAW.BIT_OR(io_rValue, i_rBitMask);
        WHEN FALSE THEN
            io_rValue:=UTL_RAW.BIT_AND(io_rValue, UTL_RAW.BIT_COMPLEMENT(i_rBitMask));
        ELSE
            NULL;
    END CASE;
END SET_BIT;

PROCEDURE NewDoc(o_xDoc OUT DOMDoc, 
                 o_xRoot OUT DOMNode, 
                 i_vEncoding VARCHAR2:=NULL)
IS
    xProcIns Dbms_XmlDom.DOMProcessingInstruction;
    xNodeProcIns DOMNode;
BEGIN
    o_xDoc:=Dbms_XmlDom.NewDomDocument;
    vXMLEncoding:=i_vEncoding;
    IF i_vEncoding IS NOT NULL THEN
        xProcIns:=Dbms_XmlDom.CreateProcessingInstruction(o_xDoc, 'xml', 'version="1.0" encoding="' || i_vEncoding || '"');
        xNodeProcIns:=Dbms_XmlDom.AppendChild(Dbms_XmlDom.MakeNode(o_xDoc), dbms_xmldom.MakeNode(xProcIns));
    END IF;
    o_xRoot:=Dbms_XmlDom.makeNode(o_xDoc);
END NewDoc;

FUNCTION AddNode(i_xParentNode DOMNode, 
                 i_vTag VARCHAR2, 
                 i_vValue VARCHAR2:=NULL,
                 i_vAttribute1 VARCHAR2:=NULL,
                 i_vAttrValue1 VARCHAR2:=NULL,
                 i_vAttribute2 VARCHAR2:=NULL,
                 i_vAttrValue2 VARCHAR2:=NULL,
                 i_vAttribute3 VARCHAR2:=NULL,
                 i_vAttrValue3 VARCHAR2:=NULL,
                 i_vAttribute4 VARCHAR2:=NULL,
                 i_vAttrValue4 VARCHAR2:=NULL,
                 i_vAttribute5 VARCHAR2:=NULL,
                 i_vAttrValue5 VARCHAR2:=NULL) RETURN DOMNode
IS
    xDoc DOMDoc;
    xNode DOMNode;
    xNodeValue DOMNode;
    vNS VARCHAR2(1000);
    vTag VARCHAR2(1000);
    xNodeAttr DOMNode;
    FUNCTION CharConvertOut(i_vValue VARCHAR2) RETURN VARCHAR2
    IS
        vValue VARCHAR2(32000);
    BEGIN
        vValue:=i_vValue;
    --    vValue:=DBMS_XMLGEN.CONVERT (i_vValue, DBMS_XMLGEN.ENTITY_ENCODE);
        IF vXMLEncoding = 'UTF-8' THEN
            RETURN CONVERT(vValue, 'UTF8');
        ELSE
            RETURN vValue;
        END IF;
    END CharConvertOut;    
BEGIN
    xDoc:=DBMS_XMLDOM.GETOWNERDOCUMENT(i_xParentNode);
	vNS:=LTRIM(SUBSTR(i_vTag, 1, INSTR(i_vTag, ':') - 1), '@');
	IF SUBSTR(i_vTag, 1, 1) = '@' THEN
    	IF i_vValue IS NOT NULL THEN
	        Dbms_XmlDom.setAttribute(Dbms_XmlDom.MakeElement(i_xParentNode), SUBSTR(i_vTag, 2), CharConvertOut(i_vValue), vNS);
        END IF;
    ELSE
        xNode:=Dbms_XmlDom.appendChild(i_xParentNode, Dbms_XmlDom.makeNode(Dbms_XmlDom.createElement(xDoc, i_vTag)));
        IF i_vValue IS NOT NULL THEN
            xNodeValue:=Dbms_XmlDom.appendChild(xNode, Dbms_XmlDom.MakeNode(Dbms_XmlDom.createTextNode(xDoc, CharConvertOut(i_vValue)))); 
        END IF;
    END IF;
    IF i_vAttribute1 IS NOT NULL THEN
        xNodeAttr:=AddNode(xNode, i_vAttribute1, i_vAttrValue1);
    END IF;
    IF i_vAttribute2 IS NOT NULL THEN
        xNodeAttr:=AddNode(xNode, i_vAttribute2, i_vAttrValue2);
    END IF;
    IF i_vAttribute3 IS NOT NULL THEN
        xNodeAttr:=AddNode(xNode, i_vAttribute3, i_vAttrValue3);
    END IF;
    IF i_vAttribute4 IS NOT NULL THEN
        xNodeAttr:=AddNode(xNode, i_vAttribute4, i_vAttrValue4);
    END IF;
    IF i_vAttribute5 IS NOT NULL THEN
        xNodeAttr:=AddNode(xNode, i_vAttribute5, i_vAttrValue5);
    END IF;
    
	RETURN xNode;	
END AddNode;


FUNCTION MD4(i_rRaw IN RAW) RETURN RAW
IS
    rMessage RAW(32000);
    nMsgLength PLS_INTEGER;
    A PLS_INTEGER:=UTL_RAW.CAST_TO_BINARY_INTEGER(HexToRaw('01234567'), UTL_RAW.LITTLE_ENDIAN);
    B PLS_INTEGER:=UTL_RAW.CAST_TO_BINARY_INTEGER(HexToRaw('89ABCDEF'), UTL_RAW.LITTLE_ENDIAN);
    C PLS_INTEGER:=UTL_RAW.CAST_TO_BINARY_INTEGER(HexToRaw('FEDCBA98'), UTL_RAW.LITTLE_ENDIAN);
    D PLS_INTEGER:=UTL_RAW.CAST_TO_BINARY_INTEGER(HexToRaw('76543210'), UTL_RAW.LITTLE_ENDIAN);
    AA PLS_INTEGER;
    BB PLS_INTEGER;
    CC PLS_INTEGER;
    DD PLS_INTEGER;
    n NUMBER;
    X RAW(64);
    FUNCTION NumToInt32(i_nNumber IN NUMBER) RETURN PLS_INTEGER
    IS
       n NUMBER;
    BEGIN
        -- [A REVOIR ] laborieux !!!
        n:=MOD(i_nNumber, 4294967296);
        IF n < 0 THEN
            n:=n + 4294967296;
        END IF; 
        n:=MOD(n,  4294967296);
        IF n > 2147483647 THEN
            n:=n - 4294967296;
        END IF;
        RETURN n;
    END NumToInt32;
    FUNCTION Int32ToNum(i_nInput IN PLS_INTEGER) RETURN NUMBER
    IS
        nOut NUMBER;
    BEGIN
        nOut:=i_nInput;
        IF nOut < 0 THEN
            nOut:=nOut + 4294967296;
        END IF; 
        RETURN nOut;
    END Int32ToNum;
    FUNCTION ShiftRight(i_nInput IN PLS_INTEGER, 
                                          i_nNbBitsToRotate IN PLS_INTEGER) RETURN PLS_INTEGER
    IS
    BEGIN
        IF i_nNbBitsToRotate = 0 THEN
            RETURN i_nInput;
        ELSE
            RETURN NumToInt32(TRUNC(Int32ToNum(i_nInput) / POWER(2, i_nNbBitsToRotate)));
        END IF;
    END ShiftRight;
    FUNCTION ShiftLeft(i_nInput IN PLS_INTEGER, 
                                         i_nNbBitsToRotate IN PLS_INTEGER) RETURN PLS_INTEGER
    IS
     BEGIN
        IF i_nNbBitsToRotate = 0 THEN
            RETURN i_nInput;
        ELSE
            RETURN NumToInt32(i_nInput * POWER(2, i_nNbBitsToRotate));
        END IF;
    END ShiftLeft;    
    FUNCTION RotateLeft(i_nInput IN PLS_INTEGER, 
                                          i_nNbBitsToRotate IN PLS_INTEGER) RETURN PLS_INTEGER
    IS
    BEGIN
        RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.BIT_OR(UTL_RAW.CAST_FROM_BINARY_INTEGER(ShiftLeft(i_nInput, i_nNbBitsToRotate)), UTL_RAW.CAST_FROM_BINARY_INTEGER(ShiftRight(i_nInput, 32 - i_nNbBitsToRotate))));
    END RotateLeft;
    FUNCTION F(i_rX IN RAW, i_rY IN RAW, i_rZ IN RAW) RETURN RAW
    IS
    BEGIN
        RETURN UTL_RAW.BIT_OR(UTL_RAW.BIT_AND(UTL_RAW.BIT_COMPLEMENT(i_rX), i_rZ), UTL_RAW.BIT_AND(i_rX, i_rY));
    END F;
    FUNCTION G(i_rX IN RAW, i_rY IN RAW, i_rZ IN RAW) RETURN RAW
    IS
    BEGIN
        RETURN UTL_RAW.BIT_OR(UTL_RAW.BIT_OR(UTL_RAW.BIT_AND(i_rX, i_rY), UTL_RAW.BIT_AND(i_rX, i_rZ)), UTL_RAW.BIT_AND(i_rY, i_rZ));
    END G;
    FUNCTION H(i_rX IN RAW, i_rY IN RAW, i_rZ IN RAW) RETURN RAW
    IS
    BEGIN
        RETURN UTL_RAW.BIT_XOR(i_rX, UTL_RAW.BIT_XOR(i_rY, i_rZ));
    END H;
    PROCEDURE FF(io_nA IN OUT PLS_INTEGER, i_nB IN PLS_INTEGER, i_nC IN PLS_INTEGER, i_nD IN PLS_INTEGER, i_nK IN PLS_INTEGER, i_nS IN PLS_INTEGER, X IN OUT NOCOPY RAW)
    IS
        n NUMBER;
    BEGIN
        n:=io_nA;
        n:=NumToInt32(n + UTL_RAW.CAST_TO_BINARY_INTEGER(F(UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nB), UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nC), UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nD))));
        n:=NumToInt32(n + UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(X, i_nK * 4 + 1, 4), UTL_RAW.LITTLE_ENDIAN));
        n:=NumToInt32(n);
        io_nA:=RotateLeft(n, i_nS);
     END FF;
    PROCEDURE GG(io_nA IN OUT PLS_INTEGER, i_nB IN PLS_INTEGER, i_nC IN PLS_INTEGER, i_nD IN PLS_INTEGER, i_nK IN PLS_INTEGER, i_nS IN PLS_INTEGER, X IN OUT NOCOPY RAW)
    IS
        n NUMBER;
    BEGIN
   
        n:=io_nA;
        n:=n + UTL_RAW.CAST_TO_BINARY_INTEGER(G(UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nB), UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nC), UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nD)));
        n:=n + UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(X, i_nK * 4 + 1, 4), UTL_RAW.LITTLE_ENDIAN);
        n:=n + UTL_RAW.CAST_TO_BINARY_INTEGER(HexToRaw('5A827999'));
        n:=NumToInt32(n);
        io_nA:=RotateLeft(n, i_nS);
    END GG;
    PROCEDURE HH(io_nA IN OUT PLS_INTEGER, i_nB IN PLS_INTEGER, i_nC IN PLS_INTEGER, i_nD IN PLS_INTEGER, i_nK IN PLS_INTEGER, i_nS IN PLS_INTEGER, X IN OUT NOCOPY RAW)
    IS
        n NUMBER;
    BEGIN
        n:=io_nA;
        n:=n + UTL_RAW.CAST_TO_BINARY_INTEGER(H(UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nB), UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nC), UTL_RAW.CAST_FROM_BINARY_INTEGER(i_nD)));
        n:=n + UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(X, i_nK * 4 + 1, 4), UTL_RAW.LITTLE_ENDIAN);
        n:=n + UTL_RAW.CAST_TO_BINARY_INTEGER(HexToRaw('6ED9EBA1'));
        n:=NumToInt32(n);
        io_nA:=RotateLeft(n, i_nS);
    END HH;
    FUNCTION copies(i_rRaw RAW, 
                    i_nLength IN PLS_INTEGER) RETURN RAW
    IS
    BEGIN
        IF i_nLength = 0 THEN
            RETURN NULL;
        ELSE
            RETURN UTL_RAW.copies(i_rRaw, i_nLength);
        END IF;
    END copies;
BEGIN
    nMsgLength:=NVL(UTL_RAW.LENGTH(i_rRaw), 0);
    rMessage:=i_rRaw || 
              HexToRAW('80') || 
              copies(HexToRAW('00'), MOD(120 - MOD(nMsgLength + 1, 64), 64)) || 
              UTL_RAW.CAST_FROM_BINARY_INTEGER(nMsgLength * 8, UTL_RAW.LITTLE_ENDIAN) ||
              HexToRaw('00000000');
    FOR i IN 1..UTL_RAW.LENGTH(rMessage) / 64
    LOOP
        X:=UTL_RAW.SUBSTR(rMessage, (i - 1) * 64 + 1, 64);
         AA:=A; BB:=B; CC:=C; DD:=D;
        -- Round 1
        FF(A, B, C, D, 0, 3, X);       FF(D, A, B, C, 1, 7, X);       FF(C, D, A, B, 2, 11, X);      FF(B, C, D, A, 3, 19, X);        
        FF(A, B, C, D, 4, 3, X);       FF(D, A, B, C, 5, 7, X);       FF(C, D, A, B, 6, 11, X);      FF(B, C, D, A, 7, 19, X);
        FF(A, B, C, D, 8, 3, X);       FF(D, A, B, C, 9, 7, X);       FF(C, D, A, B, 10, 11, X);     FF(B, C, D, A, 11, 19, X);
        FF(A, B, C, D, 12, 3, X);      FF(D, A, B, C, 13, 7, X);      FF(C, D, A, B, 14, 11, X);     FF(B, C, D, A, 15, 19, X);
        -- Round 2
        GG(A, B, C, D, 0, 3, X);       GG(D, A, B, C, 4, 5, X);       GG(C, D, A, B, 8, 9, X);       GG(B, C, D, A, 12, 13, X);
        GG(A, B, C, D, 1, 3, X);       GG(D, A, B, C, 5, 5, X);       GG(C, D, A, B, 9, 9, X);       GG(B, C, D, A, 13, 13, X);
        GG(A, B, C, D, 2, 3, X);       GG(D, A, B, C, 6, 5, X);       GG(C, D, A, B, 10, 9, X);      GG(B, C, D, A, 14, 13, X);
        GG(A, B, C, D, 3, 3, X);       GG(D, A, B, C, 7, 5, X);       GG(C, D, A, B, 11, 9, X);      GG(B, C, D, A, 15, 13, X);
        -- Round 3
        HH(A, B, C, D, 0, 3, X);       HH(D, A, B, C, 8, 9, X);       HH(C, D, A, B, 4, 11, X);      HH(B, C, D, A, 12, 15, X);
        HH(A, B, C, D, 2, 3, X);       HH(D, A, B, C, 10, 9, X);      HH(C, D, A, B, 6, 11, X);      HH(B, C, D, A, 14, 15, X);
        HH(A, B, C, D, 1, 3, X);       HH(D, A, B, C, 9, 9, X);       HH(C, D, A, B, 5, 11, X);      HH(B, C, D, A, 13, 15, X);
        HH(A, B, C, D, 3, 3, X);       HH(D, A, B, C, 11, 9, X);      HH(C, D, A, B, 7, 11, X);      HH(B, C, D, A, 15, 15, X);
        n:=A; A:=NumToInt32(n + AA);
        n:=B; B:=NumToInt32(n + BB);
        n:=C; C:=NumToInt32(n + CC);
        n:=D; D:=NumToInt32(n + DD);
     END LOOP;
    RETURN UTL_RAW.CAST_FROM_BINARY_INTEGER(A, UTL_RAW.LITTLE_ENDIAN) ||
           UTL_RAW.CAST_FROM_BINARY_INTEGER(B, UTL_RAW.LITTLE_ENDIAN) ||
           UTL_RAW.CAST_FROM_BINARY_INTEGER(C, UTL_RAW.LITTLE_ENDIAN) ||
           UTL_RAW.CAST_FROM_BINARY_INTEGER(D, UTL_RAW.LITTLE_ENDIAN);
END MD4;
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- SPNEGO FUNCTION [SPENGO.2]
-------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION OIDToRaw(i_vOID OID) RETURN RAW
IS
    -- http://msdn.microsoft.com/en-us/library/ms995330.aspx
    TvDigits STR_BY_NUM;
    nDigit PLS_INTEGER;
    nDigitHigh PLS_INTEGER;
    nDigitLow PLS_INTEGER;
    rOneDigit RAW(5);
    nLastDigit PLS_INTEGER;
    rOID RAW(100);
    NOT_AN_OID EXCEPTION;
BEGIN
    rOID:=NULL;
    TvDigits:=Split(i_vOID, '.');
    IF TvDigits.COUNT < 2 THEN
        RAISE NOT_AN_OID;
    END IF;
    nDigit:=TO_NUMBER(TvDigits(1)) * 40 + TO_NUMBER(TvDigits(2));
    rOID:=U8ToRaw(nDigit);
    FOR i IN 3..TvDigits.COUNT
    LOOP
        rOneDigit:=NULL;
        nLastDigit:=0;
        nDigit:=TO_NUMBER(TvDigits(i));
        LOOP
            nDigitHigh:=TRUNC(nDigit / 128);
            nDigitLow:=MOD(nDigit, 128);
            rOneDigit:=UTL_RAW.CONCAT(U8ToRaw(nDigitLow + nLastDigit), rOneDigit);
            nLastDigit:=128;
            nDigit:=nDigitHigh;
            EXIT WHEN nDigit = 0;
        END LOOP;
        rOID:=UTL_RAW.CONCAT(rOID, rOneDigit);
    END LOOP;
    rOID:=UTL_RAW.CONCAT(U8ToRaw(tag_ObjectIdentifier), -- OID (Object Identifier)
                         BER_LENGTH(UTL_RAW.LENGTH(rOID)), -- Size
                         rOID);
    RETURN rOID;
    
EXCEPTION
    WHEN NOT_AN_OID THEN
    RETURN NULL;
    
END OIDToRaw;

FUNCTION RawToOID(io_rRawOID IN OUT NOCOPY RAW) RETURN OID
IS
    nStart PLS_INTEGER;
    nLength PLS_INTEGER;
    nIdentifier PLS_INTEGER;
    vOID OID;
    nByte PLS_INTEGER;
    nDigit PLS_INTEGER;
BEGIN
    vOID:=NULL;
    nStart:=1;
    BER_DECODE(io_rRawOID, nStart, nIdentifier, nLength);
    IF nIdentifier = tag_ObjectIdentifier THEN
        nByte:=RAWTOU8(io_rRawOID, nStart);
        vOID:=TO_CHAR(TRUNC(nByte / 40)) || '.' || TO_CHAR(MOD(nByte, 40));
        nDigit:=0;
        FOR i IN 1..nLength - 1
        LOOP
            nByte:=RAWTOU8(io_rRawOID, nStart);
            nDigit:=nDigit * 128 + BITAND(nByte, 127);
            IF BITAND(nByte, 128) = 0 THEN
                vOID:=vOID || '.' || TO_CHAR(nDigit);
                nDigit:=0;
             END IF;
        END LOOP;
    END IF;
    RETURN vOID;
END RawToOID;

FUNCTION Encode_NegTokenInit(i_TxMechTypeList IN MechTypeList,
                             i_rMechToken IN RAW) RETURN RAW
IS
    rNegTokenInit RAW(1000);
BEGIN
    rNegTokenInit:=NULL;
    FOR i IN 1..i_TxMechTypeList.COUNT
    LOOP
        rNegTokenInit:=UTL_RAW.CONCAT(rNegTokenInit, OIDToRaw(i_TxMechTypeList(i)));
    END LOOP;
    rNegTokenInit:=Sequence_Encode(rNegTokenInit);
    rNegTokenInit:=UTL_RAW.CONCAT(
        BER_Encode(tag_CSC + 0, rNegTokenInit),
        BER_Encode(tag_CSC + 2, i_rMechToken));
    rNegTokenInit:=Sequence_Encode(rNegTokenInit);
    RETURN rNegTokenInit;
END Encode_NegTokenInit;

FUNCTION Decode_negTokenResp(i_rNegTokenResp IN OUT NOCOPY RAW) RETURN negTokenResp
IS
    xNegTokenResp negTokenResp;
    nStart PLS_INTEGER;
    nLength PLS_INTEGER;
    nIdentifier PLS_INTEGER;
    rOID RAW(100);
BEGIN
    xNegTokenResp:=NULL;
    nStart:=1;
    BER_DECODE(i_rNegTokenResp, nStart, nIdentifier, nLength);
    IF nIdentifier = tag_Context_specific + tag_Constructed + 1 THEN
        BER_DECODE(i_rNegTokenResp, nStart, nIdentifier, nLength);
        IF nIdentifier = tag_Constructed + tag_Sequence THEN
            BER_DECODE(i_rNegTokenResp, nStart, nIdentifier, nLength);
            IF nIdentifier = tag_Context_specific + tag_Constructed + 0 THEN
                BER_DECODE(i_rNegTokenResp, nStart, nIdentifier, nLength);
                IF  nIdentifier = tag_Enumerate THEN
                    xNegTokenResp.nNegState:=RAWTOU8(i_rNegTokenResp, nStart);
                    nStart:=nStart - 1; 
                END IF;
            END IF;
            nStart:=nStart + nLength;
            BER_DECODE(i_rNegTokenResp, nStart, nIdentifier, nLength);
            IF nIdentifier = tag_Context_specific + tag_Constructed + 1 THEN
                rOID:=UTL_RAW.SUBSTR(i_rNegTokenResp, nStart, nLength);
                xNegTokenResp.xSupportedMech:=RawToOID(rOID);
            END IF;
            nStart:=nStart + nLength;
            BER_DECODE(i_rNegTokenResp, nStart, nIdentifier, nLength);
            IF nIdentifier = tag_Context_specific + tag_Constructed + 2 THEN
                BER_DECODE(i_rNegTokenResp, nStart, nIdentifier, nLength);
                IF nIdentifier = tag_OctetString THEN
                    xNegTokenResp.rResponseToken:=UTL_RAW.SUBSTR(i_rNegTokenResp, nStart, nLength);
                END IF;
            END IF;
             nStart:=nStart + nLength;
        END IF;
    END IF;
    
    RETURN xNegTokenResp;
END Decode_negTokenResp;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- NTLM FUNCTION [NTLM.2]
-------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION negotiate(i_vDomain IN VARCHAR2,
                   i_vWorkstation IN VARCHAR2) RETURN RAW
IS
    nFlag ULONG;
BEGIN
--    nFlag:=Negotiate_Unicode + Negotiate_OEM + Request_Target + Negotiate_NTLM + Negotiate_Always_Sign + Negotiate_NTLM2_Key + Negotiate_128 + Negotiate_56
--                             + Negotiate_Domain_Supplied + Negotiate_Workstation_Supplied;
--    nFlag:=Negotiate_Unicode + Request_Target + Negotiate_NTLM + Negotiate_Always_Sign + Negotiate_NTLM2_Key + Negotiate_128 + Negotiate_Sign;-- + Negotiate_Key_Exchange;
    nFlag:=Negotiate_Unicode + Request_Target + Negotiate_NTLM + Negotiate_Always_Sign + Negotiate_128 + Negotiate_Sign;-- + Negotiate_Key_Exchange;

--nFlag:=-(Negotiate_56);
--RETURN ULONGToRaw(nFlag);

    RETURN UTL_RAW.CONCAT(UTL_RAW.CAST_TO_RAW(vNTLMSSP_SIGNATURE), -- Signature
                          ULONGToRaw(NTLMSSP_NEGOTIATE), -- Type 1 Indicator
                          ULONGToRaw(nFlag), -- Flags
                          USHORTToRaw(LENGTH(i_vDomain)), -- Domain Length
                          USHORTToRaw(LENGTH(i_vDomain)), -- Domain Max Length
                          ULONGToRaw(32), -- Domain Offset
                          USHORTToRaw(LENGTH(i_vWorkstation)), -- Workstation Length
                          USHORTToRaw(LENGTH(i_vWorkstation)), -- Workstation Max Length
                          ULONGToRaw(32 + LENGTH(i_vDomain)), -- Workstation Offset
                          UTL_RAW.CAST_TO_RAW(i_vDomain),
                          UTL_RAW.CAST_TO_RAW(i_vWorkstation));
                          
                          
END negotiate;

FUNCTION decode_challenge(io_rRawMsg2 IN OUT NOCOPY RAW) RETURN NTLMMessage
IS
    xNTLMMessage NTLMMessage;
    nStart PLS_INTEGER;
    nBufferLength PLS_INTEGER;
    nBufferOffset PLS_INTEGER;
    
BEGIN
    IF UTL_RAW.CAST_TO_VARCHAR2(UTL_RAW.SUBSTR(io_rRawMsg2, 1, 8)) = vNTLMSSP_SIGNATURE THEN
        nStart:=9;
        xNTLMMessage.nMsgType:=RawToU32LE(io_rRawMsg2, nStart);
        nBufferLength:=RawToU16LE(io_rRawMsg2, nStart);
        nStart:=nStart + 2;
        nBufferOffset:=RawToU32LE(io_rRawMsg2, nStart);
        nBufferOffset:=nBufferOffset + 1; -- ???
        -- [A_REVOIR] unicode (peut-être toujours en unicode ??)
        xNTLMMessage.vTargetName:=convert( RawToFixedLengthString(io_rRawMsg2, nBufferOffset, nBufferLength), get_database_charset, 'AL16UTF16LE');
        xNTLMMessage.nFlags:=RawToU32LE(io_rRawMsg2, nStart);
        xNTLMMessage.rServerChallenge:=UTL_RAW.SUBSTR(io_rRawMsg2, nStart, 8); nStart:=nStart + 8;
        nStart:=nStart + 8; -- reserved
        -- Target Info
        nBufferLength:=RawToU16LE(io_rRawMsg2, nStart);
        nStart:=nStart + 2;
        nBufferOffset:=RawToU32LE(io_rRawMsg2, nStart);
        -- A FAIRE...
        -- Version
        xNTLMMessage.vVersion:=TO_CHAR(RawToU8(io_rRawMsg2, nStart)) || '.' || 
                                TO_CHAR(RawToU8(io_rRawMsg2, nStart)) || ' (build ' || 
                                TO_CHAR(RawToU16LE(io_rRawMsg2, nStart)) || ')';
        nStart:=nStart + 3;
        xNTLMMessage.vVersion:=xNTLMMessage.vVersion || ' Rev ' || TO_CHAR(RawToU8(io_rRawMsg2, nStart));
                                
     END IF;

    RETURN xNTLMMessage;
END decode_challenge;

FUNCTION SetOddParity(i_nByte IN PLS_INTEGER) RETURN PLS_INTEGER
IS
    nMask PLS_INTEGER:=128;
    nOddParity PLS_INTEGER:=1;
BEGIN
    FOR i IN 1..7 
    LOOP
        IF BITAND(i_nByte, nMask) > 0 THEN
            nOddParity:=1 - nOddParity;
        END IF; 
        nMask:=nMask / 2;
    END LOOP;
    RETURN BITAND(i_nByte, 254) + nOddParity;
    
END SetOddParity;

FUNCTION CreateDESKey(i_rRaw7Bytes IN RAW) RETURN RAW
IS
    TYPE T7Bytes IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    TnBytes T7Bytes;
    rDESKey RAW(8);
    nByte PLS_INTEGER;
BEGIN
    FOR i IN 1..7
    LOOP
        TnBytes(i):=UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(i_rRaw7Bytes, i, 1));
    END LOOP;
    rDESKey:=U8ToRaw(SetOddParity(BITAND(TnBytes(1), 254)));
    rDESKey:=rDESKey || U8ToRaw(SetOddParity(BITAND(TnBytes(1), 1) * 128 + BITAND(TnBytes(2), 252) / 2));
    rDESKey:=rDESKey || U8ToRaw(SetOddParity(BITAND(TnBytes(2), 3) * 64 + BITAND(TnBytes(3), 248) / 4));
    rDESKey:=rDESKey || U8ToRaw(SetOddParity(BITAND(TnBytes(3), 7) * 32 + BITAND(TnBytes(4), 240) / 8));
    rDESKey:=rDESKey || U8ToRaw(SetOddParity(BITAND(TnBytes(4), 15) * 16 + BITAND(TnBytes(5), 224) / 16));
    rDESKey:=rDESKey || U8ToRaw(SetOddParity(BITAND(TnBytes(5), 31) * 8 + BITAND(TnBytes(6), 192) / 32));
    rDESKey:=rDESKey || U8ToRaw(SetOddParity(BITAND(TnBytes(6), 63) * 4 + BITAND(TnBytes(7), 128) / 64));
    rDESKey:=rDESKey || U8ToRaw(SetOddParity(BITAND(TnBytes(7), 127) * 2));
    
    RETURN rDESKey;
    
END CreateDESKey;

FUNCTION LM_Response(i_rServerChallenge IN RAW,
                     i_vPassword IN VARCHAR2) RETURN RAW
IS
BEGIN
    RETURN Response(i_rServerChallenge, LM_Hash(i_rServerChallenge, i_vPassword));
END LM_Response;

FUNCTION NTLM_Response(i_rServerChallenge IN RAW,
                       i_vPassword IN VARCHAR2) RETURN RAW
IS
BEGIN
    RETURN Response(i_rServerChallenge, NTLM_Hash(i_rServerChallenge, i_vPassword));
END NTLM_Response;     

FUNCTION Response(i_rServerChallenge IN RAW, 
                  i_rHash IN RAW) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CONCAT(DBMS_OBFUSCATION_TOOLKIT.DESEncrypt(input => i_rServerChallenge, key => CreateDESKey(UTL_RAW.SUBSTR(i_rHash, 1, 7))), 
                          DBMS_OBFUSCATION_TOOLKIT.DESEncrypt(input => i_rServerChallenge, key => CreateDESKey(UTL_RAW.SUBSTR(i_rHash, 8, 7))),
                          DBMS_OBFUSCATION_TOOLKIT.DESEncrypt(input => i_rServerChallenge, key => CreateDESKey(UTL_RAW.SUBSTR(i_rHash, 15, 7))));

END Response;

FUNCTION LM_Hash(i_rServerChallenge IN RAW,
                 i_vPassword IN VARCHAR2) RETURN RAW
IS
    vConstant CONSTANT VARCHAR2(10):='KGS!@#$%';
    rBuff RAW(14);
    rHash RAW(21);
BEGIN
    -- [A_REVOIR] Password NULL...
    rBuff:=UTL_RAW.CAST_TO_RAW(RPAD(SUBSTR(UPPER(NVL(i_vPassword, CHR(0))), 1, 14), 14, CHR(0)));
    rHash:=UTL_RAW.CONCAT(DBMS_OBFUSCATION_TOOLKIT.DESEncrypt(input => UTL_RAW.CAST_TO_RAW(vConstant), key => CreateDESKey(UTL_RAW.SUBSTR(rBuff, 1, 7))), 
                          DBMS_OBFUSCATION_TOOLKIT.DESEncrypt(input => UTL_RAW.CAST_TO_RAW(vConstant), key => CreateDESKey(UTL_RAW.SUBSTR(rBuff, 8, 7))), 
                          UTL_RAW.CAST_TO_RAW(RPAD(CHR(0), 5, CHR(0))));
    RETURN rHash;
END LM_Hash;
                     
FUNCTION NTLM_Hash(i_rServerChallenge IN RAW,
                   i_vPassword IN VARCHAR2) RETURN RAW
IS
    rHash RAW(21);
BEGIN
    rHash:=UTL_RAW.CONCAT(MD4(UTL_RAW.CAST_TO_RAW(CONVERT(i_vPassword, 'AL16UTF16LE'))), 
                          UTL_RAW.CAST_TO_RAW(RPAD(CHR(0), 5, CHR(0))));
    RETURN rHash;
END NTLM_Hash;

FUNCTION LM_SessionKey(i_rHash IN RAW) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CONCAT(UTL_RAW.SUBSTR(i_rHash, 1, 8),
                          UTL_RAW.CAST_TO_RAW(RPAD(CHR(0), 8, CHR(0))));
END LM_SessionKey;

FUNCTION NTLM_SessionKey(i_rHash IN RAW) RETURN RAW
IS
BEGIN
    RETURN MD4(i_rHash);
END NTLM_SessionKey;

FUNCTION authentication(i_rServerChallenge IN RAW,
                        i_vLogin IN VARCHAR2, 
                        i_vPassword IN VARCHAR2,
                        i_vDomain IN VARCHAR2,
                        i_vWorkstation IN VARCHAR2) RETURN RAW
IS
    nFlag ULONG;
    rNTLM_Hash RAW(21);
    rLM_Response RAW(24);
    rNTLM_Response RAW(24);
    rNTLM_SessionKey RAW(16);
    nStartLMResponse PLS_INTEGER;
    nStartNTLMResponse PLS_INTEGER;
    nStartDomain PLS_INTEGER;
    nStartLogin PLS_INTEGER;
    nStartWorkstation PLS_INTEGER;
    nStartSessionKey PLS_INTEGER;
    vDomain VARCHAR(1000);
    vLogin VARCHAR2(1000);
    vWorkstation VARCHAR2(1000);
BEGIN
    nFlag:=Negotiate_Unicode + Request_Target + Negotiate_NTLM + Negotiate_Always_Sign + Negotiate_128 + Negotiate_Sign;-- + Negotiate_Key_Exchange;
    nFlag:=Negotiate_Unicode + Request_Target + Negotiate_NTLM+ Negotiate_Always_Sign + Negotiate_128;-- + Negotiate_Key_Exchange;
    
    rLM_Response:=LM_Response(i_rServerChallenge, i_vPassword);
    rNTLM_Hash:=NTLM_Hash(i_rServerChallenge, i_vPassword);
    rNTLM_Response:=Response(i_rServerChallenge, rNTLM_Hash);
    rNTLM_SessionKey:=NTLM_SessionKey(rNTLM_Hash);
    vDomain:=CONVERT(i_vDomain, 'AL16UTF16LE');
    vLogin:=CONVERT(i_vLogin, 'AL16UTF16LE');
    vWorkstation:=CONVERT(i_vWorkstation, 'AL16UTF16LE');
    nStartLMResponse:=64;
    nStartNTLMResponse:=nStartLMResponse + UTL_RAW.LENGTH(rLM_Response);
    nStartDomain:=nStartNTLMResponse + UTL_RAW.LENGTH(rNTLM_Response);
    nStartLogin:=nStartDomain + LENGTH(vDomain);
    nStartWorkstation:=nStartLogin + LENGTH(vLogin);
    nStartSessionKey:=nStartWorkstation + LENGTH(vWorkstation);
    RETURN UTL_RAW.CONCAT(UTL_RAW.CAST_TO_RAW(vNTLMSSP_SIGNATURE), -- Signature
                          ULONGToRaw(NTLMSSP_AUTH), -- Type 3 Indicator
                          USHORTToRaw(UTL_RAW.LENGTH(rLM_Response)), -- LM Response Length
                          USHORTToRaw(UTL_RAW.LENGTH(rLM_Response)), -- LM Response Max Length
                          ULONGToRaw(nStartLMResponse), -- LM Response Offset
                          USHORTToRaw(UTL_RAW.LENGTH(rNTLM_Response)), -- NTLM Response Length
                          USHORTToRaw(UTL_RAW.LENGTH(rNTLM_Response)), -- NTLM Response Max Length
                          ULONGToRaw(nStartNTLMResponse), -- NTLM Response Offset
                          USHORTToRaw(LENGTH(vDomain)), -- Domain Length
                          USHORTToRaw(LENGTH(vDomain)), -- Domain Max Length
                          ULONGToRaw(nStartDomain), -- Domain Offset
           UTL_RAW.CONCAT(
                          USHORTToRaw(LENGTH(vLogin)), -- Login Length
                          USHORTToRaw(LENGTH(vLogin)), -- Login Max Length
                          ULONGToRaw(nStartLogin), -- Login Offset
                          USHORTToRaw(LENGTH(vWorkstation)), -- Workstation Length
                          USHORTToRaw(LENGTH(vWorkstation)), -- Workstation Max Length
                          ULONGToRaw(nStartWorkstation), -- Workstation Offset
                          USHORTToRaw(UTL_RAW.LENGTH(rNTLM_SessionKey)), -- Session Key Length
                          USHORTToRaw(UTL_RAW.LENGTH(rNTLM_SessionKey)), -- Session Key Max Length
                          ULONGToRaw(nStartSessionKey), -- Session Key Offset
                          ULONGToRaw(nFlag), -- Flags
                          -- DATA
            UTL_RAW.CONCAT(
                          rLM_Response, -- LM Response
                          rNTLM_Response, -- NTLM Response
                          UTL_RAW.CAST_TO_RAW(vDomain), -- Domain
                          UTL_RAW.CAST_TO_RAW(vLogin), -- Login
                          UTL_RAW.CAST_TO_RAW(vWorkstation), -- workstation
                          rNTLM_SessionKey)));
END authentication;
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- CIFS FUNCTION [CIFS.2]
-------------------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE INIT_ERRORS
IS
BEGIN
--select 'TvErrors(''' || Substr(col2, 3) || '''):=''' || col3 || ' (' || col1 || ')'';' from erreurs order by HexToRaw(substr(col2, 3))
    TvErrors('00000032'):='The request is not supported. (ERROR_NOT_SUPPORTED)';
    TvErrors('0000007C'):='The system call level is not correct. (ERROR_INVALID_LEVEL)';
    TvErrors('0000010C'):='More changes have occurred within the directory than will fit within the specified Change Notify response buffer. (STATUS_NOTIFY_ENUM_DIR)';
    TvErrors('000008AD'):='The user name could not be found. (NERR_UserNotFound)';
    TvErrors('00010002'):='Unspecified server error. (STATUS_INVALID_SMB)';
    TvErrors('00050002'):='The TID specified in the command was invalid. (STATUS_SMB_BAD_TID)';
    TvErrors('00060001'):='Invalid FID. (STATUS_SMB_BAD_FID)';
    TvErrors('000C0001'):='Invalid open mode. (STATUS_OS2_INVALID_ACCESS)';
    TvErrors('00160002'):='An unknown SMB command code was received by the server. (STATUS_SMB_BAD_COMMAND)';
    TvErrors('005B0002'):='The UID specified is not known as a valid ID on this server session. (STATUS_SMB_BAD_UID)';
    TvErrors('00710001'):='Maximum number of searches has been exhausted. (STATUS_OS2_NO_MORE_SIDS)';
    TvErrors('007C0001'):='Invalid information level. (STATUS_OS2_INVALID_LEVEL)';
    TvErrors('00830001'):='An attempt was made to seek to a negative absolute offset within a file. (STATUS_OS2_NEGATIVE_SEEK)';
    TvErrors('00AD0001'):='No lock request was outstanding for the supplied cancel region. (STATUS_OS2_CANCEL_VIOLATION)';
    TvErrors('00AE0001'):='The file system does not support atomic changes to the lock type.  (STATUS_OS2_ATOMIC_LOCKS_NOT_SUPPORTED)';
    TvErrors('00FA0002'):='Temporarily unable to support RAW mode transfers. Use MPX mode. (STATUS_SMB_USE_MPX)';
    TvErrors('00FB0002'):='Temporarily unable to support RAW or MPX mode transfers. Use standard read/write. (STATUS_SMB_USE_STANDARD)';
    TvErrors('00FC0002'):='Continue in MPX mode. (STATUS_SMB_CONTINUE_MPX)';
    TvErrors('010A0001'):='The copy functions cannot be used. (STATUS_OS2_CANNOT_COPY)';
    TvErrors('01130001'):='Either there are no extended attributes, or the available extended attributes did not fit into the response. (STATUS_OS2_EAS_DIDNT_FIT)';
    TvErrors('03E20001'):='Access to the extended attribute was denied. (STATUS_OS2_EA_ACCESS_DENIED)';
    TvErrors('80000005'):='There is more data available to read on the designated named pipe. (STATUS_BUFFER_OVERFLOW)';
    TvErrors('80000006'):='No (more) files found following a file search command. (STATUS_NO_MORE_FILES)';
    TvErrors('8000000E'):='Printer out of paper. (STATUS_DEVICE_PAPER_EMPTY)';
    TvErrors('C0000001'):='General error. (STATUS_UNSUCCESSFUL)';
    TvErrors('C0000002'):='Invalid Function. (STATUS_NOT_IMPLEMENTED)';
    TvErrors('C0000002'):='Unrecognized SMB command code. (STATUS_NOT_IMPLEMENTED)';
    TvErrors('C0000003'):='Invalid named pipe. (STATUS_INVALID_INFO_CLASS)';
    TvErrors('C0000004'):='The client''s MaxDataCount is too small to accommodate the results. (STATUS_INFO_LENGTH_MISMATCH)';
    TvErrors('C0000008'):='Invalid FID. (STATUS_INVALID_HANDLE)';
    TvErrors('C000000D'):='A parameter supplied with the message is invalid. (STATUS_INVALID_PARAMETER)';
    TvErrors('C000000E'):='File not found. (STATUS_NO_SUCH_DEVICE)';
    TvErrors('C000000F'):='File not found. (STATUS_NO_SUCH_FILE)';
    TvErrors('C0000010'):='Invalid Function. (STATUS_INVALID_DEVICE_REQUEST)';
    TvErrors('C0000011'):='Attempted to read beyond the end of the file. (STATUS_END_OF_FILE)';
    TvErrors('C0000012'):='The wrong disk was found in a drive. (STATUS_WRONG_VOLUME)';
    TvErrors('C0000013'):='Drive not ready. (STATUS_NO_MEDIA_IN_DEVICE)';
    TvErrors('C0000015'):='Sector not found. (STATUS_NONEXISTENT_SECTOR)';
    TvErrors('C0000016'):='There is more data available to read on the designated named pipe. (STATUS_MORE_PROCESSING_REQUIRED)';
    TvErrors('C000001E'):='Access denied. (STATUS_INVALID_LOCK_SEQUENCE)';
    TvErrors('C000001F'):='Access denied. (STATUS_INVALID_VIEW_SIZE)';
    TvErrors('C0000021'):='Access denied. (STATUS_ALREADY_COMMITTED)';
    TvErrors('C0000022'):='Access denied. (STATUS_ACCESS_DENIED)';
    TvErrors('C0000024'):='Invalid FID. (STATUS_OBJECT_TYPE_MISMATCH)';
    TvErrors('C0000032'):='Unknown media type. (STATUS_DISK_CORRUPT_ERROR)';
    TvErrors('C0000033'):='Object Name invalid. (STATUS_OBJECT_NAME_INVALID)';
    TvErrors('C0000034'):='File not found. (STATUS_OBJECT_NAME_NOT_FOUND)';
    TvErrors('C0000035'):='An attempt to create a file or directory failed because an object with the same pathname already exists. (STATUS_OBJECT_NAME_COLLISION)';
    TvErrors('C0000037'):='Invalid FID. (STATUS_PORT_DISCONNECTED)';
    TvErrors('C0000039'):='A component in the path prefix is not a directory. (STATUS_OBJECT_PATH_INVALID)';
    TvErrors('C000003A'):='A component in the path prefix is not a directory. (STATUS_OBJECT_PATH_NOT_FOUND)';
    TvErrors('C000003B'):='A component in the path prefix is not a directory. (STATUS_OBJECT_PATH_SYNTAX_BAD)';
    TvErrors('C000003E'):='Data error (incorrect CRC). (STATUS_DATA_ERROR)';
    TvErrors('C000003E'):='Bad request structure length. (STATUS_DATA_ERROR)';
    TvErrors('C000003F'):='Data error (incorrect CRC). (STATUS_CRC_ERROR)';
    TvErrors('C0000040'):='Insufficient server memory to perform the requested operation. (STATUS_SECTION_TOO_BIG)';
    TvErrors('C0000041'):='Access denied.  (STATUS_PORT_CONNECTION_REFUSED)';
    TvErrors('C0000042'):='Invalid FID. (STATUS_INVALID_PORT_HANDLE)';
    TvErrors('C0000043'):='An attempted open operation conflicts with an existing open. (STATUS_SHARING_VIOLATION)';
    TvErrors('C0000043'):='Sharing violation. A requested open mode conflicts with the sharing mode of an existing file handle. (STATUS_SHARING_VIOLATION)';
    TvErrors('C000004B'):='Access denied.  (STATUS_THREAD_IS_TERMINATING)';
    TvErrors('C000004F'):='The server file system does not support Extended Attributes. (STATUS_EAS_NOT_SUPPORTED)';
    TvErrors('C0000050'):='Either there are no extended attributes, or the available extended attributes did not fit into the response. (STATUS_EA_TOO_LARGE)';
    TvErrors('C0000054'):='A lock request specified an invalid locking mode, or conflicted with an existing file lock. (STATUS_FILE_LOCK_CONFLICT)';
    TvErrors('C0000054'):='A lock request specified an invalid locking mode, or conflicted with an existing file lock.  (STATUS_FILE_LOCK_CONFLICT)';
    TvErrors('C0000055'):='A lock request specified an invalid locking mode, or conflicted with an existing file lock. (STATUS_LOCK_NOT_GRANTED)';
    TvErrors('C0000056'):='Access denied. (STATUS_DELETE_PENDING)';
    TvErrors('C0000061'):='Access denied. (STATUS_PRIVILEGE_NOT_HELD)';
    TvErrors('C000006A'):='Invalid password. (STATUS_WRONG_PASSWORD)';
    TvErrors('C000006D'):='Access denied. (STATUS_LOGON_FAILURE)';
    TvErrors('C000006E'):='Some user account restriction has prevented successful authentication. (STATUS_ACCOUNT_RESTRICTION)';
    TvErrors('C000006F'):='Access to the server is not permitted at this time. (STATUS_INVALID_LOGON_HOURS)';
    TvErrors('C0000070'):='The client does not have permission to access this server. (STATUS_INVALID_WORKSTATION)';
    TvErrors('C0000071'):='The user''s password has expired. (STATUS_PASSWORD_EXPIRED)';
    TvErrors('C0000072'):='User account on the target machine is disabled or has expired. (STATUS_ACCOUNT_DISABLED)';
    TvErrors('C000007E'):='The byte range specified in an unlock request was not locked. (STATUS_RANGE_NOT_LOCKED)';
    TvErrors('C000007F'):='No space on file system. (STATUS_DISK_FULL)';
    TvErrors('C0000097'):='Insufficient server memory to perform the requested operation. (STATUS_TOO_MANY_PAGING_FILES)';
    TvErrors('C000009B'):='A component in the path prefix is not a directory. (STATUS_DFS_EXIT_PATH_FOUND)';
    TvErrors('C000009C'):='Bad data. (May be generated by IOCTL calls on the server.) (STATUS_DATA_ERROR)';
    TvErrors('C00000A2'):='Attempt to modify a read-only file system. (STATUS_MEDIA_WRITE_PROTECTED)';
    TvErrors('C00000AB'):='All instances of the designated named pipe are busy. (STATUS_INSTANCE_NOT_AVAILABLE)';
    TvErrors('C00000AC'):='All instances of the designated named pipe are busy. (STATUS_PIPE_NOT_AVAILABLE)';
    TvErrors('C00000AD'):='Invalid named pipe. (STATUS_INVALID_PIPE_STATE)';
    TvErrors('C00000AE'):='All instances of the designated named pipe are busy. (STATUS_PIPE_BUSY)';
    TvErrors('C00000AF'):='Invalid Function. (STATUS_ILLEGAL_FUNCTION)';
    TvErrors('C00000B0'):='The designated named pipe exists, but there is no server process listening on the server side. (STATUS_PIPE_DISCONNECTED)';
    TvErrors('C00000B0'):='Write to a named pipe with no reader. (STATUS_PIPE_DISCONNECTED)';
    TvErrors('C00000B1'):='The designated named pipe is in the process of being closed. (STATUS_PIPE_CLOSING)';
    TvErrors('C00000B4'):='Invalid named pipe. (STATUS_INVALID_READ_MODE)';
    TvErrors('C00000B5'):='Operation timed out.  (STATUS_IO_TIMEOUT)';
    TvErrors('C00000BA'):='Access denied.  (STATUS_FILE_IS_A_DIRECTORY)';
    TvErrors('C00000BB'):='This command is not supported by the server. (STATUS_NOT_SUPPORTED)';
    TvErrors('C00000C4'):='Internal server error. (STATUS_UNEXPECTED_NETWORK_ERROR)';
    TvErrors('C00000C6'):='Print queue is full - too many queued items. (STATUS_PRINT_QUEUE_FULL)';
    TvErrors('C00000C7'):='Print queue is full - no space for queued item, or queued item too big. (STATUS_NO_SPOOL_SPACE)';
    TvErrors('C00000C8'):='Invalid FID for print file. (STATUS_PRINT_CANCELLED)';
    TvErrors('C00000C9'):='The TID specified in the command was invalid. (STATUS_NETWORK_NAME_DELETED)';
    TvErrors('C00000CA'):='Invalid open mode. (STATUS_ACCESS_DENIED)';
    TvErrors('C00000CA'):='An invalid combination of access permissions for a file or directory was presented. The server cannot set the requested attributes. (STATUS_NETWORK_ACCESS_DENIED)';
    TvErrors('C00000CA'):='Access denied. The specified UID does not have permission to execute the requested command within the current context (TID). (STATUS_NETWORK_ACCESS_DENIED)';
    TvErrors('C00000CB'):='A printer request was made to a non-printer device or, conversely, a non-printer request was made to a printer device. (STATUS_BAD_DEVICE_TYPE)';
    TvErrors('C00000CC'):='Invalid server name in Tree Connect. (STATUS_BAD_NETWORK_NAME)';
    TvErrors('C00000CE'):='Too many UIDs active for this SMB connection. (STATUS_TOO_MANY_SESSIONS)';
    TvErrors('C00000D0'):='No resources currently available for this SMB request. (STATUS_REQUEST_NOT_ACCEPTED)';
    TvErrors('C00000D4'):='A file system operation (such as a rename) across two devices was attempted. (STATUS_NOT_SAME_DEVICE)';
    TvErrors('C00000D5'):='Access denied.  (STATUS_FILE_RENAMED)';
    TvErrors('C00000D9'):='The designated named pipe is in the process of being closed. (STATUS_PIPE_EMPTY)';
    TvErrors('C00000FB'):='A component in the path prefix is not a directory. (STATUS_REDIRECTOR_NOT_STARTED)';
    TvErrors('C0000101'):='Remove of directory failed because it was not empty. (STATUS_DIRECTORY_NOT_EMPTY)';
    TvErrors('C0000101'):='Access denied.  (STATUS_DIRECTORY_NOT_EMPTY)';
    TvErrors('C0000103'):='A requested opened file is not a directory. (STATUS_NOT_A_DIRECTORY)';
    TvErrors('C000010A'):='Access denied.  (STATUS_PROCESS_IS_TERMINATING)';
    TvErrors('C000011F'):='Too many open files. No FIDs are available. (STATUS_TOO_MANY_OPENED_FILES)';
    TvErrors('C0000121'):='Access denied.  (STATUS_CANNOT_DELETE)';
    TvErrors('C0000123'):='Access denied.  (STATUS_FILE_DELETED)';
    TvErrors('C0000128'):='Invalid FID. (STATUS_FILE_CLOSED)';
    TvErrors('C0000184'):='Unknown command. (STATUS_INVALID_DEVICE_STATE)';
    TvErrors('C0000193'):='User account on the target machine is disabled or has expired. (STATUS_ACCOUNT_EXPIRED)';
    TvErrors('C0000205'):='Insufficient server memory to perform the requested operation. (STATUS_INSUFF_SERVER_RESOURCES)';
    TvErrors('C0000224'):='The user''s password has expired. (STATUS_PASSWORD_MUST_CHANGE)';
    TvErrors('C0000235'):='Invalid FID. (STATUS_HANDLE_NOT_CLOSABLE)';
    TvErrors('C0000257'):='DFS pathname not on local server. (STATUS_PATH_NOT_COVERED)';
    TvErrors('FFFF0002'):='Function not supported by the server.  (STATUS_SMB_NO_SUPPORT)';
END;

FUNCTION RAW_SUBSTR(i_rRaw IN RAW, i_nStart IN PLS_INTEGER, i_nLength IN PLS_INTEGER:=NULL) RETURN RAW
IS
    nTotalLength PLS_INTEGER;
BEGIN
    nTotalLength:=UTL_RAW.LENGTH(i_rRaw);
    IF i_nLength = 0 THEN
        RETURN NULL;
    ELSIF i_nStart > nTotalLength THEN
        RETURN NULL;
    ELSIF i_nStart + i_nLength > nTotalLength THEN
        RETURN UTL_RAW.SUBSTR(i_rRaw, i_nStart);
    ELSE
        RETURN UTL_RAW.SUBSTR(i_rRaw, i_nStart, i_nLength);
    END IF;
END RAW_SUBSTR;

FUNCTION PaddingRaw(i_nSize IN PLS_INTEGER, 
                    i_vPadding IN VARCHAR2:=CHR(0)) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CAST_TO_RAW(SUBSTR(RPAD(i_vPadding, i_nSize, i_vPadding), 1, i_nSize));
END PaddingRaw;

FUNCTION RawToDump(i_rMessage IN RAW) RETURN VARCHAR2
IS
    vDump VARCHAR2(4000);
BEGIN
    SELECT DUMP(i_rMessage) INTO vDump FROM DUAL;
    RETURN vDump;
    
END RawToDump;

FUNCTION ULONGToRaw(i_nULONG IN ULONG) RETURN RAW
IS
    n1 ULONG;
    n2 ULONG;
BEGIN
    n1:=MOD(i_nULONG, 65536);
    n2:=TRUNC(i_nULONG / 65536);
    RETURN UTL_RAW.CONCAT(
        USHORTToRaw(n1), 
        USHORTToRaw(n2));
END ULONGToRaw; 

FUNCTION RawToULONG(i_rSMBMessage IN OUT NOCOPY RAW,
                    io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN ULONG
IS
    nPosition PLS_INTEGER:=io_nPosition;
    n ULONG;
BEGIN
    io_nPosition:=io_nPosition + 4;
    n:=UTL_RAW.CAST_TO_BINARY_INTEGER(RAW_SUBSTR(i_rSMBMessage, nPosition, 4), UTL_RAW.LITTLE_ENDIAN);
    IF n < 0 THEN
        n:=n + 4294967296;
    END IF;
    RETURN n;
    
END RawToULONG;

FUNCTION RawToLargeInteger(io_rSMBMessage IN OUT NOCOPY RAW,
                           io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN LARGE_INTEGER
IS
    n1 LARGE_INTEGER;
    n2 LARGE_INTEGER;
BEGIN
    n1:=RawToULONG(io_rSMBMessage, io_nPosition);
    n2:=RawToULONG(io_rSMBMessage, io_nPosition);
    RETURN n2 * 4294967296 + n1;
END RawToLargeInteger;

FUNCTION LargeIntegerToRaw(i_nLargeInteger LARGE_INTEGER) RETURN RAW
IS
    n1 ULONG;
    n2 ULONG;
BEGIN
    n1:=MOD(i_nLargeInteger, 4294967296);
    n2:=TRUNC(i_nLargeInteger / 4294967296);
    RETURN UTL_RAW.CONCAT(
        ULONGToRaw(n1),
        ULONGToRaw(n2));
END LargeIntegerToRaw;

FUNCTION USHORTToRaw(i_nUSHORT IN USHORT) RETURN RAW
IS
BEGIN
    RETURN RAW_SUBSTR(UTL_RAW.CAST_FROM_BINARY_INTEGER(NVL(i_nUSHORT, 0), UTL_RAW.LITTLE_ENDIAN), 1, 2);
END USHORTToRaw;

FUNCTION RawToUSHORT(i_rSMBMessage IN OUT NOCOPY RAW, 
                     io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN USHORT
IS
    nPosition PLS_INTEGER:=io_nPosition;
BEGIN
    io_nPosition:=io_nPosition + 2;
    RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(RAW_SUBSTR(i_rSMBMessage, nPosition, 2), UTL_RAW.LITTLE_ENDIAN);
END RawToUSHORT;

FUNCTION UCHARToRaw(i_nCHAR IN UCHAR) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CAST_TO_RAW(CHR(NVL(i_nCHAR, 0)));
END UCHARToRaw;

FUNCTION RawToUCHAR(i_rSMBMessage IN OUT NOCOPY RAW, 
                     io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN UCHAR
IS
    nPosition PLS_INTEGER:=io_nPosition;
BEGIN
    io_nPosition:=io_nPosition + 1;
    RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(RAW_SUBSTR(i_rSMBMessage, nPosition, 1));
END RawToUCHAR;    

FUNCTION BooleanToRaw(i_bValue IN BOOLEAN) RETURN RAW
IS
BEGIN
    IF i_bValue THEN
        RETURN UCHARToRaw(255);
    ELSE
        RETURN UCHARToRaw(0);
    END IF;
END BooleanToRaw;
                 

FUNCTION SMBStatusToRaw(i_xStatus IN SMBStatus) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CONCAT(UCHARToRaw(i_xStatus.ErrorClass), 
                          UCHARToRaw(i_xStatus.Reserved),
                          USHORTToRaw(i_xStatus.ErrorCode)
                          );
                          
END SMBStatusToRaw;

FUNCTION SMBStatusToULONG(i_xStatus IN SMBStatus) RETURN ULONG
IS
    nStart PLS_INTEGER;
    rRaw RAW(4);
BEGIN
    nStart:=1;
    rRaw:=SMBStatusToRaw(i_xStatus);
    RETURN RawToULONG(rRaw, nStart);
END SMBStatusToULONG;

FUNCTION RawToSMBStatus(i_rSMBMessage IN OUT NOCOPY RAW, 
                        io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN SMBStatus
IS
    xSMBStatus SMBStatus;
BEGIN
    xSMBStatus.ErrorClass:=RawToUCHAR(i_rSMBMessage, io_nPosition);
    xSMBStatus.Reserved:=RawToUCHAR(i_rSMBMessage, io_nPosition);
    xSMBStatus.ErrorCode:=RawToUSHORT(i_rSMBMessage, io_nPosition);
    RETURN xSMBStatus;
    
END RawToSMBStatus; 

FUNCTION ULONGToSMBStatus(i_nULONG IN ULONG) RETURN SMBStatus
IS
    rStatus RAW(4);
    nStart PLS_INTEGER;
BEGIN
    rStatus:=ULONGToRaw(i_nULONG);
    nStart:=1;
    RETURN RawToSMBStatus(rStatus, nStart);
    
END ULONGToSMBStatus;   

FUNCTION RawToFileTime(io_rFileTime IN OUT NOCOPY RAW,
                       io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN DATE
IS
    n1 NUMBER;
    n2 NUMBER;
    n3 NUMBER;
BEGIN
    n1:=RawToULONG(io_rFileTime, io_nPosition);
    n2:=RawToULONG(io_rFileTime, io_nPosition);
    n3:=TO_NUMBER(TO_CHAR(TO_DATE('01/01/1601', 'DD/MM/YYYY'), 'J')) + 
        ((n1 + 4294967296 * n2) / 864000000000);
    RETURN TO_DATE(TRUNC(n3), 'J') + n3 - TRUNC(n3);

END RawToFileTime;

FUNCTION FileTimeToRaw(i_dFileTime IN DATE) RETURN RAW
IS
    n1 NUMBER;
    n2 NUMBER;
    n3 NUMBER;
BEGIN
    IF i_dFileTime IS NULL THEN
        RETURN LargeIntegerToRaw(0);
    ELSE
        n3:=(i_dFileTime - TO_DATE('01/01/1601', 'DD/MM/YYYY')) * 864000000000;
        n1:=MOD(n3, 4294967296);
        n2:=TRUNC(n3 / 4294967296);
        RETURN UTL_RAW.CONCAT(
            ULONGToRaw(n1), 
            ULONGToRaw(n2));
    END IF;
END FileTimeToRaw;

-- Two successive structures : an Smb_Date followed by an Smb_Time
FUNCTION RawToSmbDateSmbTime(io_rSmbDateSmbTime IN OUT NOCOPY RAW,
                             io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN DATE
IS
    nSmbDate USHORT;
    nSmbTime USHORT;
BEGIN
    nSmbDate:=RawToUShort(io_rSmbDateSmbTime, io_nPosition);
    nSmbTime:=RawToUShort(io_rSmbDateSmbTime, io_nPosition);
    RETURN TO_DATE( TO_CHAR(BITAND(nSmbDate, 31), 'FM00') || '-' || 
                    TO_CHAR(BITAND(TRUNC(nSmbDate / 32), 15), 'FM00') || '-' ||
                    TO_CHAR(1980 + BITAND(TRUNC(nSmbDate / 512), 127), 'FM0000') || ' ' ||
                    TO_CHAR(BITAND(TRUNC(nSmbTime / 2048), 31), 'FM00') || ':' ||
                    TO_CHAR(BITAND(TRUNC(nSmbTime / 32), 63), 'FM00') || ':' ||
                    TO_CHAR(2 * BITAND(nSmbTime, 31), 'FM00'), 'DD-MM-YYYY HH24:MI:SS');
END RawToSmbDateSmbTime;

FUNCTION NbSec1970ToDate(i_nNbSec1970 IN ULONG) RETURN DATE
IS
BEGIN
    IF i_nNbSec1970 = 0 THEN
        RETURN NULL; -- unknown 
    ELSIF i_nNbSec1970 = 4294967295 THEN
        RETURN NULL; -- illimited
    ELSE
        RETURN TO_DATE('01/01/1970', 'DD/MM/YYYY') + (i_nNbSec1970 / 86400);
    END IF;
END NbSec1970ToDate;

FUNCTION OEMStringToRaw(i_vString IN VARCHAR2) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CAST_TO_RAW(i_vString || CHR(0));
END OEMStringToRaw;

-- NZT for Non-Zero-Terminated
FUNCTION OEMStringNZTToRaw(i_vString IN VARCHAR2) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CAST_TO_RAW(i_vString);
END OEMStringNZTToRaw;

FUNCTION UnicodeStringToRaw(i_vString IN VARCHAR2) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CAST_TO_RAW(CONVERT(i_vString || CHR(0), 'AL16UTF16LE'));
END UnicodeStringToRaw;

FUNCTION UnicodeStringToString(i_vString IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    RETURN CONVERT(i_vString, get_database_charset, 'AL16UTF16LE');
END UnicodeStringToString;

FUNCTION SMBStringToRaw(i_vString IN VARCHAR2) RETURN RAW
IS
BEGIN   
    IF BITAND(xCtx.xSMBHeader.Flags2, SMB_FLAGS2_UNICODE) > 0 THEN
        RETURN UnicodeStringToRaw(i_vString);
    ELSE
        RETURN OEMStringToRaw(i_vString);
    END IF;
END SMBStringToRaw;

FUNCTION SMBStringToString(i_vString IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    IF BITAND(xCtx.xSMBHeader.Flags2, SMB_FLAGS2_UNICODE) > 0 THEN
        RETURN CONVERT(i_vString, get_database_charset, 'AL16UTF16LE');
    ELSE
        RETURN i_vString;
    END IF;
END SMBStringToString;

-- return length in bytes from its length in char
FUNCTION SMBStringLength(i_nLength IN PLS_INTEGER) RETURN PLS_INTEGER
IS
BEGIN
    IF BITAND(xCtx.xSMBHeader.Flags2, SMB_FLAGS2_UNICODE) > 0 THEN
        RETURN i_nLength * 2;
    ELSE
        RETURN i_nLength;
    END IF;
END SMBStringLength;

-- Word aligment before calling an smb string
PROCEDURE SMBStringAlign(io_nStart IN OUT PLS_INTEGER, 
                         i_nPrevBlockLength IN PLS_INTEGER:=NULL)
IS
BEGIN
    IF BITAND(xCtx.xSMBHeader.Flags2, SMB_FLAGS2_UNICODE) > 0 THEN
        IF BITAND(io_nStart + NVL(i_nPrevBlockLength, 0), 1) = 0 THEN
            io_nStart:=io_nStart + 1;
        END IF;
    END IF;
END SMBStringAlign;

FUNCTION SMBStringAlignToRaw(i_nLength IN PLS_INTEGER) RETURN RAW
IS
    rAlignment RAW(1);
BEGIN
    rAlignment:=NULL;
    IF BITAND(xCtx.xSMBHeader.Flags2, SMB_FLAGS2_UNICODE) > 0 THEN
        IF BITAND(i_nLength, 1) = 1 THEN
            rAlignment:=HexToRaw('00');
        END IF;
    END IF;
    RETURN rAlignment;
    
END SMBStringAlignToRaw;
                        

FUNCTION FixedLengthStringToRaw(i_vString IN VARCHAR2, 
                                i_nLength IN PLS_INTEGER) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CAST_TO_RAW(SUBSTR(RPAD(NVL(i_vString, CHR(0)), i_nLength, CHR(0)), 1, i_nLength));
END FixedLengthStringToRaw;

FUNCTION RawToFixedLengthString(i_rSMBMessage IN OUT NOCOPY RAW, 
                                io_nPosition IN OUT NOCOPY PLS_INTEGER,
                                i_nLength IN PLS_INTEGER) RETURN VARCHAR2
IS
    nPosition PLS_INTEGER:=io_nPosition;
BEGIN
    IF i_nLength > 0 THEN
        io_nPosition:=io_nPosition + i_nLength;
        RETURN UTL_RAW.CAST_TO_VARCHAR2(RAW_SUBSTR(i_rSMBMessage, nPosition, i_nLength));
    ELSE
        RETURN NULL;
    END IF;
END RawToFixedLengthString;

FUNCTION RawToOemString(i_rSMBMessage IN OUT NOCOPY RAW, 
                        io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN VARCHAR2
IS
    vAnswer VARCHAR2(4000);
    nCar UCHAR;
BEGIN
    vAnswer:=NULL;
    LOOP
        nCar:=RawToUCHAR(i_rSMBMessage, io_nPosition);
        EXIT WHEN nCar = 0;
        EXIT WHEN io_nPosition > UTL_RAW.LENGTH(i_rSMBMessage);
        vAnswer:=vAnswer || CHR(nCar);
    END LOOP;
    RETURN vAnswer;
END RawToOemString;

FUNCTION RawToUnicodeString(i_rSMBMessage IN OUT NOCOPY RAW, 
                            io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN VARCHAR2
IS
    vAnswer VARCHAR2(4000);
    nCar PLS_INTEGER;
BEGIN
    vAnswer:=NULL;
    LOOP
        nCar:=RawToUSHORT(i_rSMBMessage, io_nPosition);
        EXIT WHEN nCar = 0;
        EXIT WHEN io_nPosition > UTL_RAW.LENGTH(i_rSMBMessage);
        vAnswer:=vAnswer || CHR(MOD(nCar, 255));
    END LOOP;
    RETURN vAnswer;

END RawToUnicodeString;

FUNCTION RawToSmbString(i_rSMBMessage IN OUT NOCOPY RAW,
                        io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN VARCHAR2
IS
BEGIN
    IF BITAND(xCtx.xSMBHeader.Flags2, SMB_FLAGS2_UNICODE) > 0 THEN
        RETURN RawToUnicodeString(i_rSMBMessage, io_nPosition);
    ELSE
        RETURN RawToOemString(i_rSMBMessage, io_nPosition);
    END IF;
END RawToSmbString;


FUNCTION SMBHeaderToRaw(i_xSMBHeader IN OUT NOCOPY SMB_Header) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CONCAT(SMB_Magic,
                          UCHARToRaw(i_xSMBHeader.Command),
                          SMBStatusToRaw(i_xSMBHeader.Status),
                          UCHARToRaw(i_xSMBHeader.Flags),
                          USHORTToRaw(i_xSMBHeader.Flags2),
                          USHORTToRaw(i_xSMBHeader.PIDHigh),
                          FixedLengthStringToRaw(i_xSMBHeader.SecurityFeatures, 8),
                          USHORTToRaw(i_xSMBHeader.Reserved),
                          USHORTToRaw(i_xSMBHeader.TID),
                          USHORTToRaw(i_xSMBHeader.PIDLow),
                          USHORTToRaw(i_xSMBHeader.UID),
                          USHORTToRaw(i_xSMBHeader.MID)
                          );
END SMBHeaderToRaw;

FUNCTION RawToSMBHeader(i_rSMBHeader IN OUT NOCOPY RAW) RETURN SMB_Header
IS
    xSMBHeader SMB_Header;
    nPosition PLS_INTEGER;
BEGIN
    nPosition:=1;
    IF RAW_SUBSTR(i_rSMBHeader, nPosition, 4) = SMB_Magic THEN
        nPosition:=nPosition + 4;
        xSMBHeader.Command:=RawToUCHAR(i_rSMBHeader, nPosition);
        xSMBHeader.Status:=RawToSMBStatus(i_rSMBHeader, nPosition);
        xSMBHeader.Flags:=RawToUCHAR(i_rSMBHeader, nPosition);
        xSMBHeader.Flags2:=RawToUSHORT(i_rSMBHeader, nPosition);
        xSMBHeader.PIDHigh:=RawToUSHORT(i_rSMBHeader, nPosition);
        xSMBHeader.SecurityFeatures:=RTRIM(RawToFixedLengthString(i_rSMBHeader, nPosition, 8), CHR(0));
        xSMBHeader.Reserved:=RawToUSHORT(i_rSMBHeader, nPosition);
        xSMBHeader.TID:=RawToUSHORT(i_rSMBHeader, nPosition);
        xSMBHeader.PIDLow:=RawToUSHORT(i_rSMBHeader, nPosition);
        xSMBHeader.UID:=RawToUSHORT(i_rSMBHeader, nPosition);
        xSMBHeader.MID:=RawToUSHORT(i_rSMBHeader, nPosition);
    END IF;
    RETURN xSMBHeader;
END RawToSMBHeader;

FUNCTION RawToSmbFea(io_rSmbFea IN OUT NOCOPY RAW,
                     io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN SMB_FEA
IS
    nExtendedAttributeFlag UChar;
    xSmbFea SMB_FEA;
    nAttrNameLength UChar;
    nAttrValueLength UShort;
BEGIN
    nExtendedAttributeFlag:=RawToUChar(io_rSmbFea, io_nPosition);
    xSmbFea.bFileNeedEA:=(BITAND(nExtendedAttributeFlag, 128) > 0);
    nAttrNameLength:=RawToUChar(io_rSmbFea, io_nPosition);
    nAttrValueLength:=RawToUShort(io_rSmbFea, io_nPosition);
    xSmbFea.vAttributeName:=RawToFixedLengthString(io_rSmbFea, io_nPosition, nAttrNameLength);
    io_nPosition:=io_nPosition + 1; 
    xSmbFea.vAttributeValue:=RawToFixedLengthString(io_rSmbFea, io_nPosition, nAttrValueLength);
    RETURN xSmbFea;
END RawToSmbFea;

FUNCTION RawToSmbFeaList(io_rSmbFeaList IN OUT NOCOPY RAW,
                         io_nPosition IN OUT NOCOPY PLS_INTEGER) RETURN SMB_FEA_LIST
IS
    nTotalLength ULONG;
    nPositionPrev PLS_INTEGER;
    txSmbFeaList SMB_FEA_LIST;
BEGIN   
    nPositionPrev:=io_nPosition;
    nTotalLength:=RawToULong(io_rSmbFeaList, io_nPosition); 
    WHILE((io_nPosition - nPositionPrev) < nTotalLength)
    LOOP
        txSmbFeaList(txSmbFeaList.COUNT + 1):=RawToSmbFea(io_rSmbFeaList, io_nPosition);
    END LOOP;
    RETURN txSmbFeaList;
    
END RawToSmbFeaList;

FUNCTION SmbFeaToRaw(i_xSmbFea IN SMB_FEA) RETURN RAW
IS
    nEAFlag UCHAR;
BEGIN
    nEAFlag:=0;
    IF i_xSmbFea.bFileNeedEA THEN
        nEAFlag:=nEAFlag + 128;
    END IF;
    RETURN UTL_RAW.CONCAT(
        UCHARToRaw(nEAFlag), -- ExtendedAttributeFlag
        UCHARToRaw(LENGTH(i_xSmbFea.vAttributeName)), -- AttributeNameLengthInBytes
        USHORTToRaw(LENGTH(i_xSmbFea.vAttributeValue)), -- AttributeValueLengthInBytes
        OEMStringToRaw(i_xSmbFea.vAttributeName), -- AttributeName
        OEMStringNZTToRaw(i_xSmbFea.vAttributeValue) -- AttributeValue
        );
        
END SmbFeaToRaw;

FUNCTION SmbFeaListToRaw(i_xSmbFeaList IN SMB_FEA_LIST) RETURN RAW
IS
    rSmbFeaList RAW(32000);
    nSize ULONG;
BEGIN
    rSmbFeaList:=NULL;
    FOR i IN 1..i_xSmbFeaList.COUNT
    LOOP
        rSmbFeaList:=UTL_RAW.CONCAT(rSmbFeaList, SmbFeaToRaw(i_xSmbFeaList(i)));
    END LOOP;
    nSize:=4 + NVL(UTL_RAW.LENGTH(rSmbFeaList), 0);
    RETURN UTL_RAW.CONCAT(
        ULONGToRaw(nSize), 
        rSmbFeaList
        );
    
END SmbFeaListToRaw;

FUNCTION SmbGeaListToRaw(i_TxAttributeName IN SMB_GEA_LIST) RETURN RAW
IS
    rSmbGeaList RAW(32000);
BEGIN
    rSmbGeaList:=NULL;
    FOR i IN 1..i_TxAttributeName.COUNT
    LOOP
        rSmbGeaList:=UTL_RAW.CONCAT(
            UCHARToRaw(LENGTH(i_TxAttributeName(i))),
            OEMStringToRaw(i_TxAttributeName(i)));
    END LOOP;
    rSmbGeaList:=UTL_RAW.CONCAT(
        ULONGToRaw(UTL_RAW.LENGTH(rSmbGeaList) + 4), 
        rSmbGeaList);
    RETURN rSmbGeaList;
END SmbGeaListToRaw;

PROCEDURE RawToSmbInfoAllocation(io_rSmbInfoAllocation IN OUT NOCOPY RAW,
                                 io_nPosition IN OUT NOCOPY PLS_INTEGER,
                                 io_xFSInfo IN OUT NOCOPY FS_INFO_T)
IS
BEGIN
    io_xFSInfo.idFileSystem:=RawToULong(io_rSmbInfoAllocation, io_nPosition);
    io_xFSInfo.SectorsPerAllocationUnit:=RawToULong(io_rSmbInfoAllocation, io_nPosition);
    io_xFSInfo.TotalAllocationUnits:=RawToULong(io_rSmbInfoAllocation, io_nPosition);
    io_xFSInfo.TotalFreeAllocationUnits:=RawToULong(io_rSmbInfoAllocation, io_nPosition);
    io_xFSInfo.BytesPerSector:=RawToUShort(io_rSmbInfoAllocation, io_nPosition);
END RawToSmbInfoAllocation;

PROCEDURE RawToSmbInfoVolume(io_rSmbInfoVolume IN OUT NOCOPY RAW,
                             io_nPosition IN OUT NOCOPY PLS_INTEGER,
                             io_xFSInfo IN OUT NOCOPY FS_INFO_T)
IS
    nLength UChar;
BEGIN
    io_xFSInfo.SerialNumber:=RawToULong(io_rSmbInfoVolume, io_nPosition);
    nLength:=RawToUChar(io_rSmbInfoVolume, io_nPosition);
    io_xFSInfo.VolumeLabel:=SmbStringToString(RawToFixedLengthString(io_rSmbInfoVolume, io_nPosition, nLength));
END RawToSmbInfoVolume;

PROCEDURE RawToSmbQueryFSVolumeInfo(io_rSmbQueryFSVolumeInfo IN OUT NOCOPY RAW,
                                    io_nPosition IN OUT NOCOPY PLS_INTEGER,
                                    io_xFSInfo IN OUT NOCOPY FS_INFO_T)
IS
    nLength ULong;
BEGIN
    io_xFSInfo.VolumeCreationTime:=RawToFileTime(io_rSmbQueryFSVolumeInfo, io_nPosition);
    io_xFSInfo.SerialNumber:=RawToULong(io_rSmbQueryFSVolumeInfo, io_nPosition);
    nLength:=RawToULong(io_rSmbQueryFSVolumeInfo, io_nPosition);
    io_nPosition:=io_nPosition + 2;
    io_xFSInfo.VolumeLabel:=UnicodeStringToString(RawToFixedLengthString(io_rSmbQueryFSVolumeInfo, io_nPosition, nLength));
END RawToSmbQueryFSVolumeInfo;

PROCEDURE RawToSmbQueryFSSizeInfo(io_rSmbQueryFSSizeInfo IN OUT NOCOPY RAW,
                                  io_nPosition IN OUT NOCOPY PLS_INTEGER,
                                  io_xFSInfo IN OUT NOCOPY FS_INFO_T)
IS
BEGIN
    io_xFSInfo.TotalAllocationUnits:=RawToLargeInteger(io_rSmbQueryFSSizeInfo, io_nPosition);
    io_xFSInfo.TotalFreeAllocationUnits:=RawToLargeInteger(io_rSmbQueryFSSizeInfo, io_nPosition);
    io_xFSInfo.SectorsPerAllocationUnit:=RawToULong(io_rSmbQueryFSSizeInfo, io_nPosition);
    io_xFSInfo.BytesPerSector:=RawToULong(io_rSmbQueryFSSizeInfo, io_nPosition);
END RawToSmbQueryFSSizeInfo;

PROCEDURE RawToSmbQueryFSDeviceInfo(io_rSmbQueryFSDeviceInfo IN OUT NOCOPY RAW,
                                  io_nPosition IN OUT NOCOPY PLS_INTEGER,
                                  io_xFSInfo IN OUT NOCOPY FS_INFO_T)
IS
BEGIN
    io_xFSInfo.DeviceType:=RawToULong(io_rSmbQueryFSDeviceInfo, io_nPosition);
    io_xFSInfo.DeviceCharacteristics:=RawToULong(io_rSmbQueryFSDeviceInfo, io_nPosition);
END RawToSmbQueryFSDeviceInfo;

PROCEDURE RawToSmbQueryFSAttributeInfo(io_rSmbQueryFSAttributeInfo IN OUT NOCOPY RAW,
                                       io_nPosition IN OUT NOCOPY PLS_INTEGER,
                                       io_xFSInfo IN OUT NOCOPY FS_INFO_T)
IS
    nLength ULong;
BEGIN
    io_xFSInfo.FileSystemAttributes:=RawToULong(io_rSmbQueryFSAttributeInfo, io_nPosition);
    io_xFSInfo.MaxFileNameLengthInBytes:=RawToULong(io_rSmbQueryFSAttributeInfo, io_nPosition);
    nLength:=RawToULong(io_rSmbQueryFSAttributeInfo, io_nPosition);
    io_xFSInfo.FileSystemName:=UnicodeStringToString(RawToFixedLengthString(io_rSmbQueryFSAttributeInfo, io_nPosition, nLength));
END RawToSmbQueryFSAttributeInfo;

-- if io_vErrMsg is already defined, return False
-- else, check the SMBHeader Status : 
-- Return True if there is no error , 
-- Else, return False and return a textual error within the io_vErrMsg parameter. 
FUNCTION ok(io_vErrMsg IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS
    bOk BOOLEAN;
    nStatus ULONG;
    vIndiceError VARCHAR2(8);
BEGIN
    IF io_vErrMsg IS NOT NULL THEN
        bOk:=FALSE;
    ELSE
        nStatus:=SMBStatusToULONG(xCtx.xSmbHeader.Status);
        IF nStatus = sus_OK THEN
            bOk:=TRUE;
        ELSE
            vIndiceError:=RawToHex(U32BEToRaw(nStatus));
            IF TvErrors.COUNT = 0 THEN
                INIT_ERRORS; 
            END IF;
            IF TvErrors.EXISTS(vIndiceError) THEN
                io_vErrMsg:=TvErrors(vIndiceError);
            ELSE
                io_vErrMsg:='Error 0x' || vIndiceError;
            END IF;
            bOk:=FALSE;
        END IF;
    END IF;
    RETURN bOk;
END ok;

-- Check the SMBHeader Status. Return True if OK.
FUNCTION ok RETURN BOOLEAN
IS
BEGIN
    RETURN (SMBStatusToULONG(xCtx.xSmbHeader.Status) = sus_OK);
END ok;

FUNCTION NO_ANDX RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CONCAT(
        UCHARToRaw(SmbCom_NO_ANDX_COMMAND), -- AndXCommand
        UCHARToRaw(0), -- AndXReserved
        USHORTToRaw(0)); --AndXOffset;
END NO_ANDX;

FUNCTION pack_smb_message(i_xSMBHeader IN OUT NOCOPY SMB_Header,
                          i_rParameters IN OUT NOCOPY RAW,
                          i_rData IN OUT NOCOPY RAW) RETURN RAW
IS
BEGIN
    RETURN UTL_RAW.CONCAT(SMBHeaderToRaw(i_xSMBHeader),
                          UCHARToRaw(NVL(UTL_RAW.LENGTH(i_rParameters), 0) / 2),
                          i_rParameters,
                          USHORTToRaw(NVL(UTL_RAW.LENGTH(i_rData), 0)),
                          i_rData
                          );
END pack_smb_message;

PROCEDURE unpack_smb_message(i_rSMBMessage IN OUT NOCOPY RAW,
                             o_xSMBHeader IN OUT NOCOPY SMB_Header,
                             o_rParameters OUT RAW,
                             o_rData OUT RAW)
IS
    nParamWordCnt UCHAR;
    nDataByteCnt USHORT;
    nPosition PLS_INTEGER;
BEGIN
    IF i_rSMBMessage IS NOT NULL THEN
        o_xSMBHeader:=RawToSMBHeader(i_rSMBMessage);
        nPosition:=33;
        nParamWordCnt:=RawToUCHAR(i_rSMBMessage, nPosition);
        o_rParameters:=RAW_SUBSTR(i_rSMBMessage, nPosition, nParamWordCnt * 2);
        nPosition:=34 + nParamWordCnt * 2;
        nDataByteCnt:=RawToUSHORT(i_rSMBMessage, nPosition);
        o_rData:=RAW_SUBSTR(i_rSMBMessage, nPosition, nDataByteCnt); 
    END IF;    
    
END unpack_smb_message;

FUNCTION replace_escape_char(i_vString IN VARCHAR2) RETURN VARCHAR2
IS
    vString VARCHAR2(32000);
    bLoopAgain BOOLEAN;
    nPos PLS_INTEGER;
BEGIN
    vString:=i_vString;
    LOOP
        bLoopAgain:=FALSE;
        nPos:=INSTR(vString, '\');
        IF nPos > 0 THEN
            IF SUBSTR(vString, nPos + 1, 1) = 'x' THEN
                vString:=SUBSTR(vString, 1, nPos - 1) || CHR(UTL_RAW.CAST_TO_BINARY_INTEGER(HexToRaw(SUBSTR(vString, nPos + 2, 2)))) || SUBSTR(vString, nPos + 4);
                bLoopAgain:=TRUE;
            END IF;
        END IF;
        EXIT WHEN NOT(bLoopAgain);
    END LOOP;
    RETURN vString;
    
END replace_escape_char;

PROCEDURE TRANSPORT_INIT(i_nTransportType IN PLS_INTEGER, 
                         i_vHost IN VARCHAR2, 
                         i_nPort IN PLS_INTEGER:=445)
IS
    xSMBHeader SMB_Header;
BEGIN
    xCtx.nTransportType:=i_nTransportType;
    xCtx.vHost:=i_vHost;
    xCtx.nPort:=i_nPort;
    xCtx.xSMBHeader:=xSMBHeader;
    
END TRANSPORT_INIT;                          

PROCEDURE SMB_COM_NEGOTIATE
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
    nPosition PLS_INTEGER;
    nProtocol PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_NEGOTIATE;
    
xCtx.xSMBHeader.PIDLow:=2502;
xCtx.xSMBHeader.MID:=1;
xCtx.xSMBHeader.Flags2:=xCtx.xSMBHeader.Flags2 + 49152;

    rParameters:=NULL;
    rData:=UTL_RAW.CAST_TO_RAW(replace_escape_char('\x02PC NETWORK PROGRAM 1.0\x00\x02LANMAN1.0\x00\x02MICROSOFT NETWORKS 3.0\x00\x02LM1.2X002\x00\x02LANMAN2.1\x00\x02NT LM 0.12\x00'));
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        -- unpack NegotiateResponse structure
        nPosition:=1;
        xCtx.xNegotiateResponse.protocolIndex:=RawToUSHORT(rParameters, nPosition);
        nProtocol:=xCtx.xNegotiateResponse.protocolIndex;
        IF nProtocol >= 1 THEN
            IF nProtocol >=5 THEN 
                xCtx.xNegotiateResponse.secmode:=RawToUCHAR(rParameters, nPosition);
            ELSE
                xCtx.xNegotiateResponse.secmode:=RawToUSHORT(rParameters, nPosition);
                xCtx.xNegotiateResponse.maxBufferSize:=RawToUSHORT(rParameters, nPosition);
            END IF;
            xCtx.xNegotiateResponse.maxMpxCount:=RawToUSHORT(rParameters, nPosition);
            xCtx.xNegotiateResponse.maxVCS:=RawToUSHORT(rParameters, nPosition);
            IF nProtocol >= 5 THEN
                xCtx.xNegotiateResponse.maxBufferSize:=RawToULONG(rParameters, nPosition);
                xCtx.xNegotiateResponse.maxRawBuffer:=RawToULONG(rParameters, nPosition);
            ELSE
                xCtx.xNegotiateResponse.RawMode:=RawToUSHORT(rParameters, nPosition); 
            END IF;
            xCtx.xNegotiateResponse.sesskey:=RawToULONG(rParameters, nPosition);
            IF nProtocol >= 5 THEN
                xCtx.xNegotiateResponse.capabilities:=RawToULONG(rParameters, nPosition);
                xCtx.xNegotiateResponse.srv_time:=RAW_SUBSTR(rParameters, nPosition, 8); nPosition:=nPosition + 8;
            ELSE
                xCtx.xNegotiateResponse.srv_time:=RAW_SUBSTR(rParameters, nPosition, 4); nPosition:=nPosition + 4;
            END IF;
            xCtx.xNegotiateResponse.srv_tzone:=RawToUSHORT(rParameters, nPosition);
            xCtx.xNegotiateResponse.cryptkeylen:=RawToUCHAR(rParameters, nPosition);
            IF BITAND(xCtx.xSMBHeader.Flags2, f2_ExtendedSecurityNegotiation) > 0 THEN
                xCtx.xNegotiateResponse.guid:=RAW_SUBSTR(rData, 1, 16);
                xCtx.xNegotiateResponse.security_blob:=RAW_SUBSTR(rData, 17);
            ELSE
                nPosition:=1;
                IF xCtx.xNegotiateResponse.cryptkeylen > 0 THEN
                    xCtx.xNegotiateResponse.cryptkey:=RAW_SUBSTR(rData, nPosition, xCtx.xNegotiateResponse.cryptkeylen); 
                    nPosition:=nPosition + xCtx.xNegotiateResponse.cryptkeylen;
                END IF;
                IF nProtocol >= 4 THEN
                    xCtx.xNegotiateResponse.domain:=RawToSmbString(rData, nPosition);
                END IF;
                IF nProtocol >= 5 THEN
                    xCtx.xNegotiateResponse.server:=RawToSmbString(rData, nPosition);
                END IF;
            END IF;
        END IF;
    END IF;
    --DebugNegotiateResponse(xCtx.xNegotiateResponse);    
END SMB_COM_NEGOTIATE;



PROCEDURE SMB_COM_SESSION_SETUP_ANDX(i_vLogin IN VARCHAR2,
                                     i_vPassword IN VARCHAR2, 
                                     i_vDomain IN VARCHAR2, 
                                     i_vWorkstation IN VARCHAR2, 
                                     i_vNativeOS IN VARCHAR2:=DBMS_UTILITY.PORT_STRING, 
                                     i_vNativeLanMan IN VARCHAR2:=vProjectName,
                                     i_rServerChallenge IN RAW:=NULL)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
    nCapabilities ULONG;
    vSecurityBlob RAW(32000);
    rPadByte RAW(1);
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_SESSION_SETUP_ANDX;
    xCtx.xSMBHeader.Flags:=BITAND(xCtx.xSMBHeader.Flags, 127);

    nCapabilities:=NVL(xCtx.xNegotiateResponse.capabilities, 0);
    IF BITAND(nCapabilities, cap_Unicode) > 0 THEN
        nCapabilities:=nCapabilities - cap_Unicode;
    END IF;
    
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;

nCapabilities:=49244 + cap_ExtendedSecurity;

--    IF i_vPassword IS NULL THEN
    IF i_rServerChallenge IS NULL THEN 
        vSecurityBlob:=security_blob_negotiate(i_vDomain, i_vWorkstation);
    ELSE
         vSecurityBlob:=security_blob_authentication(i_rServerChallenge, i_vLogin, i_vPassword, i_vDomain, i_vWorkstation);
    END IF;
    rPadByte:=NULL;
    IF BITAND(UTL_RAW.LENGTH(vSecurityBlob), 1) = 0 THEN
        rPadByte:=U8ToRaw(0);
    END IF;
--    ELSE
--        vSecurityBlob:=UTL_RAW.CAST_TO_RAW(i_vPassword);
--    END IF;
    --nCapabilities:=nCapabilities -2147483648;
    rParameters:=UTL_RAW.CONCAT(UCHARToRaw(255), -- AndXCommand
                                UCHARToRaw(0), -- AndXReserved
                                USHORTToRaw(0), -- AndXOffset
                                USHORTToRaw(65535), -- (xCtx.xNegotiateResponse.maxBufferSize), -- MaxBufferSize
                                USHORTToRaw(2), -- MaxMpxCount
                                USHORTToRaw(1), -- VcNumber
                                ULONGToRaw(xCtx.xNegotiateResponse.sesskey), -- SessionKey
                                USHORTToRaw(UTL_RAW.LENGTH(vSecurityBlob)), -- OEMPasswordLen
                    
                    
                   --             USHORTToRaw(0), -- UnicodePasswordLen
                                ULONGToRaw(0), -- Reserved
                                ULONGToRaw(nCapabilities)); -- Capabilities
--    rData:=UTL_RAW.CONCAT(UTL_RAW.CAST_TO_RAW(i_vPassword), -- OEMPassword
    rData:=UTL_RAW.CONCAT(vSecurityBlob,
    
--                          UTL_RAW.CAST_TO_RAW(i_vLogin || CHR(0)), -- AccountName
--                          UTL_RAW.CAST_TO_RAW(i_vDomain || CHR(0)), -- PrimaryDomain
                        rPadByte,
                          UTL_RAW.CAST_TO_RAW( convert(   i_vNativeOS || CHR(0)  , 'AL16UTF16LE')  ), -- NativeOS
                          UTL_RAW.CAST_TO_RAW(  convert(  i_vNativeLanMan || CHR(0),   'AL16UTF16LE'))); -- NativeLanMan
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    -- Parse Answer
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
     IF i_rServerChallenge IS NULL THEN 
        IF SMBStatusToULONG(xCtx.xSmbHeader.Status) = sus_MORE_PROCESSING_REQUIRED THEN
            DECLARE
                xNegTokenResp negTokenResp;
                xNTLMMessage NTLMMessage;
            BEGIN
                xNegTokenResp:=Decode_negTokenResp(rData);
                xNTLMMessage:=decode_challenge(xNegTokenResp.rResponseToken);
                -- MANQUE : décodage de NativeOS et NativeLAN
                IF xNTLMMessage.rServerChallenge IS NOT NULL THEN
                    SMB_COM_SESSION_SETUP_ANDX(i_vLogin, i_vPassword, i_vDomain, i_vWorkstation, i_vNativeOS, i_vNativeLanMan, xNTLMMessage.rServerChallenge);
                END IF;
            END;
        END IF;
--    ELSE
--        Dbg('Param=' || RawToDump(rParameters));
--        Dbg('Data=' || RawToDump(rData));
    END IF;
    
END SMB_COM_SESSION_SETUP_ANDX;

PROCEDURE SMB_COM_LOGOFF_ANDX
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_LOGOFF_ANDX;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=NO_ANDX;
    rData:=NULL;
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);    
END SMB_COM_LOGOFF_ANDX;


PROCEDURE SMB_COM_CHECK_DIRECTORY(i_vFolderToCheck IN VARCHAR2)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_CHECK_DIRECTORY;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=NULL;
    rData:=UTL_RAW.CONCAT(
        HexToRaw('04'), 
        SMBStringToRaw(i_vFolderToCheck));
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);

END SMB_COM_CHECK_DIRECTORY;

PROCEDURE SMB_COM_TREE_CONNECT_ANDX(i_nFlags IN PLS_INTEGER, 
                                    i_vPassword IN VARCHAR2, 
                                    i_vPath IN VARCHAR2,
                                    i_vService IN VARCHAR2, 
                                    o_nOptionalSupport OUT USHORT, 
                                    o_vService OUT VARCHAR2, 
                                    o_vNativeFileSystem OUT VARCHAR2)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;    
    nStart PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_TREE_CONNECT_ANDX;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    xCtx.xSMBHeader.TID:=65535;
    rParameters:=UTL_RAW.CONCAT(NO_ANDX,
                                USHORTToRaw(i_nFlags), -- flag
                                USHORTToRaw(LENGTH(i_vPassword || CHR(0))));
    rData:=UTL_RAW.CONCAT(OemStringToRaw(i_vPassword), 
                          SmbStringAlignToRaw(NVL(LENGTH(i_vPassword), 0)),
                          SmbStringToRaw(i_vPath),
                          OemStringToRaw(i_vService));
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        nStart:=1;
        nStart:=nStart + 4; -- NO_ANDX
        o_nOptionalSupport:=RawToUSHORT(rParameters, nStart);
        nStart:=1;
        o_vService:=RawToOemString(rData, nStart);
        SmbStringAlign(nStart, UTL_RAW.LENGTH(rParameters) + 1);
        o_vNativeFileSystem:=RawToSmbString(rData, nStart);
    END IF;

END SMB_COM_TREE_CONNECT_ANDX;       

PROCEDURE SMB_COM_TRANSACTION2(io_rSetup IN OUT NOCOPY RAW,
                               io_rTrans2Parameter IN OUT NOCOPY RAW,
                               io_rTrans2Data IN OUT NOCOPY RAW)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;    
    nFlag USHORT;
    nOffset PLS_INTEGER;
    nOffsetParam PLS_INTEGER;
    nOffsetData PLS_INTEGER;
    nPad0 PLS_INTEGER;
    nPad1 PLS_INTEGER;
    nPad2 PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_TRANSACTION2;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;

    nFlag:=0; --[A_REVOIR] DISCONNECT_TID
    nOffset:=32 + -- SMBHeader
              1 + -- Parameter length
             28 + NVL(UTL_RAW.LENGTH(io_rSetup), 0) +  -- Parameter
              2; -- Data Length
    nPad0:=0; -- Pas de pading
    IF BITAND(xCtx.xSMBHeader.Flags2, SMB_FLAGS2_UNICODE) > 0 THEN
        IF BITAND(nOffset, 1) = 1 THEN
            nPad0:=1;
            nOffset:=nOffset + 1;
        END IF;
        nOffset:=nOffset + 2;
    ELSE
        nOffset:=nOffset + 1;
    END IF;
    nPad1:=MOD(4 - MOD(nOffset, 4), 4);
    nOffset:=nOffset + nPad1;
    nOffsetParam:=nOffset;
    nOffset:=nOffset + NVL(UTL_RAW.LENGTH(io_rTrans2Parameter), 0);
    nPad2:=MOD(4 - MOD(nOffset, 4), 4);
    nOffset:=nOffset + nPad2;
    nOffsetData:=nOffset;        
    IF NVL(UTL_RAW.LENGTH(io_rTrans2Data), 0) = 0 THEN
        nOffsetData:=0;
        nPad2:=0;
    END IF;
    rParameters:=UTL_RAW.CONCAT(
        USHORTToRaw(NVL(UTL_RAW.LENGTH(io_rTrans2Parameter), 0)), -- TotalParameterCount
        USHORTToRaw(NVL(UTL_RAW.LENGTH(io_rTrans2Data), 0)), -- TotalDataCount
        USHORTToRaw(10), -- MaxParameterCount (valeur constatée dans wireshark. ??)
        USHORTToRaw(4356), -- MaxDataCount (valeur constatée dans wireshark. ??) 4356
        UCHARToRaw(0), -- MaxSetupCount (valeur constatée dans wireshark. ??)
        UCHARToRaw(0), -- Reserved1
        USHORTToRaw(nFlag), -- Flag
        ULONGToRaw(0), -- Timeout
        USHORTToRaw(0), -- Reserved2
        USHORTToRaw(NVL(UTL_RAW.LENGTH(io_rTrans2Parameter), 0)), -- ParameterCount
        USHORTToRaw(nOffsetParam), -- ParameterOffset
    UTL_RAW.CONCAT(
        USHORTToRaw(NVL(UTL_RAW.LENGTH(io_rTrans2Data), 0)), -- DataCount
        USHORTToRaw(nOffsetData), -- DataOffset
        UCHARToRaw(TRUNC(NVL(UTL_RAW.LENGTH(io_rSetup), 0) / 2)), -- SetupCount
        UCHARToRaw(0), -- Reserved3
        io_rSetup -- Setup
        ));
    rData:=UTL_RAW.CONCAT(
        PaddingRaw(nPad0),
        SMBStringToRaw(NULL),
        PaddingRaw(nPad1),
        io_rTrans2Parameter,
        PaddingRaw(nPad2),
        io_rTrans2Data);
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        io_rSetup:=NULL;
        io_rTrans2Parameter:=NULL;
        io_rTrans2Data:=NULL;
        DECLARE
            nOffsetData PLS_INTEGER;
            nStart PLS_INTEGER;
            nOffset PLS_INTEGER;
            nLength PLS_INTEGER;
        BEGIN
            nOffsetData:=32 + 1 + NVL(UTL_RAW.LENGTH(rParameters), 0) + 2;
            nStart:=7;
            nLength:=RawToUSHORT(rParameters, nStart);
            nOffset:=RawToUSHORT(rParameters, nStart);
            io_rTrans2Parameter:=RAW_SUBSTR(rData, nOffset - nOffsetData + 1, nLength);
            nStart:=nStart + 2;
            nLength:=RawToUSHORT(rParameters, nStart);
            nOffset:=RawToUSHORT(rParameters, nStart);
            io_rTrans2Data:=RAW_SUBSTR(rData, nOffset - nOffsetData + 1, nLength);
            nStart:=nStart + 2;
            nLength:=RawToUChar(rParameters, nStart) * 2;
            io_rSetup:=RAW_SUBSTR(rParameters, nStart, nLength);
        END;
    END IF;
END SMB_COM_TRANSACTION2;

PROCEDURE SMB_COM_NT_TRANSACT(i_nFunction IN USHORT,
                              io_rSetup IN OUT NOCOPY RAW,
                              io_rNTTransactParameter IN OUT NOCOPY RAW,
                              io_rNTTransactData IN OUT NOCOPY RAW,
                              i_nMaxParameterCount IN PLS_INTEGER:=10)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;  
    nOffsetParam PLS_INTEGER;
    nOffsetData PLS_INTEGER;
    nPad1 PLS_INTEGER;
    nPad2 PLS_INTEGER;
    nSetupLength PLS_INTEGER;
    nParamLength PLS_INTEGER;
    nDataLength PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_NT_TRANSACT;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    nSetupLength:=NVL(UTL_RAW.LENGTH(io_rSetup), 0);
    nParamLength:=NVL(UTL_RAW.LENGTH(io_rNTTransactParameter), 0);
    nDataLength:=NVL(UTL_RAW.LENGTH(io_rNTTransactData), 0);
    nPad1:=MOD(4 - MOD(73 + nSetupLength, 4), 4);
    nOffsetParam:=73 + nSetupLength + nPad1;
    nPad2:=MOD(4 - MOD(nParamLength, 4), 4);
    nOffsetData:=nOffsetParam + nPad2 + nParamLength;
    IF nParamLength = 0 THEN
        nOffsetParam:=0;
    END IF;
    IF nDataLength = 0 THEN
        nOffsetData:=0;
    END IF;
    rParameters:=UTL_RAW.CONCAT(
        UCHARToRaw(0), -- MaxSetupCount
        USHORTToRaw(0), -- Reserved1    
        ULONGToRaw(nParamLength), -- TotalParameterCount
        ULONGToRaw(nDataLength), -- TotalDataCount    
        ULONGToRaw(i_nMaxParameterCount), -- MaxParameterCount
        ULONGToRaw(32000), -- MaxDataCount
        ULONGToRaw(nParamLength), -- ParameterCount
        ULONGToRaw(nOffsetParam), -- ParameterOffset;
        ULONGToRaw(nDataLength), -- DataCount    
        ULONGToRaw(nOffsetData), -- DataOffset;
        UCHARToRaw(nSetupLength / 2), -- SetupCount
    UTL_RAW.CONCAT(
        USHORTToRaw(i_nFunction), -- Function
        io_rSetup));
    rData:=UTL_RAW.CONCAT(  
        PaddingRaw(nPad1),
        io_rNTTransactParameter, --Parameter
        PaddingRaw(nPad2),
        io_rNTTransactData); -- Offset   
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        DECLARE
            nStart PLS_INTEGER;
            nTotalParameterCount ULONG;
            nTotalDataCount ULONG;
            nParameterCount ULONG;
            nParameterOffset ULONG;
            nParameterDisplacement ULONG;
            nDataCount ULONG;
            nDataOffset ULONG;
            nDataDisplacement ULONG;
            nSetupCount UCHAR;
            nOffsetDate PLS_INTEGER;
        BEGIN
            nStart:=1;
            nStart:=nStart + 3; -- Reserved1
            nTotalParameterCount:=RawToULONG(rParameters, nStart); -- TotalParameterCount
            nTotalDataCount:=RawToULONG(rParameters, nStart); -- TotalDataCount
            nParameterCount:=RawToULONG(rParameters, nStart); -- ParameterCount
            nParameterOffset:=RawToULONG(rParameters, nStart); -- ParameterOffset
            nParameterDisplacement:=RawToULONG(rParameters, nStart); -- ParameterDisplacement
            nDataCount:=RawToULONG(rParameters, nStart); -- DataCount
            nDataOffset:=RawToULONG(rParameters, nStart); -- DataOffset
            nDataDisplacement:=RawToULONG(rParameters, nStart); -- DataDisplacement
            nSetupCount:=RawToUCHAR(rParameters, nStart); -- SetupCount
            io_rSetup:=RAW_SUBSTR(rParameters, nStart, nSetupCount * 2);
            nOffsetData:=32 + 1 + NVL(UTL_RAW.LENGTH(rParameters), 0) + 2;
            io_rNTTransactParameter:=RAW_SUBSTR(rData, nParameterOffset - nOffsetData + 1, nParameterCount);
            io_rNTTransactData:=RAW_SUBSTR(rData, nDataOffset - nOffsetData + 1, nDataCount);
         END;
    END IF;
        
END SMB_COM_NT_TRANSACT;

PROCEDURE SMB_COM_TRANSACTION(i_vSlotOrPipeName IN VARCHAR2, 
                              io_rTransSetup IN OUT NOCOPY RAW,
                              io_rTransParameter IN OUT NOCOPY RAW, 
                              io_rTransData IN OUT NOCOPY RAW)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;  
    nSetupCount USHORT;
    nParameterCount USHORT;
    nDataCount USHORT;
    nFlags USHORT;
    nParameterOffset USHORT;
    nDataOffset USHORT;
    nPad1 UCHAR;
    nPad2 UCHAR;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_TRANSACTION;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    nSetupCount:=NVL(UTL_RAW.LENGTH(io_rTransSetup), 0);
    nParameterCount:=NVL(UTL_RAW.LENGTH(io_rTransParameter), 0);
    nDataCount:=NVL(UTL_RAW.LENGTH(io_rTransData), 0);
    nFlags:=0;
    nParameterOffset:=63 + nSetupCount + NVL(UTL_RAW.LENGTH(SMBStringAlignToRaw(1)), 0) + SmbStringLength(LENGTH(i_vSlotOrPipeName) + 1);
    nPad1:=MOD(4 - MOD(nParameterOffset, 4), 4);
    nParameterOffset:=nParameterOffset + nPad1;
    nDataOffset:=nParameterOffset + nParameterCount;
    nPad2:=MOD(4 - MOD(nDataOffset, 4), 4);
    nDataOffset:=nDataOffset + nPad2;
    rParameters:=UTL_RAW.CONCAT(
        USHORTToRaw(nParameterCount), -- TotalParameterCount
        USHORTToRaw(nDataCount), -- TotalDataCount
        USHORTToRaw(10), -- MaxParameterCount
        USHORTToRaw(32000), -- MaxDataCount
        UCHARToRaw(0), -- MaxSetupCount
        UCHARToRaw(0), -- Reserved1
        USHORTToRaw(nFlags), -- Flags
        ULONGToRaw(0), -- Timeout
        USHORTToRaw(0), -- Reserved2
        USHORTToRaw(nParameterCount), --ParameterCount
        USHORTToRaw(nParameterOffset), -- ParameterOffset
    UTL_RAW.CONCAT(
        USHORTToRaw(nDataCount), -- DataCount
        USHORTToRaw(nDataOffset), -- DataOffset
        UCHARToRaw(nSetupCount / 2), -- SetupCount
        UCHARToRaw(0), -- Reserved3
        io_rTransSetup));
    rData:=UTL_RAW.CONCAT(
        SMBStringAlignToRaw(1), 
        SmbStringToRaw(i_vSlotOrPipeName), -- Name
        PaddingRaw(nPad1), -- Pad1
        io_rTransParameter, -- Trans_Parameters
        PaddingRaw(nPad2), -- Pad2
        io_rTransData); -- Data
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        DECLARE
            nTotalParameterCount USHORT;
            nTotalDataCount USHORT;
            nParameterCount USHORT;
            nParameterOffset USHORT;
            nParameterDisplacement USHORT;
            nDataCount USHORT;
            nDataOffset USHORT;
            nDataDisplacement USHORT;
            nSetupCount UCHAR;
            nStart PLS_INTEGER;
            nOffset PLS_INTEGER;
        BEGIN
            nStart:=1;
            nTotalParameterCount:=RawToUSHORT(rParameters, nStart); -- TotalParameterCount
            nTotalDataCount:=RawToUSHORT(rParameters, nStart); -- TotalDataCount
            nStart:=nStart + 2; -- Reserved1
            nParameterCount:=RawToUSHORT(rParameters, nStart); -- ParameterCount
            nParameterOffset:=RawToUSHORT(rParameters, nStart); -- ParameterOffset
            nParameterDisplacement:=RawToUSHORT(rParameters, nStart); -- ParameterDisplacement
            nDataCount:=RawToUSHORT(rParameters, nStart); -- DataCount
            nDataOffset:=RawToUSHORT(rParameters, nStart); -- DataOffset
            nDataDisplacement:=RawToUSHORT(rParameters, nStart); -- DataDisplacement
            nSetupCount:=RawToUCHAR(rParameters, nStart); -- SetupCount
            nStart:=nStart + 1; -- Reserved2
            io_rTransSetup:=RAW_SUBSTR(rParameters, nStart, nSetupCount * 2); -- Setup
            nOffset:=32 + 1 + NVL(UTL_RAW.LENGTH(rParameters), 0) + 2;
            io_rTransParameter:=RAW_SUBSTR(rData, nParameterOffset - nOffset + 1, nParameterCount);
            io_rTransData:=RAW_SUBSTR(rData, nDataOffset - nOffset + 1, nDataCount);
        END;
    END IF;
    
END SMB_COM_TRANSACTION;

PROCEDURE RAP_REQUEST(i_nRapOpCode IN USHORT,
                      i_vParamDesc IN VARCHAR2, 
                      i_vDataDesc IN VARCHAR2, 
                      io_rRapParam IN OUT NOCOPY RAW, 
                      io_rRapData IN OUT NOCOPY RAW,
                      o_vErrorCode OUT ERRSTR, 
                      o_nConverter OUT USHORT)
IS
    rTransSetup RAW(10);
    rTransParameter RAW(1000); 
    nStart PLS_INTEGER;
    vIndiceError VARCHAR2(8);
    nErrorCode USHORT;
BEGIN
    rTransSetup:=NULL;
    rTransParameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nRapOpCode), -- RapOpCode
        OEMStringToRaw(i_vParamDesc), -- ParamDesc
        OEMStringToRaw(i_vDataDesc), -- DataDesc
        io_rRapParam -- RapParam
        );
    SMB_COM_TRANSACTION('\PIPE\LANMAN', rTransSetup, rTransParameter, io_rRapData);
    IF ok THEN
        nStart:=1;
        nErrorCode:=RawToUSHORT(rTransParameter, nStart);
        IF nErrorCode = 0 THEN
            o_vErrorCode:=NULL;
        ELSE
            vIndiceError:=RawToHex(U32BEToRaw(nErrorCode));
            IF TvErrors.COUNT = 0 THEN
                INIT_ERRORS; 
            END IF;
            IF TvErrors.EXISTS(vIndiceError) THEN
                o_vErrorCode:=TvErrors(vIndiceError);
            ELSE
                o_vErrorCode:='Error 0x' || vIndiceError;
            END IF;
        END IF;
        o_nConverter:=RawToUSHORT(rTransParameter, nStart);
        IF nStart < UTL_RAW.LENGTH(rTransParameter) THEN
            io_rRapParam:=RAW_SUBSTR(rTransParameter, nStart);
        ELSE
            io_rRapParam:=NULL;
        END IF;
    END IF;
        
END RAP_REQUEST;

FUNCTION RawToRapString(io_rData IN OUT NOCOPY RAW,
                        i_nConverter IN USHORT,
                        io_nStart IN OUT NOCOPY PLS_INTEGER) RETURN VARCHAR2
IS
    nStart PLS_INTEGER;
BEGIN
    nStart:=RawToUSHORT(io_rData, io_nStart) - i_nConverter + 1; 
    io_nStart:=io_nStart + 2; 
    RETURN RawToOEMString(io_rData, nStart); 
END RawToRapString;

PROCEDURE RAP_NetServerGetInfo(i_nInfoLevel IN USHORT, 
                               io_xServerInfo IN OUT NOCOPY HOST_INFO_T,
                               o_vError OUT ERRSTR)
IS
    rParameter RAW(50);
    rData RAW(32000);
    nConverter USHORT;
    nTotalBytesAvailable USHORT;
    nStart PLS_INTEGER;
BEGIN
    rParameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nInfoLevel), -- InfoLevel
        USHORTToRaw(32000) --ReceiveBufferSize
        );
    RAP_REQUEST(NetServerGetInfo, 'WrLh', 'B16BBDz', rParameter, rData, o_vError, nConverter);
    IF o_vError IS NULL THEN
        nStart:=1;
        nTotalBytesAvailable:=RawToUSHORT(rParameter, nStart); -- TotalBytesAvailable
        nStart:=1;
        io_xServerInfo.vHostName:=RawToOEMString(rData, nStart); -- ServerName
        IF i_nInfoLevel >= 1 THEN
            nStart:=17;
            io_xServerInfo.nMajorVersion:=RawToUCHAR(rData, nStart); -- MajorVersion
            io_xServerInfo.nMinorVersion:=RawToUCHAR(rData, nStart); -- MinorVersion
            io_xServerInfo.nServerType:=RawToULONG(rData, nStart); -- ServerType
            io_xServerInfo.vServerComment:=RawToRapString(rData, nConverter, nStart); -- vServerComment
        END IF;
    END IF;
                
END RAP_NetServerGetInfo;

FUNCTION RAP_NetShareEnumRequest(i_nInfoLevel IN USHORT, 
                                 o_vError OUT ERRSTR) RETURN SHARE_INFO_C
IS
    rParameter RAW(50);
    vDataDesc VARCHAR2(40);
    rData RAW(32000);
    vErrorCode ERRSTR;
    nConverter USHORT;
    nEntriesReturned USHORT;
    nEntriesAvailable USHORT;
    nStart PLS_INTEGER;
    nRecordLength PLS_INTEGER;
    TxShare SHARE_INFO_C;
BEGIN
    rParameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nInfoLevel), -- InfoLevel
        USHORTToRaw(32000) --ReceiveBufferSize
        );
    CASE i_nInfoLevel
        WHEN 0 THEN
            vDataDesc:='B13';
        WHEN 1 THEN
            vDataDesc:='B13BWz';
        WHEN 2 THEN
            vDataDesc:='B13BWzWWWzB9B';
    END CASE;
    RAP_REQUEST(NetShareEnum, 'WrLeh', vDataDesc, rParameter, rData, o_vError, nConverter);
    IF o_vError IS NULL THEN
        nStart:=1;
        nEntriesReturned:=RawToUSHORT(rParameter, nStart);
        nEntriesAvailable:=RawToUSHORT(rParameter, nStart);
        CASE i_nInfoLevel 
            WHEN 0 THEN nRecordLength:=13;
            WHEN 1 THEN nRecordLength:=20;
            WHEN 2 THEN nRecordLength:=40;
        END CASE;        
        FOR i IN 1..nEntriesReturned
        LOOP
            nStart:=(i - 1) * nRecordLength + 1;
            TxShare(i).vShareName:=RawToOEMString(rData, nStart); -- NetworkName
            IF i_nInfoLevel >= 1 THEN
                nStart:=(i - 1) * nRecordLength + 15;
                TxShare(i).nType:=RawToUSHORT(rData, nStart); -- Type
                TxShare(i).vRemark:=RawToRapString(rData, nConverter, nStart); -- Remark
                IF i_nInfoLevel >= 2 THEN
                    nStart:=nStart + 2; -- Permissions (obsolete)
                    TxShare(i).nMaxUses:=RawToUSHORT(rData, nStart); -- MaxUses
                    TxShare(i).nCurrentUses:=RawToUSHORT(rData, nStart); -- CurrentUses
                    TxShare(i).vPath:=RawToRapString(rData, nConverter, nStart); -- Path
                    TxShare(i).vPassword:=RawToOEMString(rData, nStart); -- Password
                END IF;
            END IF;
        END LOOP;
    END IF;
    RETURN TxShare;
    
END RAP_NetShareEnumRequest;

-- For RAP_NetServerEnum2 and RAP_NetServerEnum3
FUNCTION RAP_NetServerEnumX(i_nOpCode IN UCHAR,
                            i_nInfoLevel IN USHORT,
                            i_nServerType IN ULONG,
                            i_vDomainName IN VARCHAR2:=NULL,
                            i_vFirstNameToReturn IN VARCHAR2:=NULL,
                            o_vError OUT ERRSTR) RETURN HOST_INFO_C
IS
    rParameter RAW(200);
    rData RAW(32000);
    vErrorCode ERRSTR;
    nConverter USHORT;
    vParamDesc VARCHAR2(40);
    vDataDesc VARCHAR2(40);
    nEntriesReturned USHORT;
    nEntriesAvailable USHORT;
    nStart PLS_INTEGER;   
    nRecordLength PLS_INTEGER;
    TxServer HOST_INFO_C;
BEGIN
    rParameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nInfoLevel), -- InfoLevel
        USHORTToRaw(32000), --ReceiveBufferSize
        ULONGToRaw(i_nServerType) -- nServerType,
        );
    IF i_nOpCode = NetServerEnum3 THEN
        vParamDesc:='WrLehDzz';
        rParameter:=UTL_RAW.CONCAT(
            rParameter, 
            OEMStringToRaw(i_vDomainName), -- DomainName
            OEMStringToRaw(i_vFirstNameToReturn) -- FirstNameToReturn
            );
    ELSIF i_vDomainName IS NOT NULL THEN
        vParamDesc:='WrLehDz';
        rParameter:=UTL_RAW.CONCAT(
            rParameter, 
            OEMStringToRaw(i_vDomainName)   -- DomainName
            );
    ELSE
        vParamDesc:='WrLehDO';
    END IF;
    CASE i_nInfoLevel
        WHEN 0 THEN
            vDataDesc:='B16';
        WHEN 1 THEN
            vDataDesc:='B16BBDz';
    END CASE;    
    RAP_REQUEST(i_nOpCode, vParamDesc, vDataDesc, rParameter, rData, o_vError, nConverter);
    IF o_vError IS NULL THEN
        nStart:=1;
        nEntriesReturned:=RawToUSHORT(rParameter, nStart);
        nEntriesAvailable:=RawToUSHORT(rParameter, nStart);
        CASE i_nInfoLevel 
            WHEN 0 THEN nRecordLength:=16;
            WHEN 1 THEN nRecordLength:=26;
        END CASE;        
        FOR i IN 1..nEntriesReturned
        LOOP
            nStart:=(i - 1) * nRecordLength + 1;
            TxServer(i).vHostName:=RawToOEMString(rData, nStart); -- ServerName
            IF i_nInfoLevel = 1 THEN
                nStart:=(i - 1) * nRecordLength + 17;
                TxServer(i).nMajorVersion:=RawToUCHAR(rData, nStart); -- MajorVersion
                TxServer(i).nMinorVersion:=RawToUCHAR(rData, nStart); -- MinorVersion
                TxServer(i).nServerType:=RawToULONG(rData, nStart); -- ServerType
                TxServer(i).vServerComment:=RawToRapString(rData, nConverter, nStart);
            END IF;
        END LOOP;  
    END IF;
    RETURN TxServer;

END RAP_NetServerEnumX;

FUNCTION RAP_NetServerEnum2(i_nInfoLevel IN USHORT,
                            i_nServerType IN ULONG,
                            i_vDomainName IN VARCHAR2:=NULL,
                            o_vError OUT ERRSTR) RETURN HOST_INFO_C
IS
BEGIN
    RETURN RAP_NetServerEnumX(NetServerEnum2, i_nInfoLevel, i_nServerType, i_vDomainName, NULL, o_vError);
END RAP_NetServerEnum2;


FUNCTION RAP_NetServerEnum3(i_nInfoLevel IN USHORT,
                            i_nServerType IN ULONG,
                            i_vDomainName IN VARCHAR2:=NULL, 
                            i_vFirstNameToReturn IN VARCHAR2:=NULL,
                            o_vError OUT ERRSTR) RETURN HOST_INFO_C
IS
BEGIN
    RETURN RAP_NetServerEnumX(NetServerEnum3, i_nInfoLevel, i_nServerType, i_vDomainName, i_vFirstNameToReturn, o_vError);
END RAP_NetServerEnum3;

FUNCTION RAP_NetUserGetInfo(i_nInfoLevel IN USHORT,
                            i_vUserName IN VARCHAR2, 
                            o_vError OUT ERRSTR) RETURN USER_INFO_T
IS
    rParameter RAW(200);
    rData RAW(32000);
    vErrorCode ERRSTR;
    nConverter USHORT;
    nStart PLS_INTEGER;
    xUserInfo USER_INFO_T;    
BEGIN
    rParameter:=UTL_RAW.CONCAT(
        OEMStringToRaw(i_vUserName), -- UserName
        USHORTToRaw(i_nInfoLevel), -- InfoLevel
        USHORTToRaw(32000) --ReceiveBufferSize
        );
    rData:=NULL;
    RAP_REQUEST(NetUserGetInfo, 'zWrLh', NULL, rParameter, rData, o_vError, nConverter);
    IF o_vError IS NULL THEN
        nStart:=1;
        xUserInfo.vUserName:=RawToOEMString(rData, nStart); -- Name
        IF i_nInfoLevel IN (1, 2) THEN
            nStart:=23;
            xUserInfo.vPassword:=RawToOEMString(rData, nStart); -- Password
            nStart:=39;
            xUserInfo.nPasswordAge:=RawToULONG(rData, nStart); -- PasswordAge
            xUserInfo.nPriv:=RawToUSHORT(rData, nStart); -- Priv
            xUserInfo.vHomeDir:=RawToRapString(rData, nConverter, nStart); -- HomeDir
            xUserInfo.vComment:=RawToRapString(rData, nConverter, nStart); -- Comment
            xUserInfo.nFlags:=RawToUSHORT(rData, nStart); -- Flags
            xUserInfo.vScriptPath:=RawToRapString(rData, nConverter, nStart); -- ScriptPath       
            IF i_nInfoLevel = 2 THEN
                xUserInfo.nAuthFlags:=RawToULONG(rData, nStart); -- AuthFlags
                xUserInfo.vFullName:=RawToRapString(rData, nConverter, nStart); -- FullName
                xUserInfo.vUsrComment:=RawToRapString(rData, nConverter, nStart); -- UsrComment
                xUserInfo.vParms:=RawToRapString(rData, nConverter, nStart); -- Parms
                xUserInfo.vWorkStations:=RawToRapString(rData, nConverter, nStart); -- WorkStations
                xUserInfo.dLastLogon:=NbSec1970ToDate(RawToULONG(rData, nStart)); -- LastLogon
                xUserInfo.dLastLogOff:=NbSec1970ToDate(RawToULONG(rData, nStart)); -- LastLogOff
                xUserInfo.dAcctExpires:=NbSec1970ToDate(RawToULONG(rData, nStart)); -- AcctExpires
                xUserInfo.nMaxStorage:=RawToULONG(rData, nStart); -- MaxStorage
                xUserInfo.nUnitsPerWeek:=RawToUSHORT(rData, nStart); -- UnitsPerWeek
                xUserInfo.vLogonHours:=RawToDump(RAW_SUBSTR(rData, RawToUSHORT(rData, nStart) - nConverter + 1, 21)); nStart:=nStart + 2; -- LogonHours
                xUserInfo.nBadPwCount:=RawToUSHORT(rData, nStart); -- BadPwCount
                xUserInfo.nNumLogons:=RawToUSHORT(rData, nStart); -- NumLogons
                xUserInfo.vLogonServer:=RawToRapString(rData, nConverter, nStart); -- LogonServer
                xUserInfo.nCountryCode:=RawToUSHORT(rData, nStart); -- CountryCode
                xUserInfo.nCodePage:=RawToUSHORT(rData, nStart); -- CodePage
            END IF;
        ELSIF i_nInfoLevel IN (10, 11) THEN
            nStart:=23;
            xUserInfo.vComment:=RawToRapString(rData, nConverter, nStart); -- Comment
            xUserInfo.vUsrComment:=RawToRapString(rData, nConverter, nStart); -- UsrComment
            xUserInfo.vFullName:=RawToRapString(rData, nConverter, nStart); -- FullName
            IF i_nInfoLevel = 11 THEN
                xUserInfo.nPriv:=RawToUSHORT(rData, nStart); -- Priv
                xUserInfo.nAuthFlags:=RawToULONG(rData, nStart); -- AuthFlags
                xUserInfo.nPasswordAge:=RawToULONG(rData, nStart); -- PasswordAge
                xUserInfo.vHomeDir:=RawToRapString(rData, nConverter, nStart); -- HomeDir
                xUserInfo.vParms:=RawToRapString(rData, nConverter, nStart); -- Parms
                xUserInfo.dLastLogon:=NbSec1970ToDate(RawToULONG(rData, nStart)); -- LastLogon
                xUserInfo.dLastLogOff:=NbSec1970ToDate(RawToULONG(rData, nStart)); -- LastLogOff
                xUserInfo.nBadPwCount:=RawToUSHORT(rData, nStart); -- BadPwCount
                xUserInfo.nNumLogons:=RawToUSHORT(rData, nStart); -- NumLogons
                xUserInfo.vLogonServer:=RawToRapString(rData, nConverter, nStart); -- LogonServer
                xUserInfo.nCountryCode:=RawToUSHORT(rData, nStart); -- CountryCode
                xUserInfo.vWorkStations:=RawToRapString(rData, nConverter, nStart); -- WorkStations
                xUserInfo.nMaxStorage:=RawToULONG(rData, nStart); -- MaxStorage
                xUserInfo.nUnitsPerWeek:=RawToUSHORT(rData, nStart); -- UnitsPerWeek
                xUserInfo.vLogonHours:=RawToDump(RAW_SUBSTR(rData, RawToUSHORT(rData, nStart) - nConverter + 1, 21)); nStart:=nStart + 2; -- LogonHours
                xUserInfo.nCodePage:=RawToUSHORT(rData, nStart); -- CodePage
            END IF;
        END IF;
    END IF;
    RETURN xUserInfo;

END RAP_NetUserGetInfo;

PROCEDURE RAP_NetWkstaGetInfo(io_xServerInfo IN OUT NOCOPY HOST_INFO_T, 
                              o_vError OUT ERRSTR)
IS
    rParameter RAW(200);
    rData RAW(1300);
    nConverter USHORT;
    nStart PLS_INTEGER;
    nPointer ULONG;
BEGIN
    rParameter:=UTL_RAW.CONCAT(
        USHORTToRaw(10), -- InfoLevel
        USHORTToRaw(1300) --ReceiveBufferSize
        );
    rData:=NULL;
    RAP_REQUEST(NetWkstaGetInfo, 'WrLh', 'zzzBBzz', rParameter, rData, o_vError, nConverter);
    IF o_vError IS NULL THEN
        nStart:=1;
        nPointer:=RawToULONG(rData, nStart) + 1; -- ComputerName
        io_xServerInfo.vHostName:=SUBSTR(RawToOEMString(rData, nPointer), 1, 255);
        nPointer:=RawToULONG(rData, nStart) + 1; -- UserName
        io_xServerInfo.vUserName:=SUBSTR(RawToOEMString(rData, nPointer), 1, 255);
        nPointer:=RawToULONG(rData, nStart) + 1; -- LanGroup
        io_xServerInfo.vLanGroup:=SUBSTR(RawToOEMString(rData, nPointer), 1, 255);
        io_xServerInfo.nMajorVersion:=RawToUCHAR(rData, nStart); -- VerMajor
        io_xServerInfo.nMinorVersion:=RawToUCHAR(rData, nStart); -- VerMinor
        nPointer:=RawToULONG(rData, nStart) + 1; -- LogonDomain
        io_xServerInfo.vLogonDomain:=SUBSTR(RawToOEMString(rData, nPointer), 1, 255);
        nPointer:=RawToULONG(rData, nStart) + 1; -- OtherDomain
        io_xServerInfo.vOtherDomain:=SUBSTR(RawToOEMString(rData, nPointer), 1, 255);
    END IF;
END RAP_NetWkstaGetInfo;

PROCEDURE RAP_NetRemoteTOD(io_xServerInfo IN OUT NOCOPY HOST_INFO_T, 
                           o_vError OUT ERRSTR)
IS
    rParameter RAW(200);
    rData RAW(100);
    nConverter USHORT;
    nStart PLS_INTEGER;
    dTimeSinceJan11970 DATE;
    nHours UCHAR;
    nMinutes UCHAR;
    nSeconds UCHAR;
    nHundreds UCHAR;
    nTimeZone PLS_INTEGER;
    nDay UCHAR;
    nMonth UCHAR;
    nYear USHORT;
    nWeekday UCHAR;
    nClockFrequency USHORT;
BEGIN
    rParameter:=USHORTToRaw(100); --ReceiveBufferSize
    rData:=NULL;
    RAP_REQUEST(NetRemoteTOD, 'rL', 'DDBBBBWWBBWB', rParameter, rData, o_vError, nConverter);
    IF o_vError IS NULL THEN
        nStart:=1;
        dTimeSinceJan11970:=NbSec1970ToDate(RawToULONG(rData, nStart)); -- TimeSinceJan11970
        io_xServerInfo.nTimeSinceBoot:=RawToULONG(rData, nStart); -- TimeSinceBoot
        nHours:=RawToUCHAR(rData, nStart); -- Hours
        nMinutes:=RawToUCHAR(rData, nStart); -- Minutes
        nSeconds:=RawToUCHAR(rData, nStart); -- Seconds
        nHundreds:=RawToUCHAR(rData, nStart); -- Hundreds
        nTimeZone:=RawToUSHORT(rData, nStart); -- TimeZone
        IF nTimeZone > 32767 THEN
            nTimeZone:=nTimeZone - 65536;
        END IF;
        nClockFrequency:=RawToUSHORT(rData, nStart); -- ClockFrequency
        nDay:=RawToUCHAR(rData, nStart); -- Day
        nMonth:=RawToUCHAR(rData, nStart); -- Month
        nYear:=RawToUSHORT(rData, nStart); -- Year
        nWeekday:=RawToUCHAR(rData, nStart); -- Weekday
        io_xServerInfo.tSystemTimestamp:=TO_TIMESTAMP_TZ(TO_CHAR(dTimeSinceJan11970, 'YYYY-MM-DD HH24:MI:SS') || 
                                                         TO_CHAR(nHundreds / 100, '.00000') ||
                                                         ' ' || TO_CHAR(TRUNC(SYSDATE) - nTimeZone /1440, 'HH24:MI'), 
                                                         'YYYY-MM-DD HH24:MI:SS.FF TZH:TZM');
    END IF;

END RAP_NetRemoteTOD;

FUNCTION RawToSID(io_rSID IN OUT NOCOPY RAW,
                  io_nStart IN OUT NOCOPY PLS_INTEGER) RETURN SID_T
IS
    xSID SID_T;
BEGIN
    xSID.nRevision:=RawToUCHAR(io_rSID, io_nStart); -- Revision
    xSID.nSubAuthorityCount:=RawToUCHAR(io_rSID, io_nStart); -- SubAuthorityCount
    xSID.xIdentifierAuthority:=RAW_SUBSTR(io_rSID, io_nStart, 6); io_nStart:=io_nStart + 6; -- IdentifierAuthority
    xSID.xSubAuthority:=SUB_AUTHORITY_C();
    xSID.xSubAuthority.EXTEND(xSID.nSubAuthorityCount);
    FOR i IN 1..xSID.nSubAuthorityCount
    LOOP
        xSID.xSubAuthority(i):=RawToULONG(io_rSID, io_nStart); 
    END LOOP;
    RETURN xSID;
    
END RawToSID;

FUNCTION SIDToString(i_xSID IN SID_T) RETURN VARCHAR2
IS
    vSID VARCHAR2(1000);
    nTest ULONG;
    nStart PLS_INTEGER;
    xIdentifierAuthority SID_IDENTIFIER_AUTHORITY_T;
BEGIN
    IF i_xSID.nRevision IS NULL THEN
        vSID:=NULL;
    ELSE
        vSID:='S-' || TO_CHAR(i_xSID.nRevision) || '-';
        nStart:=1;
        xIdentifierAuthority:=i_xSID.xIdentifierAuthority;
        nTest:=RawToUSHORT(xIdentifierAuthority, nStart);
        IF nTest = 0 THEN
            -- Decimal representation
            nStart:=3;
            vSID:=vSID || TO_CHAR(RawToU32BE(xIdentifierAuthority, nStart));
        ELSE
            -- Hexadecimal representation
            vSID:=vSID || '0x' || RawToHex(xIdentifierAuthority);
        END IF;
        FOR i IN 1..i_xSID.nSubAuthorityCount
        LOOP
            vSID:=vSID || '-' || TO_CHAR(i_xSID.xSubAuthority(i));
        END LOOP;
    END IF;
    RETURN vSID;
END SIDToString;

FUNCTION RawToACE(io_rACE IN OUT NOCOPY RAW,
                  io_nStart IN OUT NOCOPY PLS_INTEGER) RETURN ACE_T
IS
    xACE ACE_T;
    nLength USHORT;
BEGIN
    xACE.nAceType:=RawToUCHAR(io_rACE, io_nStart);
    xACE.nAceFlag:=RawToUCHAR(io_rACE, io_nStart);
    nLength:=RawToUSHORT(io_rACE, io_nStart);
    CASE xACE.nAceType
        WHEN ACCESS_ALLOWED_ACE THEN
            xACE.nMask:=RawToULONG(io_rACE, io_nStart);
            xACE.xSID:=RawToSID(io_rAce, io_nStart);
        WHEN ACCESS_DENIED_ACE THEN
            xACE.nMask:=RawToULONG(io_rACE, io_nStart);
            xACE.xSID:=RawToSID(io_rACE, io_nStart);
        
    END CASE;
    
    RETURN xACE;

END RawToACE;

FUNCTION RawToACL(io_rACL IN OUT NOCOPY RAW,
                  io_nStart IN OUT NOCOPY PLS_INTEGER) RETURN ACL_T
IS
    xACL ACL_T;
BEGIN
    xACL.nAclRevision:=RawToUCHAR(io_rACL, io_nStart);
    xACL.nSbz1:=RawToUCHAR(io_rACL, io_nStart);
    xACL.nAclSize:=RawToUSHORT(io_rACL, io_nStart);
    xACL.nAceCount:=RawToUSHORT(io_rACL, io_nStart);
    xACL.nSbz2:=RawToUSHORT(io_rACL, io_nStart);
    FOR i IN 1..xACL.nAceCount
    LOOP
        xACL.TxAce(i):=RawToACE(io_rACL, io_nStart);
    END LOOP;
    RETURN xACL;
    
END RawToACL;

PROCEDURE RawToSecurityDescriptor(io_rSecDesc IN OUT NOCOPY RAW, 
                                  io_nStart IN OUT NOCOPY PLS_INTEGER, 
                                  io_xSecurityDesc IN OUT NOCOPY SecurityDescriptor_T)
IS
    nStart PLS_INTEGER;
    nOffsetOwner ULONG;
    nOffsetGroup ULONG;
    nOffsetSacl ULONG;
    nOffsetDacl ULONG;
BEGIN
    nStart:=1;
    io_xSecurityDesc.nRevision:=RawToUCHAR(io_rSecDesc, io_nStart); -- Revision
    io_xSecurityDesc.nSbz1:=RawToUCHAR(io_rSecDesc, io_nStart); -- Sbz1
    io_xSecurityDesc.nControl:=RawToUSHORT(io_rSecDesc, io_nStart); -- Control
    nOffsetOwner:=RawToULONG(io_rSecDesc, io_nStart); -- OffsetOwner
    IF nOffsetOwner > 0 THEN
        nStart:=nOffsetOwner + 1;
        io_xSecurityDesc.xOwnerSID:=RawToSID(io_rSecDesc, nStart);
    END IF;
    nOffsetGroup:=RawToULONG(io_rSecDesc, io_nStart); -- OffsetGroup
    IF nOffsetGroup > 0 THEN
        nStart:=nOffsetGroup + 1;
        io_xSecurityDesc.xGroupSID:=RawToSID(io_rSecDesc, nStart);
    END IF;
    nOffsetSacl:=RawToULONG(io_rSecDesc, io_nStart); -- OffsetSacl
    IF nOffsetSacl > 0 THEN
        nStart:=nOffsetSacl + 1;
        io_xSecurityDesc.xSAcl:=RawToACL(io_rSecDesc, nStart); -- Sacl
    END IF;
    nOffsetDacl:=RawToULONG(io_rSecDesc, io_nStart); -- OffsetDacl
    IF nOffsetDacl > 0 THEN
        nStart:=nOffsetDacl + 1;
        io_xSecurityDesc.xDAcl:=RawToACL(io_rSecDesc, nStart); -- Dacl
    END IF;

END RawToSecurityDescriptor;

FUNCTION AceTypeToString(i_nAceType IN PLS_INTEGER) RETURN VARCHAR2
IS
    vAceType VARCHAR2(100);
BEGIN
    CASE i_nAceType
        WHEN 0 THEN vAceType:='ACCESS_ALLOWED_ACE_TYPE';
        WHEN 1 THEN vAceType:='ACCESS_DENIED_ACE_TYPE';
        WHEN 2 THEN vAceType:='SYSTEM_AUDIT_ACE_TYPE';
        WHEN 3 THEN vAceType:='SYSTEM_ALARM_ACE_TYPE';
        WHEN 4 THEN vAceType:='ACCESS_ALLOWED_COMPOUND_ACE_TYPE';
        WHEN 5 THEN vAceType:='ACCESS_ALLOWED_OBJECT_ACE_TYPE';
        WHEN 6 THEN vAceType:='ACCESS_DENIED_OBJECT_ACE_TYPE';
        WHEN 7 THEN vAceType:='SYSTEM_AUDIT_OBJECT_ACE_TYPE';
        WHEN 8 THEN vAceType:='SYSTEM_ALARM_OBJECT_ACE_TYPE';
        WHEN 9 THEN vAceType:='ACCESS_ALLOWED_CALLBACK_ACE_TYPE';
        WHEN 10 THEN vAceType:='ACCESS_DENIED_CALLBACK_ACE_TYPE';
        WHEN 11 THEN vAceType:='ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE';
        WHEN 12 THEN vAceType:='ACCESS_DENIED_CALLBACK_OBJECT_ACE_TYPE';
        WHEN 13 THEN vAceType:='SYSTEM_AUDIT_CALLBACK_ACE_TYPE';
        WHEN 14 THEN vAceType:='SYSTEM_ALARM_CALLBACK_ACE_TYPE';
        WHEN 15 THEN vAceType:='SYSTEM_AUDIT_CALLBACK_OBJECT_ACE_TYPE';
        WHEN 16 THEN vAceType:='SYSTEM_ALARM_CALLBACK_OBJECT_ACE_TYPE';
        WHEN 17 THEN vAceType:='SYSTEM_MANDATORY_LABEL_ACE_TYPE';
        WHEN 18 THEN vAceType:='SYSTEM_RESOURCE_ATTRIBUTE_ACE_TYPE';
        WHEN 19 THEN vAceType:='SYSTEM_SCOPED_POLICY_ID_ACE_TYPE';
        ELSE vAceType:='UNKNWON';
    END CASE;
    RETURN vAceType;
    
END AceTypeToString;

PROCEDURE NT_TRSACT_QUERY_SECURITY_DESC(i_nFID IN USHORT,
                                        i_nSecurityInfoFields IN ULONG,
                                        io_xSecurityDesc IN OUT NOCOPY SecurityDescriptor_T)
IS
    nFunction USHORT;
    rSetup RAW(512);
    rNTTransactParameter RAW(32000);
    rNTTransactData RAW(32000);
    nStart PLS_INTEGER;
BEGIN
    nFunction:=NTTr_QUERY_SECURITY_DESC;
    rSetup:=NULL;
    rNTTransactParameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nFID), -- FID
        USHORTToRaw(0), -- Reserved
        ULONGToRaw(i_nSecurityInfoFields)); -- SecurityInfoFields
    rNTTransactData:=NULL;
    SMB_COM_NT_TRANSACT(nFunction, rSetup, rNTTransactParameter, rNTTransactData);
    IF ok THEN
        nStart:=1;
        RawToSecurityDescriptor(rNTTransactData, nStart, io_xSecurityDesc);
    END IF;
          
END NT_TRSACT_QUERY_SECURITY_DESC;

PROCEDURE NT_TRSACT_NOTIFY_CHANGE(i_nCompletionFilter IN ULONG,
                                  i_nFID IN USHORT,
                                  i_bWatchTree IN BOOLEAN, 
                                  o_TxFileNotifyInfo OUT FILE_NOTIFY_INFO_C)
IS
    nFunction USHORT;
    rSetup RAW(512);
    rNTTransactParameter RAW(32000);
    rNTTransactData RAW(32000);
    nStart PLS_INTEGER;
    nNextEntryOffset ULONG;
    nFileNameLength ULONG;
    nAction ULONG;
    nIdx PLS_INTEGER;
    vFileName VARCHAR2(255);
BEGIN
    nFunction:=NTTr_NOTIFY_CHANGE;
    rSetup:=UTL_RAW.CONCAT(
        ULONGToRaw(i_nCompletionFilter), -- CompletionFilter
        USHORTToRaw(i_nFID), -- FID
        BooleanToRaw(i_bWatchTree), -- WatchTree
        UCHARToRaw(0)); -- Reserved
    rNTTransactParameter:=NULL;
    rNTTransactData:=NULL;
    SMB_COM_NT_TRANSACT(nFunction, rSetup, rNTTransactParameter, rNTTransactData, 4096);
    IF ok THEN
        nStart:=1;
        IF rNTTransactParameter IS NOT NULL THEN
            LOOP
                nNextEntryOffset:=RawToULONG(rNTTransactParameter, nStart);
                nAction:=RawToULONG(rNTTransactParameter, nStart);
                nFileNameLength:=RawToULONG(rNTTransactParameter, nStart);
                vFileName:=SmbStringToString(RawToFixedLengthString(rNTTransactParameter, nStart, nFileNameLength));
                nIdx:=o_TxFileNotifyInfo.COUNT + 1;
                o_TxFileNotifyInfo(nIdx).vFileName:=vFileName;
                o_TxFileNotifyInfo(nIdx).nFileAction:=nAction;
                EXIT WHEN nNextEntryOffset = 0;
                nStart:=1 + nNextEntryOffset;
            END LOOP;
        END IF;
    END IF;
          
END NT_TRSACT_NOTIFY_CHANGE;

PROCEDURE NT_TRSACT_IOCTL(i_nFunctionCode IN ULONG,
                          i_nFID IN USHORT,
                          i_bIsFctl IN BOOLEAN,
                          i_IsFlags IN BOOLEAN,
                          io_rData IN OUT NOCOPY RAW)
IS
    nFunction USHORT;
    rSetup RAW(512);
    rNTTransactParameter RAW(32000);
    rNTTransactData RAW(32000);
    nStart PLS_INTEGER;
BEGIN
    nFunction:=NTTr_IOCTL;
    rSetup:=UTL_RAW.CONCAT(
        ULONGToRaw(i_nFunctionCode), -- FunctionCode
        USHORTToRaw(i_nFID), -- FID
        BOOLEANToRaw(i_bIsFctl), -- IsFctl
        BOOLEANToRaw(i_IsFlags)); -- IsFlags
    rNTTransactParameter:=NULL;
    SMB_COM_NT_TRANSACT(nFunction, rSetup, rNTTransactParameter, io_rData);
    IF ok THEN
        nStart:=1;
    END IF;
        
END NT_TRSACT_IOCTL;

PROCEDURE FSCTL_SRV_REQUEST_RESUME_KEY(i_nFID IN USHORT, 
                                       o_rCopychunkResumeKey OUT RAW)
IS
    rData RAW(32000);
BEGIN
    rData:=NULL;
    NT_TRSACT_IOCTL(FsctlSrv_REQUEST_RESUME_KEY, i_nFID, TRUE, FALSE, rData);
    IF ok THEN
        o_rCopychunkResumeKey:=RAW_SUBSTR(rData, 1, 24);
    END IF; 
END FSCTL_SRV_REQUEST_RESUME_KEY;

PROCEDURE FSCTL_SRV_COPYCHUNK(i_nFID IN USHORT, 
                              io_rCopychunkResumeKey IN OUT NOCOPY RAW, 
                              i_TxCopyChunkList IN COPYCHUNK_C, 
                              o_nChunksWritten OUT ULONG, 
                              o_nChunkBytesWritten OUT ULONG,
                              o_nTotalBytesWritten OUT ULONG)
IS
    rData RAW(32000);
    nStart PLS_INTEGER;
BEGIN
    rData:=UTL_RAW.CONCAT(
        NVL(io_rCopychunkResumeKey, UTL_RAW.CAST_TO_RAW(RPAD(CHR(0), 24, CHR(0)))), -- CopychunkResumeKey
        ULONGToRaw(i_TxCopyChunkList.COUNT), -- ChunkCount
        ULONGToRaw(0)); -- Reserved
    FOR i IN 1..i_TxCopyChunkList.COUNT
    LOOP
        rData:=UTL_RAW.CONCAT(rData, 
            LargeIntegerToRaw(i_TxCopyChunkList(i).nSourceOffset), -- SourceOffset
            LargeIntegerToRaw(i_TxCopyChunkList(i).nDestinationOffset), -- DestinationOffset
            ULONGToRaw(i_TxCopyChunkList(i).nCopyLength), -- CopyLength
            ULONGToRaw(0)); -- Reserved
    END LOOP;      
    NT_TRSACT_IOCTL(FsctlSrv_COPYCHUNK, i_nFID, TRUE, FALSE, rData);
    IF ok THEN
        nStart:=1;
        o_nChunksWritten:=RawToULONG(rData, nStart); -- ChunksWritten
        o_nChunkBytesWritten:=RawToULONG(rData, nStart); -- ChunkBytesWritten
        o_nTotalBytesWritten:=RawToULONG(rData, nStart); -- o_nTotalBytesWritten 
    END IF;

END FSCTL_SRV_COPYCHUNK;

-- 2.2.8.1 FIND Information Levels
PROCEDURE unpack_files_info(i_nSearchCount IN USHORT, 
                            i_nFlags IN USHORT,
                            i_nInformationLevel IN USHORT,
                            io_rData IN OUT NOCOPY RAW, 
                            io_TxFileOrDirInfo IN OUT NOCOPY FileOrDirInfo_C)
IS
    nStart PLS_INTEGER;
    nLength ULONG;
    nShortLength UCHAR;
    nFileIndex ULONG;
    nNextEntry ULONG;
    nResumeKey ULONG;
BEGIN
    nStart:=1;
    FOR i IN 1..i_nSearchCount
    LOOP
        nFileIndex:=io_TxFileOrDirInfo.COUNT + 1;
        IF i_nInformationLevel IN (SMB_INFO_STANDARD, SMB_INFO_QUERY_EA_SIZE, SMB_INFO_QUERY_EAS_FROM_LIST) THEN
             nResumeKey:=NULL;
            IF BITAND(i_nFlags, SMB_FIND_RETURN_RESUME_KEYS) > 0 THEN
                nResumeKey:=RawToULong(io_rData, nStart); 
            END IF;
            io_TxFileOrDirInfo(nFileIndex).dCreationTime:=RawToSmbDateSmbTime(io_rData, nStart); 
            io_TxFileOrDirInfo(nFileIndex).dLastAccessTime:=RawToSmbDateSmbTime(io_rData, nStart); 
            io_TxFileOrDirInfo(nFileIndex).dLastWriteTime:=RawToSmbDateSmbTime(io_rData, nStart); 
            io_TxFileOrDirInfo(nFileIndex).nSize:=RawToULong(io_rData, nStart); 
            io_TxFileOrDirInfo(nFileIndex).nAllocationSize:=RawToULong(io_rData, nStart); 
            io_TxFileOrDirInfo(nFileIndex).nFileAttributes:=RawToUShort(io_rData, nStart); 
            IF i_nInformationLevel = SMB_INFO_QUERY_EA_SIZE THEN
                io_TxFileOrDirInfo(nFileIndex).nEASize:=RawToULong(io_rData, nStart); 
            ELSIF i_nInformationLevel = SMB_INFO_QUERY_EAS_FROM_LIST THEN
                io_TxFileOrDirInfo(nFileIndex).TxSmbFeaList:=RawToSmbFeaList(io_rData, nStart);
            END IF;
            nLength:=RawToUChar(io_rData, nStart);
            IF i_nInformationLevel = SMB_INFO_STANDARD THEN
                nLength:=nLength + SmbStringLength(1); 
                SMBStringAlign(nStart);
                io_TxFileOrDirInfo(nFileIndex).vFileName:=RTRIM(SMBStringToString(RawToFixedLengthString(io_rData, nStart, nLength)), CHR(0));
            ELSE
                io_TxFileOrDirInfo(nFileIndex).vFileName:=RTRIM(SMBStringToString(RawToFixedLengthString(io_rData, nStart, nLength)), CHR(0));
                SMBStringAlign(nStart);
            END IF;
        ELSIF i_nInformationLevel IN (SMB_FIND_FILE_NAMES_INFO, SMB_FIND_FILE_DIRECTORY_INFO, SMB_FIND_FILE_FULL_DIR_INFO, SMB_FIND_FILE_BOTH_DIR_INFO) THEN
            -- [A_REVOIR : décalage horaire]
            nNextEntry:=nStart + RawToULong(io_rData, nStart) - 4;
            nStart:=nStart + 4;
            IF i_nInformationLevel <> SMB_FIND_FILE_NAMES_INFO THEN
                io_TxFileOrDirInfo(nFileIndex).dCreationTime:=RawToFileTime(io_rData, nStart);
                io_TxFileOrDirInfo(nFileIndex).dLastAccessTime:=RawToFileTime(io_rData, nStart);
                io_TxFileOrDirInfo(nFileIndex).dLastWriteTime:=RawToFileTime(io_rData, nStart);
                io_TxFileOrDirInfo(nFileIndex).dLastChangeTime:=RawToFileTime(io_rData, nStart);
                io_TxFileOrDirInfo(nFileIndex).nSize:=RawToLargeInteger(io_rData, nStart);
                io_TxFileOrDirInfo(nFileIndex).nAllocationSize:=RawToLargeInteger(io_rData, nStart);
                io_TxFileOrDirInfo(nFileIndex).nExtFileAttributes:=RawToULong(io_rData, nStart); 
            END IF;
            nLength:=RawToULong(io_rData, nStart);
            IF i_nInformationLevel IN (SMB_FIND_FILE_FULL_DIR_INFO, SMB_FIND_FILE_BOTH_DIR_INFO) THEN
                io_TxFileOrDirInfo(nFileIndex).nEASize:=RawToULong(io_rData, nStart); 
                IF i_nInformationLevel = SMB_FIND_FILE_BOTH_DIR_INFO THEN
                    nShortLength:=RawToUChar(io_rData, nStart);
                    nStart:=nStart + 1;
                    io_TxFileOrDirInfo(nFileIndex).vShortFileName:=UnicodeStringToString(RawToFixedLengthString(io_rData, nStart, nShortLength));
                    nStart:=nStart + 24 - nShortLength;
                END IF;
            END IF;
            io_TxFileOrDirInfo(nFileIndex).vFileName:=SMBStringToString(RawToFixedLengthString(io_rData, nStart, nLength));
            nStart:=nNextEntry;
         END IF; 
    END LOOP;          
    
END unpack_files_info;

-- 2.2.8.3 QUERY Information Levels
PROCEDURE unpack_file_info(i_nInformationLevel IN USHORT,
                           io_rData IN OUT NOCOPY RAW, 
                           io_xFileOrDirInfo IN OUT NOCOPY FileOrDirInfo_T)
IS
    nStart PLS_INTEGER;
    nCh UCHAR;
    nLength ULONG;
BEGIN
    nStart:=1;
    IF i_nInformationLevel IN (SMB_INFO_STANDARD, SMB_INFO_QUERY_EA_SIZE) THEN
        io_xFileOrDirInfo.dCreationTime:=RawToSmbDateSmbTime(io_rData, nStart); 
        io_xFileOrDirInfo.dLastAccessTime:=RawToSmbDateSmbTime(io_rData, nStart); 
        io_xFileOrDirInfo.dLastWriteTime:=RawToSmbDateSmbTime(io_rData, nStart); 
        io_xFileOrDirInfo.nSize:=RawToULONG(io_rData, nStart);
        io_xFileOrDirInfo.nAllocationSize:=RawToULONG(io_rData, nStart);
        io_xFileOrDirInfo.nExtFileAttributes:=RawToULong(io_rData, nStart); 
        IF i_nInformationLevel = SMB_INFO_QUERY_EA_SIZE THEN
            io_xFileOrDirInfo.nEASize:=RawToULong(io_rData, nStart); 
        END IF;
    ELSIF i_nInformationLevel = SMB_QUERY_FILE_BASIC_INFO THEN
        io_xFileOrDirInfo.dCreationTime:=RawToFileTime(io_rData, nStart);
        io_xFileOrDirInfo.dLastAccessTime:=RawToFileTime(io_rData, nStart);
        io_xFileOrDirInfo.dLastWriteTime:=RawToFileTime(io_rData, nStart);
        io_xFileOrDirInfo.dLastChangeTime:=RawToFileTime(io_rData, nStart);
        io_xFileOrDirInfo.nExtFileAttributes:=RawToULong(io_rData, nStart); 
    ELSIF i_nInformationLevel = SMB_QUERY_FILE_STANDARD_INFO THEN 
        io_xFileOrDirInfo.nAllocationSize:=RawToLargeInteger(io_rData, nStart);
        io_xFileOrDirInfo.nSize:=RawToLargeInteger(io_rData, nStart);
        io_xFileOrDirInfo.nNumberOfLinks:=RawToULONG(io_rData, nStart);
        nCh:=RawToUCHAR(io_rData, nStart); io_xFileOrDirInfo.bDeletePending:=(nCh > 0);
        nCh:=RawToUCHAR(io_rData, nStart); io_xFileOrDirInfo.bDirectory:=(nCh > 0);
    ELSIF i_nInformationLevel = SMB_QUERY_FILE_EA_INFO THEN
        io_xFileOrDirInfo.nEASize:=RawToULong(io_rData, nStart); 
    ELSIF i_nInformationLevel = SMB_QUERY_FILE_NAME_INFO THEN
        nLength:=RawToULong(io_rData, nStart);
        io_xFileOrDirInfo.vFileName:=UnicodeStringToString(RawToFixedLengthString(io_rData, nStart, nLength));
    ELSIF i_nInformationLevel = SMB_QUERY_FILE_ALL_INFO THEN
        io_xFileOrDirInfo.dCreationTime:=RawToFileTime(io_rData, nStart);
        io_xFileOrDirInfo.dLastAccessTime:=RawToFileTime(io_rData, nStart);
        io_xFileOrDirInfo.dLastWriteTime:=RawToFileTime(io_rData, nStart);
        io_xFileOrDirInfo.dLastChangeTime:=RawToFileTime(io_rData, nStart);
        io_xFileOrDirInfo.nExtFileAttributes:=RawToULong(io_rData, nStart); 
        nStart:=nStart + 4; -- Reserved1
        io_xFileOrDirInfo.nAllocationSize:=RawToLargeInteger(io_rData, nStart);
        io_xFileOrDirInfo.nSize:=RawToLargeInteger(io_rData, nStart);
        io_xFileOrDirInfo.nNumberOfLinks:=RawToULONG(io_rData, nStart);
        nCh:=RawToUCHAR(io_rData, nStart); io_xFileOrDirInfo.bDeletePending:=(nCh > 0);
        nCh:=RawToUCHAR(io_rData, nStart); io_xFileOrDirInfo.bDirectory:=(nCh > 0);
        nStart:=nStart + 2; -- Reserved2       
        io_xFileOrDirInfo.nEASize:=RawToULong(io_rData, nStart); 
        nLength:=RawToULong(io_rData, nStart);
        io_xFileOrDirInfo.vFileName:=UnicodeStringToString(RawToFixedLengthString(io_rData, nStart, nLength));
    ELSIF i_nInformationLevel = SMB_QUERY_FILE_ALT_NAME_INFO THEN
        nLength:=RawToULong(io_rData, nStart);
        io_xFileOrDirInfo.vShortFileName:=UnicodeStringToString(RawToFixedLengthString(io_rData, nStart, nLength));
    ELSIF i_nInformationLevel = SMB_QUERY_FILE_STREAM_INFO THEN
        dbms_output.put_line('NextEntryOffset=' || to_char(RawToULong(io_rData, nStart)));
        nLength:=RawToULong(io_rData, nStart);
        dbms_output.put_line('StreamSize=' || to_char(RawToLargeInteger(io_rData, nStart)));
        dbms_output.put_line('StreamAllocationSize=' || to_char(RawToLargeInteger(io_rData, nStart)));
        dbms_output.put_line('StreamName='||UnicodeStringToString(RawToFixedLengthString(io_rData, nStart, nLength)));
    ELSIF i_nInformationLevel = SMB_QUERY_FILE_COMPRESS_INFO THEN
        dbms_output.put_line('CompressedFileSize=' || to_char(RawToLargeInteger(io_rData, nStart)));
        dbms_output.put_line('CompressionFormat=' || to_char(RawToUSHORT(io_rData, nStart)));
        dbms_output.put_line('CompressionUnitShift=' || to_char(RawToUCHAR(io_rData, nStart)));
        dbms_output.put_line('ChunkShift=' || to_char(RawToUCHAR(io_rData, nStart)));
        dbms_output.put_line('ClusterShift=' || to_char(RawToUCHAR(io_rData, nStart)));
        
    END IF;
END unpack_file_info;

FUNCTION pack_file_info(i_nInformationLevel IN USHORT,
                        i_xFileOrDirInfo IN FileOrDirInfo_T) RETURN RAW
IS
    rFileInfo RAW(32000);
    nValue UCHAR;
BEGIN
    CASE i_nInformationLevel
        WHEN SMB_INFO_STANDARD THEN
            -- [A_REVOIR]
            NULL;
        WHEN SMB_INFO_SET_EAS THEN
            rFileInfo:=SmbFeaListToRaw(i_xFileOrDirInfo.TxSmbFeaList); -- ExtendedAttributeList
        WHEN SMB_QUERY_FILE_BASIC_INFO THEN
            rFileInfo:=UTL_RAW.CONCAT(
                FileTimeToRaw(i_xFileOrDirInfo.dCreationTime), -- CreationTime
                FileTimeToRaw(i_xFileOrDirInfo.dLastAccessTime), -- LastAccessTime
                FileTimeToRaw(i_xFileOrDirInfo.dLastWriteTime), -- LastWriteTime
                FileTimeToRaw(i_xFileOrDirInfo.dLastChangeTime), -- LastChangeTime
                ULONGToRaw(i_xFileOrDirInfo.nExtFileAttributes), -- ExtFileAttributes
                ULONGToRaw(0)); -- Reserved
        WHEN SMB_SET_FILE_DISPOSITION_INFO THEN
            nValue:=0;
            IF i_xFileOrDirInfo.bDeletePending THEN
                nValue:=1;
            END IF;
            rFileInfo:=UCHARToRaw(nValue); -- DeletePending
        WHEN SMB_SET_FILE_ALLOCATION_INFO THEN
            rFileInfo:=LargeIntegerToRaw(i_xFileOrDirInfo.nAllocationSize); -- AllocationSize
        WHEN SMB_SET_FILE_END_OF_FILE_INFO THEN
            rFileInfo:=LargeIntegerToRaw(i_xFileOrDirInfo.nSize); -- EndOfFile
           
    END CASE;
    RETURN rFileInfo;
END pack_file_info;

PROCEDURE TRANS2_FIND_FIRST2(i_nSearchAttributes IN SMB_FILE_ATTRIBUTES, 
                             i_nSearchCount IN USHORT, 
                             i_nFlags IN USHORT,
                             i_nInformationLevel IN USHORT,
                             i_nSearchStorageType IN ULONG,
                             i_vFileName IN VARCHAR2, 
                             i_TxAttributeName IN SMB_GEA_LIST,
                             o_nSID OUT USHORT,
                             o_nSearchCount OUT USHORT,
                             o_nEndOfSearch OUT USHORT,
                             o_nEaErrorOffset OUT USHORT,
                             o_nLastNameOffset OUT USHORT,
                             o_TxFileOrDirInfo IN OUT NOCOPY FileOrDirInfo_C)
IS
    rTrans2Parameter RAW(1000);
    rTrans2Data RAW(32000);
    rSetup RAW(255);
    nStart PLS_INTEGER;
BEGIN
    rSetup:=USHORTToRaw(SmbTr2_TRANS2_FIND_FIRST2);
    rTrans2Parameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nSearchAttributes),
        USHORTToRaw(i_nSearchCount),
        USHORTToRaw(i_nFlags), 
        USHORTToRaw(i_nInformationLevel),
        ULONGToRaw(i_nSearchStorageType),
        SMBStringToRaw(i_vFileName));
    rTrans2Data:=NULL;    
    IF BITAND(i_nInformationLevel, SMB_INFO_QUERY_EAS_FROM_LIST) > 0 THEN
        rTrans2Data:=SmbGeaListToRaw(i_TxAttributeName);
    END IF;
    SMB_COM_TRANSACTION2(rSetup, rTrans2Parameter, rTrans2Data);  
    IF ok THEN
        nStart:=1;
        o_nSID:=RawToUShort(rTrans2Parameter, nStart);
        o_nSearchCount:=RawToUShort(rTrans2Parameter, nStart);
        o_nEndOfSearch:=RawToUShort(rTrans2Parameter, nStart);
        o_nEaErrorOffset:=RawToUShort(rTrans2Parameter, nStart);
        o_nLastNameOffset:=RawToUShort(rTrans2Parameter, nStart);
        unpack_files_info(o_nSearchCount, i_nFlags, i_nInformationLevel, rTrans2Data, o_TxFileOrDirInfo);
    END IF;
END TRANS2_FIND_FIRST2;

PROCEDURE TRANS2_FIND_NEXT2(i_nSID IN USHORT, 
                            i_nSearchCount IN USHORT, 
                            i_nInformationLevel IN USHORT,
                            i_nResumeKey IN ULONG,
                            i_nFlags IN USHORT,
                            i_vFileName IN VARCHAR2, 
                            i_TxAttributeName IN SMB_GEA_LIST,
                            o_nSearchCount OUT USHORT,
                            o_nEndOfSearch OUT USHORT,
                            o_nEaErrorOffset OUT USHORT,
                            o_nLastNameOffset OUT USHORT,
                            o_TxFileOrDirInfo IN OUT NOCOPY FileOrDirInfo_C)
IS
    rTrans2Parameter RAW(1000);
    rTrans2Data RAW(32000);
    rSetup RAW(255);
    nStart PLS_INTEGER;
BEGIN
    rSetup:=USHORTToRaw(SmbTr2_TRANS2_FIND_NEXT2);
    rTrans2Parameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nSID),
        USHORTToRaw(i_nSearchCount),
        USHORTToRaw(i_nInformationLevel),
        ULONGToRaw(i_nResumeKey),
        USHORTToRaw(i_nFlags), 
        SMBStringToRaw(i_vFileName));
    rTrans2Data:=NULL;    
    IF BITAND(i_nInformationLevel, SMB_INFO_QUERY_EAS_FROM_LIST) > 0 THEN
        rTrans2Data:=SmbGeaListToRaw(i_TxAttributeName);
    END IF;
    SMB_COM_TRANSACTION2(rSetup, rTrans2Parameter, rTrans2Data);  
    IF ok THEN
        nStart:=1;
        o_nSearchCount:=RawToUShort(rTrans2Parameter, nStart);
        o_nEndOfSearch:=RawToUShort(rTrans2Parameter, nStart);
        o_nEaErrorOffset:=RawToUShort(rTrans2Parameter, nStart);
        o_nLastNameOffset:=RawToUShort(rTrans2Parameter, nStart);
        unpack_files_info(o_nSearchCount, i_nFlags, i_nInformationLevel, rTrans2Data, o_TxFileOrDirInfo);
    END IF;
END TRANS2_FIND_NEXT2;

PROCEDURE TRANS2_QUERY_FS_INFORMATION(i_nInformationLevel IN USHORT, 
                                      o_xFSInfo IN OUT NOCOPY FS_INFO_T)
IS
    rTrans2Parameter RAW(1000);
    rTrans2Data RAW(1000);
    rSetup RAW(255);
    nStart PLS_INTEGER;
BEGIN
    rSetup:=USHORTToRaw(SmbTr2_TRANS2_QUERY_FS_INFO);
    rTrans2Parameter:=USHORTToRaw(i_nInformationLevel);
    rTrans2Data:=NULL;    
    SMB_COM_TRANSACTION2(rSetup, rTrans2Parameter, rTrans2Data);  
    IF ok THEN
        nStart:=1;
        CASE i_nInformationLevel
            WHEN SMB_INFO_ALLOCATION THEN
                RawToSmbInfoAllocation(rTrans2Data, nStart, o_xFSInfo);
            WHEN SMB_INFO_VOLUME THEN
                RawToSmbInfoVolume(rTrans2Data, nStart, o_xFSInfo);
            WHEN SMB_QUERY_FS_VOLUME_INFO THEN
                RawToSmbQueryFSVolumeInfo(rTrans2Data, nStart, o_xFSInfo);
            WHEN SMB_QUERY_FS_SIZE_INFO THEN
                RawToSmbQueryFSSizeInfo(rTrans2Data, nStart, o_xFSInfo);
            WHEN SMB_QUERY_FS_DEVICE_INFO THEN
                RawToSmbQueryFSDeviceInfo(rTrans2Data, nStart, o_xFSInfo);
            WHEN SMB_QUERY_FS_ATTRIBUTE_INFO THEN
                RawToSmbQueryFSAttributeInfo(rTrans2Data, nStart, o_xFSInfo);
            ELSE NULL;
        END CASE;
    END IF;
END TRANS2_QUERY_FS_INFORMATION;

PROCEDURE TRANS2_QUERY_FILE_INFORMATION(i_nFID IN USHORT,
                                        i_nInformationLevel IN USHORT, 
                                        i_xGetExtendedAttributeList IN SMB_GEA_LIST, 
                                        io_xFileOrDirInfo IN OUT NOCOPY FileOrDirInfo_T)
IS
    rTrans2Parameter RAW(1000);
    rTrans2Data RAW(1000);
    rSetup RAW(255);
    nStart PLS_INTEGER;
BEGIN
    rSetup:=USHORTToRaw(SmbTr2_TRANS2_QUERY_FILE_INFO);
    rTrans2Parameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nFID), -- FID
        USHORTToRaw(i_nInformationLevel)); -- InformationLevel
    rTrans2Data:=NULL;
    IF i_nInformationLevel = SMB_INFO_QUERY_EAS_FROM_LIST THEN
        rTrans2Data:=SmbGeaListToRaw(i_xGetExtendedAttributeList);
    END IF;
    SMB_COM_TRANSACTION2(rSetup, rTrans2Parameter, rTrans2Data);  
    IF ok THEN
        nStart:=1;
        unpack_file_info(i_nInformationLevel, rTrans2Data, io_xFileOrDirInfo);
    END IF;    
    
END TRANS2_QUERY_FILE_INFORMATION;

PROCEDURE TRANS2_QUERY_PATH_INFORMATION(i_vFileName IN VARCHAR2,
                                        i_nInformationLevel IN USHORT, 
                                        i_xGetExtendedAttributeList IN SMB_GEA_LIST, 
                                        io_xFileOrDirInfo IN OUT NOCOPY FileOrDirInfo_T)
IS
    rTrans2Parameter RAW(1000);
    rTrans2Data RAW(1000);
    rSetup RAW(255);
    nStart PLS_INTEGER;
BEGIN
    rSetup:=USHORTToRaw(SmbTr2_TRANS2_QUERY_PATH_INFO);
    rTrans2Parameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nInformationLevel), -- InformationLevel
        ULONGToRaw(0), -- Reserved
        SMBStringToRaw(i_vFileName) -- FileName
        );
    rTrans2Data:=NULL;
    IF i_nInformationLevel = SMB_INFO_QUERY_EAS_FROM_LIST THEN
        rTrans2Data:=SmbGeaListToRaw(i_xGetExtendedAttributeList);
    END IF;
    SMB_COM_TRANSACTION2(rSetup, rTrans2Parameter, rTrans2Data);  
    IF ok THEN
        nStart:=1;
        unpack_file_info(i_nInformationLevel, rTrans2Data, io_xFileOrDirInfo);
    END IF;    

END TRANS2_QUERY_PATH_INFORMATION;

PROCEDURE TRANS2_SET_FILE_INFORMATION(i_nFID IN USHORT,
                                      i_nInformationLevel IN USHORT, 
                                      i_xFileOrDirInfo IN FileOrDirInfo_T, 
                                      o_nEaErrorOffset OUT USHORT)
IS
    rTrans2Parameter RAW(1000);
    rTrans2Data RAW(1000);
    rSetup RAW(255);
    nStart PLS_INTEGER;
BEGIN
    rSetup:=USHORTToRaw(SmbTr2_TRANS2_SET_FILE_INFO);
    rTrans2Parameter:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nFID), -- FID
        USHORTToRaw(i_nInformationLevel), -- InformationLevel
        USHORTToRaw(0)); -- Reserved
    rTrans2Data:=pack_file_info(i_nInformationLevel, 
                                i_xFileOrDirInfo);
    SMB_COM_TRANSACTION2(rSetup, rTrans2Parameter, rTrans2Data);  
    IF ok THEN
        nStart:=1;
        o_nEaErrorOffset:=RawToUSHORT(rTrans2Parameter, nStart);
    END IF;                                
    
END TRANS2_SET_FILE_INFORMATION;


PROCEDURE TRANS2_CREATE_DIRECTORY(i_vDirectoryName IN VARCHAR2, 
                                  i_TxExtendedAttributeList IN SMB_FEA_LIST, 
                                  o_nEAErrorOffset OUT USHORT)
IS
    rTrans2Parameter RAW(1000);
    rTrans2Data RAW(1000);
    rSetup RAW(255);
    nStart PLS_INTEGER;
BEGIN
    rSetup:=USHORTToRaw(SmbTr2_TRANS2_CREATE_DIRECTORY);
    rTrans2Parameter:=UTL_RAW.CONCAT(
        ULONGToRaw(0), -- Reserved
        SmbStringToRaw(i_vDirectoryName)
        );
    rTrans2Data:=SmbFeaListToRaw(i_TxExtendedAttributeList);       
    SMB_COM_TRANSACTION2(rSetup, rTrans2Parameter, rTrans2Data); 
    IF ok THEN
        nStart:=1;
        o_nEAErrorOffset:=RawToUSHORT(rTrans2Parameter, nStart);
    END IF;

END TRANS2_CREATE_DIRECTORY;

PROCEDURE SMB_COM_NT_CREATE_ANDX(i_vFileName IN VARCHAR2,
                                 i_nFlags IN ULONG,
                                 i_nRootDirectoryFID IN ULONG,
                                 i_nDesiredAccess IN ULONG,
                                 i_nAllocationSize IN LARGE_INTEGER,
                                 i_xExtFileAttributes IN SMB_EXT_FILE_ATTR,
                                 i_nShareAccess IN ULONG,
                                 i_nCreateDisposition IN ULONG,
                                 i_nCreateOptions IN ULONG,
                                 i_nImpersonationLevel IN ULONG,
                                 i_nSecurityFlags IN UCHAR,
                                 o_nOpLockLevel OUT UCHAR,
                                 o_nFID OUT USHORT,
                                 o_nCreateDisposition OUT ULONG,
                                 o_dCreateTime OUT DATE,
                                 o_dLastAccessTime OUT DATE,
                                 o_dLastWriteTime OUT DATE,
                                 o_dLastChangeTime OUT DATE,
                                 o_xExtFileAttributes OUT SMB_EXT_FILE_ATTR,
                                 o_nAllocationSize OUT LARGE_INTEGER,
                                 o_nEndOfFile OUT LARGE_INTEGER,
                                 o_nResourceType OUT USHORT,
                                 o_xNMPipeStatus OUT SMB_NMPIPE_STATUS, 
                                 o_nDirectory OUT UCHAR
                                 )
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;  
    nStart PLS_INTEGER;  
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_NT_CREATE_ANDX;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=UTL_RAW.CONCAT(
        NO_ANDX, -- AndXCommand, AndXReserved, AndXOffset
        UCHARToRaw(0), -- Reserved
        USHORTToRaw(SmbStringLength(LENGTH(i_vFileName))), -- NameLength
        ULONGToRaw(i_nFlags), -- Flags
        ULONGToRaw(i_nRootDirectoryFID), -- RootDirectoryFID
        ULONGToRaw(i_nDesiredAccess), -- DesiredAccess
        LargeIntegerToRaw(i_nAllocationSize), -- AllocationSize
        ULONGToRaw(i_xExtFileAttributes), -- ExtFileAttributes
        ULONGToRaw(i_nShareAccess), -- ShareAccess
        ULONGToRaw(i_nCreateDisposition), -- CreateDisposition
        ULONGToRaw(i_nCreateOptions), -- CreateOptions
    UTL_RAW.CONCAT(
        ULONGToRaw(i_nImpersonationLevel), -- ImpersonationLevel
        UCHARToRaw(i_nSecurityFlags))); -- SecurityFlags        
    rData:=UTL_RAW.CONCAT(
        SMBStringAlignToRaw(1+UTL_RAW.LENGTH(rParameters)), 
        SmbStringToRaw(i_vFileName));
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        nStart:=1;
        nStart:=nStart + 4; -- AndXCommand, AndXReserved, AndXOffset
        o_nOpLockLevel:=RawToUCHAR(rParameters, nStart);
        o_nFID:=RawToUSHORT(rParameters, nStart);
        o_nCreateDisposition:=RawToULONG(rParameters, nStart);
        o_dCreateTime:=RawToFileTime(rParameters, nStart);
        o_dLastAccessTime:=RawToFileTime(rParameters, nStart);
        o_dLastWriteTime:=RawToFileTime(rParameters, nStart);
        o_dLastChangeTime:=RawToFileTime(rParameters, nStart);
        o_xExtFileAttributes:=RawToULONG(rParameters, nStart);
        o_nAllocationSize:=RawToLargeInteger(rParameters, nStart);
        o_nEndOfFile:=RawToLargeInteger(rParameters, nStart);
        o_nResourceType:=RawToUSHORT(rParameters, nStart);
        o_xNMPipeStatus:=RawToUSHORT(rParameters, nStart);
        o_nDirectory:=RawToUCHAR(rParameters, nStart);
    END IF;

END SMB_COM_NT_CREATE_ANDX;

PROCEDURE SMB_COM_READ_ANDX(i_nFID IN USHORT,
                            i_nOffset IN LARGE_INTEGER,
                            i_nMaxCntOfBytesToRet IN USHORT,
                            i_nMinCntOfBytesToRet IN USHORT,  
                            i_nTimeout IN ULONG,
                            io_rData IN OUT NOCOPY RAW,
                            o_nAvailable OUT USHORT
                            )
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;  
    nStart PLS_INTEGER;  
    nOffsetHigh ULONG;  
    nDataLength PLS_INTEGER;
    nDataOffset PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_READ_ANDX;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    nOffsetHigh:=TRUNC(i_nOffset / 4294967296);
    IF nOffsetHigh = 0 THEN
        nOffsetHigh:=NULL;
    END IF;
    rParameters:=UTL_RAW.CONCAT(
        NO_ANDX, 
        USHORTToRaw(i_nFID), -- FID
        ULONGToRaw(MOD(i_nOffset, 4294967296)), -- Offset
        USHORTToRaw(i_nMaxCntOfBytesToRet), -- MaxCountOfBytesToReturn
        USHORTToRaw(i_nMinCntOfBytesToRet), -- MinCountOfBytesToReturn
        ULONGToRaw(i_nTimeout), -- Timeout
        USHORTToRaw(0)); -- Remaining
    IF nOffsetHigh IS NOT NULL THEN
        rParameters:=UTL_RAW.CONCAT(
            rParameters, 
            ULONGToRaw(nOffsetHigh)); -- Offset High
    END IF;
    rData:=NULL;
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        nStart:=1;
        nStart:=nStart + 4; -- NO_ANDX
        o_nAvailable:=RawToUSHORT(rParameters, nStart); -- Available
        nStart:=nStart + 2; -- DataCompactionMode
        nStart:=nStart + 2; -- Reserved1
        nDataLength:=RawToUSHORT(rParameters, nStart); -- Data Length
        nDataOffset:=RawToUSHORT(rParameters, nStart); -- Data Offset
        -- Data offset is based upon the beginning of SMBHeader, 
        -- It must be based upon rData...
        nDataOffset:=nDataOffset - 32 - 1 - 2 - UTL_RAW.LENGTH(rParameters) + 1;
        io_rData:=RAW_SUBSTR(rData, nDataOffset, nDataLength);
    END IF;
    
END SMB_COM_READ_ANDX;

PROCEDURE SMB_COM_WRITE_ANDX(i_nFID IN USHORT, 
                             i_nOffset IN LARGE_INTEGER, 
                             i_nTimeout IN ULONG,
                             i_nWriteMode IN USHORT,
                             i_nRemaining IN USHORT,
                             io_rData IN OUT NOCOPY RAW,
                             o_nCount OUT USHORT,
                             o_nAvailable OUT USHORT)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;  
    nStart PLS_INTEGER;  
    nOffsetHigh ULONG;
    nOffsetData PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_WRITE_ANDX;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    nOffsetData:=0;
    nOffsetHigh:=TRUNC(i_nOffset / 4294967296);
    IF nOffsetHigh = 0 THEN
        nOffsetHigh:=NULL;
        nOffsetData:=4;
    END IF;
    nOffsetData:=32 + -- SMBHeader
                  1 + -- Parameter length
                 22 + -- Parameter
                 nOffsetData; -- optionnel offsetHigh
    rParameters:=UTL_RAW.CONCAT(
        NO_ANDX, -- AndXCommand, AndXReserved, AndXOffset
        USHORTToRaw(i_nFID), -- FID
        ULONGToRaw(MOD(i_nOffset, 4294967296)), -- Offset
        ULONGToRaw(i_nTimeout), -- Timeout
        USHORTToRaw(i_nWriteMode), -- WriteMode
        USHORTToRaw(i_nRemaining), -- Remaining
        USHORTToRaw(0), -- Reserved
        USHORTToRaw(UTL_RAW.LENGTH(io_rData)), -- DataLength
        USHORTToRaw(nOffsetData)
        );
    IF nOffsetHigh IS NOT NULL THEN
        rParameters:=UTL_RAW.CONCAT(
            rParameters, 
            ULONGToRaw(nOffsetHigh));
    END IF;
    rData:=io_rData;
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        nStart:=1;
        o_nCount:=RawToUSHORT(rParameters, nStart);
        o_nAvailable:=RawToUSHORT(rParameters, nStart);
    END IF;
    
END SMB_COM_WRITE_ANDX;

PROCEDURE SMB_COM_OPEN_ANDX(i_nFlags IN USHORT,
                            i_nAccessMode IN USHORT,
                            i_nSearchAttrs IN SMB_FILE_ATTRIBUTES,
                            i_nFileAttrs IN SMB_FILE_ATTRIBUTES,
                            i_dCreationTime IN DATE,
                            i_nOpenMode IN USHORT,
                            i_nAllocationSize IN ULONG,
                            i_nTimeout IN ULONG,
                            i_vFileName IN VARCHAR2,
                            o_nFID OUT USHORT,
                            o_nFileAttrs OUT SMB_FILE_ATTRIBUTES,
                            o_dLastWriteTime OUT DATE,
                            o_nFileDataSize OUT ULONG,
                            o_nAccessRights OUT USHORT,
                            o_nResourceType OUT USHORT,
                            o_nNMPipeStatus OUT SMB_NMPIPE_STATUS,
                            o_nOpenResults OUT USHORT
                            )
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;  
    nStart PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_OPEN_ANDX;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=UTL_RAW.CONCAT(
        NO_ANDX,
        USHORTToRaw(i_nFlags), -- Flags
        USHORTToRaw(i_nAccessMode), -- AccessMode
        USHORTToRaw(i_nSearchAttrs), -- SearchAttrs
        USHORTToRaw(i_nFileAttrs), -- FileAttrs
        ULONGToRaw(0), -- CreationTime [A_REVOIR]
        USHORTToRaw(i_nOpenMode), -- OpenMode
        ULONGToRaw(i_nAllocationSize), -- AllocationSize
        ULONGToRaw(i_nTimeout), -- Timeout
        USHORTToRaw(0), -- Reserved
        USHORTToRaw(0)); -- Reserved
    rData:=UTL_RAW.CONCAT(
        UCHARToRaw(0), -- Padding
        SmbStringToRaw(i_vFilename));    
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        nStart:=1;
        nStart:=nStart + 4; -- NO_ANDX
        o_nFID:=RawToUSHORT(rParameters, nStart); -- FID
        o_nFileAttrs:=RawToUSHORT(rParameters, nStart); -- FileAttrs
        o_dLastWriteTime:=NULL; nStart:=nStart + 4; -- [A_REVOIR]
        o_nFileDataSize:=RawToULONG(rParameters, nStart); -- FileDataSize
        o_nAccessRights:=RawToUSHORT(rParameters, nStart); -- AccessRights
        o_nResourceType:=RawToUSHORT(rParameters, nStart); -- ResourceType
        o_nNMPipeStatus:=RawToUSHORT(rParameters, nStart); -- NMPipeStatus
        o_nOpenResults:=RawToUSHORT(rParameters, nStart); -- OpenResults
    END IF;
END SMB_COM_OPEN_ANDX;


PROCEDURE SMB_COM_CLOSE(i_nFID IN USHORT, 
                        i_dLastTimeModified IN DATE:=NULL)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;  
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_CLOSE;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nFID), -- FID
        ULONGToRaw(0)); -- LastTimeModified [A_REVOIR]
    rData:=NULL;
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    
END SMB_COM_CLOSE;

PROCEDURE SMB_COM_RENAME(i_nSearchAttributes IN SMB_FILE_ATTRIBUTES, 
                         i_vOldFileName IN VARCHAR2, 
                         i_vNewFileName IN VARCHAR2)
                         
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
    nStart PLS_INTEGER;  
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_RENAME;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=USHORTToRaw(i_nSearchAttributes);
    rData:=UTL_RAW.CONCAT(
        HexToRaw('04'), -- BufferFormat1
        SmbStringToRaw(i_vOldFileName), -- OldFileName
        HexToRaw('04'), -- BufferFormat2, 
        SmbStringAlignToRaw(1), 
        SmbStringToRaw(i_vNewFileName)); -- NewFileName
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);

END SMB_COM_RENAME;

PROCEDURE SMB_COM_NT_RENAME(i_nSearchAttributes IN SMB_FILE_ATTRIBUTES, 
                            i_nInformationLevel IN USHORT,
                            i_vOldFileName IN VARCHAR2, 
                            i_vNewFileName IN VARCHAR2)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
    nStart PLS_INTEGER;  
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_NT_RENAME;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=UTL_RAW.CONCAT(
        USHORTTORaw(i_nSearchAttributes), -- SearchAttributes
        USHORTToRaw(i_nInformationLevel), -- InformationLevel
        ULONGToRaw(0)); -- Reserved
    rData:=UTL_RAW.CONCAT(
        HexToRaw('04'), -- BufferFormat1
        SmbStringToRaw(i_vOldFileName), -- OldFileName
        HexToRaw('04'), -- BufferFormat2, 
        SmbStringAlignToRaw(1), 
        SmbStringToRaw(i_vNewFileName)); -- NewFileName
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
        
END SMB_COM_NT_RENAME;

PROCEDURE SMB_COM_DELETE(i_nSearchAttributes IN SMB_FILE_ATTRIBUTES, 
                         i_nFileName IN VARCHAR2)
                         
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
    nStart PLS_INTEGER;  
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_DELETE;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=USHORTToRaw(i_nSearchAttributes);
    rData:=UTL_RAW.CONCAT(
        HexToRaw('04'), -- BufferFormat
        SmbStringToRaw(i_nFileName)); -- FileName
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);

END SMB_COM_DELETE;

PROCEDURE SMB_COM_FLUSH(i_nFID IN USHORT)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
    nStart PLS_INTEGER;  
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_FLUSH;
    xCtx.xSMBHeader.Flags:=8;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nFID)); -- FID
    rData:=NULL;
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    
END SMB_COM_FLUSH;


PROCEDURE SMB_COM_DELETE_DIRECTORY(i_vDirectoryName IN VARCHAR2)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_DELETE_DIRECTORY;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=NULL;
    rData:=UTL_RAW.CONCAT(
        HexToRaw('04'),
        SmbStringToRaw(i_vDirectoryName));
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    
END SMB_COM_DELETE_DIRECTORY;

PROCEDURE SMB_COM_OPEN_PRINT_FILE(i_nSetupLength IN USHORT, 
                                  i_nMode IN USHORT,
                                  i_vPrintQueueFileName IN VARCHAR2, 
                                  o_nFID OUT USHORT)
IS
    rParameters RAW(512);
    rData RAW(32000);
    rSMBMessage RAW(32000);
    rAnswer RAW(32000);
    nAnswerCode PLS_INTEGER;
    nStart PLS_INTEGER;
BEGIN
    xCtx.xSMBHeader.Command:=SmbCom_OPEN_PRINT_FILE;
    xCtx.xSMBHeader.MID:=xCtx.xSMBHeader.MID + 1;
    rParameters:=UTL_RAW.CONCAT(
        USHORTToRaw(i_nSetupLength), -- SetupLength
        USHORTToRaw(i_nMode)); -- Mode
    rData:=UTL_RAW.CONCAT(
        HexToRaw('04'),
        SmbStringToRaw(i_vPrintQueueFileName));
    rSMBMessage:=pack_smb_message(xCtx.xSMBHeader, rParameters, rData);
    SESSION_MESSAGE_CALL(rSMBMessage, nAnswerCode, rAnswer);
    unpack_smb_message(rAnswer, xCtx.xSMBHeader, rParameters, rData);
    IF ok THEN
        nStart:=1;
        o_nFID:=RawToUSHORT(rParameters, nStart);
    END IF;
END SMB_COM_OPEN_PRINT_FILE;

FUNCTION security_blob_negotiate(i_vDomain IN VARCHAR2,
                                 i_vWorkstation IN VARCHAR2) RETURN RAW
IS
    TxMechTypeList MechTypeList;
BEGIN
    -- rfc2743
    TxMechTypeList(1):=OID_NTLMSSP;
    RETURN BER_Encode(tag_Application + tag_Constructed + 0, UTL_RAW.CONCAT(
            OIDToRaw(OID_SPNEGO),
            BER_Encode(tag_CSC + 0, Encode_NegTokenInit(TxMechTypeList, OctetString_Encode(negotiate(i_vDomain, i_vWorkstation))))        
             ));
END security_blob_negotiate;

FUNCTION security_blob_authentication(i_rServerChallenge IN RAW,
                                      i_vLogin IN VARCHAR2,
                                      i_vPassword IN VARCHAR2, 
                                      i_vDomain IN VARCHAR2, 
                                      i_vWorkstation IN VARCHAR2) RETURN RAW
IS
BEGIN
    RETURN BER_Encode(tag_CSC + 1, Sequence_Encode(BER_Encode(tag_CSC + 2, OctetString_Encode(authentication(i_rServerChallenge, i_vLogin, i_vPassword, i_vDomain, i_vWorkstation)))));
END security_blob_authentication;

PROCEDURE HOST_CONNECT(i_xShare IN SHARE_T,
                       o_vError OUT ERRSTR)
IS
    bOk BOOLEAN;
    nTransportType PLS_INTEGER;
    bSocketOpened BOOLEAN;
BEGIN 
    bSocketOpened:=FALSE;
    IF i_xShare.nPort = 139 THEN
        nTransportType:=TransportType_NBT;
    ELSE
        nTransportType:=TransportType_RAW_TCP;
    END IF;
    TRANSPORT_INIT(nTransportType, i_xShare.vHost, i_xShare.nPort);
    SOCKET_OPEN(o_vError); 
    IF o_vError IS NULL THEN
        bSocketOpened:=TRUE;   
        SMB_COM_NEGOTIATE;
    END IF;
    IF ok(o_vError) THEN
        SMB_COM_SESSION_SETUP_ANDX(i_xShare.vLogin, i_xShare.vPassword, i_xShare.vDomain, UTL_INADDR.GET_HOST_NAME);
    END IF;
    bOk:=ok(o_vError);

EXCEPTION
    WHEN NETWORK_ACCESS_DENIED_BY_ACL THEN
    o_vError:=err_NET_ACCESS_DENIED_BY_ACL;
    IF bSocketOpened THEN
        SOCKET_CLOSE;
    END IF; 

END HOST_CONNECT;                       


PROCEDURE SHARE_CONNECT(i_xShare IN SHARE_T, 
                        o_vError OUT ERRSTR, 
                        i_bHostConnect IN BOOLEAN:=TRUE)
IS
    nOptionalSupport USHORT; 
    vService VARCHAR2(100);
    vNativeFileSystem VARCHAR2(100);  
    bOk BOOLEAN;
    nTransportType PLS_INTEGER;
BEGIN 
    o_vError:=NULL;
    IF i_bHostConnect THEN
        HOST_CONNECT(i_xShare, o_vError);
    END IF;
    IF o_vError IS NULL THEN
        SMB_COM_TREE_CONNECT_ANDX(8, NULL, '\\' || i_xShare.vHost || '\' || i_xShare.vShare, svc_AnyType, nOptionalSupport, vService, vNativeFileSystem);
        xCtx.vService:=vService;
        bOk:=ok(o_vError);
    END IF;

END SHARE_CONNECT;

PROCEDURE FILE_OPEN(i_vFileName IN VARCHAR2, 
                    o_nFID OUT USHORT, 
                    o_nFileDataSize OUT ULONG,
                    o_vError OUT ERRSTR, 
                    i_bFileWriteAttributes IN BOOLEAN:=FALSE)
IS
    nFileAttrs SMB_FILE_ATTRIBUTES;
    dLastWriteTime DATE;
    nAccessRights USHORT;
    nResourceType USHORT;
    nNMPipeStatus SMB_NMPIPE_STATUS;
    nOpenResults USHORT;
--    bOk BOOLEAN;
    ----
    nOpLockLevel UCHAR;
    nCreateDisposition ULONG;
    dCreateTime DATE;
    dLastAccessTime DATE;
    dLastChangeTime DATE;
    xExtFileAttributes SMB_EXT_FILE_ATTR;
    nAllocationSize LARGE_INTEGER;
--    nEndOfFile LARGE_INTEGER;
    nDirectory UCHAR;
    xGetExtendedAttributeList SMB_GEA_LIST;
    xFileOrDirInfo FileOrDirInfo_T;
    nDesiredAccess ULONG;
    bOk BOOLEAN;
BEGIN
    nDesiredAccess:=2147483648; -- GENERIC_READ
    IF i_bFileWriteAttributes THEN
        nDesiredAccess:=nDesiredAccess + 256; -- FILE_WRITE_ATTRIBUTES
    END IF;    
    SMB_COM_NT_CREATE_ANDX(i_vFileName, 0, 0, nDesiredAccess, 0, 1, 1, 1, 00, 0, 0, nOpLockLevel, o_nFID, nCreateDisposition, dCreateTime, dLastAccessTime, 
    dLastWriteTime, dLastChangeTime, xExtFileAttributes, nAllocationSize, o_nFileDataSize, nResourceType, nNMPipeStatus, nDirectory);
    bOk:=ok(o_vError);
    
    
--    IF ok(o_vError) THEN
--        TRANS2_QUERY_FILE_INFORMATION(o_nFID, SMB_QUERY_FILE_STANDARD_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
--        o_nFileDataSize:=xFileOrDirInfo.nSize;
--        bOk:=ok(o_vError);
--    END IF;
    
END FILE_OPEN;

PROCEDURE FILE_CREATE(i_vFileName IN VARCHAR2, 
                      o_nFID OUT USHORT, 
                      o_nFileDataSize OUT ULONG, 
                      o_vError OUT ERRSTR, 
                      i_bAppend IN BOOLEAN:=FALSE)
IS
    nOpLockLevel UCHAR;
    nCreateDispositionOut ULONG;
    dCreateTime DATE;
    dLastAccessTime DATE;
    dLastWriteTime DATE;
    dLastChangeTime DATE;
    xExtFileAttributes SMB_EXT_FILE_ATTR;
    nAllocationSize LARGE_INTEGER;
    nResourceType USHORT;
    nNMPipeStatus SMB_NMPIPE_STATUS; 
    nDirectory UCHAR;
    bOk BOOLEAN;
    nDesiredAccess ULONG;
    nCreateDisposition ULONG;
BEGIN
    IF xCtx.vService = svc_PrinterShare THEN
        SMB_COM_OPEN_PRINT_FILE(0, 1, i_vFileName, o_nFID); 
    ELSE
        nDesiredAccess:=268435456; -- GENERIC_ALL
        nCreateDisposition:=0; -- FILE_SUPERSEDE
        IF i_bAppend THEN
            nCreateDisposition:=3; -- FILE_OPEN_IF
        END IF;
        SMB_COM_NT_CREATE_ANDX(i_vFileName, 0, 0, nDesiredAccess, 500, 0, 0, nCreateDisposition, 0, 0, 0, nOpLockLevel, o_nFID, nCreateDispositionOut, dCreateTime, dLastAccessTime, 
        dLastWriteTime, dLastChangeTime, xExtFileAttributes, nAllocationSize, o_nFileDataSize, nResourceType, nNMPipeStatus, nDirectory);
    END IF;
    bOk:=ok(o_vError);

END FILE_CREATE;

PROCEDURE READ_FILE_INT(i_nFID IN USHORT, 
                        o_bContent OUT BLOB, 
                        i_nOffset IN ULONG, 
                        i_nLength IN ULONG, 
                        o_vError OUT ERRSTR)
IS
    rData RAW(32000);    
    nBufferSize CONSTANT PLS_INTEGER:=30000;
    nAvailable USHORT;
    nLength PLS_INTEGER;  
BEGIN
    DBMS_LOB.CREATETEMPORARY(o_bContent, FALSE);
    FOR i IN 1..CEIL(i_nLength / nBufferSize)
    LOOP
        SMB_COM_READ_ANDX(i_nFID, i_nOffset + (i - 1) * nBufferSize, nBufferSize, nBufferSize, 500, rData, nAvailable);
        EXIT WHEN NOT(ok(o_vError));
        nLength:=NVL(UTL_RAW.LENGTH(rData), 0);
        EXIT WHEN nLength = 0;
        DBMS_LOB.WRITEAPPEND(o_bContent, nLength, rData);    
    END LOOP;

END READ_FILE_INT;

PROCEDURE READ_FILE(i_vFileLocation IN VARCHAR2,
                    o_bContent OUT BLOB,
                    o_vError OUT ERRSTR)
IS
    nFID USHORT;  
    nFileDataSize ULONG;
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vFileName, nFID, nFileDataSize, o_vError);
        IF o_vError IS NULL THEN
            READ_FILE_INT(nFID, o_bContent, 0, nFileDataSize, o_vError); 
            SMB_COM_CLOSE(nFID);
            bOk:=ok(o_vError);
        END IF;  
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE;

END READ_FILE;  

PROCEDURE WRITE_FILE_INT(i_nFID IN USHORT, 
                         i_bContent IN BLOB,
                         i_nOffset IN ULONG,
                         o_vError OUT ERRSTR, 
                         i_nFlushEvery IN PLS_INTEGER:=1000)
IS
    nBufferSize CONSTANT PLS_INTEGER:=4000; --[A_REVOIR] Dès qu'on dépasse environ 4300 octets, on se prends une erreur Server Error (0x02) - 0x0001 Non Specific error code.
    rData RAW(4000);
    nCount USHORT;
    nAvailable USHORT;   
BEGIN
    FOR i IN 1..CEIL(NVL(DBMS_LOB.GETLENGTH(i_bContent), 0) / nBufferSize)
    LOOP
        rData:=DBMS_LOB.SUBSTR(i_bContent, nBufferSize, 1 + (i - 1) * nBufferSize);
        SMB_COM_WRITE_ANDX(i_nFID, i_nOffset + (i - 1) * nBufferSize, 0, 0, 0, rData, nCount, nAvailable);
        EXIT WHEN NOT(ok(o_vError));
        IF MOD(i, i_nFlushEvery) = 0 THEN
               SMB_COM_FLUSH(i_nFID);
        END IF;
    END LOOP;        

END WRITE_FILE_INT;                                          
                   
PROCEDURE WRITE_FILE(i_vFileLocation IN VARCHAR2,
                     i_bContent IN BLOB,
                     o_vError OUT ERRSTR)
IS 
    nFID USHORT;
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    nFileDataSize ULONG;
BEGIN
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_CREATE(vFileName, nFID, nFileDataSize, o_vError);
        IF o_vError IS NULL THEN
            WRITE_FILE_INT(nFID, i_bContent, 0, o_vError);
            SMB_COM_CLOSE(nFID);  
            bOk:=ok(o_vError);
        END IF;
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE;

END WRITE_FILE;

/** Return True if the two shares are in the same host
 *  @param  i_xShare1 First Share to compare
 *  @param  i_xShare2 Second Share to compare
 *  @return True if i_xShare1 = i_xShare2
 */
FUNCTION HOST_EQ(i_xShare1 IN SHARE_T, 
                 i_xShare2 IN SHARE_T) RETURN BOOLEAN
IS
    vNull CONSTANT VARCHAR2(10):='!Null!';
    bIsEqual BOOLEAN;
BEGIN
    bIsEqual:=FALSE;
    IF NVL(i_xShare1.vDomain, vNull) = NVL(i_xShare2.vDomain, vNull) THEN
        IF NVL(i_xShare1.vLogin, vNull) = NVL(i_xShare2.vLogin, vNull) THEN
            IF NVL(i_xShare1.vPassword, vNull) = NVL(i_xShare2.vPassword, vNull) THEN
                IF NVL(i_xShare1.vHost, vNull) = NVL(i_xShare2.vHost, vNull) THEN
                    IF NVL(i_xShare1.nPort, -1) = NVL(i_xShare2.nPort, -2) THEN
                        IF NVL(i_xShare1.nPort, -1) = NVL(i_xShare2.nPort, -2) THEN
                            bIsEqual:=TRUE;
                        END IF;
                    END IF;
                END IF;
            END IF; 
        END IF; 
    END IF;
    RETURN bIsEqual;

END HOST_EQ;  

/** Return True if the two shares are equal
 *  @param  i_xShare1 First Share to compare
 *  @param  i_xShare2 Second Share to compare
 *  @return True if i_xShare1 = i_xShare2
 */
FUNCTION SHARE_EQ(i_xShare1 IN SHARE_T, 
                  i_xShare2 IN SHARE_T) RETURN BOOLEAN
IS
    vNull CONSTANT VARCHAR2(10):='!Null!';
    bIsEqual BOOLEAN;
BEGIN
    bIsEqual:=FALSE;
    IF HOST_EQ(i_xShare1, i_xShare2) THEN
        IF i_xShare1.vShare = i_xShare2.vShare THEN
            bIsEqual:=TRUE;
        END IF;
    END IF; 
    RETURN bIsEqual;

END SHARE_EQ;   

PROCEDURE SRV_COPY_FILE(i_nTIDSrc IN USHORT, 
                        i_nFIDSrc IN USHORT,
                        i_nTIDDest IN USHORT,
                        i_nFIDDest IN USHORT,
                        i_nFileDataSize IN PLS_INTEGER,
                        o_vError OUT ERRSTR)
IS

    bOk BOOLEAN;
    rCopychunkResumeKey RAW(24);
    TxCopyChunkList COPYCHUNK_C;
    nChunksWritten ULONG; 
    nChunkBytesWritten ULONG;
    nTotalBytesWritten ULONG; 
    nMaxChunkSize CONSTANT PLS_INTEGER:=1048576;  
    nMaxChunkCopy CONSTANT PLS_INTEGER:=16;
    nNbIter PLS_INTEGER; 
    nNbIter2 PLS_INTEGER;
    nIterChunkSize PLS_INTEGER;
    nTIDBackup USHORT;
BEGIN
    nTIDBackup:=xCtx.xSMBHeader.TID;
    xCtx.xSMBHeader.TID:=i_nTIDSrc;
    FSCTL_SRV_REQUEST_RESUME_KEY(i_nFIDSrc, rCopychunkResumeKey);
    IF rCopychunkResumeKey IS NULL THEN
        o_vError:=err_SRV_COPYCHUNK_FAIL;
    END IF;
    xCtx.xSMBHeader.TID:=i_nTIDDest;
    IF o_vError IS NULL THEN
        nNbIter:=CEIL(i_nFileDataSize / nMaxChunkSize);
        nNbIter2:=1;
        FOR i IN 1..nNbIter
        LOOP
            DBMS_APPLICATION_INFO.SET_MODULE('SMB.COPY_FILE', TO_CHAR(ROUND(i * 100 / nNbIter)) || '%');
            TxCopyChunkList(nNbIter2).nSourceOffset:=(i - 1) * nMaxChunkSize;
            TxCopyChunkList(nNbIter2).nDestinationOffset:=(i - 1) * nMaxChunkSize;
            IF i < nNbIter THEN
                nIterChunkSize:=nMaxChunkSize;
            ELSE
                nIterChunkSize:=MOD(i_nFileDataSize, nMaxChunkSize);
                IF nIterChunkSize = 0 THEN
                    nIterChunkSize:=nMaxChunkSize;
                END IF;
            END IF;
            TxCopyChunkList(nNbIter2).nCopyLength:=nIterChunkSize;
            IF nNbIter2 = nMaxChunkCopy OR i = nNbIter THEN
                FSCTL_SRV_COPYCHUNK(i_nFIDDest, rCopychunkResumeKey, TxCopyChunkList, nChunksWritten, nChunkBytesWritten, nTotalBytesWritten); 
                IF nTotalBytesWritten IS NULL THEN
                    o_vError:=err_SRV_COPYCHUNK_FAIL;
                    EXIT;
                END IF;
                TxCopyChunkList.DELETE;
                nNbIter2:=0;
            END IF;
            nNbIter2:=nNbIter2 + 1;
        END LOOP;
    END IF;
    xCtx.xSMBHeader.TID:=nTIDBackup;
END SRV_COPY_FILE;

PROCEDURE COPY_FILE(i_vSourceFileLocation IN VARCHAR2,
                    i_vDestFileLocation IN VARCHAR2, 
                    o_vError OUT ERRSTR)
IS
    nFIDSrc USHORT; 
    nFIDDest USHORT;
    nFileDataSize ULONG;
    nFileDataSize2 ULONG;    
    nAvailable USHORT;  
    rData RAW(32000);
    rDataOut RAW(4000);    
    nBufferSize CONSTANT PLS_INTEGER:=30000;
    nBufferOutSize CONSTANT PLS_INTEGER:=4000;
    bOk BOOLEAN;
    nCount USHORT;
    xCtxBackup contextRec;
    nNbIter PLS_INTEGER;
    xSrcShare SHARE_T;
    xDestShare SHARE_T;
    vSrcFileName VARCHAR2(1000);
    vDestFileName VARCHAR2(1000);
    bSameHost BOOLEAN;
    bSrvCopyFail BOOLEAN;
    PROCEDURE SWAP_CONTEXT(i_bSameHost IN BOOLEAN)
    IS
        xCtx3 contextRec;
    BEGIN
        IF i_bSameHost THEN
            null;
            xCtx3.xSMBHeader.TID:=xCtx.xSMBHeader.TID;
            xCtx.xSMBHeader.TID:=xCtxBackup.xSMBHeader.TID;
            xCtxBackup.xSMBHeader.TID:=xCtx3.xSMBHeader.TID;
        ELSE
            xCtx3:=xCtx;
            xCtx:=xCtxBackup;
            xCtxBackup:=xCtx3;
        END IF;
    END SWAP_CONTEXT;
BEGIN
    SPLIT_URL(i_vSourceFileLocation, NULL, xSrcShare, vSrcFileName);
    SPLIT_URL(i_vDestFileLocation, NULL, xDestShare, vDestFileName);
    SHARE_CONNECT(xSrcShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vSrcFileName, nFIDSrc, nFileDataSize, o_vError); 
        IF o_vError IS NULL THEN
            bSameHost:=HOST_EQ(xSrcShare, xDestShare);
            SWAP_CONTEXT(bSameHost); -- SRC => DEST
            IF SHARE_EQ(xSrcShare, xDestShare) THEN
                xCtx.xSMBHeader.TID:=xCtxBackup.xSMBHeader.TID;
            ELSE
               SHARE_CONNECT(xDestShare, o_vError, NOT(bSameHost));
            END IF;
            IF o_vError IS NULL THEN
                FILE_CREATE(vDestFileName, nFIDDest, nFileDataSize2, o_vError);
                IF o_vError IS NULL THEN
                    bSrvCopyFail:=FALSE;
                    IF bSameHost THEN
                        DECLARE
                            nTIDSrc USHORT;
                            nTIDDest USHORT;
                        BEGIN
                            nTIDSrc:=xCtxBackup.xSMBHeader.TID;
                            nTIDDest:=xCtx.xSMBHeader.TID;
                            SRV_COPY_FILE(nTIDSrc, nFIDSrc, nTIDDest, nFIDDest, nFileDataSize, o_vError);
                            IF o_vError = err_SRV_COPYCHUNK_FAIL THEN
                                o_vError:=NULL;
                                xCtx.xSMBHeader.Status:=ULONGToSMBStatus(0);
                                bSrvCopyFail:=TRUE;
                           END IF;
                        END;
                    END IF;
                    IF NOT(bSameHost) OR bSrvCopyFail THEN
                        nNbIter:=CEIL(nFileDataSize / nBufferSize);
                        FOR i IN 1..nNbIter
                        LOOP
                            DBMS_APPLICATION_INFO.SET_MODULE('SMB.COPY_FILE', TO_CHAR(ROUND(i * 100 / nNbIter)) || '%');
                            SWAP_CONTEXT(bSameHost); -- DEST -> SRC
                            SMB_COM_READ_ANDX(nFIDSrc, (i - 1) * nBufferSize, nBufferSize, nBufferSize, 500, rData, nAvailable);
                            SWAP_CONTEXT(bSameHost); -- SRC -> DEST
                            EXIT WHEN NOT(ok(o_vError));
                            -- [A_REVOIR] En écriture on va jusqu'à 4300, donc on fait plusieurs itération, car en lecture, on gagne à faire de plus grosses lectures. 
                            FOR j IN 1..CEIL(UTL_RAW.LENGTH(rData) / nBufferOutSize)
                            LOOP
                                rDataOut:=RAW_SUBSTR(rData, (j - 1) * nBufferOutSize + 1, nBufferOutSize);
                                SMB_COM_WRITE_ANDX(nFIDDest, (i - 1) * nBufferSize + (j - 1) * nBufferOutSize, 0, 0, 0, rDataOut, nCount, nAvailable);
                                EXIT WHEN NOT(ok(o_vError));
                            END LOOP;
                            EXIT WHEN NOT(ok(o_vError));
                            IF MOD(i, 1000) = 0 THEN
                                SMB_COM_FLUSH(nFIDDest);
                            END IF;
                        END LOOP;
                    END IF;     
                    SMB_COM_CLOSE(nFIDDest);  
                    bOk:=ok(o_vError);
                END IF;
                IF NOT(bSameHost) THEN
                    SMB_COM_LOGOFF_ANDX; 
                end if;
                bOk:=ok(o_vError);
            END IF;
            IF NOT(bSameHost) THEN
                SOCKET_CLOSE;
            END IF;
            SWAP_CONTEXT(bSameHost); -- DEST -> SRC
            SMB_COM_CLOSE(nFIDSrc);
            bOk:=ok(o_vError);
        END IF;
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE;
   
END COPY_FILE; 

PROCEDURE RENAME_FILE(i_vSourceFileLocation IN VARCHAR2,
                      i_vDestFileLocation IN VARCHAR2, 
                      o_vError OUT ERRSTR)
IS
    bOk BOOLEAN;
    xSrcShare SHARE_T;
    xDestShare SHARE_T;
    vSrcFileName VARCHAR2(1000);
    vDestFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vSourceFileLocation, NULL, xSrcShare, vSrcFileName);
    SPLIT_URL(i_vDestFileLocation, NULL, xDestShare, vDestFileName);
    IF NOT(SHARE_EQ(xSrcShare, xDestShare)) THEN
        -- [A_REVOIR] Faire une copie
        o_vError:=err_SHARES_MISMATCH;
    ELSE
        SHARE_CONNECT(xSrcShare, o_vError);
        IF o_vError IS NULL THEN
            SMB_COM_RENAME(0, vSrcFileName, vDestFileName);
            bOk:=ok(o_vError);
            SMB_COM_LOGOFF_ANDX; 
            bOk:=ok(o_vError);
        END IF;
        SOCKET_CLOSE;
    END IF;

END RENAME_FILE; 

PROCEDURE MKLINK(i_vSourceFileLocation IN VARCHAR2,
                 i_vDestFileLocation IN VARCHAR2,  
                 o_vError OUT ERRSTR)  
IS
    bOk BOOLEAN;
    SMB_NT_RENAME_SET_LINK_INFO CONSTANT USHORT:=259;
    xSrcShare SHARE_T;
    xDestShare SHARE_T;
    vSrcFileName VARCHAR2(1000);
    vDestFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vSourceFileLocation, NULL, xSrcShare, vSrcFileName);
    SPLIT_URL(i_vDestFileLocation, NULL, xDestShare, vDestFileName);
    IF NOT(SHARE_EQ(xSrcShare, xDestShare)) THEN
        o_vError:=err_SHARES_MISMATCH;
    ELSE
        SHARE_CONNECT(xSrcShare, o_vError);
        IF o_vError IS NULL THEN
            SMB_COM_NT_RENAME(0, SMB_NT_RENAME_SET_LINK_INFO, vSrcFileName, vDestFileName);
            bOk:=ok(o_vError);
            SMB_COM_LOGOFF_ANDX; 
            bOk:=ok(o_vError);
        END IF;
        SOCKET_CLOSE;
    END IF;

END MKLINK; 

/** Delete File (Internal)
 *  @param  i_vFileName File to delete
 *  @param  i_nOption Delete even if file is : 1 - Readonly ; 2 - Hidden ; - 4 - System.
 *  @param  o_vError 
 */
PROCEDURE DELETE_FILE_INT(i_vFileName IN VARCHAR2,
                          i_nOption IN USHORT,  
                          o_vError OUT ERRSTR)
IS
    nFID USHORT;
    nFileDataSize PLS_INTEGER;
    xGetExtendedAttributeList SMB_GEA_LIST;
    xFileOrDirInfo FileOrDirInfo_T;
    nEaErrorOffset USHORT;
    bOk BOOLEAN;
BEGIN
    SMB_COM_DELETE(i_nOption, i_vFileName);
    bOk:=ok(o_vError);
    IF o_vError LIKE '%STATUS_CANNOT_DELETE%' THEN
        IF BITAND(i_nOption, SMB_FILE_ATTRIBUTE_READONLY) > 0 THEN
            o_vError:=NULL;
            FILE_OPEN(i_vFileName, nFID, nFileDataSize, o_vError, TRUE);
            -- Remove the READONLY attributes
            IF ok(o_vError) THEN
                TRANS2_QUERY_FILE_INFORMATION(nFID, SMB_QUERY_FILE_ALL_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
                IF BITAND(xFileOrDirInfo.nExtFileAttributes, SMB_FILE_ATTRIBUTE_READONLY) > 0 THEN
                    xFileOrDirInfo.nExtFileAttributes:=xFileOrDirInfo.nExtFileAttributes - SMB_FILE_ATTRIBUTE_READONLY;
                    TRANS2_SET_FILE_INFORMATION(nFID, SMB_SET_FILE_BASIC_INFO, xFileOrDirInfo, nEaErrorOffset);
                    bOk:=ok(o_vError);
                END IF;
                SMB_COM_CLOSE(nFID);
                bOk:=ok(o_vError);
            END IF;
            SMB_COM_DELETE(i_nOption, i_vFileName);
        END IF; 
    END IF;

END DELETE_FILE_INT;

PROCEDURE DELETE_FILE(i_vFileLocation IN VARCHAR2,
                      i_nLevel IN PLS_INTEGER:=0, 
                      o_vError OUT ERRSTR)
IS
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        DELETE_FILE_INT(vFileName, i_nLevel, o_vError);
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE;

END DELETE_FILE;                         

FUNCTION DIR_INT(i_vFileName IN VARCHAR2, 
                 o_vError OUT ERRSTR) RETURN FILE_INFO_C
IS
    nSearchAttrib SMB_FILE_ATTRIBUTES:=22;
    nSearchCount USHORT:=20; -- (En mettant environ 60, le transaction2 dépasse sa limite de 4300 octets...).. 
    nFlags USHORT:=6;
    nInfoLevel USHORT:=SMB_INFO_STANDARD; -- SMB_FIND_FILE_BOTH_DIR_INFO;
    vPattern VARCHAR2(80):='*';
    TxGea SMB_GEA_LIST;
    nSearchCount2 USHORT;
    nSID USHORT;
    nEndOfSearch USHORT;
    nEaErrorOffset USHORT;
    nLastNameOffset USHORT;
    TxFileOrDirInfo FileOrDirInfo_C;   
    TxFileInfo FILE_INFO_C; 
    bOk BOOLEAN;
BEGIN
    TRANS2_FIND_FIRST2(nSearchAttrib, nSearchCount, nFlags, nInfoLevel, 0, i_vFileName, TxGea, nSID, nSearchCount2, nEndOfSearch, nEaErrorOffset, nLastNameOffset, TxFileOrDirInfo);
    IF ok(o_vError) THEN
        WHILE(nEndOfSearch = 0) AND (nSearchCount2 > 0) -- [A_REVOIR] Bizarre le nSearchCount2 > 0 : mais bug si nSearchCount est en tout 2 fichiers + (. + ..) = 4 fichiers.
        LOOP
            TRANS2_FIND_NEXT2(nSID, nSearchCount, nInfoLevel, 0, SMB_FIND_CONTINUE_FROM_LAST + nFlags, i_vFileName, TxGea, nSearchCount2, nEndOfSearch, nEaErrorOffset, nLastNameOffset, TxFileOrDirInfo);
            EXIT WHEN NOT(ok(o_vError));
        END LOOP;
        IF o_vError IS NULL THEN
            FOR i IN 1..TxFileOrDirInfo.COUNT
            LOOP
                TxFileInfo(i).vFileName:=TxFileOrDirInfo(i).vFileName;
                TxFileInfo(i).vShortFileName:=TxFileOrDirInfo(i).vShortFileName;
                TxFileInfo(i).nExtFileAttributes:=TxFileOrDirInfo(i).nExtFileAttributes;
                TxFileInfo(i).dCreationTime:=TxFileOrDirInfo(i).dCreationTime;
                TxFileInfo(i).dLastAccessTime:=TxFileOrDirInfo(i).dLastAccessTime;
                TxFileInfo(i).dLastWriteTime:=TxFileOrDirInfo(i).dLastWriteTime;
                TxFileInfo(i).dLastChangeTime:=TxFileOrDirInfo(i).dLastChangeTime;
                TxFileInfo(i).nSize:=TxFileOrDirInfo(i).nSize;
                TxFileInfo(i).nAllocationSize:=TxFileOrDirInfo(i).nAllocationSize;
                TxFileInfo(i).bDirectory:=(BITAND(TxFileOrDirInfo(i).nFileAttributes, SMB_FILE_ATTRIBUTE_DIRECTORY) > 0);
            END LOOP;
        END IF;
    END IF;
    RETURN TxFileInfo;    
END DIR_INT;

FUNCTION DIR(i_vFolderLocation IN VARCHAR2,
             o_vError OUT ERRSTR) RETURN FILE_INFO_C
IS
    TxFileInfo FILE_INFO_C; 
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vFolderLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare,  o_vError);
    IF o_vError IS NULL THEN
        TxFileInfo:=DIR_INT(vFileName, o_vError);
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE;        
    RETURN TxFileInfo;
END DIR;        
 
PROCEDURE CHECK_DIR(i_vFolderLocation IN VARCHAR2,
                    o_vError OUT ERRSTR)             
IS
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vFolderLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        SMB_COM_CHECK_DIRECTORY(vFileName);
        bOk:=ok(o_vError);
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE;

END CHECK_DIR;             

PROCEDURE MKDIR(i_vFolderLocation IN VARCHAR2,
                o_vError OUT ERRSTR)                
IS
    TxExtendedAttributeList SMB_FEA_LIST;
    nEAErrorOffset USHORT;
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    TvFolder STR_BY_NUM;
    vError2 ERRSTR;
BEGIN
    SPLIT_URL(i_vFolderLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        TvFolder:=split(vFileName, '\');
        vFileName:=NULL;
        FOR i IN 1..TvFolder.COUNT
        LOOP
            IF vFileName IS NOT NULL THEN
                vFileName:=vFileName || '\';
            END IF;
            vFileName:=vFileName || TvFolder(i);
            vError2:=NULL;
            SMB_COM_CHECK_DIRECTORY(vFileName);
            IF NOT(ok(vError2)) THEN
                TRANS2_CREATE_DIRECTORY(vFileName, TxExtendedAttributeList, nEAErrorOffset);
                 bOk:=ok(o_vError);
                 EXIT WHEN NOT(bOk);
            END IF;
        END LOOP;
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE; 
END MKDIR;   

PROCEDURE REMOVE_DIR_CONTENT(i_vFileName IN VARCHAR2, 
                             o_vError OUT ERRSTR)
IS
    TxFileInfo FILE_INFO_C;     
    bOk BOOLEAN;
    nDeleteAttribute USHORT;
BEGIN
    TxFileInfo:=DIR_INT(RTRIM(i_vFilename, '\') || '\*', o_vError);
    FOR i IN 1..TxFileInfo.COUNT
    LOOP
        IF TxFileInfo(i).bDirectory THEN
            IF TxFileInfo(i).vFileName NOT IN ('.', '..') THEN
                REMOVE_DIR_CONTENT(i_vFileName || '\' || TxFileInfo(i).vFileName, o_vError);
            END IF;
        ELSE
            nDeleteAttribute:=SMB_FILE_ATTRIBUTE_NORMAL +
                              SMB_FILE_ATTRIBUTE_READONLY + 
                              SMB_FILE_ATTRIBUTE_HIDDEN +
                              SMB_FILE_ATTRIBUTE_SYSTEM; 
            DELETE_FILE_INT(i_vFileName || '\' || TxFileInfo(i).vFileName, nDeleteAttribute, o_vError);
        END IF;
    END LOOP;
    SMB_COM_DELETE_DIRECTORY(i_vFileName);
    bOk:=ok(o_vError);
    
END REMOVE_DIR_CONTENT;
                    
PROCEDURE RMDIR(i_vFolderLocation IN VARCHAR2,
                i_bContent IN BOOLEAN:=FALSE,
                o_vError OUT ERRSTR)                
IS
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vFolderLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        SMB_COM_DELETE_DIRECTORY(vFileName);
        bOk:=ok(o_vError);
        IF i_bContent AND o_vError LIKE '%STATUS_DIRECTORY_NOT_EMPTY%' THEN
            REMOVE_DIR_CONTENT(vFileName, o_vError);
        END IF;
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE;        
    
END RMDIR;          

FUNCTION GET_FILESYSTEM_INFO(i_vShareLocation IN VARCHAR2,
                             o_vError OUT ERRSTR) RETURN FILESYSTEM_INFO_T          
IS
    xFSInfoRaw FS_INFO_T;
    xFSInfo FILESYSTEM_INFO_T;
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vShareLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        TRANS2_QUERY_FS_INFORMATION(SMB_QUERY_FS_VOLUME_INFO, xFSInfoRaw);
        bOk:=ok(o_vError);
        TRANS2_QUERY_FS_INFORMATION(SMB_QUERY_FS_SIZE_INFO, xFSInfoRaw);
        bOk:=ok(o_vError);
        TRANS2_QUERY_FS_INFORMATION(SMB_QUERY_FS_DEVICE_INFO, xFSInfoRaw);
        bOk:=ok(o_vError);
        TRANS2_QUERY_FS_INFORMATION(SMB_QUERY_FS_ATTRIBUTE_INFO, xFSInfoRaw);
        bOk:=ok(o_vError);
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;
    SOCKET_CLOSE;    
    xFSInfo.nSerialNumber:=xFSInfoRaw.SerialNumber;
    xFSInfo.vVolumeLabel:=xFSInfoRaw.VolumeLabel;
    xFSInfo.dVolumeCreationTime:=xFSInfoRaw.VolumeCreationTime;
    xFSInfo.nTotalSpaceInBytes:=xFSInfoRaw.TotalAllocationUnits * xFSInfoRaw.SectorsPerAllocationUnit * xFSInfoRaw.BytesPerSector;
    xFSInfo.nTotalFreeSpaceInBytes:=xFSInfoRaw.TotalFreeAllocationUnits * xFSInfoRaw.SectorsPerAllocationUnit * xFSInfoRaw.BytesPerSector;
    xFSInfo.nDeviceType:=xFSInfoRaw.DeviceType;
    xFSInfo.nDeviceCharacteristics:=xFSInfoRaw.DeviceCharacteristics;
    xFSInfo.nFileSystemAttributes:=xFSInfoRaw.FileSystemAttributes;
    xFSInfo.nMaxFileNameLengthInBytes:=xFSInfoRaw.MaxFileNameLengthInBytes;
    xFSInfo.vFileSystemName:=xFSInfoRaw.FileSystemName;
    
    RETURN xFSInfo;    

END GET_FILESYSTEM_INFO;     

FUNCTION GET_FILE_INFO(i_vFileLocation IN VARCHAR2,
                       o_vError OUT ERRSTR) RETURN FILE_INFO_T
IS
    nFID USHORT;  
    nFileDataSize ULONG;
    bOk BOOLEAN;
    xGetExtendedAttributeList SMB_GEA_LIST;
    xFileOrDirInfo FileOrDirInfo_T;
    xFileInfo FILE_INFO_T;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vFileName, nFID, nFileDataSize, o_vError);
        IF o_vError IS NULL THEN
            TRANS2_QUERY_FILE_INFORMATION(nFID, SMB_QUERY_FILE_ALL_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
            bOk:=ok(o_vError);
            TRANS2_QUERY_FILE_INFORMATION(nFID, SMB_QUERY_FILE_ALT_NAME_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
            bOk:=ok(o_vError);
--            TRANS2_QUERY_FILE_INFORMATION(nFID, SMB_QUERY_FILE_STREAM_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
--            bOk:=ok(o_vError);
--            TRANS2_QUERY_FILE_INFORMATION(nFID, SMB_QUERY_FILE_COMPRESS_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
--            bOk:=ok(o_vError);
            xFileInfo.vFileName:=xFileOrDirInfo.vFileName;
            xFileInfo.vShortFileName:=xFileOrDirInfo.vShortFileName;
            xFileInfo.bDirectory:=xFileOrDirInfo.bDirectory;
            xFileInfo.dCreationTime:=xFileOrDirInfo.dCreationTime;
            xFileInfo.dLastAccessTime:=xFileOrDirInfo.dLastAccessTime;
            xFileInfo.dLastWriteTime:=xFileOrDirInfo.dLastWriteTime;
            xFileInfo.dLastChangeTime:=xFileOrDirInfo.dLastChangeTime;
            xFileInfo.nSize:=xFileOrDirInfo.nSize;
            xFileInfo.nAllocationSize:=xFileOrDirInfo.nAllocationSize;
            xFileInfo.nExtFileAttributes:=xFileOrDirInfo.nExtFileAttributes;
            SMB_COM_CLOSE(nFID);
            bOk:=ok(o_vError);
        END IF;    
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;
    SOCKET_CLOSE;
    RETURN xFileInfo;
    
END GET_FILE_INFO;

PROCEDURE GET_ATTRIB(i_vFileLocation IN VARCHAR2,
                     o_bReadOnly OUT BOOLEAN,
                     o_bArchive OUT BOOLEAN,
                     o_bSystem OUT BOOLEAN,
                     o_bHidden OUT BOOLEAN,
                     o_bDoNotIndexContent OUT BOOLEAN,
                     o_vError OUT ERRSTR)
IS                     
    nFID USHORT;  
    nFileDataSize ULONG;
    bOk BOOLEAN;
    xGetExtendedAttributeList SMB_GEA_LIST;
    xFileOrDirInfo FileOrDirInfo_T;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vFileName, nFID, nFileDataSize, o_vError);
        IF o_vError IS NULL THEN
            TRANS2_QUERY_FILE_INFORMATION(nFID, SMB_QUERY_FILE_ALL_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
            o_bReadOnly:=BITAND(xFileOrDirInfo.nExtFileAttributes, ATTR_READONLY) > 0;
            o_bArchive:=BITAND(xFileOrDirInfo.nExtFileAttributes, ATTR_ARCHIVE) > 0;
            o_bSystem:=BITAND(xFileOrDirInfo.nExtFileAttributes, ATTR_SYSTEM) > 0;
            o_bHidden:=BITAND(xFileOrDirInfo.nExtFileAttributes, ATTR_HIDDEN) > 0;
            o_bDoNotIndexContent:=BITAND(xFileOrDirInfo.nExtFileAttributes, ATTR_NOT_CONTENT_INDEXED) > 0;
            bOk:=ok(o_vError);
            SMB_COM_CLOSE(nFID);
            bOk:=ok(o_vError);
        END IF;    
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;
    SOCKET_CLOSE;

END GET_ATTRIB;       

PROCEDURE SET_ATTRIB(i_vFileLocation IN VARCHAR2,
                     i_bReadOnly IN BOOLEAN,
                     i_bArchive IN BOOLEAN,
                     i_bSystem IN BOOLEAN,
                     i_bHidden IN BOOLEAN,
                     i_bDoNotIndexContent IN BOOLEAN,
                     o_vError OUT ERRSTR)
IS
    nFID USHORT;  
    nFileDataSize ULONG;
    bOk BOOLEAN;
    xGetExtendedAttributeList SMB_GEA_LIST;
    xFileOrDirInfo FileOrDirInfo_T;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    nEaErrorOffset USHORT;
    rExtFileAttributes RAW(4);
    nStart PLS_INTEGER;
BEGIN
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vFileName, nFID, nFileDataSize, o_vError, TRUE);
        IF o_vError IS NULL THEN
            TRANS2_QUERY_FILE_INFORMATION(nFID, SMB_QUERY_FILE_ALL_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
            rExtFileAttributes:=ULongToRaw(xFileOrDirInfo.nExtFileAttributes);
            SET_BIT(rExtFileAttributes, ULongToRaw(ATTR_READONLY), i_bReadOnly);
            SET_BIT(rExtFileAttributes, ULongToRaw(ATTR_ARCHIVE), i_bArchive);
            SET_BIT(rExtFileAttributes, ULongToRaw(ATTR_SYSTEM), i_bSystem);
            SET_BIT(rExtFileAttributes, ULongToRaw(ATTR_HIDDEN), i_bHidden);
            SET_BIT(rExtFileAttributes, ULongToRaw(ATTR_NOT_CONTENT_INDEXED), i_bDoNotIndexContent);
            SET_BIT(rExtFileAttributes, ULongToRaw(ATTR_NORMAL), TRUE); -- Avoid the 0000 attributes that means = no change...
            nStart:=1;
            xFileOrDirInfo.nExtFileAttributes:=RawToULONG(rExtFileAttributes, nStart);
            TRANS2_SET_FILE_INFORMATION(nFID, SMB_SET_FILE_BASIC_INFO, xFileOrDirInfo, nEaErrorOffset);
            bOk:=ok(o_vError);
            SMB_COM_CLOSE(nFID);
            bOk:=ok(o_vError);
        END IF;    
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;
    SOCKET_CLOSE;
END SET_ATTRIB;                                 


FUNCTION GET_FILE_GROUP_OR_OWNER_SID(i_vFileLocation IN VARCHAR2,
                                     i_bOwner IN BOOLEAN, 
                                     o_vError OUT ERRSTR) RETURN VARCHAR2
IS
    nFID USHORT;  
    nFileDataSize ULONG;
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    xSecurityDesc SecurityDescriptor_T;
    nSecurityInfoFields ULONG; 
    vSID VARCHAR2(1000);
BEGIN
    vSID:=NULL;
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vFileName, nFID, nFileDataSize, o_vError);
        IF o_vError IS NULL THEN
            IF i_bOwner THEN
                nSecurityInfoFields:=OWNER_SECURITY_INFORMATION;
            ELSE
                nSecurityInfoFields:=GROUP_SECURITY_INFORMATION;
            END IF;
            NT_TRSACT_QUERY_SECURITY_DESC(nFID, nSecurityInfoFields, xSecurityDesc);
            IF ok(o_vError) THEN
                IF i_bOwner THEN 
                    vSID:=SIDToString(xSecurityDesc.xOwnerSID);
                ELSE
                    vSID:=SIDToString(xSecurityDesc.xGroupSID);
                END IF;
              END IF; 
            SMB_COM_CLOSE(nFID);
            bOk:=ok(o_vError);
        END IF;    
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;
    SOCKET_CLOSE;
    RETURN vSID;
    
END GET_FILE_GROUP_OR_OWNER_SID; 

FUNCTION GET_FILE_OWNER_SID(i_vFileLocation IN VARCHAR2,
                            o_vError OUT ERRSTR) RETURN VARCHAR2
IS
BEGIN
    RETURN GET_FILE_GROUP_OR_OWNER_SID(i_vFileLocation, TRUE, o_vError);
    
END GET_FILE_OWNER_SID; 

FUNCTION GET_FILE_GROUP_SID(i_vFileLocation IN VARCHAR2,
                            o_vError OUT ERRSTR) RETURN VARCHAR2
IS
BEGIN
    RETURN GET_FILE_GROUP_OR_OWNER_SID(i_vFileLocation, FALSE, o_vError);
    
END GET_FILE_GROUP_SID; 

FUNCTION GET_FILE_SEC_INFO(i_vFileLocation IN VARCHAR2,
                           o_vError OUT ERRSTR) RETURN XMLTYPE
IS
    nFID USHORT;  
    nFileDataSize ULONG;
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    xSecurityDesc SecurityDescriptor_T;
    nSecurityInfoFields ULONG; 
    xAce ACE_T;
    xDoc DOMDoc;
    xRoot DOMNode;
    xNode DOMNode;
    xAcl DOMNode;
    xAcesNode DOMNode;
    xAceNode DOMnode;
    xAnswer XMLTYPE;
BEGIN
    NewDoc(xDoc, xRoot, 'UTF8');
    xRoot:=AddNode(xRoot, 'SecurityDescriptor');
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vFileName, nFID, nFileDataSize, o_vError);
        IF o_vError IS NULL THEN
            nSecurityInfoFields:=OWNER_SECURITY_INFORMATION + GROUP_SECURITY_INFORMATION + DACL_SECURITY_INFORMATION;
            NT_TRSACT_QUERY_SECURITY_DESC(nFID, nSecurityInfoFields, xSecurityDesc);
            IF ok(o_vError) THEN
                xNode:=AddNode(xRoot, '@revision', TO_CHAR(xSecurityDesc.nRevision));
                xNode:=AddNode(xRoot, '@control', TO_CHAR(xSecurityDesc.nControl));
                xNode:=AddNode(xRoot, '@ownerSid', SIDToString(xSecurityDesc.xOwnerSID));
                xNode:=AddNode(xRoot, '@groupSid', SIDToString(xSecurityDesc.xGroupSID));
                IF xSecurityDesc.xDAcl.nAclRevision IS NOT NULL THEN
                    xAcl:=AddNode(xRoot, 'dacl');
                    xNode:=AddNode(xAcl, '@revision', TO_CHAR(xSecurityDesc.xDAcl.nAclRevision));
                    IF xSecurityDesc.xDAcl.TxAce.COUNT > 0 THEN
                        xAcesNode:=AddNode(xAcl, 'aces');
                        FOR i IN 1..xSecurityDesc.xDAcl.TxAce.COUNT
                        LOOP
                            xAce:=xSecurityDesc.xDAcl.TxAce(i);
                            xAceNode:=AddNode(xAcesNode, 'ace');
                            xNode:=AddNode(xAceNode, '@item', TO_CHAR(i));
                            xNode:=AddNode(xAceNode, '@type', AceTypeToString(xAce.nAceType));
                            xNode:=AddNode(xAceNode, '@flag', TO_CHAR(xAce.nAceFlag));
                            xNode:=AddNode(xAceNode, '@mask', TO_CHAR(xAce.nMask));
                            xNode:=AddNode(xAceNode, '@sid', SIDToString(xAce.xSID));
                         END LOOP;
                    END IF;
                END IF;
             END IF; 
            SMB_COM_CLOSE(nFID);
            bOk:=ok(o_vError);
        END IF;    
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;
    SOCKET_CLOSE;
     
    xAnswer:=DBMS_XMLDOM.GETXMLTYPE(xDoc);
    Dbms_XmlDom.FreeDocument(xDoc);
    
    RETURN xAnswer;
    
END GET_FILE_SEC_INFO;                           


PROCEDURE SET_FILE_INFO(i_vFileLocation IN VARCHAR2,
                        i_xFileInfo IN FILE_INFO_T, 
                        o_vError OUT ERRSTR)
IS
    nFID USHORT;  
    nFileDataSize ULONG;
    bOk BOOLEAN;
    xFileOrDirInfo FileOrDirInfo_T;
    nEaErrorOffset USHORT;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
BEGIN
    SPLIT_URL(i_vFileLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vFileName, nFID, nFileDataSize, o_vError, TRUE);
        IF o_vError IS NULL THEN
            xFileOrDirInfo.vFileName:=i_xFileInfo.vFileName;
            xFileOrDirInfo.vShortFileName:=i_xFileInfo.vShortFileName;
            xFileOrDirInfo.bDirectory:=i_xFileInfo.bDirectory;
            xFileOrDirInfo.dCreationTime:=i_xFileInfo.dCreationTime;
            xFileOrDirInfo.dLastAccessTime:=i_xFileInfo.dLastAccessTime;
            xFileOrDirInfo.dLastWriteTime:=i_xFileInfo.dLastWriteTime;
            xFileOrDirInfo.dLastChangeTime:=i_xFileInfo.dLastChangeTime;
            xFileOrDirInfo.nExtFileAttributes:=i_xFileInfo.nExtFileAttributes;
            xFileOrDirInfo.nSize:=i_xFileInfo.nSize;
            xFileOrDirInfo.nAllocationSize:=i_xFileInfo.nAllocationSize;
            TRANS2_SET_FILE_INFORMATION(nFID, SMB_SET_FILE_BASIC_INFO, xFileOrDirInfo, nEaErrorOffset);
            bOk:=ok(o_vError);
            SMB_COM_CLOSE(nFID);
            bOk:=ok(o_vError);
        END IF;    
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;
    SOCKET_CLOSE;
    
END SET_FILE_INFO;

FUNCTION GET_HOST_INFO(i_vServerLocation IN VARCHAR2, 
                       o_vError OUT ERRSTR) RETURN HOST_INFO_T                         
IS
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    bOk BOOLEAN;
    xServerInfo HOST_INFO_T;
BEGIN
    SPLIT_URL(i_vServerLocation, NULL, xShare, vFileName, TRUE);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        RAP_NetWkstaGetInfo(xServerInfo, o_vError);
        IF o_vError IS NULL THEN
            RAP_NetServerGetInfo(1, xServerInfo, o_vError);
            IF o_vError IS NULL THEN
                RAP_NetRemoteTOD(xServerInfo, o_vError);
            END IF;
        END IF;
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;    
    SOCKET_CLOSE;
    RETURN xServerInfo;
END GET_HOST_INFO;

FUNCTION GET_HOST_LIST(i_vServerLocation IN VARCHAR2, 
                       i_vDomain IN VARCHAR2:=NULL, 
                       o_vError OUT ERRSTR) RETURN HOST_INFO_C
IS
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    bOk BOOLEAN;
    TxServer HOST_INFO_C;
BEGIN
    SPLIT_URL(i_vServerLocation, NULL, xShare, vFileName, TRUE);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        TxServer:=RAP_NetServerEnum2(1, 4294967295, i_vDomain, o_vError);    
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;    
    SOCKET_CLOSE;
    RETURN TxServer;
    
END GET_HOST_LIST;        

FUNCTION GET_SHARE_LIST(i_vServerLocation IN VARCHAR2, 
                        o_vError OUT ERRSTR) RETURN SHARE_INFO_C
IS
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    bOk BOOLEAN;
    TxShare SHARE_INFO_C;
BEGIN
    SPLIT_URL(i_vServerLocation, NULL, xShare, vFileName, TRUE);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        TxShare:=RAP_NetShareEnumRequest(2, o_vError);
        IF o_vError LIKE '%ERROR_INVALID_LEVEL%' THEN
            TxShare:=RAP_NetShareEnumRequest(1, o_vError);
        END IF;
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;    
    SOCKET_CLOSE;
    RETURN TxShare;

END GET_SHARE_LIST;

FUNCTION GET_USER_INFO(i_vServerLocation IN VARCHAR2, 
                       i_vUserName IN VARCHAR2, 
                       o_vError OUT ERRSTR) RETURN USER_INFO_T
IS
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    bOk BOOLEAN;
    xUserInfo USER_INFO_T;
BEGIN
    SPLIT_URL(i_vServerLocation, NULL, xShare, vFileName, TRUE);
    SHARE_CONNECT(xShare, o_vError);
    IF o_vError IS NULL THEN
        xUserInfo:=RAP_NetUserGetInfo(2, i_vUserName, o_vError);
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);        
    END IF;    
    SOCKET_CLOSE;
    RETURN xUserInfo;
END GET_USER_INFO;

FUNCTION GET_HOT_FOLDER_LIST(i_vFolderLocationFilter IN VARCHAR2:='%') RETURN HOT_FOLDER_C
IS
    TvHotFolder HOT_FOLDER_C;
BEGIN
    RETURN TvHotFolder;
END GET_HOT_FOLDER_LIST;

PROCEDURE CREATE_HOT_FOLDER(i_vFolderLocation IN VARCHAR2, 
                            i_vCallbackProc IN VARCHAR2, 
                            o_vError OUT ERRSTR)
IS
BEGIN
    NULL;
END CREATE_HOT_FOLDER;                            
                            
PROCEDURE DROP_HOT_FOLDER(i_vFolderLocation IN VARCHAR2, 
                            o_vError OUT ERRSTR)
IS
BEGIN
    NULL;
END DROP_HOT_FOLDER;                                                    
         
PROCEDURE HOT_FOLDER(i_vFolderLocation IN VARCHAR2,
                     i_vCallbackProc IN VARCHAR2, 
                     o_vError OUT ERRSTR)
IS
    bOk BOOLEAN;
    xShare SHARE_T;
    vFileName VARCHAR2(1000);
    nFileDataSize PLS_INTEGER;
    nFID USHORT;
    TxFileNotifyInfo FILE_NOTIFY_INFO_C;
    nCnt PLS_INTEGER:=1;
    bQuit BOOLEAN:=FALSE;
    nBgJobID CONSTANT NUMBER:=SYS_CONTEXT('USERENV','BG_JOB_ID');
BEGIN
    SPLIT_URL(i_vFolderLocation, NULL, xShare, vFileName);
    SHARE_CONNECT(xShare,  o_vError);
    IF o_vError IS NULL THEN
        FILE_OPEN(vFileName, nFID, nFileDataSize, o_vError);
        IF o_vError IS NULL THEN
            LOOP
                NT_TRSACT_NOTIFY_CHANGE(8, nFID, FALSE, TxFileNotifyInfo); -- 4095
                FOR i IN 1..TxFileNotifyInfo.COUNT
                LOOP
                    IF TxFileNotifyInfo(i).vFileName = 'fini' THEN
                        bQuit:=TRUE;
                    END IF;
                    Dbg(TO_CHAR(nCnt) || '-' || TO_CHAR(i) || '-' || TO_CHAR(SYSDATE, 'HH24:MI:SS') || '-' || TxFileNotifyInfo(i).vFileName || '=>' || TO_CHAR(TxFileNotifyInfo(i).nFileAction));
                END LOOP;
        DECLARE
            nJobExists PLS_INTEGER;
        BEGIN            
            SELECT COUNT(*) INTO nJobExists
            FROM user_jobs
            WHERE job = nBgJobID;
            IF nJobExists = 0 THEN
                bQuit:=TRUE;
            END IF;
        END;
                
                EXIT WHEN bQuit;
                EXIT WHEN NOT ok(o_vError);
                DBMS_APPLICATION_INFO.SET_MODULE('SMB.HOT_FOLDER', 'nCnt=' || TO_CHAR(nCnt));
                nCnt:=nCnt + 1;
            END LOOP;
            SMB_COM_CLOSE(nFID);  
        END IF;
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(o_vError);
    END IF;
    SOCKET_CLOSE;        
END HOT_FOLDER; 

PROCEDURE SPLIT_URL(i_vFullFileName IN VARCHAR2, 
                    i_xCredential IN CREDENTIAL_T,
                    o_xShare OUT SHARE_T, 
                    o_vFileName OUT VARCHAR2,
                    i_bServerName IN BOOLEAN:=FALSE)
IS
    vFullFileName VARCHAR2(1000);
    bType1 BOOLEAN;
    nPos PLS_INTEGER;
    vCredential VARCHAR2(1000);
    SYNTAX_ERROR EXCEPTION;
BEGIN
    vFullFileName:=i_vFullFileName;
    IF i_bServerName THEN
        IF vFullFileName NOT LIKE 'smb://%' AND vFullFileName NOT LIKE 'file://%' AND vFullFileName NOT LIKE '\\%' THEN 
            vFullFileName:='\\' || vFullFileName; 
        END IF;
        vFullFileName:=RTRIM(vFullFileName, '\/') || '\IPC$';
    END IF;
    vFullFileName:=RTRIM(TRIM(vFullFileName), '\/');
    bType1:=FALSE;
    IF UPPER(SUBSTR(vFullFileName, 1, 6)) = 'SMB://' THEN
        vFullFileName:=SUBSTR(vFullFileName, 7);
        bType1:=TRUE;
    ELSIF UPPER(SUBSTR(vFullFileName, 1, 7)) = 'FILE://' THEN
        vFullFileName:=SUBSTR(vFullFileName, 8);
        bType1:=TRUE; 
    ELSIF vFullFileName NOT LIKE '\\%' THEN
        RAISE SYNTAX_ERROR;   
    END IF;
    IF bType1 THEN
        nPos:=INSTR(vFullFileName, '@', -1);
        IF nPos = 0 THEN
            bType1:=FALSE; -- contains no credential. 
        ELSE
            vCredential:=SUBSTR(vFullFileName, 1, nPos - 1);
            vFullFileName:=SUBSTR(vFullFileName, nPos + 1);
            nPos:=INSTR(vCredential, ':');
            IF nPos > 0 THEN
                o_xShare.vPassword:=SUBSTR(vCredential, nPos + 1);
                vCredential:=SUBSTR(vCredential, 1, nPos - 1);
            END IF;
            nPos:=INSTR(vCredential, ';');
            IF nPos > 0 THEN
                o_xShare.vDomain:=SUBSTR(vCredential, 1, nPos - 1);
                o_xShare.vLogin:=SUBSTR(vCredential, nPos + 1);
            ELSE
                o_xShare.vLogin:=vCredential;
            END IF;
        END IF;
    END IF;
    vFullFileName:=LTRIM(vFullFileName, '\/');
    vFullFileName:=REPLACE(vFullFileName, '/', '\');
    o_xShare.vDomain:=NVL(i_xCredential.vDomain, o_xShare.vDomain);
    o_xShare.vLogin:=NVL(i_xCredential.vLogin, o_xShare.vLogin);
    o_xShare.vPassword:=NVL(i_xCredential.vPassword, o_xShare.vPassword);
    nPos:=INSTR(vFullFileName, '\');
    IF nPos > 0 THEN
        o_xShare.vHost:=SUBSTR(vFullFileName, 1, nPos - 1);
        vFullFileName:=SUBSTR(vFullFileName, nPos + 1);
        nPos:=INSTR(o_xShare.vHost, ':');
        IF nPos > 0 THEN
            o_xShare.nPort:=SUBSTR(o_xShare.vHost, nPos + 1); -- -- may raise a VALUE_ERROR exception
            o_xShare.vHost:=SUBSTR(o_xShare.vHost, 1, nPos - 1);
        END IF;
        nPos:=INSTR(vFullFileName, '\');
        IF nPos > 0 THEN
            o_xShare.vShare:=SUBSTR(vFullFileName, 1, nPos - 1);
            o_vFileName:=SUBSTR(vFullFileName, nPos + 1);
        ELSE
            o_xShare.vShare:=vFullFileName;
            o_vFileName:=NULL;
        END IF;
    ELSE
        RAISE SYNTAX_ERROR;
    END IF;
EXCEPTION
    WHEN SYNTAX_ERROR OR VALUE_ERROR THEN
    o_xShare.vDomain:=NULL;
    o_xShare.vLogin:=NULL;
    o_xShare.vPassword:=NULL;
    o_xShare.vHost:=NULL;
    o_xShare.nPort:=NULL;
    o_xShare.vShare:=NULL;
    o_vFileName:=NULL;
END SPLIT_URL;    

FUNCTION DEFINE_SHARE(i_vDomain IN VARCHAR2, 
                      i_vLogin IN VARCHAR2, 
                      i_vPassword IN VARCHAR2, 
                      i_vHost IN VARCHAR2,
                      i_nPort IN PLS_INTEGER:=445, 
                      i_vShare IN VARCHAR2) RETURN SHARE_T
IS
    xShare SHARE_T;
BEGIN
    xShare.vDomain:=i_vDomain;
    xShare.vLogin:=i_vLogin;
    xShare.vPassword:=i_vPassword;
    xShare.vHost:=i_vHost;
    xShare.nPort:=i_nPort;
    xShare.vShare:=i_vShare;
    RETURN xShare;
    
END DEFINE_SHARE;

FUNCTION DEFINE_SHARE(i_vSmbURL VARCHAR2) RETURN SHARE_T
IS
    xShare SHARE_T;
    nPos PLS_INTEGER;
    nPos2 PLS_INTEGER;
    bOK BOOLEAN;
BEGIN
    bOK:=FALSE;
    IF SUBSTR(i_vSmbURL, 1, 6) = 'smb://' THEN
        -- Extract Domain
        nPos:=INSTR(i_vSmbURL, ';');
        IF nPos > 0 THEN
            xShare.vDomain:=SUBSTR(i_vSmbURL, 7, nPos - 7);
            -- Extract Login
            nPos2:=INSTR(i_vSmbURL, ':', nPos + 1);
            IF nPos2 > 0 THEN
                xShare.vLogin:=SUBSTR(i_vSmbURL, nPos + 1, nPos2 - 1 - nPos);
                -- Extract Password
                nPos:=INSTR(i_vSmbURL, '@', -1);
                IF nPos > nPos2 THEN
                    xShare.vPassword:=SUBSTR(i_vSmbURL, nPos2 + 1, nPos - 1 - nPos2);
                    -- Extract Host, and Share
                    nPos2:=INSTR(i_vSmbURL, '/', -1);
                    IF nPos2 > nPos THEN
                        xShare.vHost:=SUBSTR(i_vSmbURL, nPos + 1, nPos2 - 1 - nPos);
                        xShare.vShare:=SUBSTR(i_vSmbURL, nPos2 + 1);
                        bOK:=TRUE;
                        -- Optionnaly, split Host and Port
                        nPos:=INSTR(xShare.vHost, ':');
                        IF nPos > 0 THEN
                            xShare.nPort:=SUBSTR(xShare.vHost, nPos + 1); -- may raise a VALUE_ERROR exception
                            xShare.vHost:=SUBSTR(xShare.vHost, 1, nPos - 1);
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    IF NOT(bOK) THEN
        xShare:=NULL;
    END IF;
    RETURN xShare;
EXCEPTION
    WHEN VALUE_ERROR THEN
    RETURN NULL;    
    
END DEFINE_SHARE;

FUNCTION GET_VERSION RETURN VARCHAR2
IS
BEGIN
    RETURN '1.0';
END GET_VERSION;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- UTL_FILE compatibility
-------------------------------------------------------------------------------------------------------------------------------------------------------

/** If the location given in parameter is a directory, return the directory path, else, return the location itself.
 *  @param i_vLocation correspond to a oracle directory name, or directly to a real location.
 *  @param i_vFilename filename (optional)
 *  @return the real location. 
 */
FUNCTION GetRealLocation(i_vLocation IN VARCHAR2, 
                         i_vFileName IN VARCHAR2:=NULL) RETURN VARCHAR2
IS
    vRealLocation all_directories.directory_path%TYPE;
BEGIN
    BEGIN
        SELECT directory_path 
        INTO vRealLocation
        FROM all_directories
        WHERE directory_name = i_vLocation;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vRealLocation:=i_vLocation;
    END;
    IF i_vFileName IS NOT NULL THEN
        vRealLocation:=RTRIM(vRealLocation, '\/') || '/' || i_vFileName;
    END IF;
    RETURN vRealLocation;
END GetRealLocation;

/** Return True if this location can be reach with SMB protocol
 *  @param i_vLocation URI or Oracle directory
 *  @return True if we can use SMB, False if it is local file
 */        
FUNCTION UseSMB(i_vLocation IN VARCHAR2) RETURN BOOLEAN
IS
    vRealLocation all_directories.directory_path%TYPE;
    bAnswer BOOLEAN;
BEGIN
    vRealLocation:=GetRealLocation(i_vLocation);
    bAnswer:=FALSE;
    IF UPPER(SUBSTR(vRealLocation, 1, 6)) = 'SMB://' THEN
        bAnswer:=TRUE;
    ELSIF UPPER(SUBSTR(vRealLocation, 1, 7)) = 'FILE://' THEN
        bAnswer:=TRUE;
    END IF;
    RETURN bAnswer;
    
END UseSMB;

/** Convert a SMB.file_type to a UTL_FILE.file_type
 */
FUNCTION ConvertFileTypeToUTL(i_xSmbFileType IN file_type) RETURN UTL_FILE.file_type
IS
    xUtlFileType UTL_FILE.file_type;
BEGIN
    xUtlFileType.id:=i_xSmbFileType.id;
    xUtlFileType.id:=i_xSmbFileType.id;
    xUtlFileType.id:=i_xSmbFileType.id;
    IF i_xSmbFileType.use_smb THEN
        xUtlFileType.id:=NULL;
    END IF;    
    RETURN xUtlFileType;
    
END ConvertFileTypeToUTL;

/** Convert a UTL_FILE.file_type to a SMB.file_type
 */
FUNCTION ConvertFileTypeFromUTL(i_xUtlFileType IN UTL_FILE.file_type) RETURN file_type
IS
    xSmbFileType file_type;
BEGIN
    xSmbFileType.id:=i_xUtlFileType.id;
    xSmbFileType.datatype:=i_xUtlFileType.datatype;
    xSmbFileType.byte_mode:=i_xUtlFileType.byte_mode;
    xSmbFileType.use_smb:=FALSE;
    RETURN xSmbFileType;
        
END ConvertFileTypeFromUTL;

/** Return a new File Handle (corresponds to an index for the global TxFileHandle collection)
 *  @return the new File Handle
 *  @Throws internal_error (if too many open handle)
 */
FUNCTION NewFileHandle RETURN PLS_INTEGER
IS
    nNewHandle PLS_INTEGER;
    nIdx PLS_INTEGER;
BEGIN
    nNewHandle:=NVL(TxFileHandle.LAST, 0);
    IF nNewHandle < 2147483647 THEN
        nNewHandle:=nNewHandle + 1;
    ELSE
        -- [A_REVOIR] Chercher le premier trou...
        RAISE internal_error;        
    END IF;
    RETURN nNewHandle;
    
END NewFileHandle; 

/** Retrieve a file handle (index to TxFileHandle) from a file_type structure
 *  @param i_xFileType file_type structure
 *  @return file handle
 *  @throws invalid_filehandle
 */
FUNCTION GetFileHandle(i_xFileType IN file_type) RETURN PLS_INTEGER
IS
    nFileHandle PLS_INTEGER;
BEGIN
    nFileHandle:=i_xFileType.id;
    IF nFileHandle IS NULL THEN
        RAISE invalid_filehandle;
    END IF;
    IF NOT TxFileHandle.EXISTS(nFileHandle) THEN
        RAISE invalid_filehandle;
    END IF;
    RETURN nFileHandle;
    
EXCEPTION
    WHEN NUM_OVERFLOW THEN
    -- handle is pls_integer ; id is binary_integer...
    RAISE invalid_filehandle;
END GetFileHandle; 

/** Procedure used by put, put_nchar, new_line, etc...
 *  @param  i_xFileType smb file_type where to write
 *  @param  i_rBuffer buffer to write
 *  @param  i_bAutoFlush 
 *  @Throws invalid_filehandle ; write_error
 */
PROCEDURE smb_put_raw(i_xFileType IN file_type, 
                      i_rBuffer IN RAW, 
                      i_bAutoFlush IN BOOLEAN)
IS
    nHandle PLS_INTEGER;
    nFID USHORT;
    bBuffer BLOB;
    nOffset ULONG;
    nLength ULONG;
    nFlushEvery PLS_INTEGER;
    vError ERRSTR;
BEGIN
    nHandle:=GetFileHandle(i_xFileType);
    IF TxFileHandle(nHandle).vOpenMode = 'r' THEN
        RAISE write_error;
    END IF;
    xCtx:=TxFileHandle(nHandle).xCtx;
    nFID:=TxFileHandle(nHandle).nFID;
    nOffset:=TxFileHandle(nHandle).nWritePosition;
    nLength:=NVL(UTL_RAW.LENGTH(i_rBuffer), 0);
    DBMS_LOB.CreateTemporary(bBuffer, FALSE);
    DBMS_LOB.Write(bBuffer, nLength, 1, i_rBuffer);
    IF i_bAutoFlush THEN
        nFlushEvery:=1000;
    ELSE
        nFlushEvery:=NULL;
    END IF;
    WRITE_FILE_INT(nFID, bBuffer, nOffset, vError, nFlushEvery);
    TxFileHandle(nHandle).nWritePosition:=TxFileHandle(nHandle).nWritePosition + nLength;
    IF i_bAutoFlush THEN
        SMB_COM_FLUSH(nFID);
    END IF;
    -- [A_REVOIR] gérer les erreurs...
    DBMS_LOB.FreeTemporary(bBuffer);
    TxFileHandle(nHandle).xCtx:=xCtx;

END smb_put_raw;  

/** read a fragment of file and fill a raw buffer with the content
 *  @param  i_nCase : 1 = called by get_line ; 2 = called by get_line_nchar ; 3 = called by get_raw. 
 *  @param  i_xFileType
 *  @param  io_rBuffer raw buffer. is filled with the content of the fragment of the file. 
 *  @param  i_nMaxLineSize
 *  @Throws NO_DATA_FOUND (nothing to read) ; invalid_operation (if vOpenMode <> 'r'). 
 */
PROCEDURE smb_get_raw(i_nCase IN PLS_INTEGER, 
                      i_xFileType IN file_type, 
                      io_rBuffer IN OUT NOCOPY RAW, 
                      i_nMaxLineSize IN PLS_INTEGER)
IS
    nHandle PLS_INTEGER;
    nFID USHORT;
    bBuffer BLOB;
    cBuffer CLOB;
    nOffset ULONG;
    nLength ULONG;
    vError ERRSTR;
    nNewLineLength PLS_INTEGER;
    nPos1 PLS_INTEGER;
    nPos2 PLS_INTEGER;
    nOneMoreChar PLS_INTEGER;
    nMaxLineSize ULONG;
    nDestOffset ULONG;
    nSrcOffset ULONG;
    nWarning PLS_INTEGER;
    nDefaultLangCtx PLS_INTEGER;
BEGIN
    nHandle:=GetFileHandle(i_xFileType);
    IF TxFileHandle(nHandle).vOpenMode <> 'r' THEN
        RAISE invalid_operation;
    END IF;
    xCtx:=TxFileHandle(nHandle).xCtx;
    nFID:=TxFileHandle(nHandle).nFID;
    nOffset:=TxFileHandle(nHandle).nReadPosition;
    nMaxLineSize:=NVL(i_nMaxLineSize, TxFileHandle(nHandle).nMaxLineSize);
    -- + nOneMoreChar after nMaxLineSize is to manage the case where newline is 2 char length (CR + LF) a
    -- and CR is the last char, and LF at the position nMaxLineSize + 1. 
    nOneMoreChar:=0;
    IF i_nCase IN (1, 2) AND nMaxLineSize < 32767 THEN
        nOneMoreChar:=1;
    END IF;
    READ_FILE_INT(nFID, bBuffer, nOffset, nMaxLineSize + nOneMoreChar, vError);
    IF vError IS NOT NULL THEN
        dbg('smb_get_raw->'||vError);
    END IF;
    nNewLineLength:=0;
    nLength:=DBMS_LOB.GETLENGTH(bBuffer);
    -- if nothing has been read, throws a no_data_found exception
    IF nLength = 0 THEN
        DBMS_LOB.FreeTemporary(bBuffer);
        TxFileHandle(nHandle).xCtx:=xCtx;
        RAISE NO_DATA_FOUND;
    END IF;
    IF i_nCase IN (1, 2) THEN
        -- Case 1 : char
        nDestOffset:=1;
        nSrcOffset:=1;
        nDefaultLangCtx:=DBMS_LOB.default_lang_ctx;
        DBMS_LOB.CreateTemporary(cBuffer, FALSE);
        DBMS_LOB.ConvertToClob(cBuffer, bBuffer, 32767, nDestOffset, nSrcOffset, DBMS_LOB.default_csid, nDefaultLangCtx, nWarning);
        nPos1:=NVL(DBMS_LOB.INSTR(cBuffer, CHR(13)), 0);
        nPos2:=NVL(DBMS_LOB.INSTR(cBuffer, CHR(10)), 0);
        IF nPos1 = 0 AND nPos2 = 0 THEN
            -- no newline.
            nLength:=LEAST(nLength, nMaxLineSize); 
        ELSIF nPos1 = 0 AND nPos2 > 0 THEN
            -- newline detected (CR)
            nLength:=nPos2 - 1;
            nNewLineLength:=1;
        ELSIF nPos1 > 0 AND nPos2 = 0 THEN
            -- newline detected (LF)
            nLength:=nPos1 - 1;
            nNewLineLength:=1;
        ELSIF nPos1 = nPos2 - 1 THEN
            -- newline detected (CRLF)
            nLength:=nPos1 - 1;
            nNewLineLength:=2;
        ELSE
            -- newline detected (CR or LF)
            nLength:=LEAST(nPos1, nPos2) - 1;
            nNewLineLength:=1;
        END IF;
    END IF;
    io_rBuffer:=DBMS_LOB.SUBSTR(bBuffer, nLength, 1);
    TxFileHandle(nHandle).nReadPosition:=TxFileHandle(nHandle).nReadPosition + nLength + nNewLineLength;
    -- [A_REVOIR] gérer les erreurs...
    DBMS_LOB.FreeTemporary(bBuffer);
    TxFileHandle(nHandle).xCtx:=xCtx;
   
END smb_get_raw;

/** Return a new line caracter
 *  @return new line chars.
 */    
FUNCTION newline RETURN VARCHAR2
IS
BEGIN
    RETURN CHR(13) || CHR(10); -- [A_REVOIR] Faut-il renvoyer uniquement CHR(10) pour du Unix, CHR(13) pour du MacOs...
END newline;

/** Replace the %s by arguments, and \n by newline
 *  @param  i_vFormat string to format. can contain "%s" and "\n" patterns.
 *  @param  i_vArg1 string replacement for the 1st "%s". 
 *  @param  i_vArg2 string replacement for the 2nd "%s". 
 *  @param  i_vArg3 string replacement for the 3th "%s". 
 *  @param  i_vArg4 string replacement for the 4th "%s". 
 *  @param  i_vArg5 string replacement for the 5th "%s". 
 *  @return i_vFormat string with patterns replaced
 */
FUNCTION string_format(i_vFormat IN VARCHAR2,
                       i_vArg1 IN VARCHAR2 DEFAULT NULL,
                       i_vArg2 IN VARCHAR2 DEFAULT NULL,
                       i_vArg3 IN VARCHAR2 DEFAULT NULL,
                       i_vArg4 IN VARCHAR2 DEFAULT NULL,
                       i_vArg5 IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
    vString VARCHAR2(32767);
BEGIN
    vString:=REPLACE(i_vFormat, '\n', newline);
    vString:=replace_one(vString, '%s', i_vArg1);
    vString:=replace_one(vString, '%s', i_vArg2);
    vString:=replace_one(vString, '%s', i_vArg3);
    vString:=replace_one(vString, '%s', i_vArg4);
    vString:=replace_one(vString, '%s', i_vArg5);
    RETURN vString;
    
END string_format;                       
                     

FUNCTION fopen(location     IN VARCHAR2,
               filename     IN VARCHAR2,
               open_mode    IN VARCHAR2,
               max_linesize IN BINARY_INTEGER DEFAULT NULL) RETURN file_type
IS
    vOpenMode VARCHAR2(3);
    xSmbFileType file_type;
    xShare SHARE_T;
    vFileName VARCHAR2(255);
    vError ERRSTR;
    nFID USHORT;
    nWritePosition ULONG;
    nFileSize ULONG;
    nHandle PLS_INTEGER;
BEGIN
    IF NOT(UseSMB(location)) THEN
        RETURN ConvertFileTypeFromUTL(UTL_FILE.fopen(location, filename, open_mode, max_linesize));
    ELSE
        vOpenMode:=LOWER(SUBSTR(open_mode, 1, 3));
        IF vOpenMode NOT IN ('r', 'w', 'a', 'rb', 'wb', 'ab') THEN
            RAISE invalid_mode;
        END IF;
        xSmbFileType.byte_mode:=(SUBSTR(vOpenMode, -1) = 'b');
        vOpenMode:=SUBSTR(vOpenMode, 1, 1); -- 'r', 'w' ou 'a'...
        SPLIT_URL(GetRealLocation(location, filename), NULL, xShare, vFileName);
        SHARE_CONNECT(xShare, vError);
        IF vError IS NOT NULL THEN
            RAISE invalid_path;
        END IF;
        IF vFileName IS NULL THEN
            RAISE invalid_filename;
        END IF;
        nWritePosition:=0;
        CASE vOpenMode
            WHEN 'w' THEN
                FILE_CREATE(vFileName, nFID, nWritePosition, vError);
            WHEN 'a' THEN
                FILE_CREATE(vFileName, nFID, nWritePosition, vError, TRUE);
            WHEN 'r' THEN
                FILE_OPEN(vFileName, nFID, nFileSize, vError);                
        END CASE;
        IF vError IS NOT NULL THEN
            RAISE invalid_operation;
        END IF;
        -- Record in TxFileHandle structure
        nHandle:=NewFileHandle;
        TxFileHandle(nHandle).nFID:=nFID;
        TxFileHandle(nHandle).xCtx:=xCtx;
        TxFileHandle(nHandle).nReadPosition:=0;
        TxFileHandle(nHandle).nFileSize:=nFileSize;
        TxFileHandle(nHandle).nWritePosition:=nWritePosition;
        TxFileHandle(nHandle).vOpenMode:=vOpenMode;
        TxFileHandle(nHandle).nMaxLineSize:=NVL(max_linesize, 1024);
        -- Fill the file_type structure
        xSmbFileType.id:=nHandle;
        xSmbFileType.datatype:=1;
        -- xSmbFileType.byte_mode has already been filled above. 
        xSmbFileType.use_smb:=TRUE;
        RETURN xSmbFileType;
    END IF;
END fopen;    

FUNCTION fopen_nchar(location     IN VARCHAR2,
                     filename     IN VARCHAR2,
                     open_mode    IN VARCHAR2,
                     max_linesize IN BINARY_INTEGER DEFAULT NULL) RETURN file_type
IS
    xSmbFileType file_type;
BEGIN
    IF NOT(UseSMB(location)) THEN
        RETURN ConvertFileTypeFromUTL(UTL_FILE.fopen_nchar(location, filename, open_mode, max_linesize));
    ELSE
        xSmbFileType:=fopen(location, filename, open_mode, max_linesize);
        xSmbFileType.datatype:=2;
        RETURN xSmbFileType;
    END IF;
END fopen_nchar;                       

FUNCTION is_open(file IN file_type) RETURN BOOLEAN
IS
    bIsOpen BOOLEAN;
    nHandle PLS_INTEGER;
BEGIN
    IF NOT(file.use_smb) THEN
        RETURN UTL_FILE.is_open(ConvertFileTypeToUTL(file));
    ELSE
        BEGIN
            nHandle:=GetFileHandle(file);
            bIsOpen:=TRUE;
        EXCEPTION
            WHEN invalid_filehandle THEN
            bIsOpen:=FALSE;
        END;
        RETURN bIsOpen;
    END IF;

END is_open;    

PROCEDURE fclose(file IN OUT file_type)
IS
    xUtlFileType UTL_FILE.FILE_TYPE;
    nHandle PLS_INTEGER;
BEGIN
    IF NOT(file.use_smb) THEN
        xUtlFileType:=ConvertFileTypeToUTL(file);
        UTL_FILE.fclose(xUtlFileType);
        file:=ConvertFileTypeFromUTL(xUtlFileType);
    ELSE
        nHandle:=GetFileHandle(file);
        xCtx:=TxFileHandle(nHandle).xCtx;
        -- [A_REVOIR] Que faire si l'une de ces API renvoi une erreur ?
        SMB_COM_CLOSE(TxFileHandle(nHandle).nFID);
        SMB_COM_LOGOFF_ANDX; 
        SOCKET_CLOSE;
        TxFileHandle.DELETE(nHandle);
        file.id:=NULL;
        file.datatype:=NULL;
        file.byte_mode:=NULL;
    END IF;
END fclose;

PROCEDURE fclose_all
IS
    xSmbFileType file_type;
BEGIN
    UTL_FILE.fclose_all;
    WHILE(TxFileHandle.COUNT > 0)
    LOOP
        xSmbFileType.id:=TxFileHandle.FIRST;
        xSmbFileType.use_smb:=TRUE;
        fclose(xSmbFileType);
    END LOOP;
    
END fclose_all;

PROCEDURE get_line(file   IN file_type,
                   buffer OUT VARCHAR2,
                   len    IN BINARY_INTEGER DEFAULT NULL)
IS
    rBuffer RAW(32767);
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.get_line(ConvertFileTypeToUTL(file), buffer, len);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        ELSIF file.datatype <> 1 THEN
            RAISE charsetmismatch;
        END IF;
        smb_get_raw(1, file, rBuffer, len);
        buffer:=UTL_RAW.CAST_TO_VARCHAR2(rBuffer);
    END IF;
END get_line;                     

PROCEDURE get_line_nchar(file   IN  file_type,
                         buffer OUT NVARCHAR2,
                         len    IN  BINARY_INTEGER DEFAULT NULL)
IS
    rBuffer RAW(32767);
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.get_line(ConvertFileTypeToUTL(file), buffer, len);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        ELSIF file.datatype <> 2 THEN
            RAISE charsetmismatch;
        END IF;
        smb_get_raw(2, file, rBuffer, len);
        buffer:=CONVERT(UTL_RAW.CAST_TO_VARCHAR2(rBuffer), get_database_charset, 'UTF8');
    END IF;
END get_line_nchar;                           

PROCEDURE put(file   IN file_type,
              buffer IN VARCHAR2)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.put(ConvertFileTypeToUTL(file), buffer);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        ELSIF file.datatype <> 1 THEN
            RAISE charsetmismatch;
        END IF;
        smb_put_raw(file, UTL_RAW.CAST_TO_RAW(buffer), FALSE);
    END IF;
END put;                

PROCEDURE put_nchar(file   IN file_type,
                    buffer IN NVARCHAR2)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.put_nchar(ConvertFileTypeToUTL(file), buffer);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        ELSIF file.datatype <> 2 THEN
            RAISE charsetmismatch;
        END IF;
        smb_put_raw(file, UTL_RAW.CAST_TO_RAW(CONVERT(buffer, 'UTF8', get_database_n_charset)), FALSE);
    END IF;
END put_nchar;                

PROCEDURE new_line(file  IN file_type,
                   lines IN NATURAL := 1)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.new_line(ConvertFileTypeToUTL(file), lines);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        END IF;
        FOR i IN 1..lines
        LOOP
            smb_put_raw(file, UTL_RAW.CAST_TO_RAW(newline), FALSE);
        END LOOP;
    END IF;
END new_line;                     

PROCEDURE put_line(file   IN file_type,
                   buffer IN VARCHAR2,
                   autoflush IN BOOLEAN DEFAULT FALSE)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.put_line(ConvertFileTypeToUTL(file), buffer, autoflush);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        ELSIF file.datatype <> 1 THEN
            RAISE charsetmismatch;
        END IF;
        smb_put_raw(file, UTL_RAW.CAST_TO_RAW(buffer), autoflush);
        smb_put_raw(file, UTL_RAW.CAST_TO_RAW(newline), FALSE);
    END IF;

END put_line;                     

PROCEDURE put_line_nchar(file   IN file_type,
                         buffer IN NVARCHAR2)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.put_line_nchar(ConvertFileTypeToUTL(file), buffer);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        ELSIF file.datatype <> 2 THEN
            RAISE charsetmismatch;
        END IF;
        smb_put_raw(file, UTL_RAW.CAST_TO_RAW(CONVERT(buffer, 'UTF8', get_database_n_charset)), TRUE);
        smb_put_raw(file, UTL_RAW.CAST_TO_RAW(newline), FALSE);
    END IF;
END put_line_nchar;                     

procedure putf(file   IN file_type,
             format IN VARCHAR2,
             arg1   IN VARCHAR2 DEFAULT NULL,
             arg2   IN VARCHAR2 DEFAULT NULL,
             arg3   IN VARCHAR2 DEFAULT NULL,
             arg4   IN VARCHAR2 DEFAULT NULL,
             arg5   IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.putf(ConvertFileTypeToUTL(file), format, arg1, arg2, arg3, arg4, arg5);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        ELSIF file.datatype <> 1 THEN
            RAISE charsetmismatch;
        END IF;
        smb_put_raw(file, UTL_RAW.CAST_TO_RAW(string_format(format, arg1, arg2, arg3, arg4, arg5)), FALSE);
    END IF;
END putf;                 

procedure putf_nchar(file   IN file_type,
             format IN NVARCHAR2,
             arg1   IN NVARCHAR2 DEFAULT NULL,
             arg2   IN NVARCHAR2 DEFAULT NULL,
             arg3   IN NVARCHAR2 DEFAULT NULL,
             arg4   IN NVARCHAR2 DEFAULT NULL,
             arg5   IN NVARCHAR2 DEFAULT NULL)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.putf_nchar(ConvertFileTypeToUTL(file), format, arg1, arg2, arg3, arg4, arg5);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        ELSIF file.datatype <> 2 THEN
            RAISE charsetmismatch;
        END IF;
        smb_put_raw(file, UTL_RAW.CAST_TO_RAW(CONVERT(string_format(format, arg1, arg2, arg3, arg4, arg5), 'UTF8', get_database_n_charset)), FALSE);
    END IF;
END putf_nchar;                 

PROCEDURE fflush(file IN file_type)
IS
    nHandle PLS_INTEGER;
    nFID USHORT;
    vError ERRSTR;
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.fflush(ConvertFileTypeToUTL(file));
    ELSE
        nHandle:=GetFileHandle(file);
        IF TxFileHandle(nHandle).vOpenMode = 'r' THEN
            RAISE write_error;
        END IF;
        xCtx:=TxFileHandle(nHandle).xCtx;
        nFID:=TxFileHandle(nHandle).nFID;
        SMB_COM_FLUSH(nFID);
        TxFileHandle(nHandle).xCtx:=xCtx;
        IF NOT(ok(vError)) THEN
            -- [A_REVOIR]
            Dbg('fflush->' || vError);
        END IF;
    END IF;
END fflush;                

PROCEDURE put_raw(file      IN file_type,
                  buffer    IN RAW,
                  autoflush IN BOOLEAN DEFAULT FALSE)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.put_raw(ConvertFileTypeToUTL(file), buffer, autoflush);
    ELSE
        smb_put_raw(file, buffer, autoflush);
    END IF;
END put_raw;                    

PROCEDURE get_raw(file   IN  file_type,
                  buffer OUT NOCOPY RAW,
                  len    IN  BINARY_INTEGER DEFAULT NULL)
IS
BEGIN
    IF NOT(file.use_smb) THEN
        UTL_FILE.get_raw(ConvertFileTypeToUTL(file), buffer, len);
    ELSE
        IF file.datatype = 2 THEN
            RAISE charsetmismatch;
        END IF;
        smb_get_raw(3, file, buffer, len);
    END IF;
END get_raw;                    

PROCEDURE fseek(file            IN OUT file_type,
                absolute_offset IN     BINARY_INTEGER DEFAULT NULL,
                relative_offset IN     BINARY_INTEGER DEFAULT NULL)
IS
    xUtlFileType UTL_FILE.FILE_TYPE;
    nHandle PLS_INTEGER;
    nPosition BINARY_INTEGER;
BEGIN
    IF NOT(file.use_smb) THEN
        xUtlFileType:=ConvertFileTypeToUTL(file);
        UTL_FILE.fseek(xUtlFileType, absolute_offset, relative_offset);
        file:=ConvertFileTypeFromUTL(xUtlFileType);
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        END IF;
        nHandle:=GetFileHandle(file);
        IF TxFileHandle(nHandle).vOpenMode <> 'r' THEN
            RAISE read_error;
        END IF;
        nPosition:=NVL(absolute_offset, LEAST(0, TxFileHandle(nHandle).nReadPosition + relative_offset));
        IF nPosition IS NULL OR nPosition NOT BETWEEN 0 AND TxFileHandle(nHandle).nFileSize THEN
            RAISE invalid_offset;
        END IF;
        TxFileHandle(nHandle).nReadPosition:=nPosition;
    END IF;
END fseek;              

PROCEDURE fremove(location IN VARCHAR2,
                  filename IN VARCHAR2)
IS
    xShare SHARE_T;
    vFileName VARCHAR2(255);
    vError ERRSTR;
    bOk BOOLEAN;
BEGIN
    IF NOT(UseSMB(location)) THEN
        UTL_FILE.fremove(location, filename);
    ELSE
        SPLIT_URL(GetRealLocation(location, filename), NULL, xShare, vFileName);
        SHARE_CONNECT(xShare, vError);
        IF vError IS NOT NULL THEN
            RAISE invalid_path;
        END IF;
        IF vFileName IS NULL THEN
            RAISE invalid_filename;
        END IF;
        DELETE_FILE_INT(vFileName, 0, vError);
        SMB_COM_LOGOFF_ANDX; 
        bOk:=ok(vError);
        IF vError IS NOT NULL THEN
            RAISE invalid_operation;
        END IF;
    END IF;
    
END fremove;                    

PROCEDURE fcopy(src_location  IN VARCHAR2,
                src_filename  IN VARCHAR2,
                dest_location IN VARCHAR2,
                dest_filename IN VARCHAR2,
                start_line    IN BINARY_INTEGER DEFAULT 1,
                end_line      IN BINARY_INTEGER DEFAULT NULL)
IS
BEGIN
    IF NOT(UseSMB(src_location)) AND NOT(UseSMB(dest_location)) THEN
        -- full UTL_FILE operation
        UTL_FILE.fcopy(src_location, src_filename, dest_location, dest_filename, start_line, end_line);
    ELSIF UseSMB(src_location) AND UseSMB(dest_location) AND start_line = 1 AND end_line IS NULL THEN
        -- full copy with full SMB operation. 
        DECLARE
            vError ERRSTR;
        BEGIN
            COPY_FILE(GetRealLocation(src_location, src_filename), GetRealLocation(dest_location, dest_filename), vError);
            IF vError LIKE '%STATUS_OBJECT_NAME_NOT_FOUND%' THEN
                RAISE invalid_filename;
            ELSIF vError LIKE '%STATUS_OBJECT_NAME_COLLISION%' THEN
                RAISE invalid_operation;
            ELSIF vError IS NOT NULL THEN
-- [A_REVOIR]            
Dbg('Copy_File=>' || vError);
                RAISE invalid_operation;
            END IF;
        END;
     ELSE
        -- Mixed UTL_FILE and SMB operation ; or full SMB operation with extraction (start_line <> 1 or end_line not null)
        DECLARE
            xFileSrc file_type;
            xFileDest file_type;
            bExists BOOLEAN;
            nFileLengthSrc NUMBER;
            nBlockSize NUMBER;
            vLineBuffer VARCHAR2(32000);
            nBufferSize CONSTANT PLS_INTEGER:=16000;
            bSrcOpened BOOLEAN;
            bDestOpened BOOLEAN;
            nLineNumber PLS_INTEGER;
        BEGIN
            fgetattr(src_location, src_filename, bExists, nFileLengthSrc, nBlockSize);
            IF NOT(bExists) THEN    
                RAISE invalid_filename;
            END IF;
            xFileSrc:=fopen(src_location, src_filename, 'r'); bSrcOpened:=TRUE;
            xFileDest:=fopen(dest_location, dest_filename, 'w'); bDestOpened:=TRUE;
            nLineNumber:=1;
            LOOP
                BEGIN
                    get_line(xFileSrc, vLineBuffer);
                    IF nLineNumber BETWEEN start_line AND NVL(end_line, 4294967296) THEN
                        put_line(xFileDest, vLineBuffer);
                    END IF;                
                    nLineNumber:=nLineNumber + 1;
                    IF nLineNumber > end_line THEN
                        EXIT;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    IF nLineNumber < start_line THEN
                        RAISE invalid_offset;
                    END IF;
                    EXIT;
                END;
            END LOOP;
            fclose(xFileSrc); bSrcOpened:=FALSE;
            fclose(xFileDest); bDestOpened:=FALSE;
            
        EXCEPTION
            WHEN OTHERS THEN
            IF bSrcOpened THEN
                fclose(xFileSrc);
            END IF;
            IF bDestOpened THEN
                fclose(xFileDest);
            END IF;
            RAISE;
        END;
    END IF;
    
END fcopy;                  

PROCEDURE fgetattr(location    IN VARCHAR2,
                   filename    IN VARCHAR2,
                   fexists     OUT BOOLEAN,
                   file_length OUT NUMBER,
                   block_size  OUT BINARY_INTEGER)
IS
    xShare SHARE_T;
    vFileName VARCHAR2(255);
    xGetExtendedAttributeList SMB_GEA_LIST;
    xFileOrDirInfo FileOrDirInfo_T;   
    vError ERRSTR; 
BEGIN   
    IF NOT(UseSMB(location)) THEN
        UTL_FILE.fgetattr(location, filename, fexists, file_length, block_size);
    ELSE
        SPLIT_URL(GetRealLocation(location, filename), NULL, xShare, vFileName);
        SHARE_CONNECT(xShare, vError);
        IF vError IS NOT NULL THEN
            RAISE invalid_path;
        END IF;
        IF vFileName IS NULL THEN
            RAISE invalid_filename;
        END IF;
        TRANS2_QUERY_PATH_INFORMATION(vFileName, SMB_QUERY_FILE_STANDARD_INFO, xGetExtendedAttributeList, xFileOrDirInfo);
        IF ok(vError) THEN
            fexists:=TRUE;
            file_length:=xFileOrDirInfo.nSize;
            block_size:=xFileOrDirInfo.nAllocationSize;
        ELSE
            -- [A_REVOIR]
            -- Suivant le type d'erreur, déclencher des exceptions.
--  **   file_open         - file is not open for writing/appending
--  **   access_denied     - access to the directory object is denied
            
            fexists:=FALSE;
        END IF;
        SMB_COM_LOGOFF_ANDX; 
        SOCKET_CLOSE;
    END IF;

END fgetattr;                     

FUNCTION fgetpos(file IN file_type) RETURN BINARY_INTEGER
IS
    nHandle PLS_INTEGER;
BEGIN
    IF NOT(file.use_smb) THEN
        RETURN UTL_FILE.fgetpos(ConvertFileTypeToUTL(file));
    ELSE
        IF file.byte_mode THEN
            RAISE invalid_operation;
        END IF;
        nHandle:=GetFileHandle(file);
        RETURN TxFileHandle(nHandle).nReadPosition;
    END IF;

END fgetpos;    

PROCEDURE frename(src_location   IN VARCHAR2,
                  src_filename   IN VARCHAR2,
                  dest_location  IN VARCHAR2,
                  dest_filename  IN VARCHAR2,
                  overwrite      IN BOOLEAN DEFAULT FALSE)
IS
    bUseCopyAndErase BOOLEAN;
BEGIN
    bUseCopyAndErase:=FALSE;
    IF NOT(UseSMB(src_location)) AND NOT(UseSMB(dest_location)) THEN
        -- full UTL_FILE operation
        UTL_FILE.frename(src_location, src_filename, dest_location, dest_filename, overwrite);
    ELSIF UseSMB(src_location) AND UseSMB(dest_location) THEN
        -- full SMB operation on the same share
        DECLARE
            bOk BOOLEAN;
            xSrcShare SHARE_T;
            xDestShare SHARE_T;
            vSrcFileName VARCHAR2(1000);
            vDestFileName VARCHAR2(1000);
            vError ERRSTR;
        BEGIN
            SPLIT_URL(GetRealLocation(src_location, src_filename), NULL, xSrcShare, vSrcFileName);
            SPLIT_URL(GetRealLocation(dest_location, dest_filename), NULL, xDestShare, vDestFileName);
            IF NOT(SHARE_EQ(xSrcShare, xDestShare)) THEN
                bUseCopyAndErase:=TRUE;
            ELSE
                SHARE_CONNECT(xSrcShare, vError);
                IF vError IS NOT NULL THEN
                    RAISE invalid_path;
                END IF;
                IF vSrcFileName IS NULL OR vDestFileName IS NULL THEN
                    RAISE invalid_filename;
                END IF;
                SMB_COM_RENAME(0, vSrcFileName, vDestFileName);
                bOk:=ok(vError);
                IF vError LIKE '%STATUS_OBJECT_NAME_COLLISION%' AND overwrite THEN
                    vError:=NULL;
                    DELETE_FILE_INT(vDestFileName, 0, vError);
                    IF vError IS NULL THEN
                        SMB_COM_RENAME(0, vSrcFileName, vDestFileName);
                        bOk:=ok(vError);
                    END IF;
                END IF;
                SMB_COM_LOGOFF_ANDX; 
                bOk:=ok(vError);
                SOCKET_CLOSE;
                IF vError LIKE '%STATUS_OBJECT_NAME_NOT_FOUND%' THEN
                    RAISE invalid_filename;
                END IF;
                IF vError IS NOT NULL THEN
                    RAISE rename_failed;
                END IF;
            END IF;    
        END;        
    ELSE
        -- Mixed UTL_FILE / SMB operation
        bUseCopyAndErase:=TRUE;
    END IF;
    -- Instead of renaming, copy and erase. 
    IF bUseCopyAndErase THEN
        DECLARE
            xFileSrc file_type;
            xFileDest file_type;
            bExists BOOLEAN;
            nFileLengthSrc NUMBER;
            nFileLengthDest NUMBER;
            nBlockSize NUMBER;
            nBufferSize CONSTANT PLS_INTEGER:=16000;
            rBuffer RAW(16000);
            bSrcOpened BOOLEAN;
            bDestOpened BOOLEAN;
        BEGIN
            fgetattr(src_location, src_filename, bExists, nFileLengthSrc, nBlockSize);
            IF NOT(bExists) THEN    
                RAISE invalid_filename;
            END IF;
            fgetattr(dest_location, dest_filename, bExists, nFileLengthDest, nBlockSize);
            IF bExists AND NOT(overwrite) THEN
                RAISE rename_failed;
            END IF;
            xFileSrc:=fopen(src_location, src_filename, 'r'); bSrcOpened:=TRUE;
            xFileDest:=fopen(dest_location, dest_filename, 'w'); bDestOpened:=TRUE;
            FOR i IN 1..CEIL(nFileLengthSrc / nBufferSize)
            LOOP
                get_raw(xFileSrc, rBuffer, nBufferSize);
                put_raw(xFileDest, rBuffer, TRUE); 
            END LOOP;
            fclose(xFileSrc); bSrcOpened:=FALSE;
            fclose(xFileDest); bDestOpened:=FALSE;
            fremove(src_location, src_filename);
        EXCEPTION
            WHEN OTHERS THEN
            IF bSrcOpened THEN
                fclose(xFileSrc);
            END IF;
            IF bDestOpened THEN
                fclose(xFileDest);
            END IF;
            RAISE;
        END;
    END IF;    

END frename;           

PROCEDURE REVOKE_NETWORK_ACCESS(i_vACLName IN VARCHAR2:=vProjectName || '.xml')
IS
    INVALID_RESOURCE_HANDLE EXCEPTION; PRAGMA EXCEPTION_INIT(INVALID_RESOURCE_HANDLE, -31001);

BEGIN
    IF get_oracle_version >= 11 THEN
        BEGIN
            EXECUTE IMMEDIATE 'BEGIN DBMS_NETWORK_ACL_ADMIN.DROP_ACL(:1); END;' 
            USING i_vACLName;
            COMMIT;
        EXCEPTION
            WHEN INVALID_RESOURCE_HANDLE THEN
            NULL;
        END;
    END IF;

END REVOKE_NETWORK_ACCESS;

PROCEDURE GRANT_NETWORK_ACCESS(i_vSchemaName IN VARCHAR2, 
                               i_vACLName IN VARCHAR2:=vProjectName || '.xml')
IS
BEGIN
    IF get_oracle_version >= 11 THEN
        REVOKE_NETWORK_ACCESS(i_vACLName);
        EXECUTE IMMEDIATE 'BEGIN DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(:1, :2, :3, TRUE, :4); END;'
        USING i_vACLName, 'Network permission for SMB connexion', i_vSchemaName, 'connect';
        EXECUTE IMMEDIATE 'BEGIN DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(:1, :2, TRUE, :3); END;'
        USING i_vACLName, i_vSchemaName, 'resolve';
        EXECUTE IMMEDIATE 'BEGIN DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(:1, :2); END;'
        USING i_vACLName, '*';
        COMMIT;    
    END IF;
END GRANT_NETWORK_ACCESS;

FUNCTION DECODE_TEXT(i_bContent IN BLOB, 
                     i_vCharacterSet IN VARCHAR2 DEFAULT NULL,
                     i_vLineSeparator IN  VARCHAR2 DEFAULT NULL, 
                     o_vError OUT ERRSTR) RETURN CLOB
IS
BEGIN
    NULL;
END DECODE_TEXT;                     
                     
FUNCTION ENCODE_TEXT(i_cContent IN CLOB, 
                     i_vCharacterSet IN VARCHAR2 DEFAULT NULL,
                     i_vLineSeparator IN  VARCHAR2 DEFAULT NULL,
                     i_vBOM IN RAW DEFAULT NULL,
                     o_vError OUT ERRSTR) RETURN BLOB                    
IS
    bContent BLOB;
    nOffsetSrc INTEGER:=1;
    nOffsetDest INTEGER:=1;
    nBlobCsid NUMBER:=DBMS_LOB.default_csid;
    nLangContext INTEGER:=DBMS_LOB.default_lang_ctx;
    nWarning INTEGER;
BEGIN
    DBMS_LOB.CREATETEMPORARY(bContent, FALSE);
    DBMS_LOB.CONVERTTOBLOB(bContent, i_cContent, DBMS_LOB.LOBMAXSIZE, nOffsetDest, nOffsetSrc, nBlobCsid, nLangContext, nWarning);
    RETURN bContent;
END ENCODE_TEXT;                                      


END SMB;
/
