Include MasterLibDefines

/// A base class to be used by all history "tables". It contains properties that should be present on all "tables".
Class QCMasterLib.Tables.TableHistoryBase Extends (%Persistent, %XML.Adaptor, QCMasterLib.Utils.DynamicObject.Adapter) [ Abstract, NoExtent ]
{

Index CurrentRecordIdIndex On CurrentRecordId;

Index DateTimeStampIndex On DateTimeStamp;

Index HistoriseDateTimeStampIndex On HistoriseDateTimeStamp;

/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

/// The record version. used for internal versio control
Property Version As %Integer [ InitialExpression = 0 ];

/// Last Modified DateTime (Main Table)
Property DateTimeStamp As QCMasterLib.DataTypes.DateTime [ Required ];

/// Last Modified by PID
Property RecordPID As %Integer;

/// Last Modified by User
Property RecordUserIdentifier As QCMasterLib.DataTypes.UserIdentifier;

/// Last Modified by Ensemble Host (if applicable)
Property RecordEnsHost As %String(MAXLEN = "");

/// DateTime that the entry was historised
Property HistoriseDateTimeStamp As QCMasterLib.DataTypes.DateTime [ InitialExpression = {$$$Now}, ReadOnly ];

/// Historised by PID
Property HistorisePID As %Integer [ InitialExpression = {$JOB}, ReadOnly ];

/// Historised by User
Property HistoriseUserIdentifier As QCMasterLib.DataTypes.UserIdentifier [ InitialExpression = {##class(QCMasterLib.Utils.Security).GetUserIdentifier()}, ReadOnly ];

/// Historised by Ensemble Host (if applicable)
Property HistoriseEnsHost As %String(MAXLEN = "") [ InitialExpression = {$get(%Ensemble("ConfigName"),"")}, ReadOnly ];

/// A link to the ?current? record in the original table linked to this History entry
Property CurrentRecordId As %Integer;

}
