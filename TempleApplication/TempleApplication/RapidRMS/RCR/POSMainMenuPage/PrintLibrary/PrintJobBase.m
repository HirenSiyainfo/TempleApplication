//
//  PrintJobBase.m
//  RapidRMS
//
//  Created by Siya-ios5 on 9/17/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PrintJobBase.h"

@interface PrintJobBase()
@end


@implementation PrintJobBase

- (instancetype)initWithPort:(NSString *)portName portSettings:(NSString *)portSettings deviceName:(NSString *)deviceName withDelegate:(id)delegate
{
    self = [super initWithPort:portName portSettings:portSettings deviceName:deviceName withDelegate:delegate];
    if (self) {
        self.iscBuilder = [StarIoExt createCommandBuilder:StarIoExtEmulationStarPRNT];
        [self.iscBuilder beginDocument];
    }
    return self;
}

- (void)addCommand:(NSData*)printCommand {
    [self.iscBuilder appendData:printCommand];
}

- (void)addByte:(char)byte {
    [self.iscBuilder appendBytes:&byte length:1];
}

- (void)addCommandString:(NSString*)printCommandString {
    [self addCommandString:printCommandString usingEncoding:NSASCIIStringEncoding];
}

- (void)addCommandString:(NSString*)printCommandString usingEncoding:(NSStringEncoding)stringEncoding {
    [self addCommand:[printCommandString dataUsingEncoding:stringEncoding]];
}
- (void)setTextAlignment:(TEXT_ALIGNMENT)alignment  {
    
    SCBAlignmentPosition scbAlignmentPosition;
    switch (alignment) {
        case TA_LEFT:
            scbAlignmentPosition = SCBAlignmentPositionLeft;
            break;
        case TA_CENTER:
            scbAlignmentPosition = SCBAlignmentPositionCenter;
            break;
        case TA_RIGHT:
            scbAlignmentPosition = SCBAlignmentPositionRight;
            break;

        default:
            break;
    }
    
    [self.iscBuilder appendAlignment:scbAlignmentPosition];

}

- (void)enableInvertColor:(BOOL)enable  {
    [self.iscBuilder appendInvert:enable];
}
- (void)cutPaper:(PAPER_CUT_MODES)mode {
    SCBCutPaperAction scbCutPaperAction;
    
    switch (mode) {
        case PC_FULL_CUT:
            scbCutPaperAction = SCBCutPaperActionFullCut;
            break;
        case PC_PARTIAL_CUT:
            scbCutPaperAction = SCBCutPaperActionPartialCut;
            break;
        case PC_FULL_CUT_WITH_FEED:
            scbCutPaperAction = SCBCutPaperActionFullCutWithFeed;
            break;
        case PC_PARTIAL_CUT_WITH_FEED:
            scbCutPaperAction = SCBCutPaperActionPartialCutWithFeed;
            break;
        default:
            break;
    }
    
    [self.iscBuilder appendCutPaper:scbCutPaperAction];
    [self.iscBuilder endDocument];
}
-(NSData *)commandData
{
    return self.iscBuilder.commands;
}

- (void)openCashDrawer
{
    [self createData:StarIoExtEmulationStarPRNT channel:SCBPeripheralChannelNo1];
}
- (NSData *)createData:(StarIoExtEmulation)emulation
               channel:(SCBPeripheralChannel)channel {
    self.iscBuilder = [StarIoExt createCommandBuilder:emulation];
    
    [self.iscBuilder beginDocument];
    
    [self.iscBuilder appendPeripheral:channel];
    
    [self.iscBuilder endDocument];
    
    return self.iscBuilder.commands;
}
@end
