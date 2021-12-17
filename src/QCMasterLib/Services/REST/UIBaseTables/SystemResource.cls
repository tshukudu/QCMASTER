/// CRUD UI REST Service methods for the SystemResource Table.
Class QCMasterLib.Services.REST.UIBaseTables.SystemResource Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetSystemResource() As %Status
{

	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.SystemResource")		
	
	quit sc
}

ClassMethod GetSystemResourceDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.SystemResource", pID)		
	
	quit sc
}

ClassMethod CreateSystemResource() As %Status
{
	set sc = ..CreateTableEntry(%request, %session, "QCMasterLib.Tables.SystemResource")		
	
	quit sc
}

ClassMethod UpdateSystemResource(pId As %Integer) As %Status
{
	set sc = ..UpdateTableEntry(%request, %session, "QCMasterLib.Tables.SystemResource", pId)		
	
	quit sc
}

}
