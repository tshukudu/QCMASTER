ROUTINE QCMasterLibDefines [Type=INC]
/// Defines for Masterlibrary

/// Channel Defines
#define ChannelABSAAC               1
#define ChannelQLINKPayrollGov      2
#define ChannelQLINKBank            3
#define ChannelQLINKPayrollPvt      4
#define ChannelCMoS                 5
#define ChannelAccurate             6
#define ChannelAPSGov               7
#define ChannelPostOffice           8
#define ChannelSTDBank              9
#define ChannelNedbank              10
#define ChannelHyphen               11
#define ChannelIntecon              12
#define ChannelMCC                  13
#define ChannelGencorr			    14
#define ChannelFirstNationalBank	15

/// Service Defines
#define ServiceACTT1                1
#define ServiceACTT2                2
#define ServiceXMLServices          3
#define ServiceClientDirect         4
#define ServiceDebitOrder           5
#define ServiceEFTSameDay           6
#define ServiceEFT1Day              7
#define ServiceEFT2Day              8
#define ServiceNAEDO                9
#define ServiceAVS                  10
#define ServiceCMSIS                11
#define ServiceStopOrder            12
#define ServicePrlEmplImport        13
#define ServicePushPayment          14
#define ServiceBankStatement        15
#define ServiceACTT3                16
#define ServiceMMSWeb               17
#define ServiceAllpsi               18
#define ServiceDisbursement         19
#define ServiceMMSBulk              20
#define ServiceCorrespondence       21
#define ServiceDebicheckCollection	22
#define ServiceCMSISWebServices		23

/// File Types
/// ABSA TT2
#define FileTypeTT2Transmission             1
#define FileTypeTT2Transactions             2
#define FileTypeTT2TransGrps                3
#define FileTypeABSAReply                   4
#define FileTypeABSATT2Status               5
#define FileTypeABSATT2Acceptance           6
#define FileTypeABSAACKNACK                 7
/// DOEI
#define FileTypeDOEIQDOVInput               10
#define FileTypeDOEIQDOVOutput              11
#define FileTypeDOEIQDOH                    12
#define FileTypeDOEIQDOE                    13
#define FileTypeDOEIQPAY                    14
#define FileTypeDOEIQDOR                    15
#define FileTypeDOEIQDOD                    16
#define FileTypeDOEIQDOP                    17
#define FileTypeDOEIQDOA                    18
#define FileTypeDOEIQDOG                    19
#define FileTypeDOEIQOUT                    20
#define FileTypeDOEIQDOI                    21
#define FileTypeDOEIQCNH                    22
#define FileTypeDOEIQCRE                    23
#define FileTypeDOEIQCRI                    24
#define FileTypeDOEIQCRF                    25
#define FileTypeDOEIQROE					26

/// CMSIS
#define FileTypeCMSISStart                  30
#define FileTypeCMSISMCOH                   30
#define FileTypeCMSISMAVH                   31
#define FileTypeCMSISMCEH                   32
#define FileTypeCMSISMCRH                   33
#define FileTypeCMSISMAEH                   34
#define FileTypeCMSISMARH                   35
#define FileTypeCMSISMDBH                   36
#define FileTypeCMSISMDEH                   37
#define FileTypeCMSISMDRH                   38
#define FileTypeCMSISMTCH                   39
#define FileTypeCMSISEnd                    39
#define FileTypeCMISContStart               150
#define FileTypeCMSISMTPH                   150
#define FileTypeCMSISGenerated              151
#define FileTypeCMISContEnd                 159

