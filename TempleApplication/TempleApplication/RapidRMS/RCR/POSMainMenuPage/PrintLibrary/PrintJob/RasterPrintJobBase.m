//
//  RasterPrintJobBase.m
//  RapidRMS
//
//  Created by Siya-ios5 on 9/27/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RasterPrintJobBase.h"
#import "StarBitmap.h"

@implementation RasterPrintJobBase
- (instancetype)initWithPort:(NSString *)portName portSettings:(NSString *)portSettings deviceName:(NSString *)deviceName withDelegate:(id)delegate
{
    self = [super initWithPort:portName portSettings:portSettings deviceName:deviceName withDelegate:delegate];
    if (self) {
        self.iscBuilder = [StarIoExt createCommandBuilder:StarIoExtEmulationStarGraphic];
        [self.iscBuilder beginDocument];
    }
    return self;
}


- (void)printImage:(UIImage *)imageToPrint {
    [self.iscBuilder appendBitmap:imageToPrint diffusion:NO];
}


-(NSData *)commandData
{
    return self.iscBuilder.commands;
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



@end
