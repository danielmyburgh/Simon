enum ENTRY_TYPE
{
   Instant,
   Pending
};

input bool DAX = false;
input double MoneyRisk = 1000;
input double EntryLevelAdd = 10;
input int LastPriceSpread = 20;
input double Spread = 20;
input double EntryLevel = 0;
input double StopLossLevel = 0;
input double TakeProfitLevel = 0; // TakeProfitLevel (Optional)
input double Risk = 1; // Risk tolerance in percentage points

input double CommissionPerLot =  0; // Commission per lot (one side)
input bool UseMoneyInsteadOfPercentage = false;
input bool UseEquityInsteadOfBalance = false;
input bool DrawTextAsBackground = false; // DrawTextAsBackground - If true, all text label objects will be drawn as background.

input color T2_line_color = clrGray;
input color T1_line_color = clrGray;
input color midpoint_line_color = clrGray;
input color entry_font_color = clrBlue;

input int font_size = 13;
input string font_face = "Courier";
input ENUM_BASE_CORNER corner = CORNER_RIGHT_UPPER;
input int distance_x = 10;
input int distance_y = 15;
input int line_height = 15;
input color entry_line_color = clrYellow;
input color stoploss_line_color = clrLime;
input color takeprofit_line_color = clrBlue;
input color sl_font_color = clrLime;

input ENUM_LINE_STYLE entry_line_style = STYLE_SOLID;
input ENUM_LINE_STYLE stoploss_line_style = STYLE_SOLID;
input ENUM_LINE_STYLE takeprofit_line_style = STYLE_SOLID;
input int entry_line_width = 1;
input int stoploss_line_width = 1;
input int takeprofit_line_width = 1;

string SizeText;
double Size, OutputRiskMoney;
double OutputPositionSize;
double StopLoss;

// Will be used instead of input parameters as they cannot be modified during runtime.
double iEntryLevel, iStopLossLevel, iTakeProfitLevel,iMidPointLevel,iT1Level,iT2Level;
// Will be used in two or more functions.
double tEntryLine, tStopLossLevel, tTakeProfitLevel,tStopLossSize;
// -1 because it is checked in the initialization function.
double TickSize = -1, ContractSize, AccStopoutLevel, TickValue, InitialMargin = 0, MaintenanceMargin = 0, MinLot, MaxLot, LotStep;
string AccountCurrency, MarginCurrency, ProfitCurrency;
long AccStopoutMode;
int LotStep_digits;
double BID,ASK;
ENUM_SYMBOL_CALC_MODE MarginMode;

int Window = -1;


int MaxNumberLength = 10;
int second_column_x = 0;
double PosSize;

