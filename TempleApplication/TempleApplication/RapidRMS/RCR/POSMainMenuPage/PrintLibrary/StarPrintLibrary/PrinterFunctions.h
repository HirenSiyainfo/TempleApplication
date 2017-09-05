//
//  PrinterFunctions.h
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommonEnum.h"

typedef NS_ENUM(NSUInteger, ActualDrawerStatus)
{
    ActualDrawerStatusOpen = 1,
    ActualDrawerStatusClose,
};

typedef NS_ENUM(NSUInteger, ActualPrinterStatus)
{
    ActualPrinterStatusCoverIsOpen = 1,
    ActualPrinterStatusOutOfPaper,
    ActualPrinterStatusOnline,
    ActualPrinterStatusError,
};

#pragma mark - Rapid RMS section

@protocol PrinterFunctionsDelegate <NSObject>

-(void)printerTaskDidSuccessWithDevice:(NSString *)device;
-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp;
-(void)actualDrawerStatus:(ActualDrawerStatus)actualDrawerStatus;
-(void)errorOccuredInGettingStatusWithTitle:(NSString *)title message:(NSString *)message;

@end

//#define kPrintTaskNotification @"kPrintTaskNotification"
typedef enum __PRINT_STATUS_CODE__ {
    PSC_PRINT_JOB_DISPATCHED,
    PSC_PRINT_JOB_STARTED,
    PSC_PRINT_JOB_COMPLETED,
    PSC_PRINT_JOB_ERROR,
} PRINT_STATUS_CODE;



#pragma mark - StarIO section

@class SMBluetoothManager;

typedef NS_ENUM(unsigned int, Limit) {
    USE_LIMITS = 0,
    USE_FIXED = 1
};

typedef NS_ENUM(unsigned int, NarrowWide) {
    NarrowWide_2_6 = 0,
    NarrowWide_3_9 = 1,
    NarrowWide_4_12 = 2,
    NarrowWide_2_5 = 3,
    NarrowWide_3_8 = 4,
    NarrowWide_4_10 = 5,
    NarrowWide_2_4 = 6,
    NarrowWide_3_6 = 7,
    NarrowWide_4_8 = 8
};

typedef NS_ENUM(unsigned int, NarrowWideV2) 
{
    NarrowWideV2_2_5 = 0,
    NarrowWideV2_4_10 = 1,
    NarrowWideV2_6_15 = 2,
    NarrowWideV2_2_4 = 3,
    NarrowWideV2_4_8 = 4,
    NarrowWideV2_6_12 = 5,
    NarrowWideV2_2_6 = 6,
    NarrowWideV2_3_9 = 7,
    NarrowWideV2_4_12 = 8
};

typedef NS_ENUM(unsigned int, BarCodeOptions) {
    No_Added_Characters_With_Line_Feed = 0,
    Adds_Characters_With_Line_Feed = 1,
    No_Added_Characters_Without_Line_Feed = 2,
    Adds_Characters_Without_Line_Feed = 3
};

typedef NS_ENUM(unsigned int, Min_Mod_Size)
{
    _2_dots = 0,
    _3_dots = 1,
    _4_dots = 2
};


@interface PrinterFunctions : NSObject

#pragma mark - Check Status

+ (void)CheckStatusWithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings
                  sensorSetting:(SensorActive)sensorActiveSetting withDelegate:(id)delegate;

#ifdef SAMPLE_CODE

#pragma mark - Open Cash Drawer

+ (void)OpenCashDrawerWithPortname:(NSString *)portName
                      portSettings:(NSString *)portSettings
                      drawerNumber:(NSUInteger)drawerNumber;


#pragma mark - 1D Barcode

+ (void)PrintCode39WithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings
                    barcodeData:(unsigned char*)barcodeData
                barcodeDataSize:(unsigned int)barcodeDataSize
                 barcodeOptions:(BarCodeOptions)option
                         height:(unsigned char)height
                     narrowWide:(NarrowWide)width;
+ (void)PrintCode93WithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings
                    barcodeData:(unsigned char*)barcodeData
                barcodeDataSize:(unsigned int)barcodeDataSize
                 barcodeOptions:(BarCodeOptions)option
                         height:(unsigned char)height
                min_module_dots:(Min_Mod_Size) width;
+ (void)PrintCodeITFWithPortname:(NSString*)portName
                    portSettings:(NSString*)portSettings
                     barcodeData:(unsigned char*)barcodeData
                 barcodeDataSize:(unsigned int)barcodeDataSize
                  barcodeOptions:(BarCodeOptions)option
                          height:(unsigned char)height
                      narrowWide:(NarrowWideV2) width;
+ (void)PrintCode128WithPortname:(NSString*)portName
                    portSettings:(NSString*)portSettings
                     barcodeData:(unsigned char*)barcodeData
                 barcodeDataSize:(unsigned int)barcodeDataSize
                  barcodeOptions:(BarCodeOptions)option
                          height:(unsigned char)height
                 min_module_dots:(Min_Mod_Size)width;

#pragma mark - 2D Barcode

