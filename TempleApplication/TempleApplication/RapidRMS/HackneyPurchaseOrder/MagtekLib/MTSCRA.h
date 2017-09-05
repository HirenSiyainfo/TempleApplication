//
//  MTSCRA.h
//  MTSCRA
//
//  Created by Imran Jahanzeb on 1/31/12.
//  Copyright (c) 2012 MagTek. All rights reserved.
//ƒ
//
//  MTSCRA.h
//  MTSCRA
//
//  Created by Imran Jahanzeb on 1/23/12.
//  Copyright (c) 2012 MagTek. All rights reserved.
//

//#import <Foundation/Foundation.h>

//@interface MTSCRA : NSObject
//  Copyright 2011 MagTek. All rights reserved.
//

#import <AudioUnit/AudioUnit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <ExternalAccessory/ExternalAccessory.h>
//#import "MTCardData.h"
#import "AVFoundation/AVAudioSession.h"


#warning Notification method will be deprecated on next release, please use delegate
//#define _DBGPRNT


@class IMTSCRAData;
@class MTSCRADevice;

typedef NS_ENUM(NSUInteger, MTSCRATransactionData)
{
    TLV_OPSTS,
    TLV_CARDSTS,
    TLV_TRACKSTS,
    
    TLV_CARDNAME,
    TLV_CARDIIN,
    TLV_CARDLAST4,
    TLV_CARDEXPDATE,
    TLV_CARDSVCCODE,
    TLV_CARDPANLEN,
    
    TLV_ENCTK1,
    TLV_ENCTK2,
    TLV_ENCTK3,
    
    TLV_DEVSN,
    TLV_DEVSNMAGTEK,
    TLV_DEVFW,
    TLV_DEVNAME,
    TLV_DEVCAPS,
    TLV_DEVSTATUS,
    TLV_TLVVERSION,
    TLV_DEVPARTNUMBER,
    TLV_CAPMSR,
    TLV_CAPTRACKS,
    TLV_CAPMAGSTRIPEENCRYPTION,
    TLV_KSN,
    TLV_CMAC,
    TLV_SWPCOUNT,
    TLV_BATTLEVEL,
    TLV_CFGTLVVERSION,
    TLV_CFGDISCOVERY,
    TLV_CFGCARDNAME,
    TLV_CFGCARDIIN,
    TLV_CFGCARDLAST4,
    TLV_CFGCARDEXPDATE,
    TLV_CFGCARDSVCCODE,
    TLV_CFGCARDPANLEN,
    TLV_MSKTK1,
    TLV_MSKTK2,
    TLV_MSKTK3,
    TLV_HASHCODE,
    TLV_SESSIONID,
    TLV_MAGNEPRINT,
    TLV_MAGNEPRINT_STS
    
};

typedef NS_ENUM(NSUInteger, MTSCRATransactionStatus)
{
	TRANS_STATUS_OK,
    TRANS_STATUS_START,
    TRANS_STATUS_ERROR
};


typedef NS_OPTIONS(NSUInteger, MTSCRATransactionEvent)
{
	TRANS_EVENT_OK = 1,
    TRANS_EVENT_ERROR=2,
    TRANS_EVENT_START = 4,
    
};

typedef NS_OPTIONS(NSUInteger, MTSCRACapabilities)
{
	CAP_MASKING = 1,
    CAP_ENCRYPTION=2,
    CAP_CARD_AUTH = 4,
    CAP_DEVICE_AUTH = 8,
    CAP_SESSION_ID = 16,
    CAP_DISCOVERY= 32,
};

typedef NS_ENUM(NSUInteger, MTSCRADeviceType)
{
    MAGTEKAUDIOREADER,
    MAGTEKIDYNAMO,
    MAGTEKDYNAMAX,
    MAGTEKNONE
    
};

enum
{
    OK,
    UNSUPPORTED
    
};
typedef int MTSCRABLEState;

