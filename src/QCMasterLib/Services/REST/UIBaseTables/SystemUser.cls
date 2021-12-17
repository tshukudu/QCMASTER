/// CRUD UI REST Service methods for the SystemUser Table.
Class QCMasterLib.Services.REST.UIBaseTables.SystemUser Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetSystemUser() As %Status
{

	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.SystemUser")		
	
	quit sc
}

ClassMethod GetSystemUserDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.SystemUser", pID)		
	
	quit sc
}

ClassMethod CreateSystemUser() As %Status
{
	set sc = ..CreateTableEntry(%request, %session, "QCMasterLib.Tables.SystemUser")		
	
	quit sc
}

ClassMethod UpdateSystemUser(pId As %Integer) As %Status
{
	set sc = ..UpdateTableEntry(%request, %session, "QCMasterLib.Tables.SystemUser", pId)		
	
	quit sc
}

}
