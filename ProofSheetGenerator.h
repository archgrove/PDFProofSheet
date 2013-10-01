//
//  ProofSheetGenerator.h
//  PDFProofSheet
//
//  Created by Adam Wright on 01/10/2013.
//  Copyright (c) 2013 Adam Wright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface ProofSheetGenerator : NSObject

@property (readonly) CGSize size;
@property (readonly) NSUInteger minimumPageCount;

- (instancetype)initWithWidth:(NSUInteger)pWidth height:(NSUInteger)pHeight;
- (instancetype)initWithWidth:(NSUInteger)pWidth height:(NSUInteger)pHeight
                minimumPageCount:(NSUInteger)minPages;

- (CGImageRef)newImageFromPDF:(NSURL*)source error:(NSError**)error;

@end
