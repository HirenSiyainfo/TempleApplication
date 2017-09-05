//
//  CustomPageControl.m
//  POSFrontEnd
//
//  Created by Minesh Purohit on 27/11/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "CustomPageControl.h"


@implementation CustomPageControl

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    activeImage = [[UIImage imageNamed:@"page_active.png"] retain];
    inactiveImage = [[UIImage imageNamed:@"page_normal.png"] retain];
	
	activeColor = [UIColor clearColor];
	inactiveColor = [UIColor clearColor];
	
    return self;
}

-(void) updateDots
{
    for (int i = 0; i < self.subviews.count; i++)
    {
        UIImageView* dot = (self.subviews)[i];
        dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 14, 14);
    
        if (i == self.currentPage) 
		{
			dot.backgroundColor = activeColor;
            if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
            {
          dot.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_active.png"]];
            }
            else
            {
                dot.image = activeImage;
            }
		}
        else
		{
			dot.backgroundColor = inactiveColor;
            if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
            {
                dot.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_normal.png"]];
            }
            else
            {

            dot.image = inactiveImage;
            }
		}
		dot.layer.cornerRadius = 3;
    }
    
    
    
  /*  for (int i = 0; i < [self.subviews count]; i++)
    {
        UIView* dotView = [self.subviews objectAtIndex:i];
        UIImageView* dot = nil;
        
        for (UIView* subview in dotView.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView*)subview;
                break;
            }
        }
        
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 14, 14)];
            [dotView addSubview:dot];
        }
        
        if (i == self.currentPage)
        {
            if(activeImage)
                dot.image = activeImage;
        }
        else
        {
            if (inactiveImage)
                dot.image = inactiveImage;
        }
    }*/

}

-(void) setCurrentPage:(NSInteger)page
{
    super.currentPage = page;
    [self updateDots];
}


- (void)dealloc {
    [super dealloc];
}


@end
