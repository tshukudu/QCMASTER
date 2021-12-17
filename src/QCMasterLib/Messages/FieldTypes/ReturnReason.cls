/// Field type for return reason. Will probably be loaded from the return codes table using the return reason
Class QCMasterLib.Messages.FieldTypes.ReturnReason Extends %Library.String [ ClientDataType = VARCHAR, OdbcType = VARCHAR, SqlCategory = STRING ]
{

Parameter MAXLEN = 100;

Parameter XMLNAME = "return_reason";
}
