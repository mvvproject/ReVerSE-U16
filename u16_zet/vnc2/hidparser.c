 
 #include <string.h>
 #include "hidparser.h"
 

 #define ERROR(x)
void message(char *msg);
void number(unsigned char val);
char *eol = "\r\n";
 
 const char ItemSize[4]={0,1,2,4};
 
  void ResetParser(HIDParser_t* pParser)
 { 
   HIDData_t* pParser_Data;
   pParser_Data = pParser->pData;
   //===========================2015.04.29
   pParser->Pos=0;
   pParser->Count=0;
   pParser->nObject=0;
   pParser->nReport=0;

   pParser->UsageSize=0;
   memset(pParser->UsageTab,0,sizeof(pParser->UsageTab));   //USAGE_TAB_SIZE = 20
 
   memset(pParser->OffsetTab_ReportID,   0, sizeof(pParser->OffsetTab_ReportID))  ; //
   memset(pParser->OffsetTab_ReportType, 0, sizeof(pParser->OffsetTab_ReportType)); //
   memset(pParser->OffsetTab_DataOffset, 0, sizeof(pParser->OffsetTab_DataOffset)); //
   memset(pParser->pData,0,sizeof(HIDData_t));
   pParser_Data->ReportID=0x1; // Fix BUG 

 }

	
static void ResetLocalState(HIDParser_t* pParser)
 {
   pParser->UsageSize = 0;
   memset(pParser->UsageTab,0,sizeof(pParser->UsageTab));
 }
 
 uchar* GetReportOffset(HIDParser_t* pParser, 
                        const uchar  ReportID, 
                        const uchar  ReportType)
 {
   ushort Pos;
   Pos = 0x0;
   while(Pos < MAX_REPORT && pParser->OffsetTab_ReportID[Pos] != 0)
   { //search ReportID and ReportType up to MAX_REPORT
     if(  pParser->OffsetTab_ReportID  [Pos] == ReportID 
       && pParser->OffsetTab_ReportType[Pos] == ReportType){
	   //message("GetReportOffset: Report ID and Type was found: ");
	   //number(ReportID);
	   //message(" ");
	   //number(ReportType);
	   //message(eol);
	   //message("Offset: ");
	   //number(&pParser->OffsetTab_DataOffset[Pos]);
	   //message(eol);
       return &pParser->OffsetTab_DataOffset[Pos];
	}
     Pos++;
   }
   if(Pos<MAX_REPORT) // if ReportID and ReportType was not found
   {
	 //message("GetReportOffset: Report ID and Type was not found: ");
	 //message(eol);
	 //message("GetReportOffset: Make new record ");
	 //message(eol);
	 //message("GetReportOffset: Pos ");
	 //number(Pos);
	 //message(eol);
     /* Increment Report count */
     pParser->nReport++;
     pParser->OffsetTab_ReportID[Pos]   = ReportID;
     pParser->OffsetTab_ReportType[Pos] = ReportType;
     pParser->OffsetTab_DataOffset[Pos] = 0;
	 
     return &pParser->OffsetTab_DataOffset[Pos];
   }
   //=========OUT OF RANGE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	message("GetReportOffset: FATAL ERROR- Report count is out of space ");
	message(eol);
	while (1);
	return 0x0;
	//return NULL;
 }

 long FormatValue(long Value, uchar Size)
 {
   if(Size==1) 
     Value=(long)(char)Value;
   else if(Size==2) 
     Value=(long)(short)Value;
   return Value;
 }	
