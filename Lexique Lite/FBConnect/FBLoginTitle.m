//
//  FBLoginTitle.m
//  Lexique
//
//  Created by Mouhamadi ABDULLATIF on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FBLoginTitle.h"

@implementation FBLoginTitle

@synthesize isLoggedIn = _isLoggedIn;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

/**
 * return the regular button image according to the login status
 */
- (NSString *)buttonTitle {
    if (_isLoggedIn) {
        return [NSString stringWithFormat:@"logout"];
    } else {
        return [NSString stringWithFormat:@"facebook"];
    }
}

@end
