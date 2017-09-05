//
//  PaxConstants.h
//  PaxTestApp
//
//  Created by Siya Infotech on 06/06/15. - My B'day
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#ifndef PaxTestApp_PaxConstants_h
#define PaxTestApp_PaxConstants_h

#pragma mark - Pax Command Types
//// Pax Commands
// Administrative Commands
#define kPaxCommandInitialize @"A00"
#define kPaxCommandGetVariable @"A02"
#define kPaxCommandSetVariable @"A04"
#define kPaxCommandShowDialog @"A06"
#define kPaxCommandGetSignature @"A08"
#define kPaxCommandShowMessage @"A10"
#define kPaxCommandClearMessage @"A12"
#define kPaxCommandCancel @"A14"
#define kPaxCommandReset @"A16"
#define kPaxCommandUpdateImage @"A18"
#define kPaxCommandDoSignature @"A20"
#define kPaxCommandDeleteImage @"A22"
#define kPaxCommandShowImageCenterAligned @"A24"
#define kPaxCommandReboot @"A26"
#define kPaxCommandGetPINBlock @"A28"
#define kPaxCommandInputAccount @"A30"
#define kPaxCommandResetMSR @"A32"
#define kPaxCommandReportStatus @""
#define kPaxCommandInputText @"A36"
#define kPaxCommandCheckFile @"A38"
// Transaction Commands
#define kPaxCommandDoCredit @"T00"
#define kPaxCommandDoDebit @"T02"
#define kPaxCommandDoEBT @"T04"
#define kPaxCommandDoGift @"T06"
#define kPaxCommandDoLoyalty @"T08"
#define kPaxCommandDoCash @"T10"
#define kPaxCommandDoCheck @"T12"
// Batch Commands
#define kPaxCommandBatchClose @"B00"
#define kPaxCommandForceBtachClose @"B02"
#define kPaxCommandBatchClear @"B04"
// Report Commands
#define kPaxCommandLocalTotalReport @"R00"
#define kPaxCommandLocalDetailReport @"R02"
#define kPaxCommandLocalFailedReport @"R04"
#define kPaxCommandHostReport @"R06"
#define kPaxCommandHistoryReport @"R08"
// Sub-Group Information
//#define kPaxCommandAmuontInformation @""
//#define kPaxCommandAccountInformation @""
//#define kPaxCommandCheckInformation @""
//#define kPaxCommandTraceInformation @""
//#define kPaxCommandAVSInformation @""
//#define kPaxCommandCashierInformation @""
//#define kPaxCommandCommercialInformation @""
//#define kPaxCommandECommerceInformation @""
//#define kPaxCommandAdditionalInformation @""

#pragma mark - Pax Control Characters
typedef NS_ENUM(UInt8, PaxControlChar) {
    PaxControlCharSTX = 0x02,
    PaxControlCharETX = 0x03,
    PaxControlCharACK = 0x06,
    PaxControlCharNAK = 0x15,
    PaxControlCharENQ = 0x05,
    PaxControlCharFS  = 0x1C,
    PaxControlCharUS  = 0x1F,
    PaxControlCharGS  = 0x1D,
    PaxControlCharEOT = 0x04,
};

#pragma mark - EDC Types
typedef NS_ENUM(UInt8, EdcType) {
    EdcTypeAll,
    EdcTypeCredit,
    EdcTypeDebit,
    EdcTypeEbt,
    EdcTypeGift,
    EdcTypeLoyalty,
    EdcTypeCash,
    EdcTypeCheck,
};


#pragma mark - CVM Types
typedef NS_ENUM(UInt8, CVMType) {
     FailCVMProcessing = 0,
     PlaintextOfflinePINVerification,
     OnlinePIN,
     PlaintextOfflinePINandSignature,
     EncipheredOfflinePINVerification,
     EncipheredOfflinePINVerificationandSignature,
     Signature,
     NoCVMRequired,
};


