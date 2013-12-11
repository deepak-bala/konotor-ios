//
//  KonotorUtility.h
//  KonotorDemo
//
//  Created by Srikrishnan Ganesan on 20/08/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "KonotorUI.h"

@interface KonotorUtility : NSObject

+ (void) showToastWithString:(NSString*) message forMessageID:(NSString*)messageID;
+(void) updateBadgeLabel:(UILabel*) badgeLabel;
@end