//+------------------------------------------------------------------------------+
//| Will be called from OnCalculate() or Timer() after Window number is detected.|
//+------------------------------------------------------------------------------+
void Initialization()
{
  IndicatorSetString(INDICATOR_SHORTNAME, "Position Size Calculator");
      
   //Print("Launched the HS A2J Test "); 
   
   ObjectCreate(0, "Entry", OBJ_LABEL, Window, 0, 0);
   ObjectSetInteger(0, "Entry", OBJPROP_CORNER, corner);
   ObjectSetInteger(0,"Entry",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, "Entry", OBJPROP_XDISTANCE, distance_x);
   ObjectSetInteger(0, "Entry", OBJPROP_YDISTANCE, distance_y);
   ObjectSetString(0, "Entry", OBJPROP_TEXT, "Entry Lvl:    " + JustifyRight(DoubleToString(iEntryLevel, _Digits), MaxNumberLength));
   ObjectSetInteger(0, "Entry", OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, "Entry", OBJPROP_FONT, font_face);
   ObjectSetInteger(0, "Entry", OBJPROP_COLOR, entry_line_color);
   ObjectSetInteger(0, "Entry", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetInteger(0, "Entry", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Entry", OBJPROP_HIDDEN, false);
   int y_shift = line_height ;
   
   ObjectCreate(0, "MidPointLabel", OBJ_LABEL, Window, 0, 0);
   ObjectSetInteger(0, "MidPointLabel", OBJPROP_CORNER, corner);
   ObjectSetInteger(0,"MidPointLabel",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, "MidPointLabel", OBJPROP_XDISTANCE, distance_x);
   ObjectSetInteger(0, "MidPointLabel", OBJPROP_YDISTANCE, distance_y + y_shift);
   ObjectSetString(0, "MidPointLabel", OBJPROP_TEXT, "MidPoint:     " + JustifyRight(DoubleToString(iMidPointLevel, _Digits), MaxNumberLength));
   ObjectSetInteger(0, "MidPointLabel", OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, "MidPointLabel", OBJPROP_FONT, font_face);
   ObjectSetInteger(0, "MidPointLabel", OBJPROP_COLOR, sl_font_color);
   ObjectSetInteger(0, "MidPointLabel", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetInteger(0, "MidPointLabel", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "MidPointLabel", OBJPROP_HIDDEN, false);
   y_shift += line_height;
    
   ObjectCreate(0, "T1", OBJ_LABEL, Window, 0, 0);
   ObjectSetInteger(0, "T1", OBJPROP_CORNER, corner);
   ObjectSetInteger(0,"T1",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, "T1", OBJPROP_XDISTANCE, distance_x);
   ObjectSetInteger(0, "T1", OBJPROP_YDISTANCE, distance_y + y_shift);
   ObjectSetString(0, "T1", OBJPROP_TEXT, "T1:           " + JustifyRight(DoubleToString(iT1Level, _Digits), MaxNumberLength));
   ObjectSetInteger(0, "T1", OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, "T1", OBJPROP_FONT, font_face);
   ObjectSetInteger(0, "T1", OBJPROP_COLOR, takeprofit_line_color);
   ObjectSetInteger(0, "T1", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetInteger(0, "T1", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "T1", OBJPROP_HIDDEN, false);
   y_shift += line_height;
   ObjectCreate(0, "T2", OBJ_LABEL, Window, 0, 0);
   ObjectSetInteger(0, "T2", OBJPROP_CORNER, corner);
   ObjectSetInteger(0,"T2",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, "T2", OBJPROP_XDISTANCE, distance_x);
   ObjectSetInteger(0, "T2", OBJPROP_YDISTANCE, distance_y + y_shift);
   ObjectSetString(0, "T2", OBJPROP_TEXT, "T2:           " + JustifyRight(DoubleToString(iT2Level, _Digits), MaxNumberLength));
   ObjectSetInteger(0, "T2", OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, "T2", OBJPROP_FONT, font_face);
   ObjectSetInteger(0, "T2", OBJPROP_COLOR, takeprofit_line_color);
   ObjectSetInteger(0, "T2", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetInteger(0, "T2", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "T2", OBJPROP_HIDDEN, false);
   y_shift += line_height;
   
   ObjectCreate(0, "Prossize", OBJ_LABEL, Window, 0, 0);
   ObjectSetInteger(0, "Prossize", OBJPROP_CORNER, corner);
   ObjectSetInteger(0,"Prossize",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, "Prossize", OBJPROP_XDISTANCE, distance_x);
   ObjectSetInteger(0, "Prossize", OBJPROP_YDISTANCE, distance_y + y_shift);
   ObjectSetString(0, "Prossize", OBJPROP_TEXT, "Pos size:   " + JustifyRight(DoubleToString(PosSize, _Digits), MaxNumberLength));
   ObjectSetInteger(0, "Prossize", OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, "Prossize", OBJPROP_FONT, font_face);
   ObjectSetInteger(0, "Prossize", OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, "Prossize", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetInteger(0, "Prossize", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Prossize", OBJPROP_HIDDEN, false);
   y_shift += line_height;
   
   ObjectCreate(0, "Moneyrisked", OBJ_LABEL, Window, 0, 0);
   ObjectSetInteger(0, "Moneyrisked", OBJPROP_CORNER, corner);
   ObjectSetInteger(0,"Moneyrisked",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, "Moneyrisked", OBJPROP_XDISTANCE, distance_x);
   ObjectSetInteger(0, "Moneyrisked", OBJPROP_YDISTANCE, distance_y + y_shift);
   ObjectSetString(0, "Moneyrisked", OBJPROP_TEXT, "Money At Risk:" + JustifyRight(DoubleToString(MoneyRisk, _Digits), MaxNumberLength));
   ObjectSetInteger(0, "Moneyrisked", OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, "Moneyrisked", OBJPROP_FONT, font_face);
   ObjectSetInteger(0, "Moneyrisked", OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, "Moneyrisked", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetInteger(0, "Moneyrisked", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Moneyrisked", OBJPROP_HIDDEN, false);
   y_shift += line_height;
   
   ObjectCreate(0, "StopLossSize", OBJ_LABEL, Window, 0, 0);
   ObjectSetInteger(0, "StopLossSize", OBJPROP_CORNER, corner);
   ObjectSetInteger(0,"StopLossSize",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, "StopLossSize", OBJPROP_XDISTANCE, distance_x);
   ObjectSetInteger(0, "StopLossSize", OBJPROP_YDISTANCE, distance_y + y_shift);
   ObjectSetString(0, "StopLossSize", OBJPROP_TEXT, "Stoploss size:" + JustifyRight(DoubleToString(tStopLossSize, _Digits), MaxNumberLength));
   ObjectSetInteger(0, "StopLossSize", OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, "StopLossSize", OBJPROP_FONT, font_face);
   ObjectSetInteger(0, "StopLossSize", OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, "StopLossSize", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetInteger(0, "StopLossSize", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "StopLossSize", OBJPROP_HIDDEN, false);
   y_shift += line_height;
   
  
   BID =SymbolInfoDouble(Symbol(),SYMBOL_BID); 
   ObjectCreate(0, "StopLossLine", OBJ_HLINE, 0, TimeCurrent(), BID);
   ObjectSetInteger(0, "StopLossLine", OBJPROP_STYLE,STYLE_DASH);
   ObjectSetInteger(0, "StopLossLine", OBJPROP_COLOR, stoploss_line_color);
   ObjectSetInteger(0, "StopLossLine", OBJPROP_WIDTH, stoploss_line_width);
   ObjectSetInteger(0, "StopLossLine", OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, "StopLossLine", OBJPROP_HIDDEN, false);
   
   ASK = SymbolInfoDouble(Symbol(),SYMBOL_ASK); 
   ObjectCreate(0, "EntryLine", OBJ_HLINE, 0, TimeCurrent(), ASK);
   ObjectSetInteger(0, "EntryLine", OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, "EntryLine", OBJPROP_COLOR, entry_line_color);
   ObjectSetInteger(0, "EntryLine", OBJPROP_WIDTH, entry_line_width);
   ObjectSetInteger(0, "EntryLine", OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, "EntryLine", OBJPROP_HIDDEN, false);
   
   ChartRedraw();      
      
}

//+--------------------------------------------------------------------------+
//| Called every second to initialize the indicator if start fails to do so. |
//+--------------------------------------------------------------------------+
void OnTimer()
{
   if (Window == -1)
   {
      Window = ChartWindowFind();
      Initialization();
   }
   EventKillTimer();
  RecalculatePositionSize();
  Print("Ontimer");
  ChartRedraw();
}

//+------------------------------------------------------------------+
//| Main recalculation function used on every tick and on entry/SL   |
//| line drag.                                                       |
//+------------------------------------------------------------------+
void RecalculatePositionSize()
{
   
   double tMidPoint;
   double tEntryPoint,tEntryLevel;
   double T1target;
   double T2target;
   double T2midpoint;
   double T2Midpoint;
   double X1,X2;
   double tSlrange; 
   double tMidPointRange;
   double testval;
   
   tEntryLine = Round(ObjectGetDouble(0, "EntryLine", OBJPROP_PRICE), Digits());
   tStopLossLevel = Round(ObjectGetDouble(0, "StopLossLine", OBJPROP_PRICE), Digits());
   
   
      if (tEntryLine > tStopLossLevel)  
   {
      tEntryLevel = tEntryLine +  EntryLevelAdd + LastPriceSpread; //add the buffer to the entry point
      tSlrange = tEntryLine + EntryLevelAdd -  tStopLossLevel;
      tMidPointRange = (tEntryLine-tStopLossLevel)/2; //remove entry buffer to calcl true midpoint.      
      tMidPoint = tEntryLine  - tMidPointRange;//remove entry buffer to calcl true midpoint.
      PosSize = MoneyRisk /(tMidPointRange+EntryLevelAdd);      
      T1target = tEntryLine + tSlrange + Spread + EntryLevelAdd;
      T2Midpoint = T1target + (tSlrange/2);
      T2target = T1target +  tSlrange;      
      ObjectSetString(0, "Entry", OBJPROP_TEXT, "Entry Level:  " + JustifyRight(DoubleToString(tEntryLevel, _Digits), MaxNumberLength));
      ObjectSetString(0, "MidPointLabel", OBJPROP_TEXT, "MidPoint:     " + JustifyRight(DoubleToString(tMidPoint, _Digits), MaxNumberLength));
      ObjectSetString(0, "T1", OBJPROP_TEXT, "T1:           " + JustifyRight(DoubleToString(T1target, _Digits), MaxNumberLength));
      ObjectSetString(0, "T2", OBJPROP_TEXT, "T2:           " + JustifyRight(DoubleToString(T2target, _Digits), MaxNumberLength));  
      ObjectSetString(0, "T2", OBJPROP_TEXT, "T2:           " + JustifyRight(DoubleToString(T2target, _Digits), MaxNumberLength)); 
      ObjectSetString(0, "Prossize", OBJPROP_TEXT, "Pos size:" + JustifyRight(DoubleToString(PosSize, _Digits), MaxNumberLength));   
      ObjectSetString(0, "StopLossSize", OBJPROP_TEXT, "SL size:" + JustifyRight(DoubleToString(tSlrange, _Digits), MaxNumberLength)); 
      //ObjectSetString(0,"StopLossLabel",OBJPROP_TEXT,tSlrange ,MaxNumberLength);
      if ((ObjectFind(0, "MidPointLine") > -1) )
      {         
         ObjectMove(0,"MidPointLine",0,TimeCurrent(),tMidPoint);
         ObjectMove(0,"EntryLevel",0,TimeCurrent(),tEntryLevel);
         ObjectMove(0,"T1Line",0,TimeCurrent(),T1target); 
         ObjectMove(0,"T2Midpoint",0,TimeCurrent(),T2Midpoint);   
         ObjectMove(0,"T2Line",0,TimeCurrent(),T2target);
      }else{ 
         ObjectCreate(0, "MidPointLine", OBJ_HLINE, 0, TimeCurrent(), tMidPoint);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_COLOR, midpoint_line_color);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_HIDDEN, false);  
         
         ObjectCreate(0, "EntryLevel", OBJ_HLINE, 0, TimeCurrent(), tEntryLevel);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_COLOR, midpoint_line_color);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_HIDDEN, false);    
           
         ObjectCreate(0, "T1Line", OBJ_HLINE, 0, TimeCurrent(), T1target);
         ObjectSetInteger(0, "T1Line", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "T1Line", OBJPROP_COLOR, T1_line_color);
         ObjectSetInteger(0, "T1Line", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "T1Line", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "T1Line", OBJPROP_HIDDEN, false);   
         
         ObjectCreate(0, "T2Midpoint", OBJ_HLINE, 0, TimeCurrent(), T2Midpoint);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_COLOR, midpoint_line_color);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_HIDDEN, false);    
           
         ObjectCreate(0, "T2Line", OBJ_HLINE, 0, TimeCurrent(), T2target);
         ObjectSetInteger(0, "T2Line", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "T2Line", OBJPROP_COLOR, T2_line_color);
         ObjectSetInteger(0, "T2Line", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "T2Line", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "T2Line", OBJPROP_HIDDEN, false);      
      }   
   }else {   
      if (DAX) {
         tEntryLevel = tEntryLine -  EntryLevelAdd - LastPriceSpread; //add the buffer to the entry point
      }else{
         tEntryLevel = tEntryLine -  EntryLevelAdd; //add the buffer to the entry point
      }
      
      Print("tEntryLevel",tEntryLevel);
      
      tSlrange =   tStopLossLevel - (tEntryLine - EntryLevelAdd) ;
      Print("tSlange",tSlrange);
      tMidPointRange = (tStopLossLevel - tEntryLine)/2; //remove entry buffer to calcl true midpoint.      
      tMidPoint = tEntryLine  + tMidPointRange;//remove entry buffer to calcl true midpoint.
      PosSize = MoneyRisk /(tMidPointRange+EntryLevelAdd);
      
      Print("size",PosSize);
       
      T1target = tEntryLevel - tSlrange - Spread;
      T2Midpoint = T1target - (tSlrange/2);
      Print("T1",T1target);
      T2target = T1target -  tSlrange;
      Print("T2", T2target);
      ObjectSetString(0, "Entry", OBJPROP_TEXT, "Entry Level:  " + JustifyRight(DoubleToString(tEntryLevel, _Digits), MaxNumberLength));
      ObjectSetString(0, "MidPointLabel", OBJPROP_TEXT, "MidPoint:     " + JustifyRight(DoubleToString(tMidPoint, _Digits), MaxNumberLength));
      ObjectSetString(0, "T1", OBJPROP_TEXT, "T1:           " + JustifyRight(DoubleToString(T1target, _Digits), MaxNumberLength));
      ObjectSetString(0, "T2", OBJPROP_TEXT, "T2:           " + JustifyRight(DoubleToString(T2target, _Digits), MaxNumberLength));
      ObjectSetString(0, "Prossize", OBJPROP_TEXT, "Pos size:" + JustifyRight(DoubleToString(PosSize, _Digits), MaxNumberLength)); 
      ObjectSetString(0, "StopLossSize", OBJPROP_TEXT, "SL size:" + JustifyRight(DoubleToString(tSlrange, _Digits), MaxNumberLength)); 
      
      if ((ObjectFind(0, "MidPointLine") > -1) )
      {         
         ObjectMove(0,"MidPointLine",0,TimeCurrent(),tMidPoint);
         ObjectMove(0,"EntryLevel",0,TimeCurrent(),tEntryLevel);
         ObjectMove(0,"T1Line",0,TimeCurrent(),T1target);    
         ObjectMove(0,"T2Midpoint",0,TimeCurrent(),T2Midpoint); 
         ObjectMove(0,"T2Line",0,TimeCurrent(),T2target);
      }else{
      
         ObjectCreate(0, "MidPointLine", OBJ_HLINE, 0, TimeCurrent(), tMidPoint);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_COLOR, midpoint_line_color);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "MidPointLine", OBJPROP_HIDDEN, false); 
          
         ObjectCreate(0, "EntryLevel", OBJ_HLINE, 0, TimeCurrent(), tEntryLevel);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_COLOR, midpoint_line_color);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "EntryLevel", OBJPROP_HIDDEN, false);     
          
         ObjectCreate(0, "T1Line", OBJ_HLINE, 0, TimeCurrent(), T1target);
         ObjectSetInteger(0, "T1Line", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "T1Line", OBJPROP_COLOR, T1_line_color);
         ObjectSetInteger(0, "T1Line", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "T1Line", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "T1Line", OBJPROP_HIDDEN, false);     
         
         ObjectCreate(0, "T2Midpoint", OBJ_HLINE, 0, TimeCurrent(), T2Midpoint);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_COLOR, midpoint_line_color);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "T2Midpoint", OBJPROP_HIDDEN, false);    
             
         ObjectCreate(0, "T2Line", OBJ_HLINE, 0, TimeCurrent(), T2target);
         ObjectSetInteger(0, "T2Line", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, "T2Line", OBJPROP_COLOR, T2_line_color);
         ObjectSetInteger(0, "T2Line", OBJPROP_WIDTH, entry_line_width);
         ObjectSetInteger(0, "T2Line", OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, "T2Line", OBJPROP_HIDDEN, false);      
      }       
   }
}


