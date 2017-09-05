//
//  FlowerMenuView.m
//  FlowerMenuApp
//
//  Created by Siya Infotech on 04/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "FlowerMenuView.h"


typedef NS_ENUM(unsigned int, FLOWER_TYPE) {
    // FULL VIEW
    FULL,

    // QUARTER VIEW
    FIRST_QUDRANT,
    SECOND_QUDRANT,
    THIRD_QUDRANT,
    FOURTH_QUDRANT,

    // HALF VIEW
    FIRST_QUDRANT_HALF,
    SECOND_QUDRANT_HALF,
    THIRD_QUDRANT_HALF,
    FOURTH_QUDRANT_HALF,
};

#define CENTER_POINT(r) CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r))

@interface FlowerMenuView () {
    BOOL touchedInside;
    BOOL isDragging;
    CGPoint touchOffset;
    CGFloat selfRadius;
    CGFloat idleTime;
    UIImageView *anchorView;
    UIImageView *userGuideImageView;

    CGRect originalFrame;
    CGRect bloomFrame;
    BOOL isBlooming;
    FLOWER_TYPE flowerType;

    CGFloat offsetDueToAnchorPoint;
    
    BOOL firsttimeDisplayText;
}

@property (nonatomic, strong) NSTimer *idleTimer;
@property (nonatomic, weak) id<FlowerMenuViewDelegate> menuViewDelegate;

@property (nonatomic, strong) NSMutableArray *menuButtons;

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *normalImages;
@property (nonatomic, strong) NSArray *selectedImages;
@property (nonatomic, strong) NSArray *disabledImages;
@property (nonatomic, strong) NSMutableArray *anchorPoints;
@property (nonatomic, strong) NSMutableArray *offsets;

@property (nonatomic, assign) BOOL isFirstTimeSetup;

// Dynamic snap behaviour
@property (nonatomic, strong) UIDynamicAnimator *snapAnimator;
@property (nonatomic) CGPoint lastPoint;
@end

@implementation FlowerMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupMenuView];
    }
    return self;
}

- (void)awakeFromNib {
    [self setupMenuView];
}

#pragma mark - View
- (void)makeItRound:(UIView*)view {
    CGFloat viewRadius = (view.frame.size.width > view.frame.size.height ? view.frame.size.width : view.frame.size.height);
    CGRect selfFrame = view.frame;
    CGPoint selfCenter = view.center;
    
    selfFrame.size.height = viewRadius;
    selfFrame.size.width = viewRadius;
    viewRadius /= 2.0;
    
    view.layer.cornerRadius = viewRadius;
    
    view.frame = selfFrame;
    view.center = selfCenter;
}

- (void)addAnchorView {
    anchorView = [[UIImageView alloc] initWithFrame:self.bounds];
    anchorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:anchorView];
    anchorView.image = [UIImage imageNamed:@"rmsbtn.png"];

    CGPoint centerPoint = anchorView.center;
    CGRect anchorFrame = anchorView.frame;
    anchorFrame.size.width -= 10;
    anchorFrame.size.height -= 10;
    anchorView.frame = anchorFrame;
    anchorView.center = centerPoint;

  //  anchorView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
}

- (void)snapToPoint:(CGPoint)somePoint {
    [self.snapAnimator removeAllBehaviors];
    UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self snapToPoint:somePoint];
    [self.snapAnimator addBehavior:snapBehaviour];
}

- (void)attachToPoint:(CGPoint)somePoint {
    // Do nothing - REVISIT
//    UIAttachmentBehavior *attachBehaviour = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:somePoint];
//    [self.snapAnimator addBehavior:attachBehaviour];
}

