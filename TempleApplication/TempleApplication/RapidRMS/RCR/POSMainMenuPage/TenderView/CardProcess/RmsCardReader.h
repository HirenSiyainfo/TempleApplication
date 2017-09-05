//
//  RmsCardReader.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/3/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RmsCardReaderDelegate <NSObject>
- (void)didConnectToReaderDevice :(NSString *)deviceName;
- (void)didDisconnectFromReaderDevice :(NSString *)deviceName;
- (void)didSwipeFromReaderDevice :(NSString *)accountNumber withExpirationDate:(NSString *)date WithNameOnCard :(NSString *)cardName  withDeviceName:(NSString *)deviceName cardData:(NSMutableDictionary *)cardData;
-(void)didFailToRetriveCardData;

@end

@interface RmsCardReader : NSObject
@property (readonly, strong, nonatomic) id<RmsCardReaderDelegate> rmsCardReaderDelegate;

- (instancetype)initWithDelegate:(id<RmsCardReaderDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (void)closeDevice;


@end
