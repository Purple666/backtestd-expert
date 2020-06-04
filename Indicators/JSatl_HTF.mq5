//+------------------------------------------------------------------+ 
//|                                                    JSatl_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
#property description "JSatl ñ âîçìîæíîñòüþ èçìåíåíèÿ òàéìôðåéìà âî âõîäíûõ ïàðàìåòðàõ"
//---- îòðèñîâêà èíäèêàòîðà â îñíîâíîì îêíå
#property indicator_chart_window
//---- êîëè÷åñòâî èíäèêàòîðíûõ áóôåðîâ
#property indicator_buffers 2 
//---- èñïîëüçîâàíî âñåãî îäíî ãðàôè÷åñêîå ïîñòðîåíèå
#property indicator_plots   1
//+-------------------------------------+
//|  îáúÿâëåíèå êîíñòàíò                |
//+-------------------------------------+
#define RESET 0                                      // Êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷¸ò èíäèêàòîðà
#define INDICATOR_NAME "JSatl"                       // Êîíñòàíòà äëÿ èìåíè èíäèêàòîðà
#define SIZE 1                                       // Êîíñòàíòà äëÿ êîëè÷åñòâà âûçîâîâ ôóíêöèè CountIndicator
//+-------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà 1   |
//+-------------------------------------+
//---- â êà÷åñòâå èíäèêàòîðà èñïîëüçîâàíà ëèíèÿ
#property indicator_type1   DRAW_LINE
//---- â êà÷åñòâå öâåòà ëèíèè èíäèêàòîðà èñïîëüçîâàí ðîçîâûé öâåò
#property indicator_color1  clrDeepPink
//---- ëèíèÿ èíäèêàòîðà - ñïëîøíàÿ
#property indicator_style1  STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 4
#property indicator_width1  4
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label1  INDICATOR_NAME
//+-------------------------------------+
//|  îáúÿâëåíèå ïåðå÷èñëåíèé            |
//+-------------------------------------+
enum Applied_price_      //Òèï êîíñòàíòû
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+-------------------------------------+
//|  ÂÕÎÄÍÛÅ ÏÀÐÀÌÅÒÐÛ ÈÍÄÈÊÀÒÎÐÀ       |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Ïåðèîä ãðàôèêà èíäèêàòîðà
//+-------------------------------------+
//|  ÂÕÎÄÍÛÅ ÏÀÐÀÌÅÒÐÛ ÈÍÄÈÊÀÒÎÐÀ       |
//+-------------------------------------+  
input uint iLength=5; // ãëóáèíà JMA ñãëàæèâàíèÿ                   
input int iPhase=100; // ïàðàìåòð JMA ñãëàæèâàíèÿ,
//---- èçìåíÿþùèéñÿ â ïðåäåëàõ -100 ... +100,
//---- âëèÿåò íà êà÷åñòâî ïåðåõîäíîãî ïðîöåññà;
input Applied_price_ IPC=PRICE_CLOSE_;//öåíîâàÿ êîíñòàíòà
int PriceShift=0;                  //cäâèã èíäèêàòîðà ïî âåðòèêàëè â ïóíêòàõ 
int Shift=0;                       //ñäâèã èíäèêàòîðà ïî ãîðèçîíòàëè â áàðàõ    
//+-------------------------------------+
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
// äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double IndBuffer[];
//---- Îáúÿâëåíèå ñòðèíãîâ
string Symbol_,Word;
//---- Îáúÿâëåíèå öåëûõ ïåðåìåííûõ íà÷àëà îòñ÷¸òà äàííûõ
int min_rates_total;
//---- Îáúÿâëåíèå öåëûõ ïåðåìåííûõ äëÿ õåíäëîâ èíäèêàòîðîâ
int Ind_Handle;
//+------------------------------------------------------------------+
//|  Ïîëó÷åíèå òàéìôðåéìà â âèäå ñòðîêè                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- ïðîâåðêà ïåðèîäîâ ãðàôèêîâ íà êîððåêòíîñòü
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);

