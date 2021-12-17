/// UI REST CRUD service for the WorkspaceCacheUser
Class QCMasterLib.Services.REST.UIBaseTables.WorkspaceCacheUser Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetWorkspaceCacheUser() As %Status
{

	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.WorkspaceCacheUser")		
	
	quit sc
}

ClassMethod GetWorkspaceCacheUserDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.WorkspaceCacheUser", pID)		
	
	quit sc
}

ClassMethod CreateWorkspaceCacheUser() As %Status
{
	set sc = ..CreateTableEntry(%request, %session, "QCMasterLib.Tables.WorkspaceCacheUser")		
	
	quit sc
}

ClassMethod UpdateWorkspaceCacheUser(pId As %Integer) As %Status
{
	set sc = ..UpdateTableEntry(%request, %session, "QCMasterLib.Tables.WorkspaceCacheUser", pId)		
	
	quit sc
}

}
