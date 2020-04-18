//+------------------------------------------------------------------+ 
//|                                                    JSatl_HTF.mq5 | 
//|                               Copyright � 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright � 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- ����� ������ ����������
#property version   "1.00"
#property description "JSatl � ������������ ��������� ���������� �� ������� ����������"
//---- ��������� ���������� � �������� ����
#property indicator_chart_window
//---- ���������� ������������ �������
#property indicator_buffers 2 
//---- ������������ ����� ���� ����������� ����������
#property indicator_plots   1
//+-------------------------------------+
//|  ���������� ��������                |
//+-------------------------------------+
#define RESET 0                                      // ��������� ��� �������� ��������� ������� �� �������� ����������
#define INDICATOR_NAME "JSatl"                       // ��������� ��� ����� ����������
#define SIZE 1                                       // ��������� ��� ���������� ������� ������� CountIndicator
//+-------------------------------------+
//|  ��������� ��������� ���������� 1   |
//+-------------------------------------+
//---- � �������� ���������� ������������ �����
#property indicator_type1   DRAW_LINE
//---- � �������� ����� ����� ���������� ����������� ������� ����
#property indicator_color1  clrDeepPink
//---- ����� ���������� - ��������
#property indicator_style1  STYLE_SOLID
//---- ������� ����� ���������� ����� 4
#property indicator_width1  4
//---- ����������� ����� ����������
#property indicator_label1  INDICATOR_NAME
//+-------------------------------------+
//|  ���������� ������������            |
//+-------------------------------------+
enum Applied_price_      //��� ���������
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
//|  ������� ��������� ����������       |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // ������ ������� ����������
//+-------------------------------------+
//|  ������� ��������� ����������       |
//+-------------------------------------+  
input uint iLength=5; // ������� JMA �����������                   
input int iPhase=100; // �������� JMA �����������,
//---- ������������ � �������� -100 ... +100,
//---- ������ �� �������� ����������� ��������;
input Applied_price_ IPC=PRICE_CLOSE_;//������� ���������
input int PriceShift=0;                  //c���� ���������� �� ��������� � ������� 
input int Shift=0;                       //����� ���������� �� ����������� � �����    
//+-------------------------------------+
//---- ���������� ������������ ��������, ������� ����� � 
// ���������� ������������ � �������� ������������ �������
double IndBuffer[];
//---- ���������� ��������
string Symbol_,Word;
//---- ���������� ����� ���������� ������ ������� ������
int min_rates_total;
//---- ���������� ����� ���������� ��� ������� �����������
int Ind_Handle;
//+------------------------------------------------------------------+
//|  ��������� ���������� � ���� ������                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- �������� �������� �������� �� ������������
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);

//---- ������������� ���������� 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" ���������: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- ��������� ������ ���������� JSatl
   Ind_Handle=iCustom(Symbol(),TimeFrame,"JSatl",iLength,iPhase,IPC,PriceShift,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� JSatl");
      return(INIT_FAILED);
     }

//---- ������������� ������������� �������
   IndInit(0,IndBuffer,EMPTY_VALUE,min_rates_total,Shift);

//---- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- ����������� �������� ����������� �������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- ���������� �������������
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // ���������� ������� � ����� �� ������� ����
                const int prev_calculated,// ���������� ������� � ����� �� ���������� ����
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
//---- �������� ���������� ����� �� ������������� ��� �������
   if(rates_total<min_rates_total) return(RESET);

//---- ���������� ��������� � �������� ��� � ����������  
   ArraySetAsSeries(time,true);

//----
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//----     
   return(rates_total);
  }
//----
//+------------------------------------------------------------------+
//| ������������� ������������� ������                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---- ����������� ������������ �������� � ������������ ������
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- ������������� ������ ������ ������� ��������� ����������
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- ������������� ������ ���������� �� ����������� �� Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- ���������� ��������� � ������� ��� � ����������
   ArraySetAsSeries(Buffer,true);
//----
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(
                    uint     Numb,            // ����� ������� CountLine �� ������ � ���� ���������� (��������� ����� - 0)
                    string   Symb,            // ������ �������
                    ENUM_TIMEFRAMES TFrame,   // ������ �������
                    int      IndHandle,       // ����� ��������������� ����������
                    uint     BuffNumb,        // ����� ������ ��������������� ����������
                    double&  IndBuf[],        // ������� ����� ����������
                    const datetime& iTime[],  // ��������� �������
                    const int Rates_Total,    // ���������� ������� � ����� �� ������� ����
                    const int Prev_Calculated,// ���������� ������� � ����� �� ���������� ����
                    const int Min_Rates_Total // ����������� ���������� ������� � ����� ��� �������
                    )
//---- 
  {
//----
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;

//---- ������� ������������ ���������� ���������� ������ �
//���������� ������ limit ��� ����� ��������� �����
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// �������� �� ������ ����� ������� ����������
     {
      limit=Rates_Total-Min_Rates_Total-1; // ��������� ����� ��� ������� ���� �����
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // ��������� ����� ��� ������� ����� ����� 

//---- �������� ���� ������� ����������
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- ������� ���������� ������������ ������� �� �������
      IndBuf[bar]=0.0;

      //---- �������� ����� ����������� ������ � ������ IndTime
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];

         //---- �������� ����� ����������� ������ � �������
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
                     ENUM_TIMEFRAMES TFrame //������ ������� ����������
                     )
//TimeFramesCheck(INDICATOR_NAME,TimeFrame)
  {
//---- �������� �������� �������� �� ������������
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("������ ������� ��� ���������� "+IndName+" �� ����� ���� ������ ������� �������� �������!");
      Print("������� �������� ������� ��������� ����������!");
      return(RESET);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