//enum
//{
//    MASKED_TRACKDATA,
//    DEVICE_ENCRYPTION_STATUS,
//    ENCRYPTED_TRACK1,
//    ENCRYPTED_TRACK2,
//    ENCRYPTED_TRACK3,
//    MAGNEPRINT_STATUS,
//    ENCRYPTED_MAGNEPRINT,
//    DEVICE_SERIALNUMBER,
//    ENCRYPTED_SESSIONID,
//    DEVICE_KSN
//};
//typedef NSUInteger MTSCRACardDataContent;

@interface MTCardData : NSObject
{
    
}

@property(nonatomic, strong) NSString *cardIIN;
@property(nonatomic, strong) NSString *cardData;
@property(nonatomic, strong) NSString *cardLast4;
@property(nonatomic, strong) NSString *cardName;
@property(nonatomic, strong) NSString *cardExpDate;
@property(nonatomic, strong) NSString *cardServiceCode;
@property(nonatomic, strong) NSString *cardStatus;
@property(nonatomic, strong) NSString *responseData;
@property(nonatomic, strong) NSString *maskedTracks;
@property(nonatomic, strong) NSString *encryptedTrack1;
@property(nonatomic, strong) NSString *encryptedTrack2;
@property(nonatomic, strong) NSString *encryptedTrack3;
@property(nonatomic, strong) NSString *encryptionStatus;
@property(nonatomic, strong) NSString *maskedTrack1;
@property(nonatomic, strong) NSString *maskedTrack2;
@property(nonatomic, strong) NSString *maskedTrack3;
@property(nonatomic, strong) NSString *trackDecodeStatus;
@property(nonatomic, strong) NSString *encryptedMagneprint;
@property(nonatomic, strong) NSString *magneprintStatus;
@property(nonatomic, strong) NSString *deviceSerialNumber;
@property(nonatomic, strong) NSString *deviceSerialNumberMagTek;
@property(nonatomic, strong) NSString *encrypedSessionID;
@property(nonatomic, strong) NSString *deviceKSN;
@property(nonatomic, strong) NSString *deviceFirmware;
@property(nonatomic, strong) NSString *deviceName;
@property(nonatomic, strong) NSString *deviceCaps;
@property(nonatomic, strong) NSString *deviceStatus;
@property(nonatomic, strong) NSString *tlvVersion;
@property(nonatomic, strong) NSString *devicePartNumber;
@property(nonatomic, strong) NSString *capMSR;
@property(nonatomic, strong) NSString *capTracks;
@property(nonatomic, strong) NSString *capMagStripeEncryption;
@property(nonatomic, strong) NSString *maskedPAN;
@property(nonatomic) long cardPANLength;
@property(nonatomic, strong) NSString *additionalInfoTrack1;
@property(nonatomic, strong) NSString *additionalInfoTrack2;
@property(nonatomic, strong) NSString *responseType;
@property(nonatomic) long batteryLevel;
@property(nonatomic) long swipeCount;
@property(nonatomic, strong) NSString *firmware;
@property(nonatomic, strong) NSString *tagValue;
@property(nonatomic) int magnePrintLength;
@property(nonatomic, strong) NSString *cardExpDateMonth;
@property(nonatomic, strong) NSString *cardExpDateYear;
@property(nonatomic, strong) NSString *cardPAN;
@property(nonatomic, strong) NSString *track1DecodeStatus;
@property(nonatomic, strong) NSString *track2DecodeStatus;
@property(nonatomic, strong) NSString *track3DecodeStatus;
@end


@protocol MTSCRAEventDelegate <NSObject>
@optional
- (void) onDataRecieved: (MTCardData*)cardDataObj instance:(id)instance;
- (void) cardSwipeDidStart:(id)instance;
- (void) cardSwipeDidGetTransError;
- (void) onDeviceConnectionDidChange:(MTSCRADeviceType)deviceType connected:(BOOL) connected instance:(id)instance;
- (void) bleReaderConnected:(CBPeripheral*)peripheral;
- (void) bleReaderDidDiscoverPeripheral;
- (void) bleReaderStateUpdated:(MTSCRABLEState)state;

