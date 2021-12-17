Include MasterLibDefines

Class QCMasterLib.Messages.Req.GenericUIReq Extends (%Persistent, QCMasterLib.Messages.Req.UIBaseFields) [ CompileAfter = QCMasterLib.Messages.Req.UIBaseFields ]
{

/// The data.
Property Data As %GlobalCharacterStream;

/// not for the message. for persistence to be used for auditing
Property Table As %String(BlockSwaggerProjection = 1, MAXLEN = 100);

/// Date Time Stamp - Initial expression to set. Set on Save
Property DateTimeStamp As QCMasterLib.DataTypes.DateTime(BlockSwaggerProjection = 1) [ InitialExpression = {$$$Now}, ReadOnly ];


}