//+------------------------------------------------------------------+
//| Object dragging handler                                          |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
)
{
   // Recalculate on chart changes, clicks, and certain object dragging.  StopLossLine
   if ((id == CHARTEVENT_OBJECT_DRAG) && ((sparam == "EntryLine") || (sparam == "StopLossLine") ))
   {
   Print("chart event");
   	RecalculatePositionSize();   
   	ChartRedraw();
   }
}

int OnCalculate(const int rates_total,      // size of the price[] array
                 const int prev_calculated,  // bars handled on a previous call
                 const int begin,            // where the significant data start from
                 const double& price[]       // array to calculate
)
{
  // RecalculatePositionSize();
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Round down a double value to a given decimal place.              |
//+------------------------------------------------------------------+
double RoundDown(const double value, const double digits)
{
   int norm = (int)MathPow(10, digits);
   return(MathFloor(value * norm) / norm);
}

//+------------------------------------------------------------------+
//| Round a double value to a given decimal place.                   |
//+------------------------------------------------------------------+
double Round(const double value, const double digits)
{
   int norm = (int)MathPow(10, digits);
   return(MathRound(value * norm) / norm);
}

//+------------------------------------------------------------------+
//| Justify a string to the right adding enough spaces to the left.  |
//| length - target length of the resulting string.                  |
//+------------------------------------------------------------------+
string JustifyRight(string str, const int length = 14)
{
   int difference = length - StringLen(str);
   if (difference < 0) return("Error: String is longer than target length.");
   
   for (int i = 0; i < difference; i++) str = " " + str;
   
   return(str);
}

//+------------------------------------------------------------------+
//| Formats double with thousands separator.                         |
//+------------------------------------------------------------------+
string FormatDouble(const string number)
{
   // Find "." position.
   int pos = StringFind(number, ".");
   string integer = StringSubstr(number, 0, pos);
   string decimal = StringSubstr(number, pos, 3);
   string formatted = "";
   string comma = "";
   
   while (StringLen(integer) > 3)
   {
      int length = StringLen(integer);
      string group = StringSubstr(integer, length - 3);
      formatted = group + comma + formatted;
      comma = ",";
      integer = StringSubstr(integer, 0, length - 3);
   }
   if (integer == "-") comma = "";
   if (integer != "") formatted = integer + comma + formatted;
   
   return(formatted + decimal);
}

//+------------------------------------------------------------------+
//| Counts decimal places.                                           |
//+------------------------------------------------------------------+
int CountDecimalPlaces(double number)
{
   // 100 as maximum length of number.
   for (int i = 0; i < 100; i++)
   {
      if (MathAbs(MathRound(number) - number) <= FLT_EPSILON) return(i);
      number *= 10;
   }
   return(-1);
}