/// SEPDI
#define FileTypeSEPDIStart                  40
#define FileTypeSEPDIQTOP                   40
#define FileTypeSEPDIQDMP                   41
#define FileTypeSEPDIQAFH                   42
#define FileTypeSEPDIQRES                   43
#define FileTypeSEPDIQSTH                   44
#define FileTypeSEPDIQERR                   45
#define FileTypeSEPDIQXML                   46
#define FileTypeSEPDIEnd                    46
/// Payroll
#define FileQLINKPayrollEmployee            47
#define FileQLINKPayrollSPOT                48
/// Accurate bank Statement
#define FileTypeAccurateBankStatement       50
#define FileTypeAccurateBankStatementAck    52
/// SAPO POSTOFFICE
#define FileTypeSAPOPostOffice              51
/// APS
#define FileTypeAPSQTOP                     60
#define FileTypeAPSQERR                     61
#define FileTypeAPSQRESULT                  62
#define FileTypeAPSQOUT                     63
#define FileTypeAPSXREV                     64
/// MISIS
#define FileTypeMISISSTART                  70
#define FileTypeMISISMMDH                   70
#define FileTypeMISISMCOH                   71
#define FileTypeMISISMTCH                   72
#define FileTypeMISISMTPH                   73
#define FileTypeMISISMDBH                   74
#define FileTypeMISISMAVH                   75
#define FileTypeMISISMAFH                   76
#define FileTypeMISISMMMH                   77
#define FileTypeMISISMMAH                   78
#define FileTypeMISISMMCH                   79
#define FileTypeMISISEND                    79
#define FileTypeMISISSTARTEXT               111
#define FileTypeMISISMRCH                   111
#define FileTypeMISISMCAH                   112
#define FileTypeMISISMCCH                   113
#define FileTypeMISISMCLH                   114
#define FileTypeMISISENDEXT                 119

/// StandardBank
#define FileTypeSTDM65                      80
/// Nedbank AC
#define FileTypeNedbankTT2Initiate          81
#define FileTypeNedbankTT2Amend             82
#define FileTypeNedbankTT2Cancellation      83
#define FileTypeNedbankACResponse           84
#define FileTypeNedbankACACKNACK            85
/// Oracle Finance Summary
#define FileTypeOracleFS                    90
/// Hyphen Files
#define FileTypeHyphenStart                 100
#define FileTypeHyphenFACS                  100
#define FileTypeHyphenSOCSIncoming          101
#define FileTypeHyphenSOCSReturn            102
#define FileTypeHyphenEnd                   110

/// AC Pos Reg
#define FileTypeACPOSRegStart               120
#define FileTypeACPOSRegExport              120
#define FileTypeACPOSRegEnd                 129

/// Intecon Files
#define InteconMandateCreateRsp             130
#define InteconMandateEditRsp               131
#define InteconBankResponseRsp              132
#define InteconBankResponseOutput           133

#define FileTypeMCCStart                    140
#define FileTypeMCCBilling                  140
#define FileTypeMCCPayment                  141
#define FileTypeMCCEnd                      149

/// 150-159 Reserved for CMSIS Extended

/// Standard Bank AC
#define FileTypeSBSATT2START                160
#define FileTypeSBSATT2Initiate             160
#define FileTypeSBSATT2Amend                161
#define FileTypeSBSATT2Cancellation         162
#define FileTypeSBSATT2ACResponse           163
#define FileTypeSBSATT2ACKNACK              164
#define FileTypeSBSATT2END                  169

/// MMS Bulk
#define FileTypeBankSyncNotification        170
#define FileTypeBankSyncResult              171
#define FileTypeBankSyncMngMdt              172

/// FNB Input
#define FileTypeFNBInput					191
#define FileTypeFNBConfirm					192
#define FileTypeFNBHash						193
#define FileTypeFNBLoad						194


/// Correspondence - Reserved 1030 to 1050

/// System Resource Import file identifiers
#define SysResFileIdentSystemResources  "SYSTEMRESOURCES"
#define SysResFileIdentSystemResourceUI "SYSTEMUIRESOURCES"
#define SysResFileIdentSystemRoles      "SYSTEMROLES"
#define SysResFileIdentSystemUsers      "SYSTEMUSERS"
#define SysResFileIdentSystemUserAccess "SYSTEMUSERACCESS"

/// File Processing Status
#define FileStatusNew               	1
#define FileStatusParseError        	2
#define FileStatusForceProcessing   	3
#define FileStatusPending           	4
#define FileStatusInProcess         	5
#define FileStatusCompleted         	6
#define FileStatusIntegrityError    	7
#define FileStatusNACKError         	8
#define FileStatusCompletedWithErrors	9

/// File Processing Error Status
#define FileProcErrorStatusNew      1
#define FileProcErrorStatusIgnore   2
#define FileProcErrorStatusResolved 3

/// Processing Types for FPC
#define ProcessTypeFlatFile			1
#define ProcessTypeXMLSchemaBound	2

/// File Tracking Statusses
#define FileTrackStatusACK          "A"
#define FileTrackStatusNACK         "N"
#define FileTrackStatusNA           "X"
#define FileTrackStatusPending      "P"

/// UserCode to use in processing
/// File Processing Control. TODO - better names
#define FPCUserCodeUsedPrimary          1
#define FPCUserCodeUsedSecondary        2
#define FPCUserCodeUsedBoth             3

