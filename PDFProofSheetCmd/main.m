//
//  main.m
//  PDFProofSheetCmd
//
//  Created by Adam Wright on 01/10/2013.
//  Copyright (c) 2013 Adam Wright. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProofSheetGenerator.h"

void printHelp();
int validateParameters(NSInteger minimumPages, NSInteger width, NSInteger height, NSString *input, NSString *output);

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSUserDefaults *parameters = [NSUserDefaults standardUserDefaults];
        
        if ([parameters stringForKey:@"help"] != nil)
        {
            printHelp();
            
            return 0;
        }

        NSInteger minimumPages = [parameters integerForKey:@"minimumPages"];
        NSInteger width = [parameters integerForKey:@"width"];
        NSInteger height = [parameters integerForKey:@"height"];
        
        NSString *input = [parameters stringForKey:@"input"];
        NSString *output = [parameters stringForKey:@"output"];
        
        int paramTest = validateParameters(minimumPages, width, height, input, output);
        
        if (paramTest != 0)
            return paramTest;
        
        if (output == nil)
            output = [NSString stringWithFormat:@"%@.png", input];
        
        ProofSheetGenerator *generator = [[ProofSheetGenerator alloc] initWithWidth:width height:height minimumPageCount:minimumPages];
        
        NSURL *inputURL = [[NSURL alloc] initFileURLWithPath:input];
        NSError *error;
        
        CGImageRef result = [generator newImageFromPDF:inputURL error:&error];
        
        if (result)
        {
            NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:output];
            CGImageDestinationRef destRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)outputURL, kUTTypePNG, 1, NULL);
            
            if (!destRef)
            {
                printf("Cannot create output image\n");
                
                return 4;
            }
            
            CGImageDestinationAddImage(destRef, result, NULL);
            
            if (!CGImageDestinationFinalize(destRef))
            {
                printf("Could not create output image\n");
                CFRelease(destRef);
                
                return 4;
            }
            
            CFRelease(destRef);
        }
        else
        {
            printf("Error parsing input\n");
            
            return 3;
        }
    }
    
    return 0;
}

void printHelp()
{
    printf("Usage: pdfproofsheet -width=x -height=y -input=\"in path\" [-output=\"out path\"] [-minimumPages=i]\n");
    printf(" x and y are positive integers\n");
    printf(" in path is a path to a PDF\n");
    printf(" out path is a path to a PNG output, defaulting to the input with a PNG suffix\n");
    printf(" i is the minimum number of pages used in the proof, using blanks for padding\n");
}

int validateParameters(NSInteger minimumPages, NSInteger width, NSInteger height, NSString *input, NSString *output)
{
    if (width <= 0 || height <= 0)
    {
        printf("Width and height must be non-negative integers\n");
        
        return 1;
    }
    
    if (minimumPages < 0)
    {
        printf("Minimum pages must be a non-negative integer\n");
        
        return 1;
    }
    
    if (input == nil)
    {
        printHelp();
        
        return 1;
    }
    
    if (output == nil)
        output = [NSString stringWithFormat:@"%@.png", input];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir, fileExists;
    fileExists = [manager fileExistsAtPath:input isDirectory:&isDir];
    
    if (!fileExists)
    {
        printf("Input file does not exist\n");
        
        return 1;
    }
    
    if (isDir)
    {
        printf("Input file is a directory\n");
        
        return 1;
    }
    
    fileExists = [manager fileExistsAtPath:output isDirectory:&isDir];
    
    if (fileExists)
    {
        printf("Output file exists\n");
        
        return 2;
    }
    
    return 0;
}