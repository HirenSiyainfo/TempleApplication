/// @file

#if __cplusplus
extern "C" {
#endif

/// @name Graphics Context Save Stack
/// @{
void CPTPushCGContext(CGContextRef context);
void CPTPopCGContext(void);

/// @}

/// @name Graphics Context
/// @{

CF_IMPLICIT_BRIDGING_ENABLED

CGContextRef CPTGetCurrentContext(void);

CF_IMPLICIT_BRIDGING_DISABLED


/// @}

#if __cplusplus
}
#endif
