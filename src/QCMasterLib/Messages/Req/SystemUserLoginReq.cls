/// Request message for Managed System user login.
Class QCMasterLib.Messages.Req.SystemUserLoginReq Extends (%Persistent,QCMasterLib.Messages.Req.UIBaseFields,%XML.Adaptor,QCMasterLib.Utils.REST.Swagger.MessageAdapter,QCMasterLib.Utils.DynamicObject.Adapter) [ CompileAfter = (QCMasterLib.Messages.Req.UIBaseFields, QCMasterLib.Utils.REST.Swagger.MessageAdapter,QCMasterLib.Utils.DynamicObject.Adapter)]
{

Property Password As QCMasterLib.DataTypes.Password [ Required ];



}