- (void)setupMenuView {
    
    firsttimeDisplayText=YES;
    self.clipsToBounds = YES;
    touchedInside = NO;
    isDragging = NO;
    touchOffset = CGPointZero;
    isBlooming = NO;
    offsetDueToAnchorPoint = 0.0;

    [self addAnchorView];
    [self makeItRound:self];
    [self makeItRound:anchorView];
    selfRadius = MAX(self.frame.size.width, self.frame.size.height) / 2.0;
    originalFrame = self.bounds;

    bloomFrame = originalFrame;
    bloomFrame.size.width *= (3 * self.bloomFactor);
    bloomFrame.size.height *= (3 * self.bloomFactor);
    

    idleTime = 3.0;
    [self startIdleTimer];



    // Dynamic snap behaviour
    self.snapAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    [self setAnchorPoint];

//    [self snapToPoint:self.superview.center];



    CGRect imageviewFrame = bloomFrame;
    
    imageviewFrame.size.width *= 0.5;
    imageviewFrame.size.height *= 0.5;
    
    imageviewFrame.origin = CGPointZero;
    userGuideImageView=[[UIImageView alloc]initWithFrame:imageviewFrame];
    userGuideImageView.tag=1001;
    userGuideImageView.autoresizingMask=UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    userGuideImageView.contentMode = UIViewContentModeBottomLeft;
    userGuideImageView.image = [UIImage imageNamed:@"f_moreApps.png"];
    [self addSubview:userGuideImageView];
}

#pragma mark - Timer
- (void)startIdleTimer {
    self.idleTimer = [NSTimer scheduledTimerWithTimeInterval:idleTime target:self selector:@selector(idleTimerFired:) userInfo:nil repeats:NO];
}

- (void)stopIdleTimer {
    [self.idleTimer invalidate];
    self.idleTimer = nil;
}

- (void)idleTimerFired:(NSTimer*)timer {
    self.idleTimer = nil;
    [self fadeOut];
    [self closeIt];
}

#pragma mark - Point utility
- (BOOL)isPoint:(CGPoint)touchPoint insideViewFrame:(CGRect)viewFrame {
    BOOL isPointInside;

   // isPointInside = CGRectContainsPoint(viewFrame, touchPoint);
    isPointInside = (selfRadius >= [self distanceOfPoint:touchPoint fromPoint:CENTER_POINT(viewFrame)]);

    return isPointInside;
}

- (CGPoint)offsetOfPoint:(CGPoint)point fromPoint:(CGPoint)fromPoint {
    CGPoint offset;
    offset.x = point.x - fromPoint.x;
    offset.y = point.y - fromPoint.y;
    return offset;
}

- (CGPoint)movePoint:(CGPoint)point byOffset:(CGPoint)offset {
    CGPoint movedPoint;
    movedPoint.x = point.x + offset.x;
    movedPoint.y = point.y + offset.y;
    return movedPoint;
}

