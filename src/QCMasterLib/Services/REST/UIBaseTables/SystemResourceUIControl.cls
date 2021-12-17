/// CRUD UI REST Service methods for the SystemResourceUIControl Table.
Class QCMasterLib.Services.REST.UIBaseTables.SystemResourceUIControl Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetSystemResourceUIControl() As %Status
{

	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.SystemResourceUIControl")		
	
	quit sc
}

ClassMethod GetSystemResourceUIControlDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.SystemResourceUIControl", pID)		
	
	quit sc
}

ClassMethod CreateSystemResourceUIControl() As %Status
{
	set sc = ..CreateTableEntry(%request, %session, "QCMasterLib.Tables.SystemResourceUIControl")		
	
	quit sc
}

ClassMethod UpdateSystemResourceUIControl(pId As %Integer) As %Status
{
	set sc = ..UpdateTableEntry(%request, %session, "QCMasterLib.Tables.SystemResourceUIControl", pId)		
	
	quit sc
}

ClassMethod DeleteSystemResourceUIControl(pId As %Integer) As %Status
{
	set sc = ..DeleteTableEntry(%request, %session, "QCMasterLib.Tables.SystemResourceUIControl", pId)		
	
	quit sc
}

}
