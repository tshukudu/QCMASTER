/// DEPRECATED <br>
/// A table to link which Workspace a Cache User for host-to-host services has access to.
Class QCMasterLib.Tables.WorkspaceCacheUser extends (QCMasterLib.Tables.TableBase)  [ Deprecated ]{

/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

Index WorkspaceCacheUserIndex on (Workspace, CacheUser) [ Unique ];

/// Foreign Keys
ForeignKey WorkspaceFK(Workspace) References QCMasterLib.Tables.Workspace();

/// Allowed Workspace
Property Workspace As QCMasterLib.Tables.Workspace [ Required ];

/// Cache Username
Property CacheUser As %String(MAXLEN = 200) [ Required ];

/// Validate the logged in Cache user against the Client Identifier
ClassMethod CheckCacheUserWorkspace(pClientIdentifier As QCMasterLib.Messages.FieldTypes.ClientIdentifier, Output pAllowed As QCMasterLib.DataTypes.Boolean) As %Status
{
	set pAllowed = 0
	set tInst = ##class(QCMasterLib.Tables.Workspace).ClientIdentifierIndexOpen(pClientIdentifier,0)
	 if (tInst '= "") {
	 	set tObj = ##class(QCMasterLib.Tables.WorkspaceCacheUser).WorkspaceCacheUserIndexOpen(tInst.%Id(), $username,0)
	 	if (tObj '= "") {
	 		set pAllowed = 1
	 	}
	 }
	 quit $$$OK
}

}