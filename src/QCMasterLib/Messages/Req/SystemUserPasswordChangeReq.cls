/// Req message for changing a Managed System User's password.
Class QCMasterLib.Messages.Req.SystemUserPasswordChangeReq Extends (%Persistent, QCMasterLib.Messages.Req.UIBaseFields, %XML.Adaptor, QCMasterLib.Utils.REST.Swagger.MessageAdapter, QCMasterLib.Utils.DynamicObject.Adapter) [ CompileAfter = QCMasterLib.Messages.Req.UIBaseFields ]
{

Property Password As QCMasterLib.DataTypes.Password [ Required ];

Property NewPassword As QCMasterLib.DataTypes.Password(XMLNAME = "newpassword") [ Required ];

}