- (CGFloat)distanceOfPoint:(CGPoint)point fromPoint:(CGPoint)anotherPoint {
    CGPoint offset = [self offsetOfPoint:point fromPoint:anotherPoint];
    CGFloat distance = offset.x * offset.x + offset.y * offset.y;
    distance = sqrtf(distance);
    return distance;
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Only when it is 1
    if (touches.count == 1) {
        // Check if in rect
        UITouch *touch = [touches anyObject];
        // Point in super view
        CGPoint touchPoint = [touch locationInView:self.superview];
        // Check if it belongs to this view
        CGRect viewFrame = self.frame;
        if ([self isPoint:touchPoint insideViewFrame:viewFrame]) {
            [self didBeginTouch];
            // Get the off set
            touchOffset = [self offsetOfPoint:self.center fromPoint:touchPoint]; //self.center - touchPoint;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touchedInside) {
        [self didBeginDrag];

        if (touches.count == 1) {
            // Check if in rect
            UITouch *touch = [touches anyObject];
            // Point in super view
            CGPoint touchPoint = [touch locationInView:self.superview];
            self.center = [self movePoint:touchPoint byOffset:touchOffset];
//            [self updateMenuButtonPositions];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    // Point in super view
    CGPoint touchPoint = [touch locationInView:self.superview];
    self.lastPoint = [self movePoint:touchPoint byOffset:touchOffset];
    [self checkTouchFinal];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self checkTouchFinal];
}

- (void)checkTouchFinal {
    if (touchedInside) {
        [self didEndTouch];
    }
    if (isDragging) {
        [self didEndDrag];
    }
}

- (void)didBeginTouch {
    [self.superview bringSubviewToFront:self];
    [self fadeIn];
    [self stopIdleTimer];
//    self.backgroundColor = [UIColor greenColor];
    touchedInside = YES;
}

- (void)didEndTouch {
    
    
    [self startIdleTimer];
//    self.backgroundColor = [UIColor redColor];
    if (!isDragging) {
        if (isBlooming) {
            [self closeIt];
        }
        else
        {
            [self bloomIt];
        }
    }
    touchedInside = NO;
}

- (void)didBeginDrag {
    isDragging = YES;
}

- (void)setAnchorPoint {
    //    - (void)updateItemUsingCurrentState:(id<UIDynamicItem>)item
    //    [self.snapAnimator updateItemUsingCurrentState:self];
    
    
    CGFloat xPadding = anchorView.frame.size.width - 8;
    CGFloat yPadding = anchorView.frame.size.height - 15;
    
    self.anchorPoints = [NSMutableArray array];
    self.offsets = [NSMutableArray array];
    CGRect superViewFrame = self.superview.frame;
    CGFloat width = (superViewFrame.size.width - 2 * xPadding) / 2;
    CGFloat height = (superViewFrame.size.height - 2 * yPadding) / 2;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            [self.anchorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(width * i + xPadding, height * j + yPadding)]];
            NSNumber *offsetValue;
            offsetValue = [self offsetValueFor:i j:j];
            [self.offsets addObject:offsetValue];
        }
    }
}

- (void)snapToNearbyAnchorPoint {
    CGFloat distance = 10000;
    CGPoint point = self.superview.center;
    
    int i = 0;
    CGPoint somePoint = self.lastPoint;
    for (NSValue *pointValue in   self.anchorPoints) {
        CGPoint aPoint = [pointValue CGPointValue];
        CGFloat distanceFromAnchorPoint = [self distanceOfPoint:aPoint fromPoint:somePoint];
        if (distance > distanceFromAnchorPoint) {
            distance = distanceFromAnchorPoint;
            point = aPoint;
            offsetDueToAnchorPoint = ((NSNumber*)  self.offsets[i]).floatValue;
        }
        i++;
    }
    
    [self snapToPoint:point];
    
    // Update offsetDueToAnchorPoint
}

- (void)didEndDrag {
    [self snapToNearbyAnchorPoint];
    if (isBlooming) {
        [self updateMenuButtonPositions];
    }
    isDragging = NO;
}

