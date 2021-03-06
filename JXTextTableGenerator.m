//
//  JXTextTableGenerator.m
//  CSV Converter
//
//  Created by Jan on 24.11.12.
//
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "JXTextTableGenerator.h"

@implementation JXTextTableGenerator

@synthesize basicAttributes = _basicAttributes;
@synthesize headerAttributes = _headerAttributes;

@synthesize paragraphStyle = _paragraphStyle;
@synthesize tablePadding = _tablePadding;

@synthesize borderWidth = _borderWidth;
@synthesize borderColor = _borderColor;

@synthesize cellsNeedTerminators = _cellsNeedTerminators;

- (instancetype)init;
{
	return [self initWithAttributes:nil];
}

+ (instancetype)tableGenerator;
{
	id result = [(JXTextTableGenerator *)[[self class] alloc] initWithAttributes:nil];
	
	return JX_AUTORELEASE(result);
}

- (instancetype)initWithAttributes:(NSDictionary *)basicAttributes;
{
	self = [super init];
	
	if (self) {
		if (basicAttributes == nil) {
			// Use defaults
			CGFloat defaultSize = [NSFont systemFontSize];
			
			NSFont *font = [NSFont fontWithName:@"Helvetica"
										   size:defaultSize];
			
			NSColor *textColor = [NSColor blackColor];
			
			basicAttributes = @{
				NSFontAttributeName:			font,
				NSForegroundColorAttributeName:	textColor,
			};
			
		}
		
		_paragraphStyle = JX_RETAIN([NSParagraphStyle defaultParagraphStyle]);
		_tablePadding = 4.0;
		
		_borderWidth = 1.0;
		_borderColor = JX_RETAIN([NSColor colorWithCalibratedHue:0.00
											 saturation:0.00
											 brightness:0.80
												  alpha:1.00]); // Numbers-style gray
		
		_cellsNeedTerminators = YES;
		
		_basicAttributes = JX_RETAIN(basicAttributes);
		
		// Derive headerAttributes. 
		NSMutableDictionary *headerAttributes = [_basicAttributes mutableCopy];
		NSFont *font = basicAttributes[NSFontAttributeName];
		NSFont *headerFont = [[NSFontManager sharedFontManager] convertFont:font
																toHaveTrait:NSBoldFontMask];
		if (headerFont != nil) {
			headerAttributes[NSFontAttributeName] = headerFont;
		}
		
		_headerAttributes = JX_RETAIN(headerAttributes);
	}
	
	return self;
}

+ (instancetype)tableGeneratorWithAttributes:(NSDictionary *)basicAttributes;
{
	id result = [(JXTextTableGenerator *)[[self class] alloc] initWithAttributes:basicAttributes];
	
	return JX_AUTORELEASE(result);
}

#if (JX_HAS_ARC == 0)
- (void)dealloc
{
    self.basicAttributes = nil;
    self.headerAttributes = nil;
	
    self.borderColor = nil;
	
    [super dealloc];
}
#endif


- (NSMutableAttributedString *)attributedStringForTableMatrix:(NSArray *)rowColArray;
{
	return [self attributedStringForTableMatrix:rowColArray
							   tableHeaderIndex:NSNotFound];
}

