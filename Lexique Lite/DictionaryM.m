//
//  DictionaryM.m
//  Lexique Lite
//
//  Created by Mouhamadi ABDULLATIF on 29/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DictionaryM.h"


@implementation DictionaryM

@dynamic francais;
@dynamic mahorais;
@dynamic uppercaseFirstLetterOfName;

- (NSString *)uppercaseFirstLetterOfName {
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
    NSString *aString = [[self valueForKey:@"mahorais"] uppercaseString];
    
    // support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];
    
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}


@end
