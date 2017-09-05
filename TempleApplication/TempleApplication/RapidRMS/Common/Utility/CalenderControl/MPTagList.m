

#import "MPTagList.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 5.0f
#define LABEL_MARGIN_DEFAULT 10.0f
#define BOTTOM_MARGIN_DEFAULT 5.0f
#define FONT_SIZE_DEFAULT 12.0f
#define HORIZONTAL_PADDING_DEFAULT 7.0f
#define VERTICAL_PADDING_DEFAULT 3.0f
//#define BACKGROUND_COLOR [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]
#define BACKGROUND_COLOR [UIColor clearColor]
#define TEXT_COLOR [UIColor blackColor]
#define TEXT_SHADOW_COLOR [UIColor whiteColor]
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 1.0f)
#define BORDER_COLOR [UIColor lightGrayColor].CGColor
#define BORDER_WIDTH 1.0f
#define HIGHLIGHTED_BACKGROUND_COLOR [UIColor colorWithRed:0.40 green:0.80 blue:1.00 alpha:0.5]
#define DEFAULT_AUTOMATIC_RESIZE NO

@interface MPTagList()

- (void)touchedTag:(id)sender;

@end

@implementation MPTagList

@synthesize view, textArray, automaticResize;
@synthesize tagDelegate = _tagDelegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.automaticResize = DEFAULT_AUTOMATIC_RESIZE;
        self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
        self.font = [UIFont fontWithName:@"Lato" size:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
        self.font = [UIFont fontWithName:@"Lato" size:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
    }
    return self;
}

- (void)setTags:(NSArray *)array
{
    textArray = [[NSArray alloc] initWithArray:array];
    sizeFit = CGSizeZero;
    if (automaticResize) {
        [self display];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
    }
    else {
        [self setNeedsLayout];
    }
}

- (void)setTagBackgroundColor:(UIColor *)color
{
    lblBackgroundColor = color;
    [self setNeedsLayout];
}
- (void)setTagTextColor:(UIColor *)color
{
    lblTextColor = color;
    [self setNeedsLayout];
}
- (void)setTagImagesColor:(UIImage *)image {
    imgCloseBtn = image;
}
- (void)setTagHighlightColor:(UIColor *)color
{
    self.highlightedBackgroundColor = color;
    [self setNeedsLayout];
}

- (void)setViewOnly:(BOOL)viewOnly
{
    if (_viewOnly != viewOnly) {
        _viewOnly = viewOnly;
        [self setNeedsLayout];
    }
}

- (void)touchedTag:(id)sender
{
    UITapGestureRecognizer *t = (UITapGestureRecognizer *)sender;
    MPTagView *tagView = (MPTagView *)t.view;
    if(tagView && self.tagDelegate && [self.tagDelegate respondsToSelector:@selector(selectedTag:withTabView:)])
        [self.tagDelegate selectedTag:tagView.label.text withTabView:tagView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self display];
}

- (void)display
{
    NSMutableArray *tagViews = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[MPTagView class]]) {
//            MPTagView *tagView = (MPTagView*)subview;
            for (UIGestureRecognizer *gesture in subview.gestureRecognizers) {
                [subview removeGestureRecognizer:gesture];
            }
            
            [tagViews addObject:subview];
        }
        [subview removeFromSuperview];
    }

    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    
    int i=0;
    for (NSString *text in textArray) {
        MPTagView *tagView;
        if (tagViews.count > 0) {
            tagView = tagViews.lastObject;
            tagView.tag = i;
            [tagViews removeLastObject];
        }
        else {
            tagView = [[MPTagView alloc] init];
            tagView.tag = i;
        }
        
        i++;
        
        [tagView updateWithString:text
                           font:self.font
              constrainedToWidth:self.frame.size.width - (self.horizontalPadding * 2)
                        padding:CGSizeMake(self.horizontalPadding, self.verticalPadding)
                     minimumWidth:self.minimumWidth textColor:lblTextColor textImage:imgCloseBtn
         ];
        
        if (gotPreviousFrame) {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + tagView.frame.size.width + self.labelMargin > self.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + tagView.frame.size.height + self.bottomMargin);
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + self.labelMargin, previousFrame.origin.y);
            }
            newRect.size = tagView.frame.size;
            tagView.frame = newRect;
        }

        previousFrame = tagView.frame;
        gotPreviousFrame = YES;

        tagView.backgroundColor = [self getBackgroundColor];