- (NSMutableAttributedString *)attributedStringForTableMatrix:(NSArray *)rowColArray
											 tableHeaderIndex:(NSUInteger)headerIndex;
{
	NSMutableAttributedString *tableString = JX_AUTORELEASE([[NSMutableAttributedString alloc] initWithString:@""
																								   attributes:_basicAttributes]);
	
	if (rowColArray.count == 0) {
		return tableString;
	}
	
	typedef NS_ENUM(NSInteger, JXTextTableGeneratorCellType) {
		stringCellType,
		attributedStringCellType
	};

	NSUInteger columnCount;
	NSArray *headerRow = nil;
	BOOL hasHeaderRow;
	if (headerIndex != NSNotFound) {
		hasHeaderRow = YES;
		headerRow = rowColArray[headerIndex];
		columnCount = headerRow.count;
	}
	else {
		hasHeaderRow = NO;
		columnCount = [(NSArray *)[rowColArray lastObject] count];
	}
	
	JXTextTableGeneratorCellType cellType;
	NSArray *firstRow = hasHeaderRow ? headerRow : rowColArray[0];
	
	if (firstRow.count == 0) {
		return tableString;
	}
	
	id firstCell = firstRow[0];
	if ([firstCell isKindOfClass:[NSString class]]) {
		cellType = stringCellType;
	}
	else if ([firstCell isKindOfClass:[NSAttributedString class]]) {
		cellType = attributedStringCellType;
	}
	else {
		return tableString;
	}
	
	NSInteger rowCount = rowColArray.count;
	NSInteger colCount = columnCount;
	NSMutableAttributedString *preambleAttributedString = [[NSMutableAttributedString alloc] initWithString:@""
																								 attributes:_basicAttributes];
	NSMutableString *preambleString = preambleAttributedString.mutableString;
	
	NSTextTable *table = [[NSTextTable alloc] init];
	[table setNumberOfColumns:colCount];
	
	NSInteger rowIndex = 0;
	
	NSDictionary *currentAttributes = _basicAttributes;
	
	for (NSMutableArray *row in rowColArray) {
		NSInteger colIndex = 0;
		
		NSUInteger thisColumnCount = row.count;
		
		if (hasHeaderRow && (rowIndex < (NSInteger)headerIndex)) {
			if (cellType == attributedStringCellType) {
				NSUInteger thisColumnLastIndex = thisColumnCount - 1;
				
				NSUInteger preambleColumnIndex = 0;
				for (NSAttributedString *cellString in row) {
					[preambleAttributedString appendAttributedString:cellString];
					if (preambleColumnIndex < thisColumnLastIndex) {
						[preambleString appendString:@"\t"];
					}
					
					preambleColumnIndex++;
				}
				
				[preambleString appendString:@"\n"];
			}
			else {
				[preambleString appendString:[[row componentsJoinedByString:@"\t"]
											  stringByAppendingString:@"\n"]];
			}
			
			rowIndex++;
			continue;
		}
		
		if (row == headerRow) {
			currentAttributes = _headerAttributes;
		}
		
		for (id cellString in row) {
			NSMutableAttributedString *tableCellString = nil;
			if (cellType == attributedStringCellType) {
				tableCellString = [self tableCellAttributedStringWithAttributedString:(NSAttributedString *)cellString
																				table:table
																				  row:rowIndex
																			 rowCount:rowCount
																			   column:colIndex
																			 colCount:colCount];
			}
			else {
				tableCellString = [self tableCellAttributedStringWithString:(NSString *)cellString
																	  table:table
																		row:rowIndex
																   rowCount:rowCount
																	 column:colIndex
																   colCount:colCount
																 attributes:currentAttributes];
			}
			
			[tableString appendAttributedString:tableCellString];
			
			colIndex++;
		}
		
		if (row == headerRow) {
			currentAttributes = _basicAttributes;
		}
		
		rowIndex++;
	}
	
	[tableString insertAttributedString:preambleAttributedString
								atIndex:0];
	
	JX_RELEASE(preambleAttributedString);
	JX_RELEASE(table);
	
	return tableString;
}

- (NSTextTableBlock *)newTableBlockForTable:(NSTextTable *)table
										row:(NSInteger)row
								   rowCount:(NSInteger)rowCount
									 column:(NSInteger)column
								   colCount:(NSInteger)colCount;
{
    NSTextTableBlock *tableBlock = [[NSTextTableBlock alloc] initWithTable:table
															   startingRow:row
																   rowSpan:1
															startingColumn:column
																columnSpan:1];
	
	[tableBlock setWidth:_tablePadding type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockPadding];
	
	{
		[tableBlock setBorderColor:_borderColor];
		
		[tableBlock setWidth:_borderWidth type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMinYEdge];
		[tableBlock setWidth:_borderWidth type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMinXEdge];
		
		if (row == (rowCount - 1)) {
			[tableBlock setWidth:_borderWidth type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMaxYEdge];
		}
		
		if (column == (colCount - 1)) {
			[tableBlock setWidth:_borderWidth type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockBorder edge:NSMaxXEdge];
		}
	}

	return tableBlock;
}

