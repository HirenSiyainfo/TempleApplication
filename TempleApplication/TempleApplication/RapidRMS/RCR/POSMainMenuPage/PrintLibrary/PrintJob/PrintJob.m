//
//  PrintJob.m
//  RapidRMS
//
//  Created by Siya Infotech on 25/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PrintJob.h"
#import "StarBitmap.h"
#import "RasterDocument.h"

#pragma mark - Constants

#pragma mark - Escape codes
#define CC_NUL "\x00"
#define CC_SOH "\x01"
#define CC_STX "\x02"
#define CC_ETX "\x03"
#define CC_EOT "\x04"
#define CC_ENQ "\x05"
#define CC_ACK "\x06"
#define CC_BEL "\x07"
#define CC_BS "\x08"
#define CC_TAB "\x09"
#define CC_VT "\x0B"
#define CC_FF "\x0C"
#define CC_CR "\x0D"
#define CC_SO "\x0E"
#define CC_SI "\x0F"
#define CC_DLE "\x10"
#define CC_DC1 "\x11"
#define CC_DC2 "\x12"
#define CC_DC3 "\x13"
#define CC_DC4 "\x14"
#define CC_NAK "\x15"
#define CC_SYN "\x16"
#define CC_ETB "\x17"
#define CC_CAN "\x18"
#define CC_EM "\x19"
#define CC_SUB "\x1A"
#define CC_ESC "\x1B"
#define CC_FS "\x1C"
#define CC_GS "\x1D"
#define CC_RS "\x1E"
#define CC_US "\x1F"

#pragma mark - ObjC
#define COMMAND_STRING(x)   @(x)

#pragma mark - Commands
#define CMD_OPEN_CASH_DRAWER    COMMAND_STRING(CC_BEL)
#define CMD_OPEN_CASH_DRAWER2   COMMAND_STRING(CC_SUB)
#define BARCODE_HEIGHT          "\x50"
#define CMD_PRINT_BARCODE       COMMAND_STRING(CC_ESC "b\x06\x02\x02" BARCODE_HEIGHT "%@" CC_RS)
#define CMD_PAPER_CUT           COMMAND_STRING(CC_ESC "d%d")
#define CMD_SLASHED_ZERO        COMMAND_STRING(CC_ESC "/%d")
#define CMD_UNDERLINE           COMMAND_STRING(CC_ESC "-%d")
#define CMD_INVERT_COLOR        COMMAND_STRING(CC_ESC "%d")
#define CMD_BOLD                COMMAND_STRING(CC_ESC "%c")
#define CMD_UPPERLINE           COMMAND_STRING(CC_ESC "%d")
#define CMD_UPSIDE_DOWN         COMMAND_STRING("%s")
#define CMD_HEIGHT_EXPANSION    COMMAND_STRING(CC_ESC "i%d%d")
#define CMD_WIDTH_EXPANSION     CMD_HEIGHT_EXPANSION
#define CMD_LEFT_MARGIN         COMMAND_STRING(CC_GS "l%d")
#define CMD_ALIGNMENT           COMMAND_STRING(CC_ESC CC_GS "a%d")

#define CMD_QRCODE_MODEL        COMMAND_STRING(CC_ESC CC_GS "yS0")
#define CMD_QRCODE_CORRECTION   COMMAND_STRING(CC_ESC CC_GS "yS1")
#define CMD_QRCODE_CELLSIZE     COMMAND_STRING(CC_ESC CC_GS "yS2")
#define CMD_QRCODE_DATA_PREFIX  COMMAND_STRING(CC_ESC CC_GS "yD1")
#define CMD_QRCODE_DATA         COMMAND_STRING("%@")
#define CMD_QRCODE_PRINT        COMMAND_STRING(CC_ESC CC_GS "yP")


@interface PrintJob ()
{
    NSString *_deviceName;
}
@property (nonatomic, weak) id printerDelegate;
@property (nonatomic, strong) NSString *portName;
@property (nonatomic, strong) NSString *portSettings;
@property (nonatomic) CGContextRef rasterPrintingContext;
@property (nonatomic, strong) NSMutableAttributedString *rasterPrintingText;
@end

@implementation PrintJob

#pragma mark - General
- (instancetype)initWithPort:(NSString *)portName portSettings:(NSString *)portSettings deviceName:(NSString *)deviceName withDelegate:(id)delegate {
    self = [super init];
    if (self) {
        self.printCommands = [[NSMutableData alloc] init];
        self.portSettings = portSettings;
        self.portName = portName;
        _deviceName = deviceName;
        _printerWidth = 48;
        _printerDelegate = delegate;
    }
    return self;
}

- (CGFloat)pixelsForPaperSize:(NSInteger)paperSize {
    CGFloat width;
    switch (paperSize)
    {
        case 1  : width = 576; break;
        case 2  : width = 832; break;
        default : width = 384; break;
    }

    return width;

}

#pragma mark - Core
- (void)addCommand:(NSData*)printCommand {
    [self.printCommands appendData:printCommand];
}

- (void)addByte:(char)byte {
    [self.printCommands appendBytes:&byte length:1];
}

- (void)addCommandString:(NSString*)printCommandString {
    [self addCommandString:printCommandString usingEncoding:NSASCIIStringEncoding];
}

- (void)addCommandString:(NSString*)printCommandString usingEncoding:(NSStringEncoding)stringEncoding {
    [self addCommand:[printCommandString dataUsingEncoding:stringEncoding]];
}

#pragma mark - Printing text
- (void)printLine:(NSString*)text {
    [self addCommandString:[NSString stringWithFormat:@"%@\r\n", text] usingEncoding:NSUTF8StringEncoding];
}

- (void)printAttributedStringLine:(NSAttributedString*)text {
    [self.rasterPrintingText appendAttributedString:text];
}

- (void)printText:(NSString*)text {
    [self addCommandString:text usingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Bar code
- (void)printBarCode:(NSString*)barcode {
    NSString *barcodeCommandString = [NSString stringWithFormat:CMD_PRINT_BARCODE, barcode];
    [self addCommandString:barcodeCommandString usingEncoding:NSUTF8StringEncoding];
}

#pragma mark - QR code
- (void)setQRCodeModel:(NSInteger)qrCodeModel {
    [self addCommandString:CMD_QRCODE_MODEL usingEncoding:NSUTF8StringEncoding];
    [self addByte:(char)qrCodeModel];
}

- (void)setQRCodeCorrection:(NSInteger)qrCodeCorrection {
    [self addCommandString:CMD_QRCODE_CORRECTION usingEncoding:NSUTF8StringEncoding];
    [self addByte:(char)qrCodeCorrection];
}

- (void)setQRCodeCellSize:(NSInteger)qrCodeCellSize {
    [self addCommandString:CMD_QRCODE_CELLSIZE usingEncoding:NSUTF8StringEncoding];
    [self addByte:(char)qrCodeCellSize];
}

- (char)highByte:(UInt16)length {
    char highByte = (char) ((length & 0xFF00) >> 8);
    return highByte;
}

- (char)lowByte:(UInt16)length {
    char lowByte = (char) (length & 0xFF);
    return lowByte;
}

- (void)setQRCodeData:(NSString*)qrCodeData {
    UInt16 length = (UInt16) qrCodeData.length;
    char highByte = [self highByte:length];
    char lowByte = [self lowByte:length];

    [self addCommandString:CMD_QRCODE_DATA_PREFIX usingEncoding:NSUTF8StringEncoding];
    [self addByte:0];

    [self addByte:(char)lowByte];
    [self addByte:(char)highByte];

    NSString *qrcodeCommandString = [NSString stringWithFormat:CMD_QRCODE_DATA, qrCodeData];
    [self addCommandString:qrcodeCommandString usingEncoding:NSUTF8StringEncoding];
}

- (void)printQRCode {
    [self addCommandString:CMD_QRCODE_PRINT usingEncoding:NSUTF8StringEncoding];
}

- (void)printQRCodeText:(NSString *)qrCodeText model:(NSInteger)model correction:(NSInteger)correction cellSize:(NSInteger)cellSize {
    // Do not change the sequence of the calls
    [self setQRCodeModel:model];
    [self setQRCodeCorrection:correction];
    [self setQRCodeCellSize:cellSize];
    [self setQRCodeData:qrCodeText];
    [self printQRCode];
}

- (void)printQRCode:(NSString*)qrCodeText {
    [self printQRCodeText:qrCodeText model:2 correction:3 cellSize:4];
}


#pragma mark - Text formatting
- (void)enableSlashedZero:(BOOL)enable {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_SLASHED_ZERO, enable ? 1 : 0];
    [self addCommandString:slashedZeroCommandString];
}

- (void)enableUnderline:(BOOL)enable {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_UNDERLINE, enable ? 1 : 0];
    [self addCommandString:slashedZeroCommandString];
}

- (void)enableInvertColor:(BOOL)enable  {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_INVERT_COLOR, enable ? 4 : 5];
    [self addCommandString:slashedZeroCommandString];
}


- (void)enableBold:(BOOL)enable  {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_BOLD, enable ? 'E' : 'F'];
    [self addCommandString:slashedZeroCommandString];
}

- (void)enableUpperline:(BOOL)enable  {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_UPPERLINE, enable ? 1 : 0];
    [self addCommandString:slashedZeroCommandString];
}

- (void)enableUpsideDown:(BOOL)enable  {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_UPSIDE_DOWN, enable ? CC_SI : CC_DC2];
    [self addCommandString:slashedZeroCommandString];
}

- (void)setTextSize:(UInt8)textSize {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_HEIGHT_EXPANSION, (textSize % 6), (textSize % 6)];
    [self addCommandString:slashedZeroCommandString];
}

- (void)setHeightExpansion:(uint8_t)characterHeight  {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_HEIGHT_EXPANSION, (characterHeight % 6), 0];
    [self addCommandString:slashedZeroCommandString];
}

- (void)setWidthExpansion:(uint8_t)characterWidth  {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_WIDTH_EXPANSION, 0, (characterWidth % 6)];
    [self addCommandString:slashedZeroCommandString];
}

- (void)setLeftMargin:(uint8_t)margin  {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_LEFT_MARGIN, margin];
    [self addCommandString:slashedZeroCommandString];
}

- (void)setTextAlignment:(TEXT_ALIGNMENT)alignment  {
    NSString *slashedZeroCommandString = [NSString stringWithFormat:CMD_ALIGNMENT, alignment];
    [self addCommandString:slashedZeroCommandString];
}

- (void)printSeparator {
    [self setTextAlignment:TA_LEFT];
    NSString *line = [[NSString string] stringByPaddingToLength:48 withString:@"-" startingAtIndex:0];
    [self printLine:line];
}


#pragma mark - Cut Paper
- (void)cutPaper:(PAPER_CUT_MODES)mode {
    NSString *cutPaperCommandString = [NSString stringWithFormat:CMD_PAPER_CUT, mode];
    [self addCommandString:cutPaperCommandString];
}


#pragma mark - Cash Drwaer
- (void)openCashDrawer {
    [self addCommandString:CMD_OPEN_CASH_DRAWER];
}

#pragma mark - Raster Mode
- (void)printImage:(UIImage*)image {
    int maxWidth = image.size.width;
    BOOL pageModeEnable = NO;
    BOOL compressionEnable = YES;

    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_None endOfDocumentBahaviour:RasPageEndMode_None topMargin:RasTopMargin_Standard pageLength:0 leftMargin:0 rightMargin:0];

    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:image :maxWidth :pageModeEnable];
    
    NSMutableData *commandsToPrint = [[NSMutableData alloc] init];
    NSData *shortcommand = rasterDoc.BeginDocumentCommandData;
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [starbitmap getImageDataForPrinting:compressionEnable];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = rasterDoc.EndDocumentCommandData;
    [commandsToPrint appendData:shortcommand];
    
    [self addCommand:commandsToPrint];
}

- (void)beginRasterModePrinting {
    self.rasterPrintingText = [[NSMutableAttributedString alloc] init];
    self.rasterPrintingFont = [UIFont systemFontOfSize:10.0];
}

- (void)endRasterModePrinting {
    
    NSStringDrawingOptions drawingOptions = (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
    NSStringDrawingContext *stringDrawingContext = [[NSStringDrawingContext alloc] init];
    
    CGRect boundingRect = [self.rasterPrintingText boundingRectWithSize:CGSizeMake(576, 10000) options:drawingOptions context:stringDrawingContext];
    
    if ((boundingRect.size.height == 0) || (boundingRect.size.width == 0)) {
        NSAttributedString *erroMessage = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Some error occured while printing.\nText length = %lu\nBounding Rect = %@\n", (unsigned long)self.rasterPrintingText.length, NSStringFromCGRect(boundingRect)]];
        
        // Get bounding rect for the error message
        boundingRect = [erroMessage boundingRectWithSize:CGSizeMake(576, 10000) options:drawingOptions context:stringDrawingContext];
    }
    
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if ([UIScreen mainScreen].scale == 2.0) { //Retina
			UIGraphicsBeginImageContextWithOptions(boundingRect.size, NO, 1.0);
		} else { //Non Retina
			UIGraphicsBeginImageContext(boundingRect.size);
		}
	} else {
		UIGraphicsBeginImageContext(boundingRect.size);
	}
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, boundingRect.size.width + 1, boundingRect.size.height + 1);
    CGContextFillRect(ctr, rect);
    
    color = [UIColor blackColor];
    [color set];
    

    [self.rasterPrintingText drawWithRect:boundingRect options:drawingOptions context:stringDrawingContext];
    
    self.rasterPrintingContext = UIGraphicsGetCurrentContext();

    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self printImage:imageToPrint];
}


- (void)setFont:(UIFont*)font {
    self.rasterPrintingFont = font;
}

- (void)printRasterText:(NSString*)text {
    NSDictionary *attributes = @{NSFontAttributeName: self.rasterPrintingFont};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.rasterPrintingText appendAttributedString:attributedString];
}
-(NSData *)commandData
{
    return self.printCommands;
}

#pragma mark - Fire Print
- (void)firePrint {
    [PrinterFunctions sendCommand:[self commandData] portName:self.portName portSettings:self.portSettings timeoutMillis:10000 deviceName:_deviceName withDelegate:_printerDelegate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PrinterFunctions CheckStatusWithPortname:self.portName portSettings:self.portSettings sensorSetting:SensorActiveHigh withDelegate:nil];
    });
}

+ (void)actualPrinterStatus:(ActualPrinterStatus)printerStatus {
    if (printerStatus != ActualPrinterStatusOnline) {
        [Appsee addEvent:kPrinterStatusKey withProperties:@{kPrinterStatusKey:@(printerStatus)}];
    }
}

+ (void)actualDrawerStatus:(ActualDrawerStatus)drawerStatus {
    [Appsee addEvent:kDrawerDidNotOpenKey withProperties:@{kDrawerDidNotOpenKey:@(drawerStatus)}];
}

#pragma mark - Empty String If Null

- (NSString*)emptyStringIfNull:(NSString*)text {
    if ([text isKindOfClass:[NSNull class]] || text == nil) {
        text = @"";
    }
    return text;
}

#pragma mark - Set Column Widths and Alignments

- (void)setColumnWidths:(NSInteger[6])_columnWidths columnAlignments:(NSInteger[6])_columnAlignments
{
    for (int i = 0; i < 6 ; i++) {
        columnWidths [i] = _columnWidths[i];
        columnAlignments [i] = _columnAlignments[i];
    }
}

#pragma mark - text1 text2

- (void)printText1:(NSString *)text1 text2:(NSString *)text2 {
    
    text1 = [self emptyStringIfNull:text1];
    text2 = [self emptyStringIfNull:text2];
    [self printWrappedText1:text1 text2:text2];
}


- (void)printWrappedText1:(NSString *)text1 text2:(NSString *)text2 {
    NSArray *text1Segments = [self segmentsForText:text1 width:23];
    NSArray *text2Segments = [self segmentsForText:text2 width:23];
    
    NSInteger segment1Count = text1Segments.count;
    NSInteger segment2Count = text2Segments.count;
    NSInteger segmentCount = MAX(segment1Count, segment2Count);
    
    for (int i = 0; i < segmentCount; i++) {
        NSString *segment1 = nil;
        NSString *segment2 = nil;
        if (i < segment1Count) {
            segment1 = text1Segments[i];
        }
        if (i < segment2Count) {
            segment2 = text2Segments[i];
        }
        [self printSegment1:segment1 segment2:segment2];
    }
}

- (void)printSegment1:(NSString *)text1 segment2:(NSString *)text2 {
    
    if (text1 == nil) {
        text1 = @"";
    }
    
    if (text2 == nil) {
        text2 = @"";
    }
    
    NSString *padding = [[NSString string] stringByPaddingToLength:_printerWidth - text1.length - text2.length withString:@" " startingAtIndex:0];
    
    [self setTextAlignment:TA_LEFT];
    [self printLine:[NSString stringWithFormat:@"%@%@%@", text1, padding, text2]];
}