//        // Davide Cenzi, added gesture recognizer to label
//        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTag:)];
//        // if labelView is not set userInteractionEnabled, you must do so
//        [tagView setUserInteractionEnabled:YES];
//        [tagView addGestureRecognizer:gesture];
//        
        [self addSubview:tagView];
//
//        if (!_viewOnly) {
//            [tagView.button addTarget:self action:@selector(touchDownInside:) forControlEvents:UIControlEventTouchDown];
//            [tagView.button addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//            [tagView.button addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
//            [tagView.button addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
//        }

    }

    if (textArray.count==0)
    {
        sizeFit = CGSizeMake(self.frame.size.width, previousFrame.origin.y + previousFrame.size.height );
        
    }
    else
    {
        sizeFit = CGSizeMake(self.frame.size.width, previousFrame.origin.y + previousFrame.size.height + self.bottomMargin + 1.0f);
    }
    self.contentSize = sizeFit;
}

- (CGSize)fittedSize
{
    return sizeFit;
}

- (void)touchDownInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.superview.backgroundColor = self.highlightedBackgroundColor;
}

- (void)touchUpInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.superview.backgroundColor = [self getBackgroundColor];
    if(button && self.tagDelegate && [self.tagDelegate respondsToSelector:@selector(selectedTag:withTabView:)])
        [self.tagDelegate selectedTag:button.accessibilityLabel withTabView:[sender superview]];
}

- (void)touchDragExit:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.superview.backgroundColor = [self getBackgroundColor];
}

- (void)touchDragInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.superview.backgroundColor = [self getBackgroundColor];
}
     
- (UIColor *)getBackgroundColor
{
     if (!lblBackgroundColor) {
         return BACKGROUND_COLOR;
     } else {
         return lblBackgroundColor;
     }
}

- (void)dealloc
{
    view = nil;
    textArray = nil;
    lblBackgroundColor = nil;
}

@end


@implementation MPTagView

- (instancetype)init {
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_label setTextColor:TEXT_COLOR];
        [_label setShadowColor:TEXT_SHADOW_COLOR];
        [_label setShadowOffset:TEXT_SHADOW_OFFSET];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setImage:[UIImage imageNamed:@"RIM_Close_20px_sel"] forState:UIControlStateHighlighted];
        [_button setImage:[UIImage imageNamed:@"RIM_Close_20px"] forState:UIControlStateNormal];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_button addTarget:self action:@selector(touchedTag:) forControlEvents:UIControlEventTouchUpInside];
//        [_button setFrame:self.frame];
        [self addSubview:_button];
        
        [self.layer setMasksToBounds:YES];
//        [self.layer setCornerRadius:CORNER_RADIUS];
//        [self.layer setBorderColor:BORDER_COLOR];
//        [self.layer setBorderWidth: BORDER_WIDTH];
    }
    return self;
}

- (void)updateWithString:(NSString*)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth textColor:(UIColor *) textColor textImage:(UIImage *) textImage
{
    //CGSize textSize = [text sizeWithFont:font forWidth:maxWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;
    
    CGRect calculatedRect = [text boundingRectWithSize:CGSizeMake(maxWidth, 500) options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:attributes context:[[NSStringDrawingContext alloc] init]];
    
    CGSize textSize = calculatedRect.size;

    textSize.width = MAX(textSize.width, minimumWidth)+25;
    textSize.height += padding.height*2;
    textSize.height = 20;
//    textSize.height = (textSize.height >=20 )? textSize.height:20;
    self.frame = CGRectMake(0, 0, textSize.width+padding.width*2, textSize.height);
    _label.frame = CGRectMake(padding.width, 0, MIN(textSize.width-25, self.frame.size.width), textSize.height);
    _label.font = font;
    _label.text = text;
    _label.shadowColor = [UIColor clearColor];
    if (textColor) {
        _label.textColor = textColor;
    }

    _button.frame = CGRectMake(_label.frame.origin.x+_label.frame.size.width , 0 , 25, textSize.height);
    if (textImage) {
        [_button setImage:textImage forState:UIControlStateNormal];
    }
//    [_button setAccessibilityLabel:self.label.text];
}

- (void)setLabelText:(NSString*)text
{
    _label.text = text;
}

- (void)touchedTag:(id)sender
{
    MPTagView *tagView = (MPTagView *)[sender superview];
    MPTagList *tagList = (MPTagList *)[sender superview].superview;
    if(tagView && tagList.tagDelegate && [tagList.tagDelegate respondsToSelector:@selector(selectedTag:withTabView:)])
        [tagList.tagDelegate selectedTag:tagView.label.text withTabView:self];
}

- (void)dealloc
{
    _label = nil;
    _button = nil;
}

@end
