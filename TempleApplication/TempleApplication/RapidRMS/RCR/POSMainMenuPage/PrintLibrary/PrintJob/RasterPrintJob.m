//
//  RasterPrintJob.m
//  RasterPrintApp
//
//  Created by siya info on 10/09/15.
//  Copyright (c) 2015 siya info. All rights reserved.
//

#import "RasterPrintJob.h"
#import "RasterDocument.h"
#import "StarBitmap.h"

@interface RasterPrintJob () {
    RasterDocument *rasterDoc;
    UIColor *backgroundColor;
    UIColor *textcolor;
    TEXT_ALIGNMENT rasterTextAlignment;
}

@end

@implementation RasterPrintJob

- (instancetype)initWithPort:(NSString *)portName portSettings:(NSString *)portSettings deviceName:(NSString *)deviceName withDelegate:(id)delegate  {
    self = [super initWithPort:portName portSettings:portSettings deviceName:deviceName withDelegate:delegate];
    if (self) {
        [self rasterPrinterBegin];
    }
    return self;
}

- (void)printImage:(UIImage *)imageToPrint {
//    NSData *imageCommand;
//    int maxWidth = 576;
//    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:imageToPrint :maxWidth :false];
//    imageCommand = [starbitmap getImageDataForPrinting:YES];
//    [self addCommand:imageCommand];
}

- (void)rasterPrinterBegin {
    backgroundColor = [UIColor whiteColor];
    textcolor = [UIColor blackColor];
    [self enableBold:NO];
//    rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_FeedAndFullCut endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut topMargin:RasTopMargin_Standard pageLength:0 leftMargin:0 rightMargin:0];

//    NSData *shortcommand = rasterDoc.BeginDocumentCommandData;
//    [self addCommand:shortcommand];
}

- (void)rasterPrinterEnd {
//    NSData *shortcommand2 = rasterDoc.EndDocumentCommandData;
//    [self addCommand:shortcommand2];
}

/*
- (UIImage *)imageFromAttributedString:(NSAttributedString *)rasterPrintingText
{
    NSStringDrawingOptions drawingOptions = (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
    NSStringDrawingContext *stringDrawingContext = [[NSStringDrawingContext alloc] init];
    
    CGRect boundingRect = [rasterPrintingText boundingRectWithSize:CGSizeMake(576, 10000) options:drawingOptions context:stringDrawingContext];
    
    if ((boundingRect.size.height == 0) || (boundingRect.size.width == 0)) {
        NSAttributedString *erroMessage = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Some error occured while printing.\nText length = %lu\nBounding Rect = %@\n", (unsigned long)[rasterPrintingText length], NSStringFromCGRect(boundingRect)]];
        
        // Get bounding rect for the error message
        boundingRect = [erroMessage boundingRectWithSize:boundingRect.size options:drawingOptions context:stringDrawingContext];
        return nil;
    }

    CGFloat xOffset = 576 - boundingRect.size.width;
    boundingRect.size.width = 576;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) { //Retina
            UIGraphicsBeginImageContextWithOptions(boundingRect.size, NO, 1.0);
        } else { //Non Retina
            UIGraphicsBeginImageContext(boundingRect.size);
        }
    } else {
        UIGraphicsBeginImageContext(boundingRect.size);
    }
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    [backgroundColor set];
    
    CGRect rect = CGRectMake(0, 0, boundingRect.size.width + 1, boundingRect.size.height + 1);
    CGContextFillRect(ctr, rect);
//
//    [textcolor set];
    
//    [rasterPrintingText drawWithRect:boundingRect options:drawingOptions context:stringDrawingContext];
    switch (rasterTextAlignment) {
        case TA_LEFT:
            xOffset = 0;
            break;
        case TA_CENTER:
            xOffset = xOffset/2;
            break;
        case TA_RIGHT:
            xOffset = xOffset;
            break;
        default:
            break;
    }
    [rasterPrintingText drawAtPoint:CGPointMake(xOffset, 0)];
    
    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageToPrint;
}
*/

- (void)printLine:(NSString*)text
{
    if (text == nil || [text isEqualToString:@""]) {
        text = @" ";
    }
    columnWidths[0] = 48;
    columnAlignments[0] = rasterTextAlignment;
    NSArray *texts = @[text];
    [self printRasterTextRow:texts];
}

- (void)printSeparator {
    [self setTextAlignment:TA_LEFT];
    [self printImage:[UIImage imageNamed:@"dittedline.png"]];
}

- (void)firePrint {
    [self rasterPrinterEnd];
    [super firePrint];
}

//- (void)printText:(NSString*)text
//{
//
//}
//