#pragma mark - EDC Transaction Types
typedef NS_ENUM(UInt8, EdcTransactionType) {
    EdcTransactionTypeMenu,
    EdcTransactionTypeSaleRedeem,
    EdcTransactionTypeReturn,
    EdcTransactionTypeAuth,
    EdcTransactionTypePostauth,
    EdcTransactionTypeForced,
    EdcTransactionTypeAdjust,
    EdcTransactionTypeWithdrawal,
    EdcTransactionTypeActivate,
    EdcTransactionTypeIssue,
    EdcTransactionTypeAdd,
    EdcTransactionTypeCashout,
    EdcTransactionTypeDeactivate,
    EdcTransactionTypeReplace,
    EdcTransactionTypeMerge,
    EdcTransactionTypeReportlost,
    EdcTransactionTypeVoid,
    EdcTransactionTypeVSale,
    EdcTransactionTypeVRtrn,
    EdcTransactionTypeVAuth,
    EdcTransactionTypeVPost,
    EdcTransactionTypeVFrcd,
    EdcTransactionTypeVWithdraw,
    EdcTransactionTypeBalance,
    EdcTransactionTypeVerify,
    EdcTransactionTypeReactivate,
    EdcTransactionTypeForcedIssue,
    EdcTransactionTypeForcedAdd,
    EdcTransactionTypeUnload,
    EdcTransactionTypeRenew,
    EdcTransactionTypeGetConvertDetail,
    EdcTransactionTypeConvert,
    EdcTransactionTypeReversal = 99,
};

#pragma mark - EDC Card Types
typedef NS_ENUM(UInt8, EdcCardType) {
    EdcCardTypeVisa,
    EdcCardTypeMasterCard,
    EdcCardTypeAMEX,
    EdcCardTypeDiscover,
    EdcCardTypeDinerClub,
    EdcCardTypeenRoute,
    EdcCardTypeJCB,
    EdcCardTypeRevolutionCard,
    EdcCardTypeOther,
};


#pragma mark - PDRequest Enum
typedef NS_ENUM(NSInteger, PDRequest) {
    //
    PDRequestInitialize,
    PDRequestGetVariable,
    PDRequestSetVariable,
    PDRequestShowDialog,
    PDRequestGetSignature,
    PDRequestShowMessage,
    PDRequestClearMessage,
    PDRequestCancel,
    PDRequestReset,
    PDRequestUpdateImage,
    PDRequestDoSignature,
    PDRequestDeleteImage,
    PDRequestShowImageCenterAligned,
    PDRequestReboot,
    PDRequestGetPINBlock,
    PDRequestInputAccount,
    PDRequestResetMSR,
    PDRequestReportStatus,
    PDRequestInputText,
    PDRequestCheckFile,
    // Transaction Commands
    PDRequestDoCredit,
    PDRequestDoDebit,
    PDRequestDoEBT,
    PDRequestDoGift,
    PDRequestDoLoyalty,
    PDRequestDoCash,
    PDRequestDoCheck,
    // Batch Commands
    PDRequestBatchClose,
    PDRequestForceBtachClose,
    PDRequestBatchClear,
    // Report Commands
    PDRequestLocalTotalReport,
    PDRequestLocalDetailReport,
    PDRequestLocalFailedReport,
    PDRequestHostReport,
    PDRequestHistoryReport,
    // Sub-Group Information
//    PDRequestAmuontInformation,
//    PDRequestAccountInformation,
//    PDRequestCheckInformation,
//    PDRequestTraceInformation,
//    PDRequestAVSInformation,
//    PDRequestCashierInformation,
//    PDRequestCommercialInformation,
//    PDRequestECommerceInformation,
//    PDRequestAdditionalInformation,
};