+ (void)PrintQrcodeWithPortname:(NSString*)portName
                   portSettings:(NSString*)portSettings
                correctionLevel:(CorrectionLevelOption) correctionLevel
                          model:(Model)model
                       cellSize:(unsigned char)cellSize
                    barcodeData:(unsigned char*)barCodeData
                barcodeDataSize:(unsigned int)barCodeDataSize;
+ (void)PrintPDF417CodeWithPortname:(NSString *)portName
                       portSettings:(NSString *)portSettings
                              limit:(Limit)limit
                                 p1:(unsigned char)p1
                                 p2:(unsigned char)p2
                      securityLevel:(unsigned char)securityLevel
                         xDirection:(unsigned char)xDirection
                        aspectRatio:(unsigned char)aspectRatio
                        barcodeData:(unsigned char[])barcodeDat
                    barcodeDataSize:(unsigned int)barcodeDataSize;

#pragma mark - Cut

+ (void)PerformCutWithPortname:(NSString *)portName
                  portSettings:(NSString*)portSettings
                       cutType:(CutType)cuttype;

#pragma mark - TextFormatting



+ (void)PrintKanjiTextWithPortname:(NSString *)portName
                      portSettings:(NSString*)portSettings
                         kanjiMode:(int)kanjiMode
                         underline:(bool)underline
                       invertColor:(bool)invertColor
                        emphasized:(bool)emphasized
                         upperline:(bool)upperline
                        upsideDown:(bool)upsideDown
                   heightExpansion:(int)heightExpansion
                    widthExpansion:(int)widthExpansion
                        leftMargin:(unsigned char)leftMargin
                         alignment:(Alignment) alignment
                          textData:(unsigned char *)textData
                      textDataSize:(unsigned int)textDataSize;



#pragma mark - Sample Receipt (Line)

+ (void)PrintSampleReceipt3InchWithPortname:(NSString *)portName
                               portSettings:(NSString *)portSettings;
+ (void)PrintSampleReceipt4InchWithPortname:(NSString *)portName
                               portSettings:(NSString *)portSettings;
+ (void)PrintKanjiSampleReceipt3InchWithPortname:(NSString *)portName
                                    portSettings:(NSString *)portSettings;
+ (void)PrintKanjiSampleReceipt4InchWithPortname:(NSString *)portName
                                    portSettings:(NSString *)portSettings;

#pragma mark - Sample Receipt (Raster)

+ (void)PrintRasterSampleReceipt3InchWithPortname:(NSString *)portName
                                     portSettings:(NSString *)portSettings;
+ (void)PrintRasterSampleReceipt4InchWithPortname:(NSString *)portName
                                     portSettings:(NSString *)portSettings;
+ (void)PrintRasterKanjiSampleReceipt3InchWithPortname:(NSString *)portName
                                          portSettings:(NSString *)portSettings;
+ (void)PrintRasterKanjiSampleReceipt4InchWithPortname:(NSString *)portName
                                          portSettings:(NSString *)portSettings;

#pragma mark - Sample Receipt (Line) - without drawer kick

+ (void)PrintSampleReceipt3InchWithoutDrawerKickWithPortname:(NSString *)portName
                                                portSettings:(NSString *)portSettings
                                                errorMessage:(NSMutableString *)message;
+ (void)PrintSampleReceipt4InchWithoutDrawerKickWithPortname:(NSString *)portName
                                                portSettings:(NSString *)portSettings
                                                errorMessage:(NSMutableString *)message;

#pragma mark - Bluetooth Setting

+ (SMBluetoothManager *)loadBluetoothSetting:(NSString *)portName
                                portSettings:(NSString *)portSettings;



#pragma mark - Disconnect (Bluetooth)
+ (void)disconnectPort:(NSString *)portName
          portSettings:(NSString *)portSettings
               timeout:(u_int32_t)timeout;


#endif

+ (void)PrintTextWithPortname:(NSString *)portName
                 portSettings:(NSString*)portSettings
                  slashedZero:(bool)slashedZero
                    underline:(bool)underline
                  invertColor:(bool)invertColor
                   emphasized:(bool)emphasized
                    upperline:(bool)upperline
                   upsideDown:(bool)upsideDown
              heightExpansion:(int)heightExpansion
               widthExpansion:(int)widthExpansion
                   leftMargin:(unsigned char)leftMargin
                    alignment:(Alignment) alignment
                     textData:(unsigned char *)textData
                 textDataSize:(unsigned int)textDataSize;

#pragma mark - common

+ (void)PrintImageWithPortname:(NSString *)portName
                  portSettings:(NSString *)portSettings
                  imageToPrint:(UIImage *)imageToPrint
                      maxWidth:(int)maxWidth
             compressionEnable:(BOOL)compressionEnable
                withDrawerKick:(BOOL)drawerKick;

+ (void)sendCommand:(NSData *)commandsToPrint portName:(NSString *)portName portSettings:(NSString *)portSettings timeoutMillis:(u_int32_t)timeoutMillis deviceName:(NSString*)deviceName withDelegate:(id)delegate;




@end
