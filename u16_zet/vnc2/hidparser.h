 
 /* -------------------------------------------------------------------------- */
 
 #ifndef HIDPARS_H
 #define HIDPARS_H
 
 
 //#ifdef __cplusplus
 //extern "C" {
 //#endif /* __cplusplus */
 
 #include "hidtypes.h"
 
 /*
  * HIDParse
  * -------------------------------------------------------------------------- */
 int HIDParse(HIDParser_t* pParser, HIDData_t* pData);
 
 /*
  * ResetParser
  * -------------------------------------------------------------------------- */
 void ResetParser(HIDParser_t* pParser);
 
 /*
  * FindObject
  * -------------------------------------------------------------------------- */
 int FindObject(HIDParser_t* pParser, HIDData_t* pData);
 
 /*
  * GetValue
  * -------------------------------------------------------------------------- */
 //void GetValue(const uchar* Buf, HIDData* pData);
 void GetValue  (const uchar* Buf, HIDData_t* pData, ReportID_t* pReportID_tbl);
 void GetValueXY(const uchar* Buf, HIDData_t* pData, ReportID_t* pReportID_tbl);
 
 /*
  * SetValue
  * -------------------------------------------------------------------------- */
 void SetValue  (const HIDData_t* pData, uchar* Buf);
 /*
  * GetReportOffset
  * -------------------------------------------------------------------------- */
 uchar* GetReportOffset(HIDParser_t* pParser, const uchar ReportID,
                        const uchar ReportType);

 int ReportID_DataLength(HIDParser_t* pParser, uchar ReportID);
 int ReportID_Offset(HIDParser_t* pParser, uchar ReportID);
 uchar FindReport_max_ID(HIDParser_t* pParser);
 int FindMouse_XYW(HIDParser_t* pParser, HIDData_t* pData, ushort XYW);
 int FindMouse_Buttons(HIDParser_t* pParser, HIDData_t* pData);
 

 #endif

