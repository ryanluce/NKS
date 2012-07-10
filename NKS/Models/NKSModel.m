//
//  NKSModel.m
//  NKS
//
//  Created by Ryan Luce on 7/2/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import "NKSModel.h"
#include <stdlib.h>
#include <stdio.h>

//just hard code these for now [[UIScreen mainScreen] bounds] probably work as well, but may want to constrict this based on it's application.
#define SCREEN_HEIGHT 600
#define SCREEN_WIDTH 768

@interface  NKSModel()
//Recursively calculate permutations
- (void)getPermutationWithExistingString:(char *)existingString;
//Calculate every possible rule permutation
- (void)reloadPermutations;


;
//calculate and set the row at tha particular row/column
- (void)calculateRuleAtRow:(int)row andColumn:(int)column;

@end

@implementation NKSModel

@synthesize  numberOfRules = _numberOfRules, totalNeighborCount = _totalNeighborCount, pixelSize = _pixelSize;
@synthesize colors, rows = _rows, columns = _columns, isReady, updateView;


- (id)init
{
    if(self = [super init])
    {
        //Traditional Wolfram Cellular Automata dictates 2 rules and 1 neighbor, playing with it yields fun results
        _numberOfRules = 3;
        _totalNeighborCount = 3;
        //Just make them big and visible
        self.pixelSize = 4;
        
        //For now make a random start row
        _data = malloc(_rows * _columns * sizeof(int)); 
        memset(_data, 0, _rows*_columns);
    }
    return self;
}

//Goes through and calculates everything
- (void)reloadData
{
    //Don't get the data until it's ready
    self.isReady = NO;
    
    NSLog(@"Reloading perms");
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    
    _iRules = malloc(pow(10, self.totalNeighborCount*2+1) * sizeof(int));
    memset(_iRules, 0, pow(10, self.totalNeighborCount*2+1));
    
    //Get all the rule perms
    [self reloadPermutations];
   
    //Just put a random first row. 
    for(int i=0; i<_columns; i++)
    {
        _data[i] = rand()%self.numberOfRules;
    }
    
    //Make some random rules too
    _rules = malloc((pow(self.numberOfRules, self.totalNeighborCount*2+1) * sizeof(int)));
    memset(_rules, 0, pow(self.numberOfRules, self.totalNeighborCount*2+1));
    

    
    _iRules[111] = 1;
    _count = 0;
    
    for (int i=0; i<pow(self.numberOfRules, self.totalNeighborCount*2+1); i++) {
        _rules[i] = rand()%self.numberOfRules;
    }
    
    //Add some random colors
    self.colors = [NSMutableArray arrayWithCapacity:self.numberOfRules];
    for(int i =0; i < self.numberOfRules; i++)
    {
        ColorModel *tColorModel = [[ColorModel alloc] init];
        tColorModel.red = rand()%255;
        tColorModel.green = rand()%255;
        tColorModel.blue = rand()%255;
        tColorModel.alpha = 255;
        [self.colors addObject:tColorModel];
    }
    
    //the hardwork comes here, calculate each 'pixel' based on it's neighbors
    for (int i = 1; i < _rows; i++)
    {
        for (int ii = 0; ii < _columns; ii++) {
            [self calculateRuleAtRow:i andColumn:ii];
        }
    }
    //Done calculating and ready for
    self.isReady = YES;
    self.updateView = YES;
    NSLog(@"Done");

    
    NSTimeInterval timeItTookToProcess = [now timeIntervalSinceNow];
    NSLog(@"Took %f seconds to process", timeItTookToProcess);
}

- (void)reloadPermutations
{
    //Fill up a dictionary with all the perms eg @"000" @"001" @"002" @"010" etc based on the rules and neighbors
    _dRules = [NSMutableDictionary dictionary];
    char *tempStr = "";
    [self getPermutationWithExistingString:tempStr];
}

//Recursively get all rule permuatations
- (void)getPermutationWithExistingString:(char *)existingString
{
    
    //Number of rules to the power of neighbors
    int numNeighbors = self.totalNeighborCount * 2 + 1;
    for(int i = 0; i < self.numberOfRules; i++)
    {
        //
        char x[5];
        //NSLog(@"x: %s", x);
        sprintf(x, "%d", i);
        
        char newExistingString[self.totalNeighborCount * 2 + 2];
        
        strcpy(newExistingString, existingString);
        
        strcat(newExistingString, x);
        if(strlen(newExistingString) == numNeighbors)
        {
            //If the string is as long as the number of neighbors plus the center pixel, go ahead and add it to the dictionary
            int tIndex = atoi(newExistingString);
           // NSLog(@"index: %d", tIndex);
            //NSLog(@"count: %d", _count);
            _iRules[tIndex] = _count;
            _count++;
            
            //[_dRules setObject:[NSNumber numberWithInt:[_dRules count]]  forKey:tempString];
        } else {
            //else keep adding to the string eg @"01" needs to be @"010" @"011" and @"012" with 1 neighbor and 3 rules
            [self getPermutationWithExistingString:newExistingString];
        }
    }
}

