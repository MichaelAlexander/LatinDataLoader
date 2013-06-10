//
//  main.m
//  LatinAppLoader
//
//  Created by Michael Alexander on 1/21/13.
//  Copyright (c) 2013 Michael Alexander. All rights reserved.
//

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"LatinPractice";
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        NSLog(@"Here I am");
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        //purge previous data
        NSFetchRequest *fetchRequestC = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityC = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
        [fetchRequestC setEntity:entityC];
        
        NSError *errorC;
        NSArray *items = [context executeFetchRequest:fetchRequestC error:&error];
        
        
        for (NSManagedObject *managedObject in items) {
            [context deleteObject:managedObject];
            NSLog(@"object deleted Group");
        }
        if (![context save:&error]) {
            NSLog(@"Error deleting Group error:%@", errorC);
        }
        
        NSFetchRequest *fetchRequestD = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityD = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:context];
        [fetchRequestD setEntity:entityD];
        
        NSError *errorD;
        NSArray *itemsB = [context executeFetchRequest:fetchRequestD error:&error];
        
        
        for (NSManagedObject *managedObject in itemsB) {
            [context deleteObject:managedObject];
            NSLog(@"object deleted - Card");
        }
        if (![context save:&error]) {
            NSLog(@"Error deleting Card error:%@", errorD);
        }
        
        NSError* err = nil;
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"LatinGroups" ofType:@"json"];
        NSArray* latinGroups = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
        //NSLog(@"Imported Groups: %@", latinGroups);
        
        NSError* err2 = nil;
        NSString* dataPath2 = [[NSBundle mainBundle] pathForResource:@"LatinWords" ofType:@"json"];
        NSArray* latinWords = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath2]
                                                               options:kNilOptions
                                                                 error:&err2];
        NSLog(@"Imported Groups: %@", latinWords);
        
        //Insert into core data
        
        for (int i = 0; i < [latinGroups count]; i++) {
            NSManagedObject *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
            [group setValue:[[latinGroups objectAtIndex:i] objectForKey:@"groupName"] forKey:@"groupName"];
        }
        
        for (int j = 0; j < [latinWords count]; j++) {
            NSManagedObject *word = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:context];
            [word setValue:[[latinWords objectAtIndex:j] objectForKey:@"english"] forKey:@"english"];
            [word setValue:[[latinWords objectAtIndex:j] objectForKey:@"latin"] forKey:@"latin"];
            [word setValue:[[latinWords objectAtIndex:j] objectForKey:@"image"] forKey:@"image"];
            [word setValue:[[latinWords objectAtIndex:j] objectForKey:@"group"] forKey:@"group"];
        }
        
        NSError *errorB = nil;
        NSManagedObjectContext *managedObjectContext = context;
        if (managedObjectContext != nil) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&errorB]) {
                NSLog(@"Unresolved error %@, %@", errorB, [errorB userInfo]);
                abort();
            }
        }
        
        
        // Test listing 
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (int k = 0; k < [fetchedObjects count]; k++) {
            NSLog(@"Name: %@", [[fetchedObjects objectAtIndex:k] valueForKey:@"groupName"]);
        }
        
        NSFetchRequest *fetchRequestB = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityB = [NSEntityDescription entityForName:@"Card"
                                                  inManagedObjectContext:context];
        [fetchRequestB setEntity:entityB];
        NSArray *fetchedObjectsB = [context executeFetchRequest:fetchRequestB error:&error];
        for (int k = 0; k < [fetchedObjectsB count]; k++) {
            NSLog(@"English: %@", [[fetchedObjectsB objectAtIndex:k] valueForKey:@"english"]);
            NSLog(@"Latin: %@", [[fetchedObjectsB objectAtIndex:k] valueForKey:@"latin"]);
        }
        
    }
    
    return 0;
}

