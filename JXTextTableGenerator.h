//
//  JXTextTableGenerator.h
//  CSV Converter
//
//  Created by Jan on 24.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "JXArcCompatibilityMacros.h"

@interface JXTextTableGenerator : NSObject {
	NSDictionary *_basicAttributes;
	NSDictionary *_headerAttributes;
	
	NSParagraphStyle *_paragraphStyle;
	CGFloat _tablePadding;

	CGFloat _borderWidth;
	NSColor *_borderColor;
	
	BOOL _cellsNeedTerminators;
}

// A TableMatrix is an array of arrays.
// Each subarray contains cell objects.
// All subarrays need to contain a single object type:
// either NSString or NSAttributedString.
// Each entry in this topmost array represents a row.
// Each of the strings in a row represent a column of the row.
#if 0
	// Here is an example of such an array:
    NSArray *sampleTableMatrix = @[
	@[@"Header 1", @"Header 2"],
	@[@"cell 1", @"cell 2"],
	@[@"second row", @"second row 2"]
	];
#endif

// Should a row have a column count that differs from the *usual* column count in the table,
// it will be prepended to the result as tabbed text.

@property (nonatomic, readwrite, JX_STRONG) NSDictionary *basicAttributes;
@property (nonatomic, readwrite, JX_STRONG) NSDictionary *headerAttributes;

@property (nonatomic, readwrite, JX_STRONG) NSParagraphStyle *paragraphStyle;
@property (nonatomic, readwrite) CGFloat tablePadding;

@property (nonatomic, readwrite) CGFloat borderWidth;
@property (nonatomic, readwrite, JX_STRONG) NSColor *borderColor;

// Table cells need to end with a newline (\n).
// Because of this, cellsNeedTerminators defaults to YES.
// Thus every cell gets and extra newline at the end. 
// If your TableMatrix already has these newlines,
// you may suppress by setting this to NO. 
@property (nonatomic, readwrite) BOOL cellsNeedTerminators;

- (instancetype)init;
+ (instancetype)tableGenerator;

- (instancetype)initWithAttributes:(NSDictionary *)basicAttributes;
+ (instancetype)tableGeneratorWithAttributes:(NSDictionary *)basicAttributes;

- (NSMutableAttributedString *)attributedStringForTableMatrix:(NSArray *)rowColArray;

- (NSMutableAttributedString *)attributedStringForTableMatrix:(NSArray *)rowColArray
											 tableHeaderIndex:(NSUInteger)headerIndex;

@end
