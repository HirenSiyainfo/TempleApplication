//
//  CardFlightReader.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/3/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CardFlightReader.h"
#import "RmsDbController.h"

//static NSString *API_KEY = @"70c49c464619211ca78ad75d62831f6e";
//static NSString *ACCOUNT_TOKEN = @"acc_ad427082b71c4132";


@interface CardFlightReader()

//@property (readonly, weak, nonatomic) id<RmsCardReaderDelegate> cardFlightReaderDelegate;
@property (nonatomic, strong) RmsDbController  *rmsDbController;

@end

@implementation CardFlightReader
- (instancetype)initWithDelegate:(id<RmsCardReaderDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self) {
//        _cardFlightReaderDelegate = delegate;
        [self setupCardFlight];
    }
    return self;
}

-(void)setupCardFlight
{

    
    //    NSString *API_KEY1 = @"  70c49c46  4619211  ca78ad5d62831f6e   ";
    //    API_KEY1 = [API_KEY1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
//    NSString *API_KEY = [[[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"API_KEY"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    NSString *ACCOUNT_TOKEN = [[[self.rmsDbController.paymentCardTypearray firstObject] valueForKey:@"ACCOUNT_TOKEN"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
//    [[CardFlight sharedInstance]setApiToken:API_KEY accountToken:ACCOUNT_TOKEN];
//    [[CardFlight sharedInstance] setLogging:YES];
//    
//    _cardReader = [[CFTReader alloc] initAndConnect];
//    [_cardReader swipeTimeoutDuration:0];
//    [_cardReader setDelegate:self];


   /* NSString *amount = [NSString stringWithFormat:@"%.2f",5.08];
    NSDictionary *paymentInfo = @{@"amount":[NSDecimalNumber decimalNumberWithString:amount],
                                  @"currency":@"USD",
                                  @"description": @"Description",
                                  };*/
}


//#pragma mark - Reader Delegate
//- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error {
//    if (!error)
//    {
//        NSMutableDictionary *cardData = [[NSMutableDictionary alloc]init];
//        [cardData setObject:card forKey:@"CardData"];
//        
//        NSString *accountNo = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",card.last4];
//        [self.rmsCardReaderDelegate didSwipeFromReaderDevice:accountNo withExpirationDate:@"XXXX" WithNameOnCard:card.name
//                                              withDeviceName:@"CardFlight" cardData:cardData];
//    }
//    else
//    {
//        [_cardReader beginSwipeWithMessage:nil];
//    }
//}
//
//- (void)readerGenericResponse:(NSString *)cardData
//{
//   // [_cardReader swipeTimeoutDuration:0];
//    [_cardReader beginSwipeWithMessage:nil];
//}
//
//- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error {
//    if (isConnected)
//    {
//   //
//        [_cardReader beginSwipeWithMessage:nil];
//      //  [_cardReader swipeTimeoutDuration:0];
//        [self.rmsCardReaderDelegate didConnectToReaderDevice:@"CardFlight"];
//    }
//    else
//    {
//        [self.rmsCardReaderDelegate didDisconnectFromReaderDevice:@"CardFlight"];
//    }
//}
//- (void)closeDevice
//{
//    _cardReader = nil;
//}

- (void)readerIsAttached {
    
}

- (void)readerIsDisconnected {
    [self.rmsCardReaderDelegate didDisconnectFromReaderDevice:@"CardFlight"];
}

- (void)readerSerialNumber:(NSString *)serialNumber {
}

@end
