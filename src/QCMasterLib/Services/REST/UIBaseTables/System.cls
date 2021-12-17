/// CRUD UI Rest Service methods for the System Table
Class QCMasterLib.Services.REST.UIBaseTables.System Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetSystem() As %Status
{

	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.System")		
	
	quit sc
}

ClassMethod GetSystemDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.System", pID)		
	
	quit sc
}

ClassMethod CreateSystem() As %Status
{
	set sc = ..CreateTableEntry(%request, %session, "QCMasterLib.Tables.System")		
	
	quit sc
}

ClassMethod UpdateSystem(pId As %Integer) As %Status
{
	set sc = ..UpdateTableEntry(%request, %session, "QCMasterLib.Tables.System", pId)		
	
	quit sc
}

}
