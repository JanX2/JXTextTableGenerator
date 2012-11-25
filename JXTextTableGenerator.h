//
//  JXTextTableGenerator.h
//  CSV Converter
//
//  Created by Jan on 24.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

@interface JXTextTableGenerator : NSObject

// A CSVArray is an array of NSString arrays.
// Each entry in this topmost array represents a row.
// Each of the strings in a row represents the columns for the row.
#if 0
	// Here is an example of such an array:
    NSArray *sampleCSVArray = @[
	@[@"Header 1", @"Header 2"],
	@[@"cell 1", @"cell 2"],
	@[@"second row", @"second row 2"]
	];
#endif

- (NSMutableAttributedString *)attributedStringForCSVArray:(NSArray *)rowColArray
										  tableHeaderIndex:(NSUInteger)headerIndex;

@end
