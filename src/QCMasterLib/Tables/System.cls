/// A lookup used to add "Systems" for the security configurations.
Class QCMasterLib.Tables.System Extends QCMasterLib.Tables.TableBase [ CompileAfter = QCMasterLib.Tables.SystemHistory] 
{

Index DescriptionIndex On Description [ Unique ];

Property Description As %String(MAXLEN="") [ Required ];

}