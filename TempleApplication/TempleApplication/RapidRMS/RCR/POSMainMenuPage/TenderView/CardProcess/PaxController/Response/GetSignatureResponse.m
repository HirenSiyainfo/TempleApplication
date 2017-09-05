//
//  GetSignatureResponse.m
//  PaxControllerApp
//
//  Created by siya info on 28/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GetSignatureResponse.h"
#import "PaxResponse+Internal.h"
#import <UIKit/UIKit.h>


@implementation SignaturePoint

- (instancetype)initWithX:(float)x y:(float)y {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
    }
    return self;
}

- (instancetype)initWithString:(NSString*)xCommaY {
    NSArray *coordinates = [xCommaY componentsSeparatedByString:@","];

    if (coordinates.count != 1) {
        self = nil;
    } else {
        self = [self initWithXValue:coordinates[0] yValue:coordinates[1]];
    }

    return self;
}

- (instancetype)initWithXValue:(NSString*)x yValue:(NSString*)y {
    self = [self initWithX:x.floatValue y:y.floatValue];
    return self;
}

@end

@interface GetSignatureResponse () {
    float _maxX;
    float _maxY;
}

@end

@implementation GetSignatureResponse
- (void)setupMessageFormat {
    responseMessageFields = @[
                              @(FieldIndexMultiPacket),
                              @(FieldIndexCommandType),
                              @(FieldIndexVersion),
                              @(FieldIndexResponseCode),
                              @(FieldIndexResponseMessage),
                              @(FieldIndexSignatureTotalLength),
                              @(FieldIndexSignatureResponseLength),
                              @(FieldIndexSignature),
                              ];
}

- (void)parseFieldData:(NSData *)fieldData forFieldId:(FieldIndex)fieldId {
    switch (fieldId) {
        case FieldIndexSignatureTotalLength:
            [self parseSignatureTotalLength:fieldData];

            break;
        case FieldIndexSignatureResponseLength:
            [self parseSignatureResponseLength:fieldData];

            break;
        case FieldIndexSignature:
            [self parseSignature:fieldData];

            break;
        default:
            [super parseFieldData:fieldData forFieldId:fieldId];
            break;
    }
}

- (void)parseSignatureTotalLength:(NSData *)data {
    // Serial Number : M : ans3
//    NSUInteger length = 3;
//    _serialNumber = [self anStringFrom:0 maxLength:length data:data];
}

- (void)parseSignatureResponseLength:(NSData *)data {
    // Serial Number : M : ans3
//    NSUInteger length = 3;
//    _serialNumber = [self anStringFrom:0 maxLength:length data:data];
}

- (void)parseSignature:(NSData *)data {
    // Signature : O : no length
    // Assume it to be ASCII text
    NSString *signatureString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    NSArray *coordinates = [signatureString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",^~"]];
    NSInteger count = coordinates.count;

    if ((count % 2) == 1) {
        count--;
    }

    NSMutableArray *signaturePoints = [NSMutableArray array];

    // Bounds
    _maxX = 0;
    _maxY = 0;

    for (int index = 0; index < count; index += 2) {
        NSString *xValue = coordinates[index];
        NSString *yValue = coordinates[index + 1];
        if ((xValue.length == 0) || (yValue.length == 0)) {
            // Discard blank values
            continue;
        }
        SignaturePoint *point = [[SignaturePoint alloc] initWithXValue:xValue yValue:yValue];
        [signaturePoints addObject:point];

        if (point.y == 65535) {
            continue;
        }
        _maxX = MAX(_maxX, point.x);
        _maxY = MAX(_maxY, point.y);
    }
    _signaturePoints = [NSArray arrayWithArray:signaturePoints];
}


- (UIImage*)signatureImage {
    CGPoint penupPoint = CGPointMake(0, 65535);
    UIImage *signatureImage;
    CGPoint previousPoint = penupPoint;
    UIBezierPath *signPath = [[UIBezierPath alloc] init];

    signPath.lineWidth = 2;
    signPath.lineCapStyle = kCGLineCapRound;
    signPath.lineJoinStyle = kCGLineJoinRound;


   // UIGraphicsBeginImageContextWithOptions(CGSizeMake(400, 400), NO, 1);
     UIGraphicsBeginImageContext(CGSizeMake(_maxX + 5, _maxY + 5));
    [[UIColor blackColor] setStroke];
   
    CGRect rect = CGRectMake(0, 0, _maxX + 5, _maxY + 5);
    UIBezierPath *shape1 = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor whiteColor] setFill];
    [shape1 fill];
    
    for (SignaturePoint *aPoint in _signaturePoints) {
        CGPoint currentPoint = CGPointMake(aPoint.x, aPoint.y);

        if (CGPointEqualToPoint(currentPoint, penupPoint)) {
            // This is pen-up
            // Just skip it
            previousPoint = currentPoint;
            continue;
        }

        if (CGPointEqualToPoint(previousPoint, penupPoint)) {
            // Previous one was pen-up
            // Move to this point
            [signPath moveToPoint:currentPoint];
        } else {
            [signPath addLineToPoint:currentPoint];
        }
        previousPoint = currentPoint;
    }

    [signPath stroke];

    signatureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return signatureImage;
}

@end