//- (void) sendDataForEmail:(NSData*) data;

@end


@interface MTSCRA : NSObject <NSStreamDelegate>
{
@private
    
	NSString *cardIIN;
	NSString *cardData;
	NSString *cardLast4;
	NSString *cardName;
	NSString *cardExpDate;
	NSString *cardServiceCode;
	NSString *cardStatus;
	NSString *responseData;
	NSString *maskedTracks;
    NSString *stdTrack1;
    NSString *stdTrack2;
    NSString *stdTrack3;
    NSString *encryptedTrack1;
    NSString *encryptedTrack2;
    NSString *encryptedTrack3;
    NSString *encryptionStatus;
    NSString *maskedTrack1;
    NSString *maskedTrack2;
    NSString *maskedTrack3;
	NSString *trackDecodeStatus;
    NSString *encryptedMagneprint;
    NSString *magneprintStatus;
    NSString *deviceSerialNumber;
    NSString *deviceSerialNumberMagTek;
    NSString *encrypedSessionID;
    NSString *deviceKSN;
    NSString *deviceFirmware;
    NSString *deviceName;
    NSString *deviceCaps;
    NSString *deviceStatus;
    NSString *tlvVersion;
    NSString *devicePartNumber;
    NSString *capMSR;
    NSString *capTracks;
    NSString *capMagStripeEncryption;
    NSString *maskedPAN;
    NSString *additionalInfoTrack1;
    NSString *additionalInfoTrack2;
    NSString *responseType;
	NSString *batteryLevel;
	NSString *swipeCount;
	
    AudioUnit					rioUnit;
    AURenderCallbackStruct		inputProc;
    
    AudioStreamBasicDescription	thruFormat;
    AudioBufferList             bufferlist;
    AudioBuffer                 buf;
    AudioBuffer                 buf1;
    BOOL                        isDeviceConnected;
    long eventMask;
    long devCapabilities;
    
    Byte *commandBits;
    int commandBitsIndex;
    
    EAAccessory * _accessory;
	EASession *   _session;
	EAAccessoryManager *eaAccessory;
    NSMutableString *dataFromiDynamo;
	NSMutableString *deviceProtocolString;
	NSMutableString *configParams;
    
    AVAudioSession *audioSession;
    
    MTSCRADeviceType devType;
    //MTCardData* cardDataObj;
}


void audioReaderDelegate(void*self, int status);

//Initialize device
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL openDevice;

//Close device
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL closeDevice;

//Retrieves if the device is connected
@property (NS_NONATOMIC_IOSONLY, getter=isDeviceConnected, readonly) BOOL deviceConnected;

//Retrieve Masked Track1 if any
@property (NS_NONATOMIC_IOSONLY, getter=getTrack1Masked, readonly, copy) NSString *track1Masked;

//Retrieve Masked Track2 if any
@property (NS_NONATOMIC_IOSONLY, getter=getTrack2Masked, readonly, copy) NSString *track2Masked;

//Retrieve Masked Track3 if any
@property (NS_NONATOMIC_IOSONLY, getter=getTrack3Masked, readonly, copy) NSString *track3Masked;

//Retrieves existing stored Masked data, only supported for iDynamo, it will return a empty string in audio reader
@property (NS_NONATOMIC_IOSONLY, getter=getMaskedTracks, readonly, copy) NSString *maskedTracks;

//Retrieve Encrypted Track1 if any
@property (NS_NONATOMIC_IOSONLY, getter=getTrack1, readonly, copy) NSString *track1;

//Retrieve Encrypted Track2 if any
@property (NS_NONATOMIC_IOSONLY, getter=getTrack2, readonly, copy) NSString *track2;

//Retrieve Encrypted Track3 if any
@property (NS_NONATOMIC_IOSONLY, getter=getTrack3, readonly, copy) NSString *track3;

