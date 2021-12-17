/// Used to Assign Roles to Systems.
Class QCMasterLib.Tables.SystemRole Extends QCMasterLib.Tables.TableBase [ CompileAfter = QCMasterLib.Tables.SystemRoleHistory ]
{
/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

/// Indeces
Index DescriptionSystemIndex On (Description,System) [ Unique ];

Index SystemIndex On System [ Type = Bitmap ];

Index EnabledIndex On Enabled  [ Type = Bitmap ];

/// Foreign Keys
ForeignKey SystemFK(System) References QCMasterLib.Tables.System();  

/// Role Description
Property Description As %String(MAXLEN=250) [ Required ];

/// Reference to System applicable to this role.
Property System As QCMasterLib.Tables.System [ Required ];

/// Indicated whether this resource is enabled or not.
Property Enabled As QCMasterLib.DataTypes.Boolean [ InitialExpression = 1, Required ];

/// System Resources assigned to this role.
Property SystemResource As Array of QCMasterLib.Tables.SystemResource;

/// Overloaded Validator Method
Method %OnValidateObject() As %Status [ Private ] 
{
	set sc = $$$OK
	set scErr = ""
	set tResourceCount = ..SystemResource.Count()
	for i=1:1:tResourceCount
	{
		set tTempRes = ..SystemResource.GetAt(i)
		if (tTempRes.System.Description '= ..System.Description){
			//set esc = $$$ERROR($$$GeneralError, "System Resource "_ tTempRes.System.Description _" does not match this System.")
			set esc = $$$ERROR($$$DatatypeValidationFailed, "Property "_$classname()_"::SystemResource("_$this_",ID="_..%Id()_") "_ tTempRes.System.Description _" does not match this System.")
			set scErr = $$$ADDSC(scErr,esc)
		}
	} // End For
	if (scErr '= ""){
		quit scErr
	}     
    quit sc
}

}