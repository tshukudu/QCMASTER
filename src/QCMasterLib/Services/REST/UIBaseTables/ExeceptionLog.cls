/// UI Base table for Exception Log GET REST methods
Class QCMasterLib.Services.REST.UIBaseTables.ExeceptionLog Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetExceptionLog() As %Status
{
	///set sc = ..GetTableListList(%request, %session, "MasterLib.Tables.ExceptionLog")		
	
	quit sc
}

ClassMethod GetExceptionLogDetail(pID As %Integer) As %Status
{
	///set sc = ..GetTableEntry(%request, %session, "MasterLib.Tables.ExceptionLog", pID)		
	
	quit sc
}

}