/// Country
#define CountrySA                   "ZAF"
#define CountryNAM                  "NAM"
#define CountryUnknown          "zzz"

/// Currency
#define CurrencySA                  "ZAR"
#define CurrencyNAD                 "NAD"
#define CurrencyUnknown        "zzz"


///Bank Service Defines
#define BankServiceAVS              1
#define BankServiceAVSR             2
#define BankServiceTwoDayEFT        3
#define BankServiceAEDO             4
#define BankServiceNAEDO            5
#define BankServiceAC               6
#define BankService1DayEFT          7
#define BankService5DayEFT          8
#define BankServiceSameDayEFT       9

/// Collection Agent Types
#define ColAgentTypeEmployerPayroll         1
#define ColAgentType3rdPartySP              2
#define ColAgentTypeFinancialInstitution    3

/// Collection Agent Commission Application
#define ColAgentCommissionApplicationGlobal     1
#define ColAgentCommissionApplicationIndividual 2

/// Collection Agent Commission on Reversals
#define ColAgentCommissionAOnReversalsNA     1
#define ColAgentCommissionAOnReversalsSubtract  2
#define ColAgentCommissionAOnReversalsAdd 2

/// Record Map Section Identifiers
#define RMSectionIdentifierHeader              "Header"
#define RMSectionIdentifierDetail              "Detail"
#define RMSectionIdentifierDetailResponse      "DetailResponse"
#define RMSectionIdentifierDetailAVS           "DetailAVS"
#define RMSectionIdentifierDetailAdd           "DetailAdd"
#define RMSectionIdentifierDetailAmend         "DetailAmend"
#define RMSectionIdentifierDetailCancel        "DetailCancel"
#define RMSectionIdentifierDetailFix           "DetailFix"
#define RMSectionIdentifierDetailPHAdd         "DetailPHAdd"
#define RMSectionIdentifierDetailPHDel         "DetailPHDel"
#define RMSectionIdentifierDetailRealTime      "DetailRealTime"
#define RMSectionIdentifierDetailDelete        "DetailDelete"
#define RMSectionIdentifierDetailArrear        "DetailArrear"
#define RMSectionIdentifierDetailOnceOff       "DetailOnceOff"
#define RMSectionIdentifierTrailer             "Trailer"

/// Complimentary Service on Mandate Action flags
#define CSonMdtNotApplicable            1
#define CSonMdtCMoS                     2
#define CSonMdtChannel                  3
#define CSonMdtCMoSFailOverToChannel    4

/// Complex Record map Property Type
#define CRMPropertyTypeReference        1
#define CRMPropertyTypeArray            2

/// AVS Types used in QLKServices
#define AVSTypeDebit                    1
#define AVSTypeCredit                   2
#define AVSTypeEstate                   3
#define AVSTypeTrust                    4
#define AVSTypeInvest                   6
#define AVSTypeNoCellEmail				8
#define AVSTypeIDDebit					9

//// SystemUser Source
#define SystemUserSourceCache                   1
#define SystemUserSourceActiveDirectory         2
#define SystemUserSourceSystemManaged           3

/// System User Login failure Reasons
#define SystemUserLoginFailInvalidPass          1
#define SystemUserLoginFailPassExpired          2
#define SystemUserLoginFailUserDisabled         3

/// File Distribution Status
#define FileDistStatusProcessAgain              1
#define FileDistStatusCompleted                 2

/// File Distribution Action
#define FileDistActionMove                      1
#define FileDistActionCopy                      2

/// Frequencues
#define FrequencyOnceOff                        "O"
#define FrequencyWeekly                         "W"
#define FrequencyFortnightly                    "F"
#define FrequencyMonthly                        "M"
#define FrequencyQuarterly                      "Q"
#define FrequencyHalfYearly                     "H"
#define FrequencyAnnually                       "A"
#define FrequencyRuleBased                      "R"

#define SQLFrequencyOnceOff                     'O'
#define SQLFrequencyWeekly                      'W'
#define SQLFrequencyFortnightly                 'F'
#define SQLFrequencyMonthly                     'M'
#define SQLFrequencyQuarterly                   'Q'
#define SQLFrequencyHalfYearly                  'H'
#define SQLFrequencyAnnually                    'A'
#define SQLFrequencyRuleBased                   'R'

/// Frequency Types
#define FrequencyTypeRecurring                  1
#define FrequencyTypeOnceOff                    2
#define FrequencyTypeArrear                     3