//---- Èíèöèàëèçàöèÿ ïåðåìåííûõ 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" èíäèêàòîð: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà JSatl
   Ind_Handle=iCustom(Symbol(),TimeFrame,"JSatl",iLength,iPhase,IPC,PriceShift,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà JSatl");
      return(INIT_FAILED);
     }

//---- Èíèöèàëèçàöèÿ èíäèêàòîðíîãî áóôåðîâ
   IndInit(0,IndBuffer,EMPTY_VALUE,min_rates_total,Shift);

//---- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- çàâåðøåíèå èíèöèàëèçàöèè
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // êîëè÷åñòâî èñòîðèè â áàðàõ íà òåêóùåì òèêå
                const int prev_calculated,// êîëè÷åñòâî èñòîðèè â áàðàõ íà ïðåäûäóùåì òèêå
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷¸òà
   if(rates_total<min_rates_total) return(RESET);

//---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(time,true);

//----
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//----     
   return(rates_total);
  }
//----
//+------------------------------------------------------------------+
//| Èíèöèàëèçàöèÿ èíäèêàòîðíîãî áóôåðà                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---- ïðåâðàùåíèå äèíàìè÷åñêèõ ìàññèâîâ â èíäèêàòîðíûå áóôåðû
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷¸òà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà ïî ãîðèçîíòàëè íà Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðàõ êàê â òàéìñåðèÿõ
   ArraySetAsSeries(Buffer,true);
//----
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(
                    uint     Numb,            // Íîìåð ôóíêöèè CountLine ïî ñïèñêó â êîäå èíäèêàòîðà (ñòàðòîâûé íîìåð - 0)
                    string   Symb,            // Ñèìâîë ãðàôèêà
                    ENUM_TIMEFRAMES TFrame,   // Ïåðèîä ãðàôèêà
                    int      IndHandle,       // Õåíäë îáðàáàòûâàåìîãî èíäèêàòîðà
                    uint     BuffNumb,        // Íîìåð áóôåðà îáðàáàòûâàåìîãî èíäèêàòîðà
                    double&  IndBuf[],        // Ïðè¸ìíûé áóôåð èíäèêàòîðà
                    const datetime& iTime[],  // Òàéìñåðèÿ âðåìåíè
                    const int Rates_Total,    // êîëè÷åñòâî èñòîðèè â áàðàõ íà òåêóùåì òèêå
                    const int Prev_Calculated,// êîëè÷åñòâî èñòîðèè â áàðàõ íà ïðåäûäóùåì òèêå
                    const int Min_Rates_Total // ìèíèìàëüíîå êîëè÷åñòâî èñòîðèè â áàðàõ äëÿ ðàñ÷¸òà
                    )
//---- 
  {
//----
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;

//---- ðàñ÷¸òû íåîáõîäèìîãî êîëè÷åñòâà êîïèðóåìûõ äàííûõ è
//ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷¸òà áàðîâ
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷¸òà èíäèêàòîðà
     {
      limit=Rates_Total-Min_Rates_Total-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷¸òà âñåõ áàðîâ
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷¸òà íîâûõ áàðîâ 

//---- îñíîâíîé öèêë ðàñ÷¸òà èíäèêàòîðà
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- îáíóëèì ñîäåðæèìîå èíäèêàòîðíûõ áóôåðîâ äî ðàñ÷¸òà
      IndBuf[bar]=0.0;

      //---- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâ IndTime
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];

         //---- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);

         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
     }
//----     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(
                     string IndName,
                     ENUM_TIMEFRAMES TFrame //Ïåðèîä ãðàôèêà èíäèêàòîðà
                     )
//TimeFramesCheck(INDICATOR_NAME,TimeFrame)
  {
//---- ïðîâåðêà ïåðèîäîâ ãðàôèêîâ íà êîððåêòíîñòü
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Ïåðèîä ãðàôèêà äëÿ èíäèêàòîðà "+IndName+" íå ìîæåò áûòü ìåíüøå ïåðèîäà òåêóùåãî ãðàôèêà!");
      Print("Ñëåäóåò èçìåíèòü âõîäíûå ïàðàìåòðû èíäèêàòîðà!");
      return(RESET);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