#pragma mark - PDResponse enum
typedef NS_ENUM(NSInteger, PDResponse) {
    //
    PDResponseInitialize,
    PDResponseGetVariable,
    PDResponseSetVariable,
    PDResponseShowDialog,
    PDResponseGetSignature,
    PDResponseShowMessage,
    PDResponseClearMessage,
    PDResponseCancel,
    PDResponseReset,
    PDResponseUpdateImage,
    PDResponseDoSignature,
    PDResponseDeleteImage,
    PDResponseShowImageCenterAligned,
    PDResponseReboot,
    PDResponseGetPINBlock,
    PDResponseInputAccount,
    PDResponseResetMSR,
    PDResponseReportStatus,
    PDResponseInputText,
    PDResponseCheckFile,
    // Transaction Commands
    PDResponseDoCredit,
    PDResponseDoDebit,
    PDResponseDoEBT,
    PDResponseDoGift,
    PDResponseDoLoyalty,
    PDResponseDoCash,
    PDResponseDoCheck,
    // Batch Commands
    PDResponseBatchClose,
    PDResponseForceBtachClose,
    PDResponseBatchClear,
    // Report Commands
    PDResponseLocalTotalReport,
    PDResponseLocalDetailReport,
    PDResponseLocalFailedReport,
    PDResponseHostReport,
    PDResponseHistoryReport,
    // Sub-Group Information
//    PDResponseAmuontInformation,
//    PDResponseAccountInformation,
//    PDResponseCheckInformation,
//    PDResponseTraceInformation,
//    PDResponseAVSInformation,
//    PDResponseCashierInformation,
//    PDResponseCommercialInformation,
//    PDResponseECommerceInformation,
//    PDResponseAdditionalInformation,
};