- (NSMutableAttributedString *)tableCellAttributedStringWithString:(NSString *)string
															 table:(NSTextTable *)table
															   row:(NSInteger)row
														  rowCount:(NSInteger)rowCount
															column:(NSInteger)column
														  colCount:(NSInteger)colCount
														attributes:(NSDictionary *)basicAttributes
{
	NSTextTableBlock *tableBlock = [self newTableBlockForTable:table
														   row:row
													  rowCount:rowCount
														column:column
													  colCount:colCount];
	
	NSArray *textBlocks = @[tableBlock];
	
	NSMutableParagraphStyle *paragraphStyle = [_paragraphStyle mutableCopy];
	[paragraphStyle setTextBlocks:textBlocks];
	
	NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] initWithString:string
																				   attributes:basicAttributes];
	if (_cellsNeedTerminators)  [cellString.mutableString appendString:@"\n"];
	
	[cellString addAttribute:NSParagraphStyleAttributeName
					   value:paragraphStyle
					   range:NSMakeRange(0, [cellString length])];
	JX_RELEASE(paragraphStyle);
	
	JX_RELEASE(tableBlock);

	return JX_AUTORELEASE(cellString);
}

- (NSMutableAttributedString *)tableCellAttributedStringWithAttributedString:(NSAttributedString *)text
																	   table:(NSTextTable *)table
																		 row:(NSInteger)row
																	rowCount:(NSInteger)rowCount
																	  column:(NSInteger)column
																	colCount:(NSInteger)colCount
{
	NSTextTableBlock *tableBlock = [self newTableBlockForTable:table
														   row:row
													  rowCount:rowCount
														column:column
													  colCount:colCount];
	
	NSArray *tableBlockArray = @[tableBlock];
	
	NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
	if (_cellsNeedTerminators)  [cellString.mutableString appendString:@"\n"];
	
	__block BOOL paragraphStyleFound = NO;
	
	NSRange cellStringRange = NSMakeRange(0, cellString.length);

	// Enumerate NSParagraphStyleAttributeName attributes and change each one.
	[cellString enumerateAttribute:NSParagraphStyleAttributeName
						   inRange:cellStringRange
						   options:0
						usingBlock:^(NSParagraphStyle *sourceParagraphStyle, NSRange range, BOOL *stop) {
							NSMutableParagraphStyle *paragraphStyle;
							if (sourceParagraphStyle != nil) {
								paragraphStyle = [sourceParagraphStyle mutableCopy];
							}
							else {
								paragraphStyle = [_paragraphStyle mutableCopy];
							}
							
							NSArray *textBlocks = [paragraphStyle textBlocks];
							if (textBlocks != nil) {
								// An NSParagraphStyle can have multiple table blocks in its textBlocks array.
								// This will result in nested tables!
								// The table we are currently generating will be the new outermost table.
								// So it needs to be the first in the textBlocks array.
								textBlocks = [tableBlockArray arrayByAddingObjectsFromArray:textBlocks];
							}
							else {
								textBlocks = tableBlockArray;
							}
							
							[paragraphStyle setTextBlocks:textBlocks];
							
							[cellString addAttribute:NSParagraphStyleAttributeName
											   value:paragraphStyle
											   range:range];
							
							JX_RELEASE(paragraphStyle);
							
							paragraphStyleFound = YES;
						}];
	
	JX_RELEASE(tableBlock);
	
	return JX_AUTORELEASE(cellString);
}

@end
