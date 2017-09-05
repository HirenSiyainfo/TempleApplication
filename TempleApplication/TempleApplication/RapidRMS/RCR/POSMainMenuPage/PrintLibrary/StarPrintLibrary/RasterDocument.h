//
//  RasterDocument.h
//  IOS_SDK
//
//  Created by Tzvi on 8/17/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, RasTopMargin)
{
    RasTopMargin_Default = 0,
    RasTopMargin_Small = 1,
    RasTopMargin_Standard = 2,
};

typedef NS_ENUM(unsigned int, RasSpeed)
{
    RasSpeed_Full = 0,
    RasSpeed_Medium = 1,
    RasSpeed_Low = 2,
};

typedef NS_ENUM(unsigned int, RasPageEndMode)
{
    RasPageEndMode_Default = 0,
    RasPageEndMode_None = 1,
    RasPageEndMode_FeedToCutter = 2,
    RasPageEndMode_FeedToTearbar = 3,
    RasPageEndMode_FullCut = 4,
    RasPageEndMode_FeedAndFullCut = 5,
    RasPageEndMode_PartialCut = 6,
    RasPageEndMode_FeedAndPartialCut = 7,
    RasPageEndMode_Eject = 8,
    RasPageEndMode_FeedAndEject = 9
    
};


@interface RasterDocument : NSObject {
    RasTopMargin mTopMargin;
    RasSpeed mSpeed;
    RasPageEndMode mFFmode;
    RasPageEndMode mEOTMode;
    int mPageLength;
    int mLeftMargin;
    int mRightMargin;
}

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDefaults:(RasSpeed)speed
    endOfPageBehaviour:(RasPageEndMode)endOfPageBehaviour_m
endOfDocumentBahaviour:(RasPageEndMode)endOfDocumentBehaviour_m
             topMargin:(RasTopMargin)topMargin_m
            pageLength:(int)pageLength_m
            leftMargin:(int)leftMargin_m
           rightMargin:(int)rightMargin_m NS_DESIGNATED_INITIALIZER;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *BeginDocumentCommandData;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *EndDocumentCommandData;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *PageBreakCommandData;

@end