//================================================================
//====================HID PARSER==================================
//================================================================	
 int HIDParse(HIDParser_t* pParser, HIDData_t* pData)
 {
   int Found;
   HIDData_t* pParser_Data;
   //--test
   uchar* pPosTST;
   //--------------------------
   pParser_Data = pParser->pData;
   //===========================2015.04.29
   Found=0;
  
   while(!Found && pParser->Pos < pParser->ReportDescSize)
   {
     /* Get new pParser->Item if current pParser->Count is empty */
     if(pParser->Count==0)
     {
       pParser->Item  = pParser->ReportDesc[pParser->Pos++];
       pParser->Value = 0;
       memcpy(&pParser->Value, &pParser->ReportDesc[pParser->Pos], ItemSize[pParser->Item & SIZE_MASK]);
       /* Pos on next item */
       pParser->Pos += ItemSize[pParser->Item & SIZE_MASK];
     }
 
     switch(pParser->Item & ITEM_MASK) // Which ITEM, what we want to do , #define ITEM_MASK  0xFC
     {
       case ITEM_UPAGE : // USage page = 0x6
       {
         /* Copy UPage in Usage stack */
         pParser->UPage = (ushort)pParser->Value;
         break;
       }
       case ITEM_USAGE : //0x6, 0x9
       {
         /* Copy global or local UPage if any, in Usage stack */
          if((pParser->Item & SIZE_MASK)>2)
           pParser->UsageTab[pParser->UsageSize].UPage = (ushort)(pParser->Value>>16);
         else
           pParser->UsageTab[pParser->UsageSize].UPage = pParser->UPage;
 
         /* Copy Usage in Usage stack */
         pParser->UsageTab[pParser->UsageSize].Usage = (ushort)(pParser->Value & 0xFFFF);
 
         /* Increment Usage stack size */
         pParser->UsageSize++;
 
         break;
       }
       case ITEM_COLLECTION :  //A1
       {
       /* Get UPage/Usage from UsageTab and store them in pParser->Data.Path ==============*/
       //pParser->Data.Path_Node[pParser->Data.Path_Size].UPage = pParser->UsageTab[0].UPage;
		 pParser_Data->Path_Node[pParser_Data->Path_Size].UPage = pParser->UsageTab[0].UPage;
         pParser_Data->Path_Node[pParser_Data->Path_Size].Usage = pParser->UsageTab[0].Usage;
         pParser_Data->Path_Size++;
       
         /* Unstack UPage/Usage from UsageTab (never remove the last) */
         if(pParser->UsageSize>0)
         {
           uchar ii=0;
           while(ii<pParser->UsageSize)
           {
             pParser->UsageTab[ii].Usage = pParser->UsageTab[ii+1].Usage;
             pParser->UsageTab[ii].UPage = pParser->UsageTab[ii+1].UPage;
             ii++;
           }
           /* Remove Usage */
           pParser->UsageSize--;
         }
 
         /* Get Index if any */
         if(pParser->Value>=0x80)
         {
           pParser_Data->Path_Node[pParser_Data->Path_Size].UPage = 0xFF;
           pParser_Data->Path_Node[pParser_Data->Path_Size].Usage = pParser->Value & 0x7F;
           pParser_Data->Path_Size++;
         }
		 ResetLocalState(pParser);
         break;
       }
       case ITEM_END_COLLECTION :
       {
         pParser_Data->Path_Size--;
         /* Remove Index if any */
         if(pParser_Data->Path_Node[pParser_Data->Path_Size].UPage == 0xFF)
           pParser_Data->Path_Size--;
		 ResetLocalState(pParser);
         break;
       }
       case ITEM_FEATURE :
       case ITEM_INPUT :
       case ITEM_OUTPUT :
       {
         /* An object was found */
         Found=1;
 
         /* Increment object count */
         pParser->nObject++;
 
         /* Get new pParser->Count from global value */
         if(pParser->Count==0)
         {
           pParser->Count=pParser->ReportCount;
         }
 
         /* Get UPage/Usage from UsageTab and store them in pParser->Data.Path */
         pParser_Data->Path_Node[pParser_Data->Path_Size].UPage = pParser->UsageTab[0].UPage;
         pParser_Data->Path_Node[pParser_Data->Path_Size].Usage = pParser->UsageTab[0].Usage;
         pParser_Data->Path_Size++;
   
         /* Unstack UPage/Usage from UsageTab (never remove the last) */
         if(pParser->UsageSize>0)
         {
           uchar ii=0;
           while(ii<pParser->UsageSize)
           {
             pParser->UsageTab[ii].UPage = pParser->UsageTab[ii+1].UPage;
             pParser->UsageTab[ii].Usage = pParser->UsageTab[ii+1].Usage;
             ii++;
           }
           /* Remove Usage */
           pParser->UsageSize--;
         }
 
         /* Copy data type */
         pParser_Data->Type=(uchar)(pParser->Item & ITEM_MASK);
 
         /* Copy data attribute */
         pParser_Data->Attribute=(uchar)pParser->Value;
 
         /* Store offset */
         pParser_Data->Offset=*GetReportOffset(pParser, pParser_Data->ReportID, (uchar)(pParser->Item & ITEM_MASK));
     
         /* Get Object in pData */
         /* -------------------------------------------------------------------------- */
         memcpy(pData, pParser_Data, sizeof(HIDData_t));
         /* -------------------------------------------------------------------------- */
 
         /* Increment Report Offset */
         pPosTST = GetReportOffset(pParser, pParser_Data->ReportID, (uchar)(pParser->Item & ITEM_MASK));
		 *pPosTST += pParser_Data->Size;

		 //message("GetReportOffset incr +: ");
         //number(pParser_Data->Size);
         //message(eol);

		 //message("GetReportOffset: ");
         //number(*pPosTST);
         //message(eol);
		
         /* Remove path last node */
         pParser_Data->Path_Size--;
 
         /* Decrement count */
         pParser->Count--;
		 if (pParser->Count == 0) {
		   ResetLocalState(pParser);
		 }
         break;
       }
       case ITEM_REP_ID :
       {
         pParser_Data->ReportID=(uchar)pParser->Value;
         break;
       }
       case ITEM_REP_SIZE :
       {
         pParser_Data->Size=(uchar)pParser->Value;
         break;
       }
       case ITEM_REP_COUNT :
       {
         pParser->ReportCount=(uchar)pParser->Value;
         break;
       }
       case ITEM_UNIT_EXP :
       {
         pParser_Data->UnitExp=(char)pParser->Value;
	     // Convert 4 bits signed value to 8 bits signed value
	     if (pParser_Data->UnitExp > 7)
			 pParser_Data->UnitExp|=0xF0;
		 break;
       }
       case ITEM_UNIT :
       {
         pParser_Data->Unit=pParser->Value;
         break;
       }
       case ITEM_LOG_MIN :
       {
         pParser_Data->LogMin = FormatValue(pParser->Value, ItemSize[pParser->Item & SIZE_MASK]);
         break;
       }
       case ITEM_LOG_MAX :
       {
         pParser_Data->LogMax = FormatValue(pParser->Value, ItemSize[pParser->Item & SIZE_MASK]);
         break;
       }
       case ITEM_PHY_MIN :
       {
         pParser_Data->PhyMin = FormatValue(pParser->Value, ItemSize[pParser->Item & SIZE_MASK]);
         break;
       }
       case ITEM_PHY_MAX :
       {
         pParser_Data->PhyMax = FormatValue(pParser->Value, ItemSize[pParser->Item & SIZE_MASK]);
         break;
       }
       case ITEM_LONG :
       {
		  /* can't handle long items, but should at least skip them */
		  pParser->Pos+=(u_char)(pParser->Value & 0xff);
       }
     }
   } /* while(!Found && pParser->Pos<pParser->ReportDescSize) */
   return Found;
 }