/// Rule based scheduling
#define ActionDayRuleLastFriday                 1
#define ActionDayRuleSecondLastWorkingDay       2
#define ActionDayRuleThirdLastWorkingDay        3
#define ActionDayRuleFourthLastWorkingDay       4
#define ActionDayRuleLastFridayNotLastDay       5

/// Movement Indicators
#define MovementIndicatorBackward               1
#define MovementIndicatorForward                2

/// Payroll ID
#define PayrollIdPERSAL                         1
#define PayrollIdDOD                            2

/// Product Comparison
#define ProductComparisonEquals                 1
#define ProductComparisonContains               2

/// TruncateIndicator
#define TruncateIndicatorNA                     1
#define TruncateIndicatorFront                  2
#define TruncateIndicatorBack                   3

/// Commission Type
#define CommissionTypePercentage                1
#define CommissionTypeFlatRate                  2

/// BulkMatchDeviationControl
#define BulkMatchDeviationControlNoDeviation    1
#define BulkMatchDeviationControlPercentage     2
#define BulkMatchDeviationControlAmount         3

/// AVSR AccountStatus
#define AccountStatusClosed                     0
#define AccountStatusOpenLess3Months            1
#define AccountStatusOpenMore3Months            3

/// Channel Config Premium Holiday Modes
#define PremHolModeSupported                    1
#define PremHolModeSystemManaged                2

/// Util
#define NullAssign                              "$nullset"

/// Collection Methods
#define CollMethodUnknown                   0
#define CollMethodPayroll                   1
#define CollMethodBank                      2
#define CollMethodPushPay                   3
#define CollMethodDisbursement              4

/// File Trailer Count Modes
#define FileTrailerCountModeNA				1
#define FileTrailerCountModeDetailRowsOnly	2
#define FileTrailerCountModeAllRows			3

/// File Trailer Check Toatl Modes
#define FileTrailerCheckTotalModeNA				1
#define FileTrailerCheckTotalModeDetailRowsOnly	2

/// DataExtract Job Status
#define DEJobNew						1
#define DEJobExtracting					2
#define DEJobWriting					3
#define DEJobComplete					4

/// DataExtract JobOutput Status
#define DEJobOutputNew						1
#define DEJobOutputWriting					2
#define DEJobOutputComplete					3
#define DEJobOutputError					4

/// DataExtract JobOutputFile Status
#define DEJobOutputFileWriting				1
#define DEJobOutputFileComplete				2
#define DEJobOutputFileError				3

/// DataExtractOutputType
#define DEOutputTypeXML					1

/// DataExtractOutputXMLSetupType
#define DEOutputXMLTypeRootNode				1
#define DEOutputXMLTypeNode					2
#define DEOutputXMLTypeAttribute			3

/// DataMaintenance Method
#define DataMaintProcessMethodSQL			1
#define DataMaintProcessMethodObject		2


///===============================================
/// Functions
#define LeftPad(%Value,%Length,%PadChar)            $translate($justify(%Value,%Length)," ",%PadChar)
#define RightPad(%Value,%Length,%PadChar)           $extract(%Value _ $translate($justify("",%Length)," ",%PadChar),0,%Length)
#define Now                                         $zdatetime($Horolog,3)
#define CurrentDate                                 $piece($horolog,",",1)
#define CurrentTime                                 $piece($horolog,",",2)
#define GetFileNameFromPath(%FileName)              $piece($translate(%FileName, "\", "/"), "/", *)
#define GetFileNameFromStream(%InputStream)         ##class(MasterLib.Utils.File).GetFileName(%InputStream)
#define PrepFileForParsing(%InputStream)            ##class(MasterLib.Utils.File).PrepFileForParsing(%InputStream)
#define InArray(%Array,%Value)                      ##class(MasterLib.Utils.RuleFunctions.General).InArray(%Array,%Value)
#define GetCustomDataValue(%CustomData,%FieldName)  ##class(MasterLib.Utils.RuleFunctions.General).GetCustomDataVal(%CustomData, %FieldName)
#define CustomDataExists(%FieldName,%CustomData)    ##class(MasterLib.Utils.RuleFunctions.General).CustomDataFieldExists(%FieldName, %CustomData)
#define GetMetric(%Metric,%Value)                   ##class(Ens.BusinessMetric).GetMetric(%Metric,%Value)
#define IsValidInteger(%Value)						$select($number(%Value,"I")="":0,1:1)