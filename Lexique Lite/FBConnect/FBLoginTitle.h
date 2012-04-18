//
//  FBLoginTitle.h
//  Lexique
//
//  Created by Mouhamadi ABDULLATIF on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBLoginTitle : NSString {
    
    BOOL  _isLoggedIn;
}

@property(nonatomic) BOOL isLoggedIn; 

- (NSString *)buttonTitle;

@end