void GetValue(const uchar* Buf, HIDData_t* pData, ReportID_t* pReportID_tbl)
 {
   //int Bit=pData->Offset+8;    /* First byte of report indicate report ID  ????? */
   ushort Bit = pData->Offset;     
   ushort Weight = 0;
   ReportID_t* pReportID_tb;
   int ID;
	//======================
   int Value;
   uchar ValueSIZE;	
   uchar Sift;	
	
   ValueSIZE = pData->Size;

   pData->Value = 0;
   pReportID_tb = pReportID_tbl;
   
   //Find current report ID
   ID = pData->ReportID;

   // ADD ReportID offset
   Bit += pReportID_tb[ID].ReportID_Offset;
 
  
   while(Weight < pData->Size)
   {
     int State=Buf[Bit>>3]&(1<<(Bit%8)); // I can shift 
     if(State)
     {
       pData->Value+=(1<<Weight); // ADD Bit
     }
     Weight++;
     Bit++;
   }
	
	Value = pData->Value;
 /*  if(pData->Value > pData->LogMax)
     pData->Value=FormatValue(pData->Value, (uchar)((pData->Size-1)/8+1));
 */
    //if (pData->Value > pData->LogMax)
    //  pData->Value |= ~pData->LogMax;
 }

void GetValueXY(const uchar* Buf, HIDData_t* pData, ReportID_t* pReportID_tbl)
 {
   //int Bit=pData->Offset+8;    /* First byte of report indicate report ID  ????? */
   int Bit = pData->Offset;     
   int Weight = 0;
   ReportID_t* pReportID_tb;
   int ID;
	//======================
   int Value;
   uchar ValueSIZE;	
   uchar Sift;
   
	
   ValueSIZE = pData->Size;

   pData->Value = 0;
   pReportID_tb = pReportID_tbl;
   
   //Find current report ID
   ID = pData->ReportID;

   // ADD ReportID offset
   Bit += pReportID_tb[ID].ReportID_Offset;
 
   while(Weight < pData->Size)
   {
     int State=Buf[Bit>>3]&(1<<(Bit%8)); // I can shift 
     if(State)
     {
       pData->Value+=(1<<Weight); // ADD Bit
     }
     Weight++;
     Bit++;
   }
    //==================================================
    // Nof Sign bit should be 8 => 0x100================
	Value = pData->Value;
	if (pData->Size > 8){
		Sift = (pData->Size - 9);
		Value >>= Sift;
	}else if (pData->Size == 8){
		Value <<= 1;
	}
	//                  Sign BIT         + 8bits
	pData->Value = (Value & 0x100) | ((pData->Value) & 0xFF) ;
	
	//if (pData->Size == 8){
		//                  Sign BIT         + 8bits
	//	pData->Value = Value & 0x100 | ((pData->Value >>= 0) & 0xFF);       // SIZE 8 bit - cm
		//pData->Value = Value & 0x100 | ((pData->Value >>= 1) & 0xFF);     // SIZE 8 bit - cm
		//pData->Value = (Value & 0x100) | ((pData->Value >>= 3) & 0xFF);   // SIZE 8 bit - cm
	//}
	//else if (pData->Size == 12){
		//                  Sign BIT         + 8bits
	//	pData->Value = (Value & 0x100) | ((pData->Value <<= 0) & 0xFF);     // SIZE 12 bit - cm
		//pData->Value = (Value & 0x100) | ((pData->Value <<= 1) & 0xFF);   // SIZE 12 bit - cm
		//pData->Value = Value & 0x100 | ((pData->Value >>= 1) & 0xFF);     // SIZE 12 bit - cm
    //}
	//else
 }

