//
//  AppDelegate.m
//  PDFProofSheet
//
//  Created by Adam Wright on 30/09/2013.
//  Copyright (c) 2013 Adam Wright. All rights reserved.
//

#import "AppDelegate.h"

#import <Quartz/Quartz.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //PDFDocument *d = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:@"/Users/adamw/Desktop/Thesises/144.pdf"]];
    
    const int width = 1010;
    const int height = 1000;
    
    ProofSheetGenerator *gen = [[ProofSheetGenerator alloc] initWithWidth:1000 height:1000];
    CGImageRef img = [gen newImageFromPDF:[NSURL fileURLWithPath:@"/Users/adamw/Desktop/PhDThesis.pdf"] error:nil];
    
    
    self.imageView.image = [[NSImage alloc] initWithCGImage:img size:NSMakeSize(width, height)];
    CGImageRelease(img);
}

@end
