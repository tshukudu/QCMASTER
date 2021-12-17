/// Data type for date in order to set the format consitently
Class QCMasterLib.DataTypes.Date Extends %Library.Date [ ClientDataType = DATE, OdbcType = DATE, SqlCategory = DATE ]
{

Parameter FORMAT = 8;

ClassMethod XSDToLogical(%val As %String) as %Date
{
	set %val = $zstrip(%val,"<","0")
	if (%val = "") {
		return %val
	}
	return $zdateh(%val, 8)
}

ClassMethod DisplayToLogical(%val As %String) as %Date
{
	set %val = $zstrip(%val,"<","0")
	if (%val = "") {
		return %val
	}
	return $zdateh(%val, 8)
}

ClassMethod LogicalToXSD(%val As %Date) as %String
{
	return $zdate(%val, 8)
}

}
