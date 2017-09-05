//
//  PrintJob.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrinterFunctions.h"
#import <StarIO_Extension/StarIoExtManager.h>
#import <StarIO_Extension/StarIoExt.h>
#import <StarIO_Extension/ISCBBuilder.h>

#pragma mark - Paper cut modes
typedef enum __PAPER_CUT_MODES__ {
    PC_FULL_CUT,
    PC_PARTIAL_CUT,
    PC_FULL_CUT_WITH_FEED,
    PC_PARTIAL_CUT_WITH_FEED,
} PAPER_CUT_MODES;

#pragma mark - Text Alignment
typedef enum __TEXT_ALIGNMENT__ {
    TA_LEFT,
    TA_CENTER,
    TA_RIGHT
} TEXT_ALIGNMENT;

typedef NS_ENUM(NSUInteger, RCAlignment) {
    RCAlignmentLeft,
    RCAlignmentCenter,
    RCAlignmentRight,
};

@interface PrintJob : NSObject {
    NSInteger columnWidths[6];
    NSInteger columnAlignments[6];

}

@property (nonatomic, strong) UIFont *rasterPrintingFont;
@property (assign) NSInteger printerWidth;
@property (nonatomic, strong) NSMutableData *printCommands;
@property (nonatomic, strong) ISCBBuilder *iscBuilder;

- (instancetype)initWithPort:(NSString *)portName portSettings:(NSString *)portSettings deviceName:(NSString *)deviceName withDelegate:(id)delegate NS_DESIGNATED_INITIALIZER;

- (void)printLine:(NSString*)text;
- (void)printAttributedStringLine:(NSAttributedString*)text;
- (void)printText:(NSString*)text;

- (void)printText1:(NSString *)text1 text2:(NSString *)text2;
- (void)printText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3;
- (void)printText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 text4:(NSString *)text4;
- (void)printWrappedText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 text4:(NSString *)text4;

- (NSString *)rightAlignedText:(NSString *)textValue columnWidth:(NSInteger)columnWidth;

- (void)printBarCode:(NSString*)barcode;
- (void)cutPaper:(PAPER_CUT_MODES)mode;
- (void)printSeparator;
- (void)enableSlashedZero:(BOOL)enable;
- (void)enableUnderline:(BOOL)enable;
- (void)enableInvertColor:(BOOL)enable;
- (void)enableBold:(BOOL)enable;
- (void)enableUpperline:(BOOL)enable;
- (void)enableUpsideDown:(BOOL)enable;
- (void)setHeightExpansion:(uint8_t)characterHeight;
- (void)setWidthExpansion:(uint8_t)characterWidth;
- (void)setTextSize:(UInt8)textSize;
- (void)setLeftMargin:(uint8_t)margin;
- (void)setTextAlignment:(TEXT_ALIGNMENT)alignment;

- (void)openCashDrawer;

// QR Code
- (void)printQRCode:(NSString*)qrCodeText;
- (void)printQRCodeText:(NSString *)qrCodeText model:(NSInteger)model correction:(NSInteger)correction cellSize:(NSInteger)cellSize;


// Column Printing
- (void)setColumnWidths:(NSInteger[6])_columnWidths columnAlignments:(NSInteger[6])_columnAlignments;

// Raster mode printing
- (void)printImage:(UIImage*)image;
- (void)beginRasterModePrinting;
- (void)endRasterModePrinting;

- (void)setFont:(UIFont*)font;
- (void)printRasterText:(NSString*)text;
// Raster mode printing

+ (void)actualPrinterStatus:(ActualPrinterStatus)printerStatus;
+ (void)actualDrawerStatus:(ActualDrawerStatus)drawerStatus;

- (void)firePrint;
- (void)addCommand:(NSData*)printCommand;

@end
