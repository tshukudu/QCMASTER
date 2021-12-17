/// Used to manage resources used by external systems.
Class QCMasterLib.Tables.SystemResource Extends QCMasterLib.Tables.TableBase [ CompileAfter = QCMasterLib.Tables.SystemResourceHistory ] 
{

/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

/// Indices
Index SystemIndex On System [ Type = Bitmap ];

Index SystemResourceIdentifierIndex On (System, ResourceIdentifier) [ Unique ];

Index EnabledIndex On Enabled [ Type = Bitmap ];

/// Foreign keys
ForeignKey SystemFK(System) References QCMasterLib.Tables.System(); 

/// Reference to System Table - the system this resource is assigned to.
Property System As QCMasterLib.Tables.System [ Required ];

/// Resource name
Property ResourceIdentifier As %String(MAXLEN = "") [ Required ];

/// Indicated whether this resource is enabled or not.
Property Enabled As QCMasterLib.DataTypes.Boolean [ InitialExpression = 1, Required ];

}