- (NSArray *)segmentsForText:(NSString*)text width:(NSUInteger)width {
    NSMutableArray *text1Segments = [NSMutableArray array];
    
    if (text.length == 0) {
        return text1Segments;
    }
    
    width = MIN(width, text.length);
    NSRange segmentRange;
    segmentRange.location = 0;
    segmentRange.length = width;
    for (NSString *segment = [text substringWithRange:segmentRange]; segment.length != 0; segment = [text substringWithRange:segmentRange]) {
        [text1Segments addObject:segment];
        
        text = [text substringFromIndex:segmentRange.length];
        width = MIN(width, text.length);
        segmentRange.location = 0;
        segmentRange.length = width;
    }
    
    return text1Segments;
}

#pragma mark - text1 text2 text3

- (void)printText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 {
    text1 = [self emptyStringIfNull:text1];
    text2 = [self emptyStringIfNull:text2];
    text3 = [self emptyStringIfNull:text3];
    [self printWrappedText1:text1 text2:text2 text3:text3];
}

- (void)printWrappedText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 {
    NSArray *text1Segments = [self segmentsForText:text1 width:columnWidths[0]];
    NSArray *text2Segments = [self segmentsForText:text2 width:columnWidths[1]];
    NSArray *text3Segments = [self segmentsForText:text3 width:columnWidths[2]];
    
    NSInteger segment1Count = text1Segments.count;
    NSInteger segment2Count = text2Segments.count;
    NSInteger segment3Count = text3Segments.count;
    NSInteger segmentCount = MAX(segment1Count, segment2Count);
    segmentCount = MAX(segmentCount, segment3Count);
    
    for (int i = 0; i < segmentCount; i++) {
        NSString *segment1 = nil;
        NSString *segment2 = nil;
        NSString *segment3 = nil;
        if (i < segment1Count) {
            segment1 = text1Segments[i];
        }
        if (i < segment2Count) {
            segment2 = text2Segments[i];
        }
        if (i < segment3Count) {
            segment3 = text3Segments[i];
        }
        [self printSegment1:segment1 segment2:segment2 segment3:segment3];
    }
}

- (void)printSegment1:(NSString *)text1 segment2:(NSString *)text2 segment3:(NSString *)text3 {
    
    if (text1 == nil) {
        text1 = @"";
    }
    
    if (text2 == nil) {
        text2 = @"";
    }
    
    if (text3 == nil) {
        text3 = @"";
    }
    
    NSString *segment1;
    NSString *segment2;
    NSString *segment3;
    
    segment1 = [self text:text1 columnWidth:columnWidths[0] alignment:columnAlignments[0]];
    segment2 = [self text:text2 columnWidth:columnWidths[1] alignment:columnAlignments[1]];
    segment3 = [self text:text3 columnWidth:columnWidths[2] alignment:columnAlignments[2]];
    [self setTextAlignment:TA_LEFT];
    
    [self printLine:[NSString stringWithFormat:@"%@ %@ %@", segment1, segment2, segment3]];
}

- (NSString *)text:(NSString *)textValue columnWidth:(NSInteger)columnWidth alignment:(NSInteger)alignment
{
    NSString *segment;
    switch (alignment) {
        case RCAlignmentLeft:
            segment = [self leftAlignedText:textValue columnWidth:columnWidth];
            break;
        case RCAlignmentRight:
            segment = [self rightAlignedText:textValue columnWidth:columnWidth];
            break;
        case RCAlignmentCenter:
            segment = [self centerAlignedText:textValue columnWidth:columnWidth];
            break;
        default:
            break;
    }
    return segment;
}

- (NSString *)rightAlignedText:(NSString *)textValue columnWidth:(NSInteger)columnWidth {
    NSInteger leftPaddingLength = columnWidth - textValue.length;
    NSString *textValue2 = @" ";
    if (leftPaddingLength < 0) {
        leftPaddingLength = 0;
        textValue2 = @"";
    }
    
    textValue2 = [textValue2 stringByPaddingToLength:leftPaddingLength withString:@" " startingAtIndex:0];
    textValue2 = [textValue2 stringByAppendingString:textValue];
    return textValue2;
}

- (NSString *)leftAlignedText:(NSString *)textValue columnWidth:(NSInteger)columnWidth {
    NSInteger leftPaddingLength = columnWidth - textValue.length;
    NSString *textValue2 = @" ";
    if (leftPaddingLength < 0) {
        leftPaddingLength = 0;
        textValue2 = @"";
    }
    
    textValue2 = [textValue2 stringByPaddingToLength:leftPaddingLength withString:@" " startingAtIndex:0];
    textValue2 = [textValue stringByAppendingString:textValue2];
    return textValue2;
}