#pragma mark - Pax Response Code
typedef NS_ENUM(NSUInteger, PaxRespCode) {
    PaxRespCodeOk = 0,
    PaxRespCodeDecline = 100,
    PaxRespCodeTimeout = 100001,
    PaxRespCodeAborted = 100002,

    PaxRespCodeFormatError = 100003,
    PaxRespCodeNoProtocolVersion = PaxRespCodeFormatError,
    PaxRespCodeAmountInvalid = PaxRespCodeFormatError,
    PaxRespCodeTipInvalid = PaxRespCodeFormatError,
    PaxRespCodeCashBackInvalid = PaxRespCodeFormatError,
    PaxRespCodeMerchantFeeInvalid = PaxRespCodeFormatError,
    PaxRespCodeTaxAmountInvalid = PaxRespCodeFormatError,
    PaxRespCodeAcctInvalid = PaxRespCodeFormatError,
    PaxRespCodeExpDateInvalid = PaxRespCodeFormatError,
    PaxRespCodeEbtTypeInvalid = PaxRespCodeFormatError,
    PaxRespCodeVoucherInvalid = PaxRespCodeFormatError,
    PaxRespCodeReferenceInvalid = PaxRespCodeFormatError,
    PaxRespCodeInvoiceInvalid = PaxRespCodeFormatError,
    PaxRespCodeAuthCodeInvalid = PaxRespCodeFormatError,
    PaxRespCodeTransInvalid = PaxRespCodeFormatError,
    PaxRespCodeTimestampInvalid = PaxRespCodeFormatError,
    PaxRespCodeClerkInvalid = PaxRespCodeFormatError,
    PaxRespCodeShiftIdInvalid = PaxRespCodeFormatError,
    PaxRespCodePoNumberInvalidCustomerCodeInvalid = PaxRespCodeFormatError,
    PaxRespCodeTaxReasonInvalidTaxExemptIdInvalid = PaxRespCodeFormatError,
    PaxRespCodeMeModeInvalid = PaxRespCodeFormatError,
    PaxRespCodeMeTypeInvalidSecureTypeInvalidOrderNumberInvalidInstallmentsInvalid = PaxRespCodeFormatError,
    PaxRespCodeCurrentInstInvalid = PaxRespCodeFormatError,
    PaxRespCodeTableNumberInvalid = PaxRespCodeFormatError,
    PaxRespCodeGuestNumberInvalid = PaxRespCodeFormatError,
    PaxRespCodeSignInvalidCheckInvalidTicketNumberInvalidMetypeInvalid = PaxRespCodeFormatError,
    PaxRespCodeTipSwitchClosedCashBackNotAllowedMerchantFeeNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeCommercialNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeEbtTypeNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeTaxNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeTipNotAllowedVocherNotAllowedAuthCodeNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeTransNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeAmountNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeInstallmentsNotNull = PaxRespCodeFormatError,
    PaxRespCodeCurrentinstNotNull = PaxRespCodeFormatError,
    PaxRespCodeMotoArgsConflict = PaxRespCodeFormatError,
    PaxRespCodeSubtransTypeInvalid = PaxRespCodeFormatError,
    PaxRespCodeCheckTypeInvalid = PaxRespCodeFormatError,
    PaxRespCodeIdTypeInvalid = PaxRespCodeFormatError,
    PaxRespCodeDobInvalid = PaxRespCodeFormatError,
    PaxRespCodeDobFormatInvalid = PaxRespCodeFormatError,
    PaxRespCodeTableNumberNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeGuestNumberNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeMotoEcNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeOnlyRetailSupport = PaxRespCodeFormatError,
    PaxRespCodeMerchanTfeeOnlyForCb = PaxRespCodeFormatError,
    PaxRespCodeRegionArgsError = PaxRespCodeFormatError,
    PaxRespCodeEdcOrCardTypeMustExist = PaxRespCodeFormatError,
    PaxRespCodeRefNoMissing = PaxRespCodeFormatError,
    PaxRespCodeCardtypeOnlyForCredit = PaxRespCodeFormatError,
    PaxRespCodeUnsupportCardType = PaxRespCodeFormatError,
    PaxRespCodeIndexInvalid = PaxRespCodeFormatError,
    PaxRespCodeNoTransAvailable = PaxRespCodeFormatError,
    PaxRespCodeEbtInfoInvalid = PaxRespCodeFormatError,
    PaxRespCodeHostDenied = PaxRespCodeFormatError,
    PaxRespCodeCvvInvalid = PaxRespCodeFormatError,
    PaxRespCodeZipCodeInvalid = PaxRespCodeFormatError,
    PaxRespCodeAddressInvalid = PaxRespCodeFormatError,
    PaxRespCodeCvvNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeZipCodeNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeAddressNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeEdcMissing = PaxRespCodeFormatError,
    PaxRespCodeSignNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeAmountTooLarge = PaxRespCodeFormatError,
    PaxRespCodeInvalidOverride = PaxRespCodeFormatError,
    PaxRespCodePoNumberNotSupport = PaxRespCodeFormatError,
    PaxRespCodeTaxExemptIdNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeCustomerCodeNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeTaxReasonNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeTicketNumberNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeTransTypeNull = PaxRespCodeFormatError,
    PaxRespCodeSecureTypeNotSupport = PaxRespCodeFormatError,
    PaxRespCodeSignatureFileNotExist = PaxRespCodeFormatError,
    PaxRespCodeRequestlenInvalid = PaxRespCodeFormatError,
    PaxRespCodeOffsizeInvalid = PaxRespCodeFormatError,
    PaxRespCodeSignflagInvalid = PaxRespCodeFormatError,
    PaxRespCodeUnsupportSignature = PaxRespCodeFormatError,
    PaxRespCodeClerkidInvalid = PaxRespCodeFormatError,
    PaxRespCodeMotoEcInfoNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeOverrideNotAllowed = PaxRespCodeFormatError,
    PaxRespCodeDupCheckInvalid = PaxRespCodeFormatError,
    PaxRespCodeRoutingNumberInvalid = PaxRespCodeFormatError,
    PaxRespCodeCheckNumberInvalid = PaxRespCodeFormatError,
    PaxRespCodeCheckidInvalid = PaxRespCodeFormatError,
    PaxRespCodePhoneNumberInvalid = PaxRespCodeFormatError,
    PaxRespCodeSubTransTypeInvalid = PaxRespCodeFormatError,
    PaxRespCodePleaseSpecifyEbtType = PaxRespCodeFormatError,
    PaxRespCodeAlreadyAdded = PaxRespCodeFormatError,
    PaxRespCodePleaseDoFailedReport = PaxRespCodeFormatError,
    PaxRespCodeOffsetInvalid = PaxRespCodeFormatError,
    PaxRespCodeFlagInvalid = PaxRespCodeFormatError,
    PaxRespCodeUploadFlagInvalid = PaxRespCodeFormatError,
    PaxRespCodeRefNumberInvalid = PaxRespCodeFormatError,
    PaxRespCodeNoRefNumber = PaxRespCodeFormatError,
    PaxRespCodeTimeoutInvalid = PaxRespCodeFormatError,
    PaxRespCodeImageNameInvalid = PaxRespCodeFormatError,
    PaxRespCodeNoImageName = PaxRespCodeFormatError,
    PaxRespCodeDeleteFailed = PaxRespCodeFormatError,
    PaxRespCodeNoTimeout = PaxRespCodeFormatError,
    PaxRespCodeNoEdcType = PaxRespCodeFormatError,
    PaxRespCodeEdcTypeInvalid = PaxRespCodeFormatError,
    PaxRespCodeNoUploadFlag = PaxRespCodeFormatError,
    PaxRespCodeDataInvalid = PaxRespCodeFormatError,
    PaxRespCodeNoOffset = PaxRespCodeFormatError,
    PaxRespCodeInstallFailed = PaxRespCodeFormatError,
    PaxRespCodeImageNotFound = PaxRespCodeFormatError,
    PaxRespCodeNoFlag = PaxRespCodeFormatError,
    PaxRespCodeTipRequestFlagInvalid = PaxRespCodeFormatError,
    PaxRespCodeCardTypeDisabled = PaxRespCodeFormatError,
    PaxRespCodeExpDateMissing = PaxRespCodeFormatError,
    PaxRespCodeMeModeNotSupport = PaxRespCodeFormatError,
    PaxRespCodeAccountMismatch = PaxRespCodeFormatError,
    PaxRespCodeUnsupportInDemo = PaxRespCodeFormatError,
    PaxRespCodeExpDateNotAllowed = PaxRespCodeFormatError,
    PaxRespCodePlzVoidAddtip = PaxRespCodeFormatError,

    PaxRespCodeUnsupportTrans = 100004,
    PaxRespCodeUnsupportEdc = 100005,
    PaxRespCodeBatchFailed = 100006,
    PaxRespCodeConnectError = 100007,
    PaxRespCodeSendError = 100008,
    PaxRespCodeReceiveError = 100009,
    PaxRespCodeCommError = 100010,
    PaxRespCodeDupTransaction = 100011,
    PaxRespCodeGetVarError = 100012,

    PaxRespCodeSetVarError = 100013,
    PaxRespCodeInvalidVarValue = PaxRespCodeSetVarError,
    PaxRespCodePleaseSetVar = PaxRespCodeSetVarError,

    PaxRespCodeInvalidDataEntry = 100014,
    PaxRespCodeCvvError = 100015,
    PaxRespCodeAvsError = 100016,
    PaxRespCodeHaloExceed = 100017,
    PaxRespCodeSwipeOnly = 100018,

    PaxRespCodeTrackInvalid = 100019,
    PaxRespCodeSwipeError = PaxRespCodeTrackInvalid,

    PaxRespCodeCannotAdjust = 100020,

    PaxRespCodeAlreadyVoided = 100021,
    PaxRespCodeAlreadyCompl = PaxRespCodeAlreadyVoided,

    PaxRespCodePinpadError = 100022,

    PaxRespCodeUnknowError = 100023,
    PaxRespCodeNotFound = PaxRespCodeUnknowError,
    PaxRespCodeUserAborted = PaxRespCodeUnknowError,
    PaxRespCodeCannotVoid = PaxRespCodeUnknowError,

    PaxRespCodeNoHostApp = 100024,
    PaxRespCodePleaseSettle = 100025,
    PaxRespCodeUnsupportCommand = 100027,
    PaxRespCodeTaxExceedAmt = 100028,
    PaxRespCodeTerminalError = 199999,

};


