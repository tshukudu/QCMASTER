Include QCMasterLibDefines

Class QCMasterLib.Messages.Rsp.GenericUIRsp Extends (%RegisteredObject, QCMasterLib.Messages.Rsp.UIBaseFields) [ CompileAfter = QCMasterLib.Messages.Rsp.UIBaseFields ]
{

/// The raw JSON of the data projected.
Property Data As %GlobalCharacterStream;

/// Date Time Stamp - Initial expression to set. Set on Save
Property DateTimeStamp As QCMasterLib.DataTypes.DateTime(BlockSwaggerProjection = 1) [ InitialExpression = {$$$Now}, ReadOnly ];

/// The model presented in the Data section.
Property Model As %String(MAXLEN = "");

/// The number of pages available. Used in listings(GET)
Property TotalPages As %Integer;

/// The number of records available. Used in listings(GET)
Property TotalResults As %Integer;

}