- (NSNumber*)offsetValueFor:(int)i j:(int)j {
    CGFloat offsetValue;

    switch (i) {
        case 0:
            switch (j) {
                case 0:
                    offsetValue = M_PI_2;
                    break;

                case 1:
                    offsetValue =  M_PI_4;
                    break;
                    
                default:
                    offsetValue = 0;
                    break;
            }
            break;

        case 1:
            switch (j) {
                case 0:
                    offsetValue = M_PI_2 * 1.5;
                    break;

                case 1:
                    offsetValue =  -M_PI_4;
                    break;

                default:
                    offsetValue = -M_PI_4;
                    break;
            }
            break;
            
        default:
            switch (j) {
                case 0:
                    offsetValue = M_PI;
                    break;

                case 1:
                    offsetValue = M_PI * 1.25;
                    break;

                default:
                    offsetValue = -M_PI_2;
                    break;
            }
            break;
    }
    return @(offsetValue);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Buttons
- (void)removeAllButtons {
    // Remove from supre view
    for (UIButton *menuButton in self.menuButtons) {
        [menuButton removeFromSuperview];
    }
    self.menuButtons = nil;
}

- (void)addButtonToMenuView:(UIButton *)aButton {
    // This method is implemented if you wish to add button to a view other than self.
    [self addSubview:aButton];
}

- (void)addButtonWithFrame:(CGRect)buttonFrame title:(NSString *)title index:(NSInteger)index {
    UIButton *aButton;
    aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aButton.frame = buttonFrame;
    //[aButton setTitle:title forState:UIControlStateNormal];
    [aButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [aButton setBackgroundColor:[UIColor orangeColor]];
    aButton.autoresizingMask = UIViewAutoresizingNone;

    aButton.tag = index;
    
    [aButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventAllTouchEvents];
    [aButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(buttonToucheLeft:) forControlEvents:UIControlEventTouchUpOutside];

    // Add to view
    [self addButtonToMenuView:aButton];
    // Some house keeping
    [self.menuButtons addObject:aButton];
    //
    [self makeItRound:aButton];
}

- (void)addButtonsWithTitles:(NSArray*)titles {
    if (titles.count == 0) {
        return;
    }

    self.menuButtons = [NSMutableArray array];
    CGRect buttonFrame = self.frame;

    NSInteger index = -1;
    for (NSString *title in titles) {
        index++;

        [self addButtonWithFrame:buttonFrame title:title index:index];
    }
    [self updateMenuButtonPositions];
}

- (void)updateMenuButtonPositions {
    if (self.menuButtons.count == 0) {
        return;
    }
    CGPoint centerPoint = anchorView.center;

    CGFloat theta = self.totalAngle / (self.menuButtons.count <= 1 ? 1 : (self.menuButtons.count - 1));
    NSInteger index = -1;

    if (self.menuButtons.count > 6) {
       self. bloomFactor = 0.0;
    }

    CGFloat flowerRadius = selfRadius * self.bloomFactor;

    NSInteger direction = 1.0; // clockwise (-1) anticlockwise

    for (UIButton *aButton in self.menuButtons) {
        CGPoint offset;
        index++;
        CGFloat angle = (index * theta) + self.quadrantOffset + offsetDueToAnchorPoint;
        offset.x = (flowerRadius * 2) * cosf(angle) * direction;
        offset.y = (flowerRadius * 2) * sinf(angle);

        
        if(_isFirstTimeSetup){
            
             aButton.center = [self movePoint:centerPoint byOffset:offset];
        }
        else{
            [UIView animateWithDuration:0.5 animations:^{
                aButton.center = [self movePoint:centerPoint byOffset:offset];
            } completion:nil];
        }
        
//        aButton.transform = CGAffineTransformMakeRotation(angle);
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            userGuideImageView.transform=CGAffineTransformMakeRotation(angle);
             [self setNeedsDisplay];
        });
        
       

    }
    _isFirstTimeSetup=FALSE;
}

#pragma mark - Fade Animation
- (void)changeAlpha:(CGFloat)alpha duration:(CGFloat)duration {
    if (self.alpha == alpha) {
        // Do nothing
        return;
    }

    // Without animation
    if (duration < 0.0) {
        self.alpha = alpha;
        return;
    }

    [UIView animateWithDuration:duration animations:^{
        self.alpha = alpha;
    } completion:^(BOOL finished) {

    }];
}

- (void)fadeOut {
    CGFloat alpha = 0.5;
    CGFloat duration = 0.5;
    [self changeAlpha:alpha duration:duration];
}

- (void)fadeIn {
    CGFloat alpha = 1.0;
    CGFloat duration = 0.5;
    [self changeAlpha:alpha duration:duration];
}

#pragma mark - Bloom Animation
- (CGRect)moveRect:(CGRect)rect toCenter:(CGPoint)point {
    rect.origin.x = point.x - rect.size.width / 2.0;
    rect.origin.y = point.y - rect.size.height / 2.0;
    return rect;
}

- (void)changeFrame:(CGRect)newFrame {
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{

        CGRect movedFrame = [self moveRect:newFrame toCenter:self.center];
//        self.layer.cornerRadius = (MAX(movedFrame.size.width, self.frame.size.width)) / 2.0;
        self.frame = movedFrame;
        self.layer.cornerRadius = movedFrame.size.width / 2.0;

        [self updateMenuButtonPositions];
    } completion:^(BOOL finished) {
        if (finished) {
//            self.layer.cornerRadius = self.frame.size.width / 2.0;
            self.userInteractionEnabled = YES;
            userGuideImageView.center = anchorView.center;
//            [self bringSubviewToFront:userGuideImageView];
        }
    }];
}

