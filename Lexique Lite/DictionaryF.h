//
//  DictionaryF.h
//  Lexique Lite
//
//  Created by Mouhamadi ABDULLATIF on 29/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DictionaryF : NSManagedObject

@property (nonatomic, retain) NSString * francais;
@property (nonatomic, retain) NSString * mahorais;
@property (nonatomic, retain) NSString * uppercaseFirstLetterOfName;

@end
