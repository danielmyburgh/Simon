
//+------------------------------------------------------------------+
#property copyright "Copyright , Daniel Myburgh"
#property link      "www.binaryjunkies.co.za"
#property version   "1.1"
#property description "Sets up HS level vallues."

#property indicator_chart_window
#property indicator_plots 0

//int second_column_x = 0;

// input int MaxNumberLength = 10; // How many digits will there be in numbers as maximum?
#include "SIMON_BASE.mqh"

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   Window = 0;
   IndicatorSetString(INDICATOR_SHORTNAME, "HS level indicator");
   Initialization();
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   Print("deinitialize");
   ObjectDelete(0, "Entry");
   ObjectDelete(0, "MidPointLabel");
   ObjectDelete(0, "T1");
   ObjectDelete(0, "T2");
   ObjectDelete(0, "Prossize");
   ObjectDelete(0, "Moneyrisked");
   ObjectDelete(0, "StopLossSize");
   ObjectDelete(0, "StopLossLine");
   ObjectDelete(0, "EntryLine");
   ObjectDelete(0, "MidPointLine");
   ObjectDelete(0, "EntryLevel");
   ObjectDelete(0, "T1Line");
   ObjectDelete(0, "T2Line");
   ObjectDelete(0, "T2Midpoint");
   
   
   ChartRedraw();
//   ObjectDelete(0, "Entry");
//    if (DeleteLines) ObjectDelete(0, "EntryLine");
//    ObjectDelete(0, "StopLoss");
//    if (DeleteLines) ObjectDelete(0, "StopLossLine");
//    if (CommissionPerLot > 0) ObjectDelete(0, "CommissionPerLot");
//    ObjectDelete(0, "Risk");
//    ObjectDelete(0, "AccountSize");
//    ObjectDelete(0, "Divider");
//    ObjectDelete(0, "RiskMoney");
//    ObjectDelete(0, "PositionSize");
//   	ObjectDelete(0, "StopLossLabel");
// 	ObjectDelete(0, "TakeProfitLabel");
//    if (iTakeProfitLevel > 0)
//    {
//       ObjectDelete(0, "TakeProfit");
//       if (DeleteLines) ObjectDelete(0, "TakeProfitLine");
//       ObjectDelete(0, "RR");
//       ObjectDelete(0, "PotentialProfit");
//    }
//    if (ShowPortfolioRisk)
//    {
//       ObjectDelete(0, "CurrentPortfolioMoneyRisk");
//       ObjectDelete(0, "CurrentPortfolioRisk");
//       ObjectDelete(0, "PotentialPortfolioMoneyRisk");
//       ObjectDelete(0, "PotentialPortfolioRisk");
//    }
//    if (ShowMargin)
//    {
//       ObjectDelete(0, "PositionMargin");
//       ObjectDelete(0, "FutureUsedMargin");
//       ObjectDelete(0, "FutureFreeMargin");
//    }
//    ChartRedraw();;
}