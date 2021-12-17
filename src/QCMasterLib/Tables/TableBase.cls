Include QCMasterLibDefines

/// A base class to be used by all "tables". It contains properties and methods that should be present on all "tables".
Class QCMasterLib.Tables.TableBase Extends (%Persistent, %XML.Adaptor, %Populate, QCMasterLib.Utils.DynamicObject.Adapter) [ Abstract, NoExtent ]
{

Index DateTimeStampIndex On DateTimeStamp;

/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

Parameter VERSIONPROPERTY [ Final ] = "Version";

/// The record version. used for internal versio control
Property Version As %Integer [ InitialExpression = 0 ];

/// Last Modified DateTime
Property DateTimeStamp As QCMasterLib.DataTypes.DateTime [ InitialExpression = {$$$Now}, Required, SqlComputeCode = { Set {*} = $$$Now }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Last Modified by PID
Property RecordPID As %Integer [ InitialExpression = {$JOB}, SqlComputeCode = { Set {*} = $JOB }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Last Modified by User
Property RecordUserIdentifier As QCMasterLib.DataTypes.UserIdentifier [ InitialExpression = {##class(QCMasterLib.Utils.Security).GetUserIdentifier()}, SqlComputeCode = { Set {*} = ##class(MasterLib.Utils.Security).GetUserIdentifier() }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Last Modified by Ensemble Host (if applicable)
Property RecordEnsHost As %String(MAXLEN = "") [ InitialExpression = {$get(%Ensemble("ConfigName"),"")}, SqlComputeCode = { Set {*} = $get(%Ensemble("ConfigName"),"") }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Automatically updates DateTimeStamp when the entry is saved</br>
/// If this method is overridden, please apply this code within the new method, or invoke this one in the subclass
Method %OnAddToSaveSet(depth As %Integer, insert As %Integer, callcount As %Integer) As %Status [ Private ]
{
	set sc = $$$OK
	try {
		set ..DateTimeStamp = $$$Now
		set ..RecordPID = $JOB
		set ..RecordUserIdentifier = ##class(QCMasterLib.Utils.Security).GetUserIdentifier()
		set ..RecordEnsHost = $get(%Ensemble("ConfigName"),"")
	}catch tEx {
		if (sc = $$$OK) {
			set sc = tEx.AsStatus()
		}
	}
	quit sc
}

/// "Hook" for additional code to be executed together with the cutom OnDelete implementation which is generated.
/// Override where additional code is needed
ClassMethod OnDeleteAdditinal(pId As %Integer) As %Status [ Private, ServerOnly = 1 ]
{
	quit $$$OK
}

/// Calls historisation prior to deletion
ClassMethod GenerateHistoriseCode(pTrigger As %Boolean, pTriggerName As %String = "") As %Status [ ServerOnly = 1 ]
{
	#dim tHistTable As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	#dim tHistProp As %Dictionary.CompiledProperty

	set sc = $$$OK
	try {
		set tHistTableDef = ##class(%Dictionary.CompiledClass).%OpenId(%compiledclass.Name _ "History",0)
		if (tHistTableDef = "") {
			//set %code = 0
			do %code.WriteLine("	// No history table")
			return sc
		}
		// Calc sql table name
		Set tSQLTableName =  $translate($piece(%compiledclass.Name, ".", 1, *-1) , ".", "_") _ "." _ $piece(%compiledclass.Name, ".", *)
		
		// Create method code
	if (pTrigger = 1) {
		do %code.WriteLine("	new tHistDisabled")
	} else {
		do %code.WriteLine("	set sc = $$$OK")
	}
	do %code.WriteLine("	set tHistDisabled = $get(^historisetabledisabled("""_%compiledclass.Name_"""),0)")
	do %code.WriteLine("	if (tHistDisabled = 0) {")
        	if (pTrigger = 1) {
            	do %code.WriteLine("		new tId,sc,tCtr,tHistObj,%ok,%msg,SQLCODE,%oper")
            	do %code.WriteLine("		set tId = {ID}")
        	} else {
            	do %code.WriteLine("		set tId = pId")
        	}
        	do %code.WriteLine("		#SQLCompile Select=Logical")
	do %code.WriteLine("		set tHistObj = ##class(" _ %compiledclass.Name _ "History).%New()")
	
	// Process Properties
	do %code.WriteLine("		set tHistObj.CurrentRecordId = tId")
	for i=1:1:%compiledclass.Properties.Count() {
		set tCompiledProp = %compiledclass.Properties.GetAt(i)
		// Skip ISC properties
		if ($find(tCompiledProp.Name, "%") '= 0) {
			continue
		}
		if (tCompiledProp.Transient = 1) {
			continue
		}
		// Check if field in history table
		set tHistPropFound = 0
		for j=1:1:tHistTableDef.Properties.Count() {
			set tHistProp = tHistTableDef.Properties.GetAt(j)
			if (tHistProp.Name = tCompiledProp.Name) {
				set tHistPropFound = 1
			}
		}
		if (tHistPropFound = 0) {
			throw ##class(%Exception.General).%New("HistoryPropertyNotExist",,,"Property " _ tCompiledProp.Name _ " does not exist on the history table.")
		}
		// skip collections
		if (tCompiledProp.Collection '= "") {
			continue
		}
		// Create assignment code
		set tPropertyClass = ##class(%Dictionary.CompiledClass).%OpenId(tCompiledProp.Type,0)
		set tAssignDirect = 0
		if (tPropertyClass.ClassType = "datatype") {
			set tAssignDirect = 1
		}
		if (tAssignDirect) {
			do %code.WriteLine("		set tHistObj." _ tCompiledProp.Name _ "=" _ "{" _ tCompiledProp.Name _ "*O}")
		} else {
			do %code.WriteLine("		do tHistObj." _ tCompiledProp.Name _ "SetObjectId(" _ "{" _ tCompiledProp.Name _ "*O})")
		}
	} // end for non-collection property assignment
	
	// Process array collections
	for i=1:1:%compiledclass.Properties.Count() {
		set tCompiledProp = %compiledclass.Properties.GetAt(i)
		// Skip ISC properties
		if ($find(tCompiledProp.Name, "%") '= 0) {
			continue
		}
		if (tCompiledProp.Collection '= "array") {
			continue
		}
		if (tCompiledProp.Transient = 1) {
			continue
		}
		set tPropertyClass = ##class(%Dictionary.CompiledClass).%OpenId(tCompiledProp.Type,0)
		set tAssignDirect = 0
		if (tPropertyClass.ClassType = "datatype") {
			set tAssignDirect = 1
		}
		// Select from the array table projection and assign
		set tCursorName = $extract(tCompiledProp.Name,1,16) _ i _ "CursHst" _ pTriggerName
		if (pTrigger = 1) {
			do %code.WriteLine("		new t"_ tCompiledProp.Name)
		}
		do %code.WriteLine("		set tCtr = 0")
		do %code.WriteLine("		&sql(DECLARE "_ tCursorName _" CURSOR FOR ")
		do %code.WriteLine("			SELECT " _ tCompiledProp.Name _ " INTO :t" _ tCompiledProp.Name)
		do %code.WriteLine("			FROM " _ tSQLTableName _ "_" _ tCompiledProp.Name)
		do %code.WriteLine("			WHERE " _ $piece(%compiledclass.Name, ".", *) _ " = :tId)")
		do %code.WriteLine("		&sql(OPEN " _ tCursorName _ ")")
		do %code.WriteLine("		for {")
		do %code.WriteLine("			&sql(FETCH " _ tCursorName _ ")")
		do %code.WriteLine("			quit:(SQLCODE '= 0)")
		if (tAssignDirect) {
			do %code.WriteLine("			do tHistObj." _ tCompiledProp.Name _ ".SetAt(t" _ tCompiledProp.Name _ ", $i(tCtr))")
		} else {
			do %code.WriteLine("			do tHistObj." _ tCompiledProp.Name _ ".SetObjectIdAt(t" _ tCompiledProp.Name _ ", $i(tCtr))")
		}
		do %code.WriteLine("			}")
		do %code.WriteLine("			&sql(CLOSE " _ tCursorName _ ")")
	}
	// End of if modified, Save and quir
	do %code.WriteLine("	set sc = tHistObj.%Save(0)")
        	if (pTrigger = 1) {
            		do %code.WriteLine("		if ($$$ISERR(sc)) {")
            		do %code.WriteLine("			set %ok = 0")
            		do %code.WriteLine("			set %msg = $System.Status.GetErrorText(sc)")
            		do %code.WriteLine("		}")
            		do %code.WriteLine("	}")
            	} else {
	            	do %code.WriteLine("	}")
	            	do %code.WriteLine("	quit sc")
	      }
	} catch tEx {
		set sc = tEx.AsStatus()
	}
	quit sc
}

/// Automtically historises the table endtry when it is altered via SQL
/// Compile-time generated code method in derived classes
Trigger HistoriseRecord [ CodeMode = objectgenerator, Event = UPDATE, Foreach = row/object, Order = 10 ]
{
	if (%compiledclass.Name = "MasterLib.Tables.TableBase") {
		set %code = 0
		return $$$OK
	} else {
		set sc = ##class(MasterLib.Tables.TableBase).GenerateHistoriseCode(1, "BU")
	}
	quit sc
}

/// Automtically historises the table endtry when it is deleted via SQL
/// Compile-time generated code method in derived classes
Trigger ArchiveRecordOnDelete [ CodeMode = objectgenerator, Event = DELETE, Foreach = row/object, Order = 10 ]
{
	if (%compiledclass.Name = "MasterLib.Tables.TableBase") {
		set %code = 0
		return $$$OK
	} else {
		do %code.WriteLine("	new sc")
		do %code.WriteLine("	set sc = ##class(" _ %compiledclass.Name _ ").OnDeleteAdditinal({ID})")
		do %code.WriteLine("	if $$$ISERR(sc) {")
		do %code.WriteLine("		set %ok = 0")
		do %code.WriteLine("		set %msg = $System.Status.GetErrorText(sc)")
		do %code.WriteLine("		return")
		do %code.WriteLine("	}")
		set sc = ##class(MasterLib.Tables.TableBase).GenerateHistoriseCode(1, "BD")
	}
	quit sc
}

}
