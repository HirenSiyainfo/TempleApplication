/// @file

#if __cplusplus
extern "C" {
#endif


CF_IMPLICIT_BRIDGING_ENABLED

CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat cornerRadius);

CF_IMPLICIT_BRIDGING_DISABLED

void AddRoundedRectPath(CGContextRef context, CGRect rect, CGFloat cornerRadius);

#if __cplusplus
}
#endif