//Retrieve Encrypted MagnePrint, only supported for iDynamo, it will return a empty string in audio reader
@property (NS_NONATOMIC_IOSONLY, getter=getMagnePrint, readonly, copy) NSString *magnePrint;

//Retrieve MagnePrint Status, only supported for iDynamo, it will return a empty string in audio reader
@property (NS_NONATOMIC_IOSONLY, getter=getMagnePrintStatus, readonly, copy) NSString *magnePrintStatus;

//Retrieve Device Serial Number
@property (NS_NONATOMIC_IOSONLY, getter=getDeviceSerial, readonly, copy) NSString *deviceSerial;

//Retrieve Device Serial Number created by MagTek
@property (NS_NONATOMIC_IOSONLY, getter=getMagTekDeviceSerial, readonly, copy) NSString *magTekDeviceSerial;

//Retrieve Firmware Vsersion Number
@property (NS_NONATOMIC_IOSONLY, getter=getFirmware, readonly, copy) NSString *firmware;

//Retrieve Device Name
@property (NS_NONATOMIC_IOSONLY, getter=getDeviceName, readonly, copy) NSString *deviceName;

//Retrieve Device Capabilities
@property (NS_NONATOMIC_IOSONLY, getter=getDeviceCaps, readonly, copy) NSString *deviceCaps;

//Retrieve Device Status
@property (NS_NONATOMIC_IOSONLY, getter=getDeviceStatus, readonly, copy) NSString *deviceStatus;

//Retrieve TLV Version
@property (NS_NONATOMIC_IOSONLY, getter=getTLVVersion, readonly, copy) NSString *TLVVersion;

//Retrieve Device Part Number
@property (NS_NONATOMIC_IOSONLY, getter=getDevicePartNumber, readonly, copy) NSString *devicePartNumber;

//Retrieve Key Serial Number
@property (NS_NONATOMIC_IOSONLY, getter=getKSN, readonly, copy) NSString *KSN;

//Retrieve individual tag value, only supported in audio reader
- (NSString *) getTagValue: (UInt32)tag;

//Retrieve MSR Capability
@property (NS_NONATOMIC_IOSONLY, getter=getCapMSR, readonly, copy) NSString *capMSR;

//Retrieve Tracks Capability
@property (NS_NONATOMIC_IOSONLY, getter=getCapTracks, readonly, copy) NSString *capTracks;

//Retrieve MagStripe Encryption Capability
@property (NS_NONATOMIC_IOSONLY, getter=getCapMagStripeEncryption, readonly, copy) NSString *capMagStripeEncryption;

@property (NS_NONATOMIC_IOSONLY, getter=getMagnePrintLength, readonly) int magnePrintLength;

//Send Commands To The Device

- (void) sendCommandToDevice:(NSString *)pData __attribute__((deprecated))  __deprecated_msg("use sendcommandWithLength instead.");

- (void) sendcommandWithLength:(NSString *)command;

//Sets the protocol String for iDynamo
- (void) setDeviceProtocolString:(NSString *)pData;
//Sets the config params for SDK
- (void) setConfigurationParams:(NSString *)pData;

//Setup the events to listen for
- (void) listenForEvents:(UInt32)event;

//Retrieves the Device Type
- (long) getDeviceType;


//Retrieve card PAN
@property (NS_NONATOMIC_IOSONLY, getter=getCardPAN, readonly, copy) NSString *cardPAN;

//Retrieves the Length of teh PAN
@property (NS_NONATOMIC_IOSONLY, getter=getCardPANLength, readonly) int cardPANLength;

//Retrieve Session ID, only supported for iDynamo, it will return a empty string in audio reader
@property (NS_NONATOMIC_IOSONLY, getter=getSessionID, readonly, copy) NSString *sessionID;

//Retrieved the whole Response from the reader
@property (NS_NONATOMIC_IOSONLY, getter=getResponseData, readonly, copy) NSString *responseData;