//=========================================================2015_04_
  int ReportID_DataLength(HIDParser_t* pParser, uchar ReportID)
 {
   int Offset; //= 0;
   HIDData_t FoundData;
   
   Offset = 0x0;	
   ResetParser(pParser);
   while(HIDParse(pParser, &FoundData))
   {
     if(FoundData.ReportID == ReportID)
     {
		Offset+= FoundData.Size;
	 }				

   }
   return Offset;
 }

 int ReportID_Offset(HIDParser_t* pParser, uchar ReportID)
 {
   int Offset; // = 0;
   HIDData_t FoundData;
   
   Offset = 0x0;	
   ResetParser(pParser);
   while(HIDParse(pParser, &FoundData))
   {
     if(FoundData.ReportID > ReportID)
     {
		Offset+= FoundData.Size;
	 }				

   }
   return Offset;
 }
//=========================================================2015_04_
	
 uchar FindReport_max_ID(HIDParser_t* pParser)
 {
   uchar ReportID; 
   HIDData_t FoundData;
   uchar byteCount;
 //================== DEBUG OK ===================================
 //	message("FindReport_max_ID : ");
 //	message(eol);
 //============================================================		
 //for (byteCount = 0x0; byteCount < 0x80; byteCount++)
 //{
 //	number(pParser->ReportDesc[byteCount]);
 //	if  (byteCount == 0x0F) {message(eol);}
 //	if  (byteCount == 0x1F) {message(eol);}
 //	if  (byteCount == 0x2F) {message(eol);}
 //	if  (byteCount == 0x3F) {message(eol);}
 //	if  (byteCount == 0x4F) {message(eol);}
 //	if  (byteCount == 0x5F) {message(eol);}
 //	if  (byteCount == 0x6F) {message(eol);}
 //	if  (byteCount == 0x7F) {message(eol);}
 //	}	
 //======================================================
   byteCount = 0x0;
   ReportID  = 0;
   ResetParser(pParser);
   //message("FindReport_max_ID FoundData.ReportID: ");
	
   while(HIDParse(pParser, &FoundData))
   {
	byteCount++;
     if(FoundData.ReportID > ReportID)
     {
		ReportID = FoundData.ReportID;
	 }
   }
   //number(FoundData.ReportID);
   //message(eol);
   //message("Nof HIDParse run: ");
   //number(byteCount);
   //message(eol);
   return ReportID;
 }
	
 int FindMouse_XYW(HIDParser_t* pParser, HIDData_t* pData, ushort XYW)
 {
   HIDData_t FoundData;
   ResetParser(pParser);
   while(HIDParse(pParser, &FoundData))
   {   //0x0902: USAGE - Mouse           :  0x0930-UsageX; 0x0931-UsageY; 0x0938-Wheel  
	 if(FoundData.Path_Node[0].Usage == 0x2 && FoundData.Path_Node[2].Usage == XYW)
     {
       memcpy(pData, &FoundData, sizeof(HIDData_t));
	   
	   //-------------------------------
	   //message(eol);
	   //message("FoundData Offset ");
	   //number(FoundData.Offset);
	   //message(eol);
	   //message("FoundData Size(bit) ");
	   //number(FoundData.Size);
	   //message(eol);
	   //-------------------------------
       return 1;
     }
   }
   return 0;
 }
  
 int FindMouse_Buttons(HIDParser_t* pParser, HIDData_t* pData)
 {
   HIDData_t FoundData;
   ResetParser(pParser);
   while(HIDParse(pParser, &FoundData))
   {   //0x0902: USAGE - Mouse               :       0x0901-Usage Pointer  
	 if(FoundData.Path_Node[0].Usage == 0x2 && FoundData.Path_Node[1].Usage == 0x01)
     {
       memcpy(pData, &FoundData, sizeof(HIDData_t));
	   pData->Size   = 0x3; // 3 Buttons, not just one
	   pData->PhyMax = 0x7;
	   pData->PhyMin = 0x0;
	   pData->LogMax = 0x7;
	   pData->LogMin = 0x0;
       return 1;
     }
   }
   return 0;
 }

