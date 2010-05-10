//
//  OpalXMLEvent.h
//  Opal
//
//  Created by Christian Niles on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum OpalXMLEventType {
	OPAL_START_DOCUMENT_EVENT = 1,
	OPAL_DOCTYPE_EVENT,
	OPAL_START_TAG_EVENT,
	OPAL_TEXT_EVENT,
	OPAL_END_TAG_EVENT,
	OPAL_PROCESSING_INSTRUCTION_EVENT,
	OPAL_COMMENT_EVENT
};
typedef enum OpalXMLEventType OpalXMLEventType;

@interface OpalXMLEvent : NSObject {
	OpalXMLEventType type;
	
	NSString *version;
	NSString *encoding;
	BOOL standalone;
	
	NSString *tagName;
	NSDictionary *attributes;
	NSString *content;
}

// ===== START DOCUMENT ================================================================================================

+ (OpalXMLEvent *)startDocumentEvent;
+ (OpalXMLEvent *)startDocumentEventWithEncoding:(NSString *)encoding;
+ (OpalXMLEvent *)startDocumentEventWithVersion:(NSString *)version encoding:(NSString *)encoding standalone:(BOOL)standalone;

- (id)initStartDocumentEvent;
- (id)initStartDocumentEventWithEncoding:(NSString *)encoding;
- (id)initStartDocumentEventWithVersion:(NSString *)version encoding:(NSString *)encoding standalone:(BOOL)standalone;

// ===== START TAG =====================================================================================================

+ (OpalXMLEvent *)startTagEventWithTagName:(NSString *)startTagName andAttributes:(NSDictionary *)attributes;
- (id)initStartTagEventWithTagName:(NSString *)startTagName andAttributes:(NSDictionary *)attributes;

// ===== END TAG =======================================================================================================

+ (OpalXMLEvent *)endTagEventWithTagName:(NSString *)endTagName;
- (id)initEndTagEventWithTagName:(NSString *)endTagName;

// ===== TEXT ==========================================================================================================

+ (OpalXMLEvent *)textEventWithContent:(NSString *)textContent;
- (id)initTextEventWithContent:(NSString *)textContent;

// ===== COMMENTS ======================================================================================================

+ (OpalXMLEvent *)commentEventWithContent:(NSString *)comment;
- (id)initCommentEventWithContent:(NSString *)comment;


// ===== PROPERTIES ====================================================================================================

@property (readonly) OpalXMLEventType type;

@property (readonly) NSString *version;
@property (readonly) NSString *encoding;
@property (readonly) BOOL standalone;

@property (readonly) NSString *tagName;
@property (readonly) NSDictionary *attributes;
@property (readonly) NSString *content;

@end