- (NSString *)centerAlignedText:(NSString *)textValue columnWidth:(NSInteger)columnWidth {
    NSInteger leftPaddingLength = floor((columnWidth - textValue.length) / 2.0);
    NSInteger rightPaddingLength = ceil((columnWidth - textValue.length) / 2.0);
    NSString *leftPadding = nil;
    NSString *rightPadding = nil;
    if (leftPaddingLength < 0) {
        leftPaddingLength = 0;
        leftPadding = @"";
        rightPadding = @" ";
    }
    if (rightPaddingLength < 0) {
        rightPaddingLength = 0;
        rightPadding = @"";
        leftPadding = @" ";
    }
    
    leftPadding = [leftPadding stringByPaddingToLength:leftPaddingLength withString:@" " startingAtIndex:0];
    rightPadding = [leftPadding stringByPaddingToLength:rightPaddingLength withString:@" " startingAtIndex:0];
    NSString *centerAlignedText = [NSString stringWithFormat:@"%@%@%@", leftPadding, textValue, rightPadding];
    return centerAlignedText;
}

#pragma mark - text1 text2 text3 text4

- (void)printText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 text4:(NSString *)text4 {
    text1 = [self emptyStringIfNull:text1];
    text2 = [self emptyStringIfNull:text2];
    text3 = [self emptyStringIfNull:text3];
    text4 = [self emptyStringIfNull:text4];
    
    [self printWrappedText1:text1 text2:text2 text3:text3 text4:text4];
}

// Total width 48, 4 texts with count 11, 11 , 11  and 12. 1 character gap between two texts.

- (void)printWrappedText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 text4:(NSString *)text4{
    NSArray *text1Segments = [self segmentsForText:text1 width:columnWidths[0]];
    NSArray *text2Segments = [self segmentsForText:text2 width:columnWidths[1]];
    NSArray *text3Segments = [self segmentsForText:text3 width:columnWidths[2]];
    NSArray *text4Segments = [self segmentsForText:text4 width:columnWidths[3]];
    
    NSInteger segment1Count = text1Segments.count;
    NSInteger segment2Count = text2Segments.count;
    NSInteger segment3Count = text3Segments.count;
    NSInteger segment4Count = text4Segments.count;
    
    NSInteger segmentCount = MAX(segment1Count, segment2Count);
    segmentCount = MAX(segmentCount, segment3Count);
    segmentCount = MAX(segmentCount, segment4Count);
    
    for (int i = 0; i < segmentCount; i++) {
        NSString *segment1 = nil;
        NSString *segment2 = nil;
        NSString *segment3 = nil;
        NSString *segment4 = nil;
        
        if (i < segment1Count) {
            segment1 = text1Segments[i];
        }
        if (i < segment2Count) {
            segment2 = text2Segments[i];
        }
        if (i < segment3Count) {
            segment3 = text3Segments[i];
        }
        if (i < segment4Count) {
            segment4 = text4Segments[i];
        }
        [self printSegment1:segment1 segment2:segment2 segment3:segment3 segment4:segment4];
    }
}

- (void)printSegment1:(NSString *)text1 segment2:(NSString *)text2 segment3:(NSString *)text3 segment4:(NSString *)text4{
    
    if (text1 == nil) {
        text1 = @"";
    }
    
    if (text2 == nil) {
        text2 = @"";
    }
    
    if (text3 == nil) {
        text3 = @"";
    }
    
    if (text4 == nil) {
        text4 = @"";
    }
    
    NSString *segment1;
    NSString *segment2;
    NSString *segment3;
    NSString *segment4;
    
    segment1 = [self text:text1 columnWidth:columnWidths[0] alignment:columnAlignments[0]];
    segment2 = [self text:text2 columnWidth:columnWidths[1] alignment:columnAlignments[1]];
    segment3 = [self text:text3 columnWidth:columnWidths[2] alignment:columnAlignments[2]];
    segment4 = [self text:text4 columnWidth:columnWidths[3] alignment:columnAlignments[3]];
    
    [self setTextAlignment:TA_LEFT];
    
    [self printLine:[NSString stringWithFormat:@"%@ %@ %@ %@", segment1, segment2, segment3, segment4]];
}

@end
