/// General REST Methgod error XML response. Typilcally used when an invalid REST post packet has been received.
Class QCMasterLib.Messages.Rsp.RESTMethodErrorRsp Extends (%Persistent, %XML.Adaptor, QCMasterLib.Utils.DynamicObject.Adapter)
{

Parameter SUPPRESSTYPEPREFIX = 1;

/// A general return code of the operation, indicates success, failure and/or when there are field errors.
Property ReturnCode As QCMasterLib.Messages.FieldTypes.ReturnCode [ Required ];

/// A descriptive reason of the return code
Property ReturnReason As QCMasterLib.Messages.FieldTypes.ReturnReason [ Required ];


}
