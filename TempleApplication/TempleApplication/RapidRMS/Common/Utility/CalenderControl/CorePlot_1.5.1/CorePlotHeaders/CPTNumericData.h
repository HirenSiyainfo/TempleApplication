#import "CPTNumericDataType.h"

@interface CPTNumericData : NSObject<NSCopying, NSMutableCopying, NSCoding> {
    @protected
    NSData *data;
    CPTNumericDataType dataType;
    NSArray *shape; // array of dimension shapes (NSNumber<unsigned>)
    CPTDataOrder dataOrder;
}

/// @name Data Buffer
/// @{
@property (readonly, copy) NSData *data;
@property (readonly, assign) const void *bytes;
@property (readonly, assign) NSUInteger length;
/// @}

/// @name Data Format
/// @{
@property (readonly, assign) CPTNumericDataType dataType;
@property (readonly, assign) CPTDataTypeFormat dataTypeFormat;
@property (readonly, assign) size_t sampleBytes;
@property (readonly, assign) CFByteOrder byteOrder;
/// @}

/// @name Dimensions
/// @{
@property (readonly, copy) NSArray *shape;
@property (readonly, assign) NSUInteger numberOfDimensions;
@property (readonly, assign) NSUInteger numberOfSamples;
@property (readonly, assign) CPTDataOrder dataOrder;
/// @}

/// @name Factory Methods
/// @{
+(instancetype)numericDataWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;
+(instancetype)numericDataWithData:(NSData *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray;
+(instancetype)numericDataWithArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;
+(instancetype)numericDataWithArray:(NSArray *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray;

+(instancetype)numericDataWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
+(instancetype)numericDataWithData:(NSData *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
+(instancetype)numericDataWithArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
+(instancetype)numericDataWithArray:(NSArray *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;
-(instancetype)initWithData:(NSData *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray;
-(instancetype)initWithArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray;
-(instancetype)initWithArray:(NSArray *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray;

-(instancetype)initWithData:(NSData *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
-(instancetype)initWithData:(NSData *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
-(instancetype)initWithArray:(NSArray *)newData dataType:(CPTNumericDataType)newDataType shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
-(instancetype)initWithArray:(NSArray *)newData dataTypeString:(NSString *)newDataTypeString shape:(NSArray *)shapeArray dataOrder:(CPTDataOrder)order;
/// @}

/// @name Samples
/// @{
-(NSUInteger)sampleIndex:(NSUInteger)idx, ...;
-(void *)samplePointer:(NSUInteger)sample NS_RETURNS_INNER_POINTER;
-(void *)samplePointerAtIndex:(NSUInteger)idx, ... NS_RETURNS_INNER_POINTER;
-(NSNumber *)sampleValue:(NSUInteger)sample;
-(NSNumber *)sampleValueAtIndex:(NSUInteger)idx, ...;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *sampleArray;
/// @}

@end
