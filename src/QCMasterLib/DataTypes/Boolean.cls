/// Custom boolean datatype to allow for several variations of True/False values.
Class QCMasterLib.DataTypes.Boolean Extends %Library.Boolean [ ClientDataType = BOOLEAN, OdbcType = BIT, SqlCategory = INTEGER ]
{

Parameter XSDTYPE = "boolean";

Parameter SwaggerType = "string";

Parameter SwaggerEnum = ";T:True;F:False";

ClassMethod XSDToLogical(%val As %String) As %Boolean
{
	set tTrueList = $ListBuild("T","TRUE","1")
	set tFalseList = $ListBuild("F","FALSE","0")
	if ($ListFind(tTrueList,$ZCONVERT(%val,"u")) > 0)
	{
		set %val = 1
	}
	elseif ($ListFind(tFalseList,$ZCONVERT(%val,"u")) > 0)
	{
		set %val = 0
	}
	else 
	{
		set %val = ""
	}
	return %val
}

ClassMethod DisplayToLogical(%val As %String) As %Boolean
{
	set tTrueList = $ListBuild("T","TRUE","1")
	set tFalseList = $ListBuild("F","FALSE","0")
	if ($ListFind(tTrueList,$ZCONVERT(%val,"u")) > 0)
	{
		set %val = 1
	}
	elseif ($ListFind(tFalseList,$ZCONVERT(%val,"u")) > 0)
	{
		set %val = 0
	}
	else 
	{
		set %val = ""
	}
	return %val
}

ClassMethod LogicalToXSD(%val As %Boolean) As %String
{
	if %val = 1
	{
		set %val = "T"		
	} 
	elseif %val = 0 
	{
		set %val = "F"
	}
	else 
	{
		set %val = "" 
	}
	
	return %val
}

ClassMethod LogicalToDisplay(%val As %Boolean = 0) As %String
{
	if %val = 1
	{
		set %val = "T"		
	} 
	elseif %val = 0 
	{
		set %val = "F"
	}
	else 
	{
		set %val = "" 
	}
	
	return %val
}

}
