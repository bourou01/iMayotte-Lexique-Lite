//
//  AppDelegate.m
//  imayottelexique
//
//  Created by bourou01 on 01/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController = _navController;


@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)dealloc
{
    self.navController = nil;
    
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    /****************************************************************************************
     *                          REMPLISSAGE DE LA BASE DE DONNEE
     ****************************************************************************************/
 


if (0)
{
    
    //
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //récupération du chemin vers le fichier contenant le JSON
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dictionary" ofType:@"txt"];
    
    //création d'un string avec le contenu de JSON 
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    //Parsage du JSON à l'aide du framework importé
    NSDictionary *json = [myJSON JSONValue];
    
    
    //récupération des 2 dictionnarys
    NSDictionary *lexiques = [json objectForKey:@"DICTIONARY"];
    
    
    //récupération du dictionnaire 1 et 2 "mahorais-français"
    NSArray *lexique1 = [lexiques objectForKey:@"ma-fr"];
    NSArray *lexique2 = [lexiques objectForKey:@"fr-ma"];
    
    
    
    //insertion des illustration dan sla base de donnée
    

    
    for (NSDictionary *iim in lexique1) {

        DictionaryM *dictionaryM = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"DictionaryM" 
                                    inManagedObjectContext:context];
        
        dictionaryM.mahorais = [NSString stringWithString:[iim objectForKey:@"ma"]];
        dictionaryM.francais = [NSString stringWithString:[iim objectForKey:@"fr"]];

        
    }
    
    //insertion des illustration dan sla base de donnée
    
    for (NSDictionary *iif in lexique2) {
        

        DictionaryF *dictionaryF = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"DictionaryF" 
                                    inManagedObjectContext:context];
        
        dictionaryF.mahorais = [NSString stringWithString:[iif objectForKey:@"ma"]];
        dictionaryF.francais = [NSString stringWithString:[iif objectForKey:@"fr"]];

        
        
    }

    
    

    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
     //
}
        
    /****************************************************************************************
     *                          FIN REMPLISSAGE DE LA BASE DE DONNEE
     ****************************************************************************************/

    
    // commented because we alrady have our xib file
    //self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    
    
    RootViewController *root = (RootViewController *)[_navController topViewController];
    //DictionaryViewController *root = [[DictionaryViewController alloc] init];
    
    
    
    root.managedObjectContext = [self managedObjectContext];
    
    //self.window.backgroundColor = [UIColor blueColor];
    
    [self.window addSubview:_navController.view];
    
    
    

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
}


/*
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            //
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
*/
#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Lexique_Lite" withExtension:@"momd"];
    //__managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    __managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Lexique_Lite.sqlite"];
    
    NSString *storePath = [[self applicationDocumentsDirectory2] stringByAppendingPathComponent:@"Lexique_Lite.sqlite"];
    
    
    /*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
    
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Lexique_Lite" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}

	}
    
	//NSURL *storeUrl = [NSURL fileURLWithPath:[storePath absoluteString]];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];	

    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSString *)applicationDocumentsDirectory2 {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}




@end
