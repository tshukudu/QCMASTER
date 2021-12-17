/// Message Field type for group of field errors
Class QCMasterLib.Messages.FieldTypes.FieldError Extends (%SerialObject, %XML.Adaptor, QCMasterLib.Utils.DynamicObject.Adapter)
{

Parameter XMLNAME = "field_error_entry";

Parameter JSONNAME = "FieldErrorEntry";


/// Field name on which the return code applies
Property FieldName As QCMasterLib.DataTypes.FieldName(XMLNAME = "field_name") [ Required ];

/// Return Code of the operation
Property ReturnCode As QCMasterLib.Messages.FieldTypes.ReturnCode [ Required ];

/// Description of the Return Code of the operation
Property ReturnReason As QCMasterLib.Messages.FieldTypes.ReturnReason [ Required ];

}