#pragma mark - Field Index
typedef NS_ENUM(NSInteger, FieldIndex) {
    FieldIndexMultiPacket,
    FieldIndexCommandType,
    FieldIndexVersion,
    FieldIndexResponseCode,
    FieldIndexResponseMessage,
    
    // Command Specific field Index
    // First field of the command specific data
    // should have this index (FieldIndexCommandSpecificFields).
    //
    // E.g.;
    // FieldIndexHostInformation = FieldIndexCommandSpecificFields,
    FieldIndexCommandSpecificFields,
    
    
    // Initialize
    FieldIndexSerialNumber = FieldIndexCommandSpecificFields,

    // Initialize
    FieldIndexVariableValue = FieldIndexCommandSpecificFields,
    
    // Get Signature
    FieldIndexSignatureTotalLength = FieldIndexCommandSpecificFields,
    FieldIndexSignatureResponseLength,
    FieldIndexSignature,

    // Do Credit
    FieldIndexHostInformation = FieldIndexCommandSpecificFields,
    FieldIndexTransactionType,
    FieldIndexAmountInformation,
    FieldIndexAccountInformation,
    FieldIndexTraceInformation,
    FieldIndexAvsInformation,
    FieldIndexCommercialInformation,
    FieldIndexMotoECommerceInformation,
    FieldIndexAdditionalInformation,

    // Batch Close
    FieldIndexBCHostInformation = FieldIndexCommandSpecificFields,
    FieldIndexTotalCount,
    FieldIndexTotalAmount,
    FieldIndexTimeStamp,
    FieldIndexLineNumber,
    FieldIndexLineMessage,
    
    
    // Host Report
    FieldIndexHostReportLineNumber,
    FieldIndexHostReportLineMessage,
    FieldIndexHostReportType,
    FieldIndexHostTimeStamp,
    
    FieldIndexHistoryReportTotalCount,
    FieldIndexHistoryReportTotalAmount,
    FieldIndexHistoryReportTimeStamp,
    FieldIndexHistoryReportBatchNumber,
    
    FieldIndexLocalTotalReportEDCType,
    FieldIndexLocalTotalReportTotalData,
    
    

    /// Local Detail Report Response
    FieldIndexLocalDetailReportTotalRecord,
    FieldIndexLocalDetailRecordNumber,
    FieldIndexLocalDetailTransactionType,
    FieldIndexLocalDetailOriginalTransactionType,
    FieldIndexLocalDetailCashierInformation,
    FieldIndexLocalDetailCheckInformation
    
};


#pragma mark - Field Unit Index
typedef NS_ENUM(NSInteger, FieldUnitIndex) {
    // Initialize - Serial Number
    FieldUnitIndexSerialNumber = 0,

    // Host Information
    FieldUnitIndexHostResponseCode = 0,
    FieldUnitIndexHostResponseMessage,
    FieldUnitIndexAuthCode,
    FieldUnitIndexHostReferenceNumber,
    FieldUnitIndexTraceNumber,
    FieldUnitIndexBatchNumber,
    
    //
//    FieldUnitIndex,
//    FieldUnitIndex,
//    FieldUnitIndex,
};

#pragma mark - Field Unit Index
typedef NS_ENUM(NSInteger, CardType) {
    // Initialize - Serial Number
    VisaCard = 01,
    MasterCard = 02,
    AMEX = 03,
    Discover = 04,
    DinerClub = 05,
    enRoute = 06,
    JCB = 07,
    RevolutionCard = 8,
    OTHER = 99
};
typedef NS_ENUM(NSInteger, EntryMode) {
    // Initialize - Serial Number
    Manual = 0,
    Swipe = 1,
    Contactless = 2,
    Scanner = 3,
    Chip = 4,
    ChipFallBackSwipe = 5,
};
#endif
