/// CRUD UI REST Service methods for the SystemUserLoginLog Table.
Class QCMasterLib.Services.REST.UIBaseTables.SystemUserLoginLog Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetSystemUserLoginLog() As %Status
{
	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.SystemUserLoginLog")		
	
	quit sc
}

ClassMethod GetSystemUserLoginLogDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.SystemUserLoginLog", pID)		
	
	quit sc
}

}
