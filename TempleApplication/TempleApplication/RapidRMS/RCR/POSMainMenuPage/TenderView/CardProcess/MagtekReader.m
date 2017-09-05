//
//  MagtekReader.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/4/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "MagtekReader.h"
#import "RcrController.h"
#import "MTSCRA.h"
#import "MediaPlayer/MPMusicPlayerController.h"
#define PROTOCOLSTRING @"com.magtek.idynamo"
#define _DGBPRNT

@interface MagtekReader()
{
    
}
//@property (readonly, weak, nonatomic) id<RmsCardReaderDelegate> rmsCardReaderDelegate;
@property (nonatomic, retain) MTSCRA *magtekReader;
@property (nonatomic, strong) RcrController *crmController;
@end

@implementation MagtekReader
- (instancetype)initWithDelegate:(id<RmsCardReaderDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self) {
//        _magTechReaderDelegate = delegate;
        [self setupMagtekReader];
    }
    return self;
}
-(void)setupMagtekReader
{
    
    self.crmController = [RcrController sharedCrmController];
    
    self.magtekReader = [[MTSCRA alloc] init];
    [self.magtekReader listenForEvents:(TRANS_EVENT_START|TRANS_EVENT_OK|TRANS_EVENT_ERROR)];
    
    // Register notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackDataReady:)
                                                 name:@"trackDataReadyNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devConnStatusChange)
                                                 name:@"devConnectionNotification" object:nil];
    
    
    int cardReaderOption = [self getCardReaderOption];
    if(cardReaderOption==8)
    {
         [self.magtekReader setDeviceType:MAGTEKIDYNAMO];
    }
    else if(cardReaderOption==9){
        
         [self.magtekReader setDeviceType:MAGTEKAUDIOREADER];
    }
    else{
         [self.magtekReader setDeviceType:MAGTEKIDYNAMO];
    }
    [self openDevice];
    
}

-(int)getCardReaderOption{

    int intcoptin=0;
    
    for(int i = 0;i<self.crmController.globalArrTenderConfig.count;i++)
    {
       
        if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"] intValue ] == 8 || [[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"] intValue ] == 9 )
        {
           intcoptin= [[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"] intValue];
            break;
        }
    
    }
    return intcoptin;
}
#pragma mark -
#pragma mark Post Notification Selector Methods
#pragma mark -

- (void)trackDataReady:(NSNotification *)notification
{
    NSNumber *status = [notification.userInfo valueForKey:@"status"];
    
    [self performSelectorOnMainThread:@selector(onDataEvent:) withObject:status waitUntilDone:NO];
}

- (void)devConnStatusChange 
{
#ifdef _DGBPRNT
    NSLog(@"******* devConnStatusChange *******");
#endif
    
    // Ensure that updateConnStatus is performed on the Main Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self updateConnStatus];
        
    });
}

// Method For Check The Device Status

- (void)updateConnStatus
{
#ifdef _DGBPRNT
    NSLog(@"updateConnStatus");
#endif
    BOOL isDeviceOpened    = self.magtekReader.deviceOpened;
    BOOL isDeviceConnected = self.magtekReader.deviceConnected;
    
    if(isDeviceConnected)
    {
        if(isDeviceOpened)
        {
            [self.rmsCardReaderDelegate didConnectToReaderDevice:@"Magtek"];
        }
        else
        {
            [self.rmsCardReaderDelegate didDisconnectFromReaderDevice:@"Magtek"];
        }
    }
    else
    {
        [self.rmsCardReaderDelegate didDisconnectFromReaderDevice:@"Magtek"];
    }
}



#pragma mark -
#pragma mark Helper Methods
#pragma mark -
// Methods For Open and Close The Device
- (void)openDevice
{
    [self.magtekReader setDeviceProtocolString:(PROTOCOLSTRING)];
    
    if(!self.magtekReader.deviceOpened)
    {
        [self.magtekReader openDevice];
    }
    [self updateConnStatus];
}

- (void)closeDevice
{
    //Remove Notification
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"trackDataReadyNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"devConnectionNotification" object:nil];

    if(self.magtekReader.deviceOpened)
    {
        [self.magtekReader closeDevice];
    }
    
    [self.magtekReader clearBuffers];
    
    [self updateConnStatus];
}

#pragma mark -
#pragma mark Post Notification Selector Helper Methods
#pragma mark -

- (void)onDataEvent:(id)status
{
    NSLog(@"onDataEvent");
	switch ([status intValue])
    {
        case TRANS_STATUS_OK:
            
            NSLog(@"TRANS_STATUS_OK");
            
            [self fetchDataFromCard];
            break;
        case TRANS_STATUS_START:
            
            NSLog(@"TRANS_STATUS_START");
            break;
        case TRANS_STATUS_ERROR:
            if(self.magtekReader != NULL)
            {
                NSLog(@"TRANS_STATUS_ERROR");
                [self updateConnStatus];
            }
            break;
        default:
            break;
    }
}


//Method for fetch the data....

