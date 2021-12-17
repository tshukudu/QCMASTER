Class QCMasterLib.Tables.Workspace Extends (QCMasterLib.Tables.TableBase)   
{

/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

Index ClientIdentifierIndex On ClientIdentifier [ Unique ];

/// Client Identifier on all messages
Property ClientIdentifier As %Integer [ Required ];

/// Record create date and time stamp
Property CreateDateTimeStamp As QCMasterLib.DataTypes.DateTime [ InitialExpression = {$zdatetime($Horolog,3)}, Required, ReadOnly ];

}