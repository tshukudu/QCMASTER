/// UI REST CRUD Methods for the Workspace table
Class QCMasterLib.Services.REST.UIBaseTables.Workspace Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase)
{

ClassMethod GetInstitutionList() As %Status
{
	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.Workspace")
	
	quit sc
}

ClassMethod GetInstitutionDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.Workspace", pID)		
	
	quit sc
}

ClassMethod CreateInstitution() As %Status
{
	set sc = ..CreateTableEntry(%request, %session, "QCMasterLib.Tables.Workspace")		
	
	quit sc
}

ClassMethod UpdateInstitution(pId As %Integer) As %Status
{
	set sc = ..UpdateTableEntry(%request, %session, "QCMasterLib.Tables.Workspace", pId)		
	
	quit sc
}

}
