//
//  KonotorUITextView.m
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 11/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorUITextView.h"
#import <QuartzCore/QuartzCore.h>

@implementation KonotorUITextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0]];
        [self setText:@""];
        [self setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
        [self setTextColor:[UIColor blackColor]];
        [self setReturnKeyType:UIReturnKeySend];
        [self setEnablesReturnKeyAutomatically:YES];
                
    }
    return self;
}

- (BOOL) canBecomeFirstResponder{
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