- (void)fetchDataFromCard
{
    if(self.magtekReader != NULL)
    {
        if([self.magtekReader getDeviceType] == MAGTEKAUDIOREADER)
        {
            NSString *pResponse = [NSString stringWithFormat:@"Response.Type: %@\n"
                                   "Track.Status: %@\n"
                                   "Card.Status: %@\n"
                                   "Encryption.Status: %@\n"
                                   "Battery.Level: %ld\n"
                                   "Swipe.Count: %ld\n"
                                   "Track.Masked: %@\n"
                                   "Track1.Masked: %@\n"
                                   "Track2.Masked: %@\n"
                                   "Track3.Masked: %@\n"
                                   "Track1.Encrypted: %@\n"
                                   "Track2.Encrypted: %@\n"
                                   "Track3.Encrypted: %@\n"
                                   "MagnePrint.Encrypted: %@\n"
                                   "MagnePrint.Status: %@\n"
                                   "SessionID: %@\n"
                                   "Card.IIN: %@\n"
                                   "Card.Name: %@\n"
                                   "Card.Last4: %@\n"
                                   "Card.ExpDate: %@\n"
                                   "Card.SvcCode: %@\n"
                                   "Card.PANLength: %d\n"
                                   "KSN: %@\n"
                                   "Device.SerialNumber: %@\n"
                                   "TLV.CARDIIN: %@\n"
                                   "MagTek SN: %@\n"
                                   "Firmware Part Number: %@\n"
                                   "TLV Version: %@\n"
                                   "Device Model Name: %@\n"
                                   "Capability MSR: %@\n"
                                   "Capability Tracks: %@\n"
                                   "Capability Encryption: %@\n",
                                   self.magtekReader.responseType,
                                   self.magtekReader.trackDecodeStatus,
                                   self.magtekReader.cardStatus,
                                   self.magtekReader.encryptionStatus,
                                   self.magtekReader.batteryLevel,
                                   self.magtekReader.swipeCount,
                                   self.magtekReader.maskedTracks,
                                   self.magtekReader.track1Masked,
                                   self.magtekReader.track2Masked,
                                   self.magtekReader.track3Masked,
                                   self.magtekReader.track1,
                                   self.magtekReader.track2,
                                   self.magtekReader.track3,
                                   self.magtekReader.magnePrint,
                                   self.magtekReader.magnePrintStatus,
                                   self.magtekReader.sessionID,
                                   self.magtekReader.cardIIN,
                                   self.magtekReader.cardName,
                                   self.magtekReader.cardLast4,
                                   self.magtekReader.cardExpDate,
                                   self.magtekReader.cardServiceCode,
                                   self.magtekReader.cardPANLength,
                                   self.magtekReader.KSN,
                                   self.magtekReader.deviceSerial,
                                   [self.magtekReader getTagValue:TLV_CARDIIN],
                                   self.magtekReader.magTekDeviceSerial,
                                   self.magtekReader.firmware,
                                   self.magtekReader.TLVVersion,
                                   self.magtekReader.deviceName,
                                   self.magtekReader.capMSR,
                                   self.magtekReader.capTracks,
                                   self.magtekReader.capMagStripeEncryption];
            
            NSLog(@"pResponse : %@ ",pResponse);
            
            if([self.magtekReader.track2 isEqualToString:@";E?"] || [self.magtekReader.track1 isEqualToString:@"%E?"])
            {
                [self.rmsCardReaderDelegate didFailToRetriveCardData];
            }
            else
            {
                NSString *sendData = [NSString stringWithFormat:@"<SecurityInfo>%@</SecurityInfo><Track1>%@</Track1><Track2>%@</Track2><SecureFormat>MagneSafeV1</SecureFormat>",self.magtekReader.KSN,self.magtekReader.track1,self.magtekReader.track2];
                
                NSLog(@"Credit Card track 1 %@ ",self.magtekReader.track1);
                NSLog(@"Credit Card track 2 %@ ",self.magtekReader.track2);
                NSLog(@"Credit Card tract 3 %@ ", self.magtekReader.track3);
                NSLog(@"Credit Card track1masked %@ ", self.magtekReader.track1Masked);
                NSLog(@"Credit Card track2Masked %@ ", self.magtekReader.track2Masked);
                NSLog(@"Credit Card track3Masked %@ ", self.magtekReader.track3Masked);
                NSLog(@"Credit Card Track Decode Status %@ ", self.magtekReader.trackDecodeStatus);
                NSLog(@"Credit Card maskedTracks %@ ", self.magtekReader.maskedTracks);
                NSLog(@"Credit Card Track 1 Decode Status %@ ", self.magtekReader.track1DecodeStatus );
                NSLog(@"Credit Card Track 2 Decode Status %@ ", self.magtekReader.track2DecodeStatus);
                NSLog(@"Credit Card Track 3 Decode Status %@ ", self.magtekReader.track3DecodeStatus);
                NSLog(@"Credit Card Cap Track %@ ", self.magtekReader.capTracks);
                NSLog(@"Credit Card Encryption Status %@ ", self.magtekReader.encryptionStatus);
                
                NSMutableDictionary *cardData = [[NSMutableDictionary alloc]init];
                cardData[@"sendData"] = sendData;
                
                [self.rmsCardReaderDelegate didSwipeFromReaderDevice:[NSString stringWithFormat:@"XXXX XXXX XXXX %@",self.magtekReader.cardLast4] withExpirationDate:self.magtekReader.cardExpDate WithNameOnCard:self.magtekReader.cardName withDeviceName:@"Magtek" cardData:cardData];
            }
        }
        else
        {
            NSString * pResponse = [NSString stringWithFormat:@"Track.Status: %@\n"
                                    "Encryption.Status: %@\n"
                                    "Track.Masked: %@\n"
                                    "Track1.Masked: %@\n"
                                    "Track2.Masked: %@\n"
                                    "Track3.Masked: %@\n"
                                    "Track1.Encrypted: %@\n"
                                    "Track2.Encrypted: %@\n"
                                    "Track3.Encrypted: %@\n"
                                    "Card.IIN: %@\n"
                                    "Card.Name: %@\n"
                                    "Card.Last4: %@\n"
                                    "Card.ExpDate: %@\n"
                                    "Card.SvcCode: %@\n"
                                    "Card.PANLength: %d\n"
                                    "KSN: %@\n"
                                    "Device.SerialNumber: %@\n"
                                    "MagnePrint: %@\n"
                                    "MagnePrintStatus: %@\n"
                                    "SessionID: %@\n"
                                    "Device Model Name: %@\n",
                                    self.magtekReader.trackDecodeStatus,
                                    self.magtekReader.encryptionStatus,
                                    self.magtekReader.maskedTracks,
                                    self.magtekReader.track1Masked,
                                    self.magtekReader.track2Masked,
                                    self.magtekReader.track3Masked,
                                    self.magtekReader.track1,
                                    self.magtekReader.track2,
                                    self.magtekReader.track3,
                                    self.magtekReader.cardIIN,
                                    self.magtekReader.cardName,
                                    self.magtekReader.cardLast4,
                                    self.magtekReader.cardExpDate,
                                    self.magtekReader.cardServiceCode,
                                    self.magtekReader.cardPANLength,
                                    self.magtekReader.KSN,
                                    self.magtekReader.deviceSerial,
                                    self.magtekReader.magnePrint,
                                    self.magtekReader.magnePrintStatus,
                                    self.magtekReader.sessionID,
                                    self.magtekReader.deviceName];
            
            
            NSLog(@"pResponse : %@ ",pResponse);
            
            if([self.magtekReader.track2 isEqualToString:@";E?"] || [self.magtekReader.track1 isEqualToString:@"%E?"])
            {
                [self.rmsCardReaderDelegate didFailToRetriveCardData];
            }
            else
            {
                NSString *sendData = [NSString stringWithFormat:@"<SecurityInfo>%@</SecurityInfo><Track1>%@</Track1><Track2>%@</Track2><SecureFormat>MagneSafeV1</SecureFormat>",self.magtekReader.KSN,self.magtekReader.track1,self.magtekReader.track2];
                
                
                NSLog(@"Credit Card track 1 %@ ",self.magtekReader.track1);
                NSLog(@"Credit Card track 2 %@ ",self.magtekReader.track2);
                NSLog(@"Credit Card tract 3 %@ ", self.magtekReader.track3);
                NSLog(@"Credit Card track1masked %@ ", self.magtekReader.track1Masked);
                NSLog(@"Credit Card track2Masked %@ ", self.magtekReader.track2Masked);
                NSLog(@"Credit Card track3Masked %@ ", self.magtekReader.track3Masked);
                NSLog(@"Credit Card Track Decode Status %@ ", self.magtekReader.trackDecodeStatus);
                NSLog(@"Credit Card maskedTracks %@ ", self.magtekReader.maskedTracks);
                NSLog(@"Credit Card Track 1 Decode Status %@ ", self.magtekReader.track1DecodeStatus );
                NSLog(@"Credit Card Track 2 Decode Status %@ ", self.magtekReader.track2DecodeStatus);
                NSLog(@"Credit Card Track 3 Decode Status %@ ", self.magtekReader.track3DecodeStatus);
                NSLog(@"Credit Card Cap Track %@ ", self.magtekReader.capTracks);
                NSLog(@"Credit Card Encryption Status %@ ", self.magtekReader.encryptionStatus);

                NSMutableDictionary *cardData = [[NSMutableDictionary alloc]init];
                cardData[@"sendData"] = sendData;
                
              [self.rmsCardReaderDelegate didSwipeFromReaderDevice:[NSString stringWithFormat:@"XXXX XXXX XXXX %@",self.magtekReader.cardLast4] withExpirationDate:self.magtekReader.cardExpDate WithNameOnCard:self.magtekReader.cardName withDeviceName:@"Magtek" cardData:cardData];
            }
        }
        [self.magtekReader clearBuffers];
    }
}

@end