//get the rule based on the previous rows pixel at this column and it's neighbors
- (void)calculateRuleAtRow:(int)row andColumn:(int)column
{
    //Make a search string to get out of the rule dictionary
    //NSString *searchString = @"";
    int charLength = self.totalNeighborCount * 2 + 2;
    char searchString[charLength];
    //NSLog(@"search string %s, %d", searchString, charLength);
    //temporarily change the row to the parent row
    row = row -1;
    
    //Loop through all the neighbors and the center pixel
    for(int i = -self.totalNeighborCount; i <= self.totalNeighborCount; i++)
    {
        //i is a pixel offset, when it's 0 it is the center pixel
        int searchColumn = column + i;
        
        //Make sure to wrap around the edges, ie there is no -1 pixel at column 0
        if(searchColumn < 0)
        {
            searchColumn += _columns;
        } else if(searchColumn > _columns - 1)
        {
            searchColumn -= _columns;
        }
        //Instead of a multidimension array, just offset each row with the number of columns
        int tempRule = _data[(row * _columns) + searchColumn];
        if(i == -self.totalNeighborCount)
        {
            sprintf(searchString, "%d", tempRule);
        } else {
            char stringToConcat[2];
            sprintf(stringToConcat, "%d", tempRule);
            strcat(searchString, stringToConcat);            
        }

       
        //searchString = [NSString stringWithFormat:@"%@%d", searchString, tempRule];
    }
    row = row + 1;
    int theRule = atoi(searchString);
    //NSLog(@"rule: %d", theRule);
    //Set the pixel to the rule index store in the dictionary
    _data[column + (row * _columns)] = _rules[_iRules[theRule]];
}

- (void)setPixelSize:(int)pixelSize
{
    //Calculate the size and rows/coluns
    _pixelSize = pixelSize;
    _rows = floor(SCREEN_HEIGHT/pixelSize);
    _columns = floor(SCREEN_WIDTH/pixelSize);
    //May want to do this automatically later, for now just let the viewcontroller manually call reloadData
    //[self reloadData];
}

- (int)getRuleAtRow:(int)row andColumn:(int)column
{
    //Pretty simple, just convenience method to get past the 1 dimensional array limitation
    return _data[(row *_columns) + column];
}

//Get the color to draw in the viewcontroller
- (ColorModel *)getColorAtRow:(int)row andColumn:(int)column
{
    int rule = [self getRuleAtRow:row andColumn:column];
  
    return [self.colors objectAtIndex:rule];
}

//Usually there will only be on NKS model with whatever viewcontroller that needs the data accessing it as it needs
+ (NKSModel *)sharedInstance
{
    static dispatch_once_t prod;
    static NKSModel *sharedInstance;
    //GCD
    dispatch_once(&prod, ^{
        sharedInstance = [[NKSModel alloc] init];
    });
    return sharedInstance;
}
@end

/* My older, slower functions
 
 //Recursively get all rule permuatations
 - (void)getPermutationWithExistingString:(NSString *)existingString
 {
 
 //Number of rules to the power of neighbors
 int numNeighbors = self.totalNeighborCount * 2 + 1;
 for(int i = 0; i < self.numberOfRules; i++)
 {
 NSString *tempString = [NSString stringWithFormat:@"%@%d", existingString, i];
 if([tempString length] == numNeighbors)
 {
 //If the string is as long as the number of neighbors plus the center pixel, go ahead and add it to the dictionary
 
 [_dRules setObject:[NSNumber numberWithInt:[_dRules count]]  forKey:tempString];
 } else {
 //else keep adding to the string eg @"01" needs to be @"010" @"011" and @"012" with 1 neighbor and 3 rules
 [self getPermutationWithExistingString:tempString];
 }
 }
 }
 
 //get the rule based on the previous rows pixel at this column and it's neighbors
 - (void)calculateRuleAtRow:(int)row andColumn:(int)column
 {
 //Make a search string to get out of the rule dictionary
 NSString *searchString = @"";
 //temporarily change the row to the parent row
 row = row -1;
 
 //Loop through all the neighbors and the center pixel
 for(int i = -self.totalNeighborCount; i <= self.totalNeighborCount; i++)
 {
 //i is a pixel offset, when it's 0 it is the center pixel
 int searchColumn = column + i;
 
 //Make sure to wrap around the edges, ie there is no -1 pixel at column 0
 if(searchColumn < 0)
 {
 searchColumn += _columns;
 } else if(searchColumn > _columns - 1)
 {
 searchColumn -= _columns;
 }
 //Instead of a multidimension array, just offset each row with the number of columns
 int tempRule = _data[(row * _columns) + searchColumn];
 
 searchString = [NSString stringWithFormat:@"%@%d", searchString, tempRule];
 }
 row = row + 1;
 //Set the pixel to the rule index store in the dictionary
 _data[column + (row * _columns)] = _rules[[[_dRules objectForKey:searchString] intValue]];
 }

 
 */