// Bar Code
- (void)printBarCode:(NSString*)barcode
{
    //[UIImage imageNamed:@"qrCode.png"]
    UIImage *barcodeImage =[self generateBarCodeWithString:barcode];
    barcodeImage = [self centerAlignImage:barcodeImage];
    [self printImage:barcodeImage];
}

- (UIImage *)generateBarCodeWithString:(NSString *)string {
    NSData *stringData = [string dataUsingEncoding:NSASCIIStringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    UIImage *barcodeImage = [self imageFromFilter:filter];
    return barcodeImage;
}

// QR Code
- (void)printQRCodeText:(NSString *)qrCodeText model:(NSInteger)model correction:(NSInteger)correction cellSize:(NSInteger)cellSize {
    [self printQRCode:qrCodeText];
}

- (void)printQRCode:(NSString*)qrCodeText
{
    UIImage *qrCodeImage =[self generateQRCodeWithString:qrCodeText];
    qrCodeImage = [self centerAlignImage:qrCodeImage];
    [self printImage:qrCodeImage];
}

- (UIImage *)generateQRCodeWithString:(NSString *)string {
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    UIImage *qrCodeImage = [self imageFromFilter:filter];
    return qrCodeImage;
}

- (UIImage *)imageFromFilter:(CIFilter *)filter {
    CGRect extent = filter.outputImage.extent;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:filter.outputImage fromRect:extent];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    if ([filter.name isEqualToString:@"CIQRCodeGenerator"]) {
        image = [self resizeImage:image size:CGSizeMake(image.size.width * 8, image.size.height * 8)];
    }
    else
    {
        image = [self resizeImage:image size:CGSizeMake(extent.size.width * 3, extent.size.height * 3)];
    }
    CGImageRelease(cgImage);
    return image;
}

-(UIImage *)resizeImage:(UIImage*)img size:(CGSize)newSize
{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)centerAlignImage:(UIImage *)image
{
    CGFloat maxWidth = 576;
    CGFloat xOffset = (maxWidth/2) - (image.size.width/2);
    CGRect imageRect = CGRectMake(xOffset, 0, maxWidth, image.size.height);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([UIScreen mainScreen].scale == 2.0) { //Retina
            UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 1.0);
        } else { //Non Retina
            UIGraphicsBeginImageContext(imageRect.size);
        }
    } else {
        UIGraphicsBeginImageContext(imageRect.size);
    }
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    [backgroundColor set];
    
    CGRect rect = CGRectMake(0, 0, imageRect.size.width + 1, imageRect.size.height + 1);
    CGContextFillRect(ctr, rect);
    
    [image drawAtPoint:CGPointMake(xOffset, 0)];

    UIImage *centerAlignImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return centerAlignImage;
}
//
//- (void)cutPaper:(PAPER_CUT_MODES)mode
//{
//
//}

- (void)enableSlashedZero:(BOOL)enable
{

}

- (void)enableUnderline:(BOOL)enable
{

}

- (void)enableInvertColor:(BOOL)enable
{
    if (enable) {
        backgroundColor = [UIColor blackColor];
        textcolor = [UIColor whiteColor];
    }
    else
    {
        backgroundColor = [UIColor whiteColor];
        textcolor = [UIColor blackColor];
    }
}

- (void)enableBold:(BOOL)enable
{
    if (enable) {
        self.rasterPrintingFont = [UIFont boldSystemFontOfSize:24.0];
    }
    else
    {
        self.rasterPrintingFont = [UIFont systemFontOfSize:24.0];
    }
}

- (void)enableUpperline:(BOOL)enable
{

}

- (void)enableUpsideDown:(BOOL)enable
{

}

- (void)setHeightExpansion:(uint8_t)characterHeight
{

}

- (void)setWidthExpansion:(uint8_t)characterWidth
{

}

- (void)setTextSize:(UInt8)textSize
{

}

- (void)setLeftMargin:(uint8_t)margin
{

}

- (void)setTextAlignment:(TEXT_ALIGNMENT)alignment
{
    rasterTextAlignment = alignment;
}

// Raster mode printing

//- (void)printImage:(UIImage*)image
//{
//
//}


//- (void)setFont:(UIFont*)font
//{
//
//}



#pragma mark - IP Printing

- (void)printRasterTextRow:(NSArray *)texts {
    NSMutableArray *attributedTexts = [NSMutableArray array];
    CGRect columnRects[6];
    
    CGFloat maxRectHeight = 10000;
    CGFloat pixelValuePerChar = 12.0; // 48 characters are printed in LinePrinting mode in 576 pixels
    
    for (int i = 0; i < texts.count && i < 6; i++) {
        NSDictionary *attributes = @{NSFontAttributeName:self.rasterPrintingFont, NSForegroundColorAttributeName:textcolor,NSBackgroundColorAttributeName:backgroundColor,};
        
        NSAttributedString *rasterPrintingText = [[NSAttributedString alloc] initWithString:texts[i] attributes:attributes];
        [attributedTexts addObject:rasterPrintingText];
        
        CGFloat xOffset = 0;
        
        if (i > 0) {
            CGRect previousRect = columnRects[i - 1];
            xOffset = previousRect.origin.x + previousRect.size.width + pixelValuePerChar;
        }
        columnRects[i] = CGRectMake(xOffset, 0, columnWidths[i] * pixelValuePerChar, maxRectHeight);
    }
    
    UIImage *image = [self imageFromAttributedTexts:attributedTexts columnRects:columnRects];
    [self printImage:image];
}

- (void)printWrappedText1:(NSString *)text1 text2:(NSString *)text2 {
    NSArray *texts = @[text1, text2];
    [self printRasterTextRow:texts];
}

- (void)printWrappedText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 {
    NSArray *texts = @[text1, text2, text3];
    [self printRasterTextRow:texts];
}

- (void)printWrappedText1:(NSString *)text1 text2:(NSString *)text2 text3:(NSString *)text3 text4:(NSString *)text4 {
    NSArray *texts = @[text1, text2, text3, text4];
    [self printRasterTextRow:texts];
}


- (CGRect)boundingRectForRasterPrintingText:(NSAttributedString *)rasterPrintingText
inRect:(CGRect)boundingRect
{
    NSStringDrawingOptions drawingOptions = (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
    NSStringDrawingContext *stringDrawingContext = [[NSStringDrawingContext alloc] init];
    
    CGRect calculatedBoundingRect = [rasterPrintingText boundingRectWithSize:boundingRect.size options:drawingOptions context:stringDrawingContext];
    
    if ((calculatedBoundingRect.size.height == 0) || (calculatedBoundingRect.size.width == 0)) {
//        NSAttributedString *erroMessage = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Some error occured while printing.\nText length = %lu\nBounding Rect = %@\n", (unsigned long)[rasterPrintingText length], NSStringFromCGRect(calculatedBoundingRect)]];
        
        // Get bounding rect for the error message
        //        rasterPrintingText = erroMessage;
        //        calculatedBoundingRect = [rasterPrintingText boundingRectWithSize:boundingRect.size options:drawingOptions context:stringDrawingContext];
    }
    return calculatedBoundingRect;
}

- (void)drawText:(NSAttributedString *)rasterPrintingText inRect:(CGRect)boundingRect textAlignment:(TEXT_ALIGNMENT)textAlignment
{
    CGRect calculatedBoundingRect;
    calculatedBoundingRect = [self boundingRectForRasterPrintingText:rasterPrintingText inRect:boundingRect];
    
    CGFloat boundingRectWidth = boundingRect.size.width;
    CGFloat xOffset = boundingRectWidth - calculatedBoundingRect.size.width;

    switch (textAlignment) {
        case TA_LEFT:
            xOffset = 0;
            break;
        case TA_CENTER:
            xOffset = xOffset/2;
            break;
        case TA_RIGHT:
            xOffset = xOffset;
            break;
        default:
            break;
    }
    
    boundingRect.origin.x += xOffset;
    [rasterPrintingText drawInRect:boundingRect];
}

- (UIImage *)imageFromAttributedTexts:(NSMutableArray *)attributedTexts columnRects:(CGRect[6])columnRects
{
    CGFloat maxHeight = 0;
    for (int i = 0; i < attributedTexts.count; i++) {
        CGRect boundingRect = columnRects[i];
        boundingRect = [self boundingRectForRasterPrintingText:attributedTexts[i] inRect:boundingRect];
        maxHeight = MAX(maxHeight, boundingRect.size.height);
    }
    CGSize paperSize = CGSizeMake(576, maxHeight);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([UIScreen mainScreen].scale == 2.0) { //Retina
            UIGraphicsBeginImageContextWithOptions(paperSize, NO, 1.0);
        } else { //Non Retina
            UIGraphicsBeginImageContext(paperSize);
        }
    } else {
        UIGraphicsBeginImageContext(paperSize);
    }
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    [backgroundColor set];
    
    CGRect rect = CGRectMake(0, 0, paperSize.width + 1, paperSize.height + 1);
    CGContextFillRect(ctr, rect);


    for (int i = 0; i < attributedTexts.count; i++) {
        CGRect boundingRect = columnRects[i];
        NSAttributedString *rasterPrintingText = attributedTexts[i];
        TEXT_ALIGNMENT textAlignment = (TEXT_ALIGNMENT) columnAlignments[i];
        [self drawText:rasterPrintingText inRect:boundingRect textAlignment:textAlignment];
    }

    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return imageToPrint;
}



/*
 */

@end
