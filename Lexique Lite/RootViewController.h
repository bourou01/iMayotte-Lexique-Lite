//
//  DictionaryViewController.h
//  imayottelexique
//
//  Created by bourou01 on 02/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryM.h"
#import "DictionaryF.h"
#import "AppDelegate.h"

#import "DetailsViewController.h"
#import "AboutViewController.h"


@interface RootViewController : UITableViewController <UISearchBarDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>
{
    // other class ivars
    // required ivars for this example
    NSFetchedResultsController *fetchedResultsController_;
    NSFetchedResultsController *searchFetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    
    // The saved state of the search UI if a memory warning removed the view.
    NSString        *savedSearchTerm_;
    NSInteger       savedScopeButtonIndex_;
    BOOL            searchWasActive_;
    
    // changeLanguage
    NSMutableDictionary *currentLanguageProperty_;
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;


@property (nonatomic, retain) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, retain) UISearchDisplayController *mySearchDisplayController;


// changeLanguage
- (void)changeLanguageList:(id)sender;
- (void)performAboutView:(id)sender;

//- (NSString *)uppercaseFirstLetterOfName;



- (NSDictionary *)performLanguage:(NSString *)whichLanguage;

@property (nonatomic, retain) NSMutableDictionary *currentLanguageProperty;

@end