- (void)bloomIt {
    
    if (!isBlooming) {
        isBlooming = YES;
    
        if(firsttimeDisplayText)
        {
        
//            CGRect imageviewFrame = bloomFrame;
//            
//            imageviewFrame.size.width *= 0.5;
//            imageviewFrame.size.height *= 0.5;
//            
//            imageviewFrame.origin = CGPointZero;
//            userGuideImageView=[[UIImageView alloc]initWithFrame:imageviewFrame];
//              userGuideImageView.tag=1001;
//            userGuideImageView.autoresizingMask=UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
//            userGuideImageView.contentMode = UIViewContentModeTopRight;
//            [userGuideImageView setImage:[UIImage imageNamed:@"f_moreApps.png"]];
//            [self addSubview:userGuideImageView];


        }
        [self changeFrame:bloomFrame];
    }
}

- (void)closeIt {
    if (isBlooming) {
        isBlooming = NO;
        [self changeFrame:originalFrame];
       // UIImageView *imgTemp = (UIImageView *)[self viewWithTag:1001];
        //[imgTemp removeFromSuperview];
    }
}

#pragma mark - Button action
- (void)buttonClicked:(UIButton*)sender {
    [self.menuViewDelegate didSelectMenuItem:sender.tag];
    [self closeIt];
    [self startIdleTimer];
}

- (void)buttonTouched:(UIButton*)sender {
    [self stopIdleTimer];
}

- (void)buttonToucheLeft:(UIButton*)sender {
    [self startIdleTimer];
}

#pragma mark - Main interface
- (void)setupMenuWithTitles:(NSArray*)titles delegate:(id<FlowerMenuViewDelegate>)delegate {
    bloomFrame = originalFrame;
    bloomFrame.size.width *= (3 * self.bloomFactor);
    bloomFrame.size.height *= (3 * self.bloomFactor);

    [self removeAllButtons];

    self.titles = titles;
    self.normalImages = nil;
    self.disabledImages = nil;
    self.selectedImages = nil;
    _isFirstTimeSetup=TRUE;
    [self addButtonsWithTitles:self.titles];
    self.menuViewDelegate = delegate;
}

- (void)setNormalButtonImages:(NSArray *)normalImages {
    for (int i = 0; i < normalImages.count; i++) {
        if ((i < self.menuButtons.count) && (i < normalImages.count)) {
            UIButton *aButton = self.menuButtons[i];
            [aButton setImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
        }
    }
}

- (void)setSelectedButtonImages:(NSArray *)selectedImages {
    for (int i = 0; i < selectedImages.count; i++) {
        if ((i < self.menuButtons.count) && (i < selectedImages.count)) {
            UIButton *aButton = self.menuButtons[i];
            [aButton setImage:[UIImage imageNamed:selectedImages[i]] forState:UIControlStateSelected];
        }
    }
}

- (void)setupMenuWithTitles:(NSArray*)titles normalImages:(NSArray*)normalImages selectedImages:(NSArray*)selectedImages disabledImages:(NSArray*)disabledImages delegate:(id<FlowerMenuViewDelegate>)delegate {
    _isFirstTimeSetup=TRUE;
    [self setupMenuWithTitles:titles delegate:delegate];

    self.normalImages = normalImages;
    self.disabledImages = disabledImages;
    self.selectedImages = selectedImages;

    [self setNormalButtonImages:normalImages];
    [self setSelectedButtonImages:selectedImages];
}

- (void)enableMenuItem:(BOOL)enable atIndex:(NSInteger)index {
    if (index >= self.menuButtons.count) {
        return;
    }
    UIButton *aButton = self.menuButtons[index];
    aButton.enabled = enable;
}
@end
