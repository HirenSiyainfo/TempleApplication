@interface CPTColorSpace : NSObject<NSCoding> {
    @private
    CGColorSpaceRef cgColorSpace;
}

@property (nonatomic, readonly, assign) CGColorSpaceRef cgColorSpace;

/// @name Factory Methods
/// @{
+(CPTColorSpace *)genericRGBSpace;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithCGColorSpace:(CGColorSpaceRef)colorSpace;
/// @}

@end
