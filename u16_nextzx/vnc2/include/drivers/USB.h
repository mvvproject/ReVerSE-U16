/*
** USB.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Company Confidential
**
** Header file containing definitions for USB Classes
**
** Author: FTDI
** Project: Vinculum II
** Module: Vinculum II Firmware
** Requires:
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef USB_H
#define USB_H

#define USB_CLASS_DEVICE							 0x00
#define USB_CLASS_AUDIO								 0x01
#define USB_CLASS_CDC_CONTROL						 0x02
#define USB_CLASS_HID								 0x03
#define USB_CLASS_PHYSICAL							 0x05
#define USB_CLASS_IMAGE								 0x06
#define USB_CLASS_PRINTER							 0x07
#define USB_CLASS_MASS_STORAGE						 0x08
#define USB_CLASS_HUB								 0x09
#define USB_CLASS_CDC_DATA							 0x0a
#define USB_CLASS_SMART_CARD						 0x0b
#define USB_CLASS_CONTENT_SECURITY					 0x0d
#define USB_CLASS_VIDEO								 0x0e
#define USB_CLASS_PERSONAL_HEALTHCARE				 0x0f
#define USB_CLASS_DIAGNOSTIC_DEVICE					 0xdc
#define USB_CLASS_WIRELESS_CONTROLLER				 0xe0
#define USB_CLASS_MISCELLANEOUS						 0xef
#define USB_CLASS_APPLICATION						 0xfe
#define USB_CLASS_VENDOR							 0xff

#define USB_SUBCLASS_ANY							 0xff
#define USB_PROTOCOL_ANY							 0xff

// USB_CLASS_DEVICE
#define USB_SUBCLASS_DEVICE							 0x00
#define USB_PROTOCOL_DEVICE							 0x00

// USB_CLASS_AUDIO
#define USB_SUBCLASS_AUDIO_UNDEFINED				 0x00
#define USB_SUBCLASS_AUDIO_AUDIOCONTROL				 0x01
#define USB_SUBCLASS_AUDIO_AUDIOSTREAMING			 0x02
#define USB_SUBCLASS_AUDIO_MIDISTREAMING			 0x03
#define USB_PROTOCOL_AUDIO_UNDEFINED				 0x00
#define USB_PROTOCOL_AUDIO_VERSION_02_00			 0x20

// USB_CLASS_CDC_CONTROL
#define USB_SUBCLASS_CDC_CONTROL_DIRECT_LINE		 0x01
#define USB_SUBCLASS_CDC_CONTROL_ABSTRACT			 0x02
#define USB_SUBCLASS_CDC_CONTROL_TELEPHONE			 0x03
#define USB_SUBCLASS_CDC_CONTROL_MULTI_CHANNEL		 0x04
#define USB_SUBCLASS_CDC_CONTROL_CAPI				 0x05
#define USB_SUBCLASS_CDC_CONTROL_ETHERNET_NETWORKING 0x06
#define USB_SUBCLASS_CDC_CONTROL_ATM_NETWORKING		 0x07
#define USB_SUBCLASS_CDC_CONTROL_WIRELESS_HANDSET	 0x08
#define USB_SUBCLASS_CDC_CONTROL_DEVICE_MANAGEMENT	 0x09
#define USB_SUBCLASS_CDC_CONTROL_MOBILE_DIRECT_LINE	 0x0a
#define USB_SUBCLASS_CDC_CONTROL_OBEX				 0x0b
#define USB_SUBCLASS_CDC_CONTROL_ETHERNET_EMULATION	 0x0c
#define USB_PROTOCOL_CDC_CONTROL_NONE				 0x00
#define USB_PROTOCOL_CDC_CONTROL_ITU_T_V250			 0x01
#define USB_PROTOCOL_CDC_CONTROL_PCCA_101			 0x02
#define USB_PROTOCOL_CDC_CONTROL_PCCA_101_ANNEX_O	 0x03
#define USB_PROTOCOL_CDC_CONTROL_GSM_707			 0x04
#define USB_PROTOCOL_CDC_CONTROL_3GPP_2707			 0x05
#define USB_PROTOCOL_CDC_CONTROL_TIA_CS00170		 0x06
#define USB_PROTOCOL_CDC_CONTROL_USBEEM				 0x07

// USB_CLASS_HID
#define USB_SUBCLASS_HID_NONE						 0x00
#define USB_SUBCLASS_HID_BOOT_INTERFACE				 0x01
#define USB_PROTOCOL_HID_NONE						 0x00
#define USB_PROTOCOL_HID_KEYBOARD					 0x01
#define USB_PROTOCOL_HID_MOUSE						 0x02

// USB_CLASS_IMAGE
#define USB_SUBCLASS_IMAGE_STILLIMAGE				 0x01
#define USB_PROTOCOL_IMAGE_PIMA						 0x01

// USB_CLASS_PRINTER
#define USB_SUBCLASS_PRINTER						 0x01
#define USB_PROTOCOL_PRINTER_UNIDIRECTIONAL			 0x01
#define USB_PROTOCOL_PRINTER_BIDIRECTIONAL			 0x02
#define USB_PROTOCOL_PRINTER_1284_4_BIDIRECTIONAL	 0x03

// USB_CLASS_MASS_STORAGE
#define USB_SUBCLASS_MASS_STORAGE_SCSI				 0x06
#define USB_PROTOCOL_MASS_STORAGE_BOMS				 0x50

// USB_CLASS_HUB
#define USB_SUBCLASS_HUB							 0x00
#define USB_PROTOCOL_HUB_FULL_SPEED					 0x00
#define USB_PROTOCOL_HUB_HI_SPEED_S_TT				 0x01
#define USB_PROTOCOL_HUB_HI_SPEED_M_TT				 0x02

// USB_CLASS_CDC_DATA
#define USB_SUBCLASS_CDC_DATA						 0x00
#define USB_PROTOCOL_CDC_DATA						 0x00
#define USB_PROTOCOL_CDC_ISDN_BRI					 0x30
#define USB_PROTOCOL_CDC_HDLC						 0x31
#define USB_PROTOCOL_CDC_TRANSPARENT				 0x32
#define USB_PROTOCOL_CDC_Q921M						 0x50
#define USB_PROTOCOL_CDC_Q921						 0x51
#define USB_PROTOCOL_CDC_Q921TM						 0x52
#define USB_PROTOCOL_CDC_DATA_COMPRESSION			 0x90
#define USB_PROTOCOL_CDC_EURO_ISDN					 0x91
#define USB_PROTOCOL_CDC_V24_RATE_ADAPTATION		 0x92
#define USB_PROTOCOL_CDC_CAPI						 0x93

// USB_CLASS_VIDEO
#define USB_SUBCLASS_VIDEO_UNDEFINED				 0x00
#define USB_SUBCLASS_VIDEO_VIDEOCONTROL				 0x01
#define USB_SUBCLASS_VIDEO_VIDEOSTREAMING			 0x02
#define USB_SUBCLASS_VIDEO_INTERFACE_COLLECTION		 0x03
#define USB_PROTOCOL_VIDEO_UNDEFINED				 0x00

// USB_CLASS_APPLICATION
// Device Firmware Upgrade Class
#define USB_SUBCLASS_DFU							 0x01
#define USB_PROTOCOL_DFU_RUNTIME					 0x01
#define USB_PROTOCOL_DFU_DFUMODE					 0x02
// IrDA Bridge Class
#define USB_SUBCLASS_IRDA_BRIDGE					 0x02
// Test and Measurement Class
#define USB_SUBCLASS_USBTMC							 0x03
#define USB_PROTOCOL_USBTMC							 0x00
#define USB_PROTOCOL_USBTMC_USB488					 0x01

// USB_CLASS_VENDOR
#define USB_SUBCLASS_VENDOR_NONE					 0x00
// Android Debugger interfaces all have the following interface subclass:
#define USB_SUBCLASS_VENDOR_ADB						 0x42
#define USB_SUBCLASS_VENDOR_VENDOR					 0xff
#define USB_PROTOCOL_VENDOR_NONE					 0x00

#define USB_VID_ANY									 0xffff
#define USB_PID_ANY									 0xffff

#define USB_VID_FTDI								 0x0403
#define USB_PID_FTDI_FT232							 0x6001
#define USB_PID_FTDI_FT2232							 0x6010
#define USB_PID_FTDI_FT4232							 0x6011
#define USB_PID_FTDI_FT_X_SERIES					 0x6015

// Table 9-2. Format of Setup Data
typedef struct _usb_deviceRequest_t
{
    // D7: Data transfer direction
    //		0 = Host-to-device
    //		1 = Device-to-host
    // D6...5: Type
    //		0 = Standard
    //		1 = Class
    //		2 = Vendor
    //		3 = Reserved
    // D4...0: Recipient
    //		0 = Device
    //		1 = Interface
    //		2 = Endpoint
    //		3 = Other
    unsigned char  bmRequestType;
    // Table 9-4.
    unsigned char  bRequest;
    unsigned short wValue;
    unsigned short wIndex;
    unsigned short wLength;
} usb_deviceRequest_t;

// Data transfer direction
#define USB_BMREQUESTTYPE_HOST_TO_DEV 0x00
#define USB_BMREQUESTTYPE_DEV_TO_HOST 0x80
// Type
#define USB_BMREQUESTTYPE_STANDARD	  0x00
#define USB_BMREQUESTTYPE_CLASS		  0x20
#define USB_BMREQUESTTYPE_VENDOR	  0x40
// Recipient
#define USB_BMREQUESTTYPE_DEVICE	  0x00
#define USB_BMREQUESTTYPE_INTERFACE	  0x01
#define USB_BMREQUESTTYPE_ENDPOINT	  0x02
#define USB_BMREQUESTTYPE_PORT		  0x03

// Table 9-4. Standard Request Codes
// Used as bRequest in usb_deviceRequest_t and bDescriptorType in usb_deviceDescriptor_t
//		bRequest										Value	// Reference
#define USB_REQUEST_CODE_GET_STATUS		   0  // 9.4.5 Get Status
#define USB_REQUEST_CODE_CLEAR_FEATURE	   1  // 9.4.1 Clear Feature
#define USB_REQUEST_CODE_SET_FEATURE	   3  // 9.4.9 Set Feature
#define USB_REQUEST_CODE_SET_ADDRESS	   5  // 9.4.6 Set Address
#define USB_REQUEST_CODE_GET_DESCRIPTOR	   6  // 9.4.3 Get Descriptor
#define USB_REQUEST_CODE_SET_DESCRIPTOR	   7  // 9.4.8 Set Descriptor
#define USB_REQUEST_CODE_GET_CONFIGURATION 8  // 9.4.2 Get Configuration
#define USB_REQUEST_CODE_SET_CONFIGURATION 9  // 9.4.7 Set Configuration
#define USB_REQUEST_CODE_GET_INTERFACE	   10 // 9.4.4 Get Interface
#define USB_REQUEST_CODE_SET_INTERFACE	   11 // 9.4.10 Set Interface
#define USB_REQUEST_CODE_SYNCH_FRAME	   12 // 9.4.11 Synch Frame

// Table 9-5. Descriptor Types
// Used for wValue high byte in 9.4.3 Get Descriptor, 9.4.8 Set Descriptor
//		Descriptor Types								Value
#define USB_DESCRIPTOR_TYPE_DEVICE					  1
#define USB_DESCRIPTOR_TYPE_CONFIGURATION			  2
#define USB_DESCRIPTOR_TYPE_STRING					  3
#define USB_DESCRIPTOR_TYPE_INTERFACE				  4
#define USB_DESCRIPTOR_TYPE_ENDPOINT				  5
#define USB_DESCRIPTOR_TYPE_DEVICE_QUALIFIER		  6
#define USB_DESCRIPTOR_TYPE_OTHER_SPEED_CONFIGURATION 7
#define USB_DESCRIPTOR_TYPE_INTERFACE_POWER			  8
#define USB_DESCRIPTOR_TYPE_INTERFACE_ASSOCIATION     11

// Table 9-6. Standard Feature Selectors
// Used for wValue in 9.4.9 Set Feature, 9.4.1 Clear Feature
//		Feature Selector Recipient Value
#define USB_FEATURE_DEVICE_REMOTE_WAKEUP 1 // Device
#define USB_FEATURE_ENDPOINT_HALT		 0 // Endpoint
#define USB_FEATURE_TEST_MODE			 2 // Device

// Table 9-8. Standard Device Descriptor
typedef struct _usb_deviceDescriptor_t
{
    unsigned char  bLength;
    unsigned char  bDescriptorType;
    unsigned short bcdUSB;
    unsigned char  bDeviceClass;
    unsigned char  bDeviceSubclass;
    unsigned char  bDeviceProtocol;
    unsigned char  bMaxPacketSize0;
    unsigned short idVendor;
    unsigned short idProduct;
    unsigned short bcdDevice;
    unsigned char  iManufacturer;
    unsigned char  iProduct;
    unsigned char  iSerialNumber;
    unsigned char  bNumConfigurations;
} usb_deviceDescriptor_t;

// Table 9-9. Device_Qualifier Descriptor
typedef struct _usb_deviceQualifierDescriptor_t
{
    unsigned char  bLength;
    unsigned char  bDescriptorType;
    unsigned short bcdUSB;
    unsigned char  bDeviceClass;
    unsigned char  bDeviceSubclass;
    unsigned char  bDeviceProtocol;
    unsigned char  bMaxPacketSize0;
    unsigned char  bNumConfigurations;
    unsigned char  bReserved;
} usb_deviceQualifierDescriptor_t;

// Table 9-10. Standard Configuration Descriptor
typedef struct _usb_deviceConfigurationDescriptor_t
{
    unsigned char  bLength;
    unsigned char  bDescriptorType;
    unsigned short wTotalLength;
    unsigned char  bNumInterfaces;
    unsigned char  bConfigurationValue;
    unsigned char  iConfiguration;
    unsigned char  bmAttributes;
    unsigned char  bMaxPower;
} usb_deviceConfigurationDescriptor_t;

// Config descriptor bmAttributes values
#define USB_CONFIG_BMATTRIBUTES_REMOTE_WAKEUP	  0x20
#define USB_CONFIG_BMATTRIBUTES_SELF_POWERED	  0x40
#define USB_CONFIG_BMATTRIBUTES_RESERVED_SET_TO_1 0x80

// Table 9-12. Standard Interface Descriptor
typedef struct _usb_deviceInterfaceDescriptor_t
{
    unsigned char bLength;
    unsigned char bDescriptorType;
    unsigned char bInterfaceNumber;
    unsigned char bAlternateSetting;
    unsigned char bNumEndpoints;
    unsigned char bInterfaceClass;
    unsigned char bInterfaceSubclass;
    unsigned char bInterfaceProtocol;
    unsigned char iInterface;
} usb_deviceInterfaceDescriptor_t;

// Table 9-13. Standard Endpoint Descriptor
typedef struct _usb_deviceEndpointDescriptor_t
{
    unsigned char  bLength;
    unsigned char  bDescriptorType;
    unsigned char  bEndpointAddress;
    unsigned char  bmAttributes;
    unsigned short wMaxPacketSize;
    unsigned char  bInterval;
} usb_deviceEndpointDescriptor_t;

#define USB_ENDPOINT_DESCRIPTOR_ATTR_MASK		 0x03
#define USB_ENDPOINT_DESCRIPTOR_ATTR_CONTROL	 0x00
#define USB_ENDPOINT_DESCRIPTOR_ATTR_ISOCHRONOUS 0x01
#define USB_ENDPOINT_DESCRIPTOR_ATTR_BULK		 0x02
#define USB_ENDPOINT_DESCRIPTOR_ATTR_INTERRUPT	 0x03

// USB ECN Interface Association Descriptors
typedef struct _usb_interfaceAssociationDescriptor_t
{
    unsigned char  bLength;
    unsigned char  bDescriptorType;
    unsigned char  bFirstInterface;
    unsigned char  bInterfaceCount;
    unsigned char  bFunctionClass;
    unsigned char  bFunctionSubClass;
    unsigned char  bFunctionProtocol;
    unsigned char  iFunction;
} usb_interfaceAssociationDescriptor_t;

// Table 9-15. String Descriptor Zero, Specifying Languages Supported by the Device
typedef struct _usb_deviceStringDescriptorZero_t
{
    unsigned char  bLength;
    unsigned char  bDescriptorType;
    unsigned short wLANGID0;
    // unsigned short wLANGID1;
    // unsigned short wLANGID...;
    // unsigned short wLANGIDn;
} usb_deviceStringDescriptorZero_t;

// Table 9-16. UNICODE String Descriptor
typedef struct _usb_deviceStringDescriptor_t
{
    unsigned char bLength;
    unsigned char bDescriptorType;
    unsigned char bString;
    // unsigned char chString[0];
    // unsigned char chString[...];
    // unsigned char chString[n];
} usb_deviceStringDescriptor_t;

// Table 11-13. Hub Descriptor
typedef struct _usb_hubDescriptor_t
{
    unsigned char  bLength;
    unsigned char  bDescriptorType;
    unsigned char  bNbrPorts;
    unsigned short wHubCharacteristics;
    unsigned char  bPwrOn2PwrGood;
    unsigned char  bHubContrCurrent;
    // from this point on there are variable size fields depending
    // on bNbrPorts
    unsigned char  DeviceRemovable[16];
    unsigned char  PortPwrCtrlMask[16];
} usb_hubDescriptor_t;

#define USB_HUB_REQUEST_CODE_GET_STATUS			  0
#define USB_HUB_REQUEST_CODE_CLEAR_FEATURE		  1
#define USB_HUB_REQUEST_CODE_SET_FEATURE		  3
#define USB_HUB_REQUEST_CODE_GET_DESCRIPTOR		  6
#define USB_HUB_REQUEST_CODE_SET_DESCRIPTOR		  7
#define USB_HUB_REQUEST_CODE_CLEAR_TT_BUFFER	  8
#define USB_HUB_REQUEST_CODE_RESET_TT			  9
#define USB_HUB_REQUEST_CODE_GET_TT_STATE		  10
#define USB_HUB_REQUEST_CODE_STOP_TT			  11

// Table 11-13. Hub Descriptor							Value
#define USB_DESCRIPTOR_TYPE_HUB					  0x29

#define USB_HUB_CLASS_FEATURE_C_HUB_LOCAL_POWER	  0
#define USB_HUB_CLASS_FEATURE_C_HUB_OVER_CURRENT  1
#define USB_HUB_CLASS_FEATURE_PORT_CONNECTION	  0
#define USB_HUB_CLASS_FEATURE_PORT_ENABLE		  1
#define USB_HUB_CLASS_FEATURE_PORT_SUSPEND		  2
#define USB_HUB_CLASS_FEATURE_PORT_OVER_CURRENT	  3
#define USB_HUB_CLASS_FEATURE_PORT_RESET		  4
#define USB_HUB_CLASS_FEATURE_PORT_POWER		  8
#define USB_HUB_CLASS_FEATURE_PORT_LOW_SPEED	  9
#define USB_HUB_CLASS_FEATURE_C_PORT_CONNECTION	  16
#define USB_HUB_CLASS_FEATURE_C_PORT_ENABLE		  17
#define USB_HUB_CLASS_FEATURE_C_PORT_SUSPEND	  18
#define USB_HUB_CLASS_FEATURE_C_PORT_OVER_CURRENT 19
#define USB_HUB_CLASS_FEATURE_C_PORT_RESET		  20
#define USB_HUB_CLASS_FEATURE_PORT_TEST			  21
#define USB_HUB_CLASS_FEATURE_PORT_INDICATOR	  22

// Table 11-19. Hub Status Field, wHubStatus
// Table 11-20. Hub Change Field, wHubChange
typedef struct _usb_hubStatus_t
{
    // first word - hub status
    unsigned short localPowerSource : 1;
    unsigned short overCurrent : 1;
    unsigned short resv1 : 14;
    // second word - hub status change
    unsigned short localPowerSourceChange : 1;
    unsigned short overCurrentChange : 1;
    unsigned short resv2 : 14;
} usb_hubStatus_t;

// Table 11-21. Port Status Field, wPortStatus
typedef struct _usb_hubPortStatus_t
{
    // first word - port status
    unsigned short currentConnectStatus : 1;       // 0
    unsigned short portEnabled : 1;                // 1
    unsigned short portSuspend : 1;                // 2
    unsigned short portOverCurrent : 1;            // 3
    unsigned short portReset : 1;                  // 4
    unsigned short resv1 : 3;                      // 5..7
    unsigned short portPower : 1;                  // 8
    unsigned short portLowSpeed : 1;               // 9
    unsigned short portHighSpeed : 1;              // 10
    unsigned short portTest : 1;                   // 11
    unsigned short portIndicator : 1;              // 12
    unsigned short resv2 : 3;                      // 13..15
    // second word - port status change
    unsigned short currentConnectStatusChange : 1; // 0
    unsigned short portEnabledChange : 1;          // 1
    unsigned short portSuspendChange : 1;          // 2
    unsigned short portOverCurrentChange : 1;      // 3
    unsigned short portResetChange : 1;            // 4
    unsigned short resv3 : 3;                      // 5..7
    unsigned short portPowerChange : 1;            // 8
    unsigned short portLowSpeedChange : 1;         // 9
    unsigned short portHighSpeedChange : 1;        // 10
    unsigned short portTestChange : 1;             // 11
    unsigned short portIndicatorChange : 1;        // 12
    unsigned short resv4 : 3;                      // 13..15
} usb_hubPortStatus_t;

typedef struct _usb_hub_selector_t {
    unsigned char hub_port;
    unsigned char selector;
} usb_hub_selector_t;

// USB Language Identifiers for use with USB_REQUEST_CODE_GET_DESCRIPTOR for
// string descriptors (LANGID is the wIndex value)
// from USB Language Identifiers (LANGIDs) PDF Page 4
#define USB_LANGID_AFRIKAANS				  0x0436
#define USB_LANGID_ALBANIAN					  0x041c
#define USB_LANGID_ARABIC_SAUDI_ARABIA		  0x0401
#define USB_LANGID_ARABIC_IRAQ				  0x0801
#define USB_LANGID_ARABIC_EGYPT				  0x0c01
#define USB_LANGID_ARABIC_LIBYA				  0x1001
#define USB_LANGID_ARABIC_ALGERIA			  0x1401
#define USB_LANGID_ARABIC_MOROCCO			  0x1801
#define USB_LANGID_ARABIC_TUNISIA			  0x1c01
#define USB_LANGID_ARABIC_OMAN				  0x2001
#define USB_LANGID_ARABIC_YEMEN				  0x2401
#define USB_LANGID_ARABIC_SYRIA				  0x2801
#define USB_LANGID_ARABIC_JORDAN			  0x2c01
#define USB_LANGID_ARABIC_LEBANON			  0x3001
#define USB_LANGID_ARABIC_KUWAIT			  0x3401
#define USB_LANGID_ARABIC_UAE				  0x3801
#define USB_LANGID_ARABIC_BAHRAIN			  0x3c01
#define USB_LANGID_ARABIC_QATAR				  0x4001
#define USB_LANGID_ARMENIAN					  0x042b
#define USB_LANGID_ASSAMESE					  0x044d
#define USB_LANGID_AZERI_LATIN				  0x042c
#define USB_LANGID_AZERI_CYRILLIC			  0x082c
#define USB_LANGID_BASQUE					  0x042d
#define USB_LANGID_BELARUSSIAN				  0x0423
#define USB_LANGID_BENGALI					  0x0445
#define USB_LANGID_BULGARIAN				  0x0402
#define USB_LANGID_BURMESE					  0x0455
#define USB_LANGID_CATALAN					  0x0403
#define USB_LANGID_CHINESE_TAIWAN			  0x0404
#define USB_LANGID_CHINESE_PRC				  0x0804
#define USB_LANGID_CHINESE_HONG_KONG_SAR_PRC  0x0c04
#define USB_LANGID_CHINESE_SINGAPORE		  0x1004
#define USB_LANGID_CHINESE_MACAU_SAR		  0x1404
#define USB_LANGID_CROATIAN					  0x041a
#define USB_LANGID_CZECH					  0x0405
#define USB_LANGID_DANISH					  0x0406
#define USB_LANGID_DUTCH_NETHERLANDS		  0x0413
#define USB_LANGID_DUTCH_BELGIUM			  0x0813
#define USB_LANGID_ENGLISH_UNITED_STATES	  0x0409
#define USB_LANGID_ENGLISH_UNITED_KINGDOM	  0x0809
#define USB_LANGID_ENGLISH_AUSTRALIAN		  0x0c09
#define USB_LANGID_ENGLISH_CANADIAN			  0x1009
#define USB_LANGID_ENGLISH_NEW_ZEALAND		  0x1409
#define USB_LANGID_ENGLISH_IRELAND			  0x1809
#define USB_LANGID_ENGLISH_SOUTH_AFRICA		  0x1c09
#define USB_LANGID_ENGLISH_JAMAICA			  0x2009
#define USB_LANGID_ENGLISH_CARIBBEAN		  0x2409
#define USB_LANGID_ENGLISH_BELIZE			  0x2809
#define USB_LANGID_ENGLISH_TRINIDAD			  0x2c09
#define USB_LANGID_ENGLISH_ZIMBABWE			  0x3009
#define USB_LANGID_ENGLISH_PHILIPPINES		  0x3409
#define USB_LANGID_ESTONIAN					  0x0425
#define USB_LANGID_FAEROESE					  0x0438
#define USB_LANGID_FARSI					  0x0429
#define USB_LANGID_FINNISH					  0x040b
#define USB_LANGID_FRENCH_STANDARD			  0x040c
#define USB_LANGID_FRENCH_BELGIAN			  0x080c
#define USB_LANGID_FRENCH_CANADIAN			  0x0c0c
#define USB_LANGID_FRENCH_SWITZERLAND		  0x100c
#define USB_LANGID_FRENCH_LUXEMBOURG		  0x140c
#define USB_LANGID_FRENCH_MONACO			  0x180c
#define USB_LANGID_GEORGIAN					  0x0437
#define USB_LANGID_GERMAN_STANDARD			  0x0407
#define USB_LANGID_GERMAN_SWITZERLAND		  0x0807
#define USB_LANGID_GERMAN_AUSTRIA			  0x0c07
#define USB_LANGID_GERMAN_LUXEMBOURG		  0x1007
#define USB_LANGID_GERMAN_LIECHTENSTEIN		  0x1407
#define USB_LANGID_GREEK					  0x0408
#define USB_LANGID_GUJARATI					  0x0447
#define USB_LANGID_HEBREW					  0x040d
#define USB_LANGID_HINDI					  0x0439
#define USB_LANGID_HUNGARIAN				  0x040e
#define USB_LANGID_ICELANDIC				  0x040f
#define USB_LANGID_INDONESIAN				  0x0421
#define USB_LANGID_ITALIAN_STANDARD			  0x0410
#define USB_LANGID_ITALIAN_SWITZERLAND		  0x0810
#define USB_LANGID_JAPANESE					  0x0411
#define USB_LANGID_KANNADA					  0x044b
#define USB_LANGID_KASHMIRI_INDIA			  0x0860
#define USB_LANGID_KAZAKH					  0x043f
#define USB_LANGID_KONKANI					  0x0457
#define USB_LANGID_KOREAN					  0x0412
#define USB_LANGID_KOREAN_JOHAB				  0x0812
#define USB_LANGID_LATVIAN					  0x0426
#define USB_LANGID_LITHUANIAN				  0x0427
#define USB_LANGID_LITHUANIAN_CLASSIC		  0x0827
#define USB_LANGID_MACEDONIAN				  0x042f
#define USB_LANGID_MALAY_MALAYSIAN			  0x043e
#define USB_LANGID_MALAY_BRUNEI_DARUSSALAM	  0x083e
#define USB_LANGID_MALAYALAM				  0x044c
#define USB_LANGID_MANIPURI					  0x0458
#define USB_LANGID_MARATHI					  0x044e
#define USB_LANGID_NEPALI_INDIA				  0x0861
#define USB_LANGID_NORWEGIAN_BOKMAL			  0x0414
#define USB_LANGID_NORWEGIAN_NYNORSK		  0x0814
#define USB_LANGID_ORIYA					  0x0448
#define USB_LANGID_POLISH					  0x0415
#define USB_LANGID_PORTUGUESE_BRAZIL		  0x0416
#define USB_LANGID_PORTUGUESE_STANDARD		  0x0816
#define USB_LANGID_PUNJABI					  0x0446
#define USB_LANGID_ROMANIAN					  0x0418
#define USB_LANGID_RUSSIAN					  0x0419
#define USB_LANGID_SANSKRIT					  0x044f
#define USB_LANGID_SERBIAN_CYRILLIC			  0x0c1a
#define USB_LANGID_SERBIAN_LATIN			  0x081a
#define USB_LANGID_SINDHI					  0x0459
#define USB_LANGID_SLOVAK					  0x041b
#define USB_LANGID_SLOVENIAN				  0x0424
#define USB_LANGID_SPANISH_TRADITIONAL_SORT	  0x040a
#define USB_LANGID_SPANISH_MEXICAN			  0x080a
#define USB_LANGID_SPANISH_MODERN_SORT		  0x0c0a
#define USB_LANGID_SPANISH_GUATEMALA		  0x100a
#define USB_LANGID_SPANISH_COSTA_RICA		  0x140a
#define USB_LANGID_SPANISH_PANAMA			  0x180a
#define USB_LANGID_SPANISH_DOMINICAN_REPUBLIC 0x1c0a
#define USB_LANGID_SPANISH_VENEZUELA		  0x200a
#define USB_LANGID_SPANISH_COLOMBIA			  0x240a
#define USB_LANGID_SPANISH_PERU				  0x280a
#define USB_LANGID_SPANISH_ARGENTINA		  0x2c0a
#define USB_LANGID_SPANISH_ECUADOR			  0x300a
#define USB_LANGID_SPANISH_CHILE			  0x340a
#define USB_LANGID_SPANISH_URUGUAY			  0x380a
#define USB_LANGID_SPANISH_PARAGUAY			  0x3c0a
#define USB_LANGID_SPANISH_BOLIVIA			  0x400a
#define USB_LANGID_SPANISH_EL_SALVADOR		  0x440a
#define USB_LANGID_SPANISH_HONDURAS			  0x480a
#define USB_LANGID_SPANISH_NICARAGUA		  0x4c0a
#define USB_LANGID_SPANISH_PUERTO_RICO		  0x500a
#define USB_LANGID_SUTU						  0x0430
#define USB_LANGID_SWAHILI_KENYA			  0x0441
#define USB_LANGID_SWEDISH					  0x041d
#define USB_LANGID_SWEDISH_FINLAND			  0x081d
#define USB_LANGID_TAMIL					  0x0449
#define USB_LANGID_TATAR_TATARSTAN			  0x0444
#define USB_LANGID_TELUGU					  0x044a
#define USB_LANGID_THAI						  0x041e
#define USB_LANGID_TURKISH					  0x041f
#define USB_LANGID_UKRAINIAN				  0x0422
#define USB_LANGID_URDU_PAKISTAN			  0x0420
#define USB_LANGID_URDU_INDIA				  0x0820
#define USB_LANGID_UZBEK_LATIN				  0x0443
#define USB_LANGID_UZBEK_CYRILLIC			  0x0843
#define USB_LANGID_VIETNAMESE				  0x042a
#define USB_LANGID_HID_USAGE_DATA_DESCRIPTOR  0x04ff
#define USB_LANGID_HID_VENDOR_DEFINED_1		  0xf0ff
#define USB_LANGID_HID_VENDOR_DEFINED_2		  0xf4ff
#define USB_LANGID_HID_VENDOR_DEFINED_3		  0xf8ff
#define USB_LANGID_HID_VENDOR_DEFINED_4		  0xfcff

#endif                                 // USB_H