//Retrieves the Name in the Card
@property (NS_NONATOMIC_IOSONLY, getter=getCardName, readonly, copy) NSString *cardName;

//Retrieves the IIN in the Card
@property (NS_NONATOMIC_IOSONLY, getter=getCardIIN, readonly, copy) NSString *cardIIN;

//Retrieves the Last 4 of the PAN
@property (NS_NONATOMIC_IOSONLY, getter=getCardLast4, readonly, copy) NSString *cardLast4;

//Retrieves the Expiration Date
@property (NS_NONATOMIC_IOSONLY, getter=getCardExpDate, readonly, copy) NSString *cardExpDate;

@property (NS_NONATOMIC_IOSONLY, getter=getExpDateMonth, readonly, copy) NSString *expDateMonth;

@property (NS_NONATOMIC_IOSONLY, getter=getExpDateYear, readonly, copy) NSString *expDateYear;

//Retrieves the Service Code
@property (NS_NONATOMIC_IOSONLY, getter=getCardServiceCode, readonly, copy) NSString *cardServiceCode;

//Retrieves the Card Status
@property (NS_NONATOMIC_IOSONLY, getter=getCardStatus, readonly, copy) NSString *cardStatus;

//Retrieves the Track Decode Status
@property (NS_NONATOMIC_IOSONLY, getter=getTrackDecodeStatus, readonly, copy) NSString *trackDecodeStatus;

@property (NS_NONATOMIC_IOSONLY, getter=getTrack1DecodeStatus, readonly, copy) NSString *track1DecodeStatus;
@property (NS_NONATOMIC_IOSONLY, getter=getTrack2DecodeStatus, readonly, copy) NSString *track2DecodeStatus;
@property (NS_NONATOMIC_IOSONLY, getter=getTrack3DecodeStatus, readonly, copy) NSString *track3DecodeStatus;

//Retrieve Response Type
@property (NS_NONATOMIC_IOSONLY, getter=getResponseType, readonly, copy) NSString *responseType;

//Sets the type of device to Open
-(void) setDeviceType: (UInt32)deviceType;

//Retrieves device opened status
@property (NS_NONATOMIC_IOSONLY, getter=isDeviceOpened, readonly) BOOL deviceOpened;

// Clears all the buffer that is stored during card swipe or command response
- (void) clearBuffers;

//Retrieves the battery Level
@property (NS_NONATOMIC_IOSONLY, getter=getBatteryLevel, readonly) long batteryLevel;

//Retrieves the swipe count
@property (NS_NONATOMIC_IOSONLY, getter=getSwipeCount, readonly) long swipeCount;

//Gets the current version of the SDK.
@property (NS_NONATOMIC_IOSONLY, getter=getSDKVersion, readonly, copy) NSString *SDKVersion;

//Retrieves the Operation Status
@property (NS_NONATOMIC_IOSONLY, getter=getOperationStatus, readonly, copy) NSString *operationStatus;

//Config Functions
@property (NS_NONATOMIC_IOSONLY, getter=getEncryptionStatus, readonly, copy) NSString *encryptionStatus;

// Stops scanning for surrounding Peripherals
- (void)stopScanningForPeripherals;

// Starts scanning for surrounding Peripherals
- (void)startScanningForPeripherals;

// Sets the UUID String
- (void)setUUIDString:(NSString *)uuidString;

// Retrieves the currently connected Peripheral
@property (NS_NONATOMIC_IOSONLY, getter=getConnectedPeripheral, readonly, copy) CBPeripheral *connectedPeripheral;

// Retrieves the list of Peripherals that are in range and can be connected to
@property (NS_NONATOMIC_IOSONLY, getter=getDiscoveredPeripherals, readonly, copy) NSMutableArray *discoveredPeripherals;

@property (nonatomic, weak) id <MTSCRAEventDelegate> delegate;


@property (NS_NONATOMIC_IOSONLY, getter=getDeviceInformationDictionary, readonly, copy) NSDictionary *deviceInformationDictionary;

@end