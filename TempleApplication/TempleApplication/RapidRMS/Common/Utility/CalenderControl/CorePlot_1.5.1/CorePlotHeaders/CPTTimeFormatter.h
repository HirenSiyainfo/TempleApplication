/// @file

@interface CPTTimeFormatter : NSNumberFormatter {
    @private
    NSDateFormatter *dateFormatter;
    NSDate *referenceDate;
}

@property (nonatomic, readwrite, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite, copy) NSDate *referenceDate;

/// @name Initialization
/// @{
-(instancetype)initWithDateFormatter:(NSDateFormatter *)aDateFormatter;
/// @}

@end
