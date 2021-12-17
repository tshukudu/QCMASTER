/// Base Q LINK UI Request Message Fields
/// To be inherited on all Q LINK UI message definitions
Class QCMasterLib.Messages.Req.UIBaseFields Extends (%XML.Adaptor, QCMasterLib.Utils.DynamicObject.Adapter, QCMasterLib.Utils.REST.Swagger.MessageAdapter) [ Abstract, CompileAfter = QCMasterLib.Tables.Institution ]
{

/// A unique code that identifies the system that is interfacing to Q LINK.
Property SystemIdentifier As QCMasterLib.DataTypes.SystemIdentifier [ Required ];

/// The current version of the system interfacing to Q LINK.
Property SystemVersion As QCMasterLib.Messages.FieldTypes.SystemVersion [ Required ];

/// Free-text value stored as reference to the origination of the message.
Property ClientAuditData As QCMasterLib.Messages.FieldTypes.ClientAuditData [ Required ];

/// The user identifier for the record submitted.
Property UserIdentifier As QCMasterLib.DataTypes.UserIdentifier [ Required ];

}
