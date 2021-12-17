/// CRUD UI REST Service methods for the SystemUserWorkspace Table.
Class QCMasterLib.Services.REST.UIBaseTables.SystemUserWorkspace Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetSystemUserWorkspace() As %Status
{

	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.SystemUserWorkspace")		
	quit sc
}

ClassMethod GetSystemUserWorkspaceDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.SystemUserWorkspace", pID)
	quit sc
}

ClassMethod CreateSystemWorkspace() As %Status
{
	set sc = ..CreateTableEntry(%request, %session, "QCMasterLib.Tables.SystemUserWorkspace")
	quit sc
}

ClassMethod UpdateSystemUserWorkspace(pId As %Integer) As %Status
{
	set sc = ..UpdateTableEntry(%request, %session, "QCMasterLib.Tables.SystemUserWorkspace", pId)
	quit sc
}

ClassMethod DeleteSystemUserWorkspace(pId As %Integer) As %Status
{
	set sc = ..DeleteTableEntry(%request, %session, "QCMasterLib.Tables.SystemUserWorkspace", pId)
	quit sc
}

}
