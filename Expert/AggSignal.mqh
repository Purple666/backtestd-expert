//+------------------------------------------------------------------+
//|                                                 ExpertSignal.mqh |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <ExpertBase.mqh>
#include "Assert.mqh"

//+------------------------------------------------------------------+
//| Macro definitions.                                               |
//+------------------------------------------------------------------+
//--- check if a market model is used
#define IS_PATTERN_USAGE(p)          ((m_patterns_usage&(((int)1)<<p))!=0)
//+------------------------------------------------------------------+
//| Class CAggSignal.                                             |
//| Purpose: Base class trading signals.                             |
//| Derives from class CExpertBase.                                  |
//+------------------------------------------------------------------+
class CAggSignal : public CExpertBase
  {
protected:
   //--- variables
   double            m_base_price;     // base price for detection of level of entering (and/or exit?)
   //--- variables for working with additional filters
   CArrayObj         m_filters;        // array of all filters


   CAggSignal *m_confirm;
   CAggSignal *m_confirm2;
   // CAggSignal *m_confirm3;
   CAggSignal *m_continue;
   CAggSignal *m_exit;
   CAggSignal *m_volume;
   CAggSignal *m_baseline;  // TODO write a CExpertBaselineSignal class
   CiATR          m_atr;

   CArrayObj         m_entry_filters;  // array of filters that are checked for an open/close signal
   CArrayObj         m_side_filters;   // array of filters that are checked for a state
   CArrayObj         m_exit_filters;   // array of filters that are checked for exit 
   //--- Adjusted parameters
   double            m_weight;         // "weight" of a signal in a combined filter
   int               m_patterns_usage; // bit mask of  using of the market models of signals
   int               m_general;        // index of the "main" signal (-1 - no)
   long              m_ignore;         // bit mask of "ignoring" the additional filter
   long              m_invert;         // bit mask of "inverting" the additional filter
   int               m_threshold_open; // threshold value for opening
   int               m_threshold_close;// threshold level for closing
   double            m_price_level;    // level of placing a pending orders relatively to the base price
   double            m_stop_level;     // level of placing of the "stop loss" order relatively to the open price
   double            m_take_level;     // level of placing of the "take profit" order relatively to the open price
   int               m_expiration;     // time of expiration of a pending order in bars
   double            m_direction;      // weighted direction
   double            m_side;           // the general side of the indicators
   double            m_exit_direction; // 

public:
                     CAggSignal(void);
                    ~CAggSignal(void);
   //--- methods of access to protected data
   void              BasePrice(double value) { m_base_price=value;      }
   int               UsedSeries(void);
   //--- methods of setting adjustable parameters
   void              Weight(double value)      { m_weight=value;          }
   void              PatternsUsage(int value)  { m_patterns_usage=value;  }
   void              General(int value)        { m_general=value;         }
   void              Ignore(long value)        { m_ignore=value;          }
   void              Invert(long value)        { m_invert=value;          }
   void              ThresholdOpen(int value)  { m_threshold_open=value;  }
   void              ThresholdClose(int value) { m_threshold_close=value; }
   void              PriceLevel(double value)  { m_price_level=value;     }
   void              StopLevel(double value)   { m_stop_level=value;      }
   void              TakeLevel(double value)   { m_take_level=value;      }
   void              Expiration(int value)     { m_expiration=value;      }
   //--- method of initialization of the object
   void              Magic(ulong value);
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods for working with additional filters
   // TODO private
   bool      AddFilter(CAggSignal *filter); // { return AddEntryFilter(filter); }
   // virtual bool      AddEntryFilter(CAggSignal *filter);
   // virtual bool      AddSideFilter(CAggSignal *filter);
   // virtual bool      AddExitFilter(CAggSignal *filter);
   bool AddConfirmSignal(CAggSignal *filter);
   bool AddConfirm2Signal(CAggSignal *filter);
   bool AddBaselineSignal(CAggSignal *filter);
   bool AddExitSignal(CAggSignal *filter);
   bool AddVolumeSignal(CAggSignal *filter);
   bool AddAtr(uint atr_period = 14);
   //--- methods for generating signals of entering the market
   virtual bool      CheckOpenLong(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      CheckOpenShort(double &price,double &sl,double &tp,datetime &expiration);
   //--- methods for detection of levels of entering the market
   virtual bool      OpenLongParams(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      OpenShortParams(double &price,double &sl,double &tp,datetime &expiration);
   //--- methods for generating signals of exit from the market
   virtual bool      CheckCloseLong(double &price);
   virtual bool      CheckCloseShort(double &price);
   //--- methods for detection of levels of exit from the market
   virtual bool      CloseLongParams(double &price);
   virtual bool      CloseShortParams(double &price);
   //--- methods for generating signals of reversal of positions
   virtual bool      CheckReverseLong(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      CheckReverseShort(double &price,double &sl,double &tp,datetime &expiration);
   //--- methods for generating signals of modification of pending orders
   virtual bool      CheckTrailingOrderLong(COrderInfo *order,double &price)  { return(false); }
   virtual bool      CheckTrailingOrderShort(COrderInfo *order,double &price) { return(false); }
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void)                                      { return(0);     }
   virtual int       ShortCondition(void)                                     { return(0);     }
   virtual double    Direction(void);
   void              SetDirection(void) { m_direction=Direction(); }
   
   virtual double    GetData(const int buffer_num)                            { return(0.0); }
   double            GetAtrValue() { return m_atr.Main(m_every_tick ? 0 : 1); }

   
   bool ConfirmSignalLong()     { return m_confirm && m_confirm.LongSignal();  }
   bool ConfirmSideLong()       { return !m_confirm  || m_confirm.LongSide();    }
   bool Confirm2SideLong()      { return !m_confirm2 || m_confirm2.LongSide();   }
   bool ContSignalLong()        { return m_continue && m_continue.LongSignal(); }
   bool ExitSignalLong()        { return m_exit && m_exit.LongSignal();     }
   bool BaselineSignalLong()    { return m_baseline && m_baseline.LongSignal(); }
   bool BaselineSideLong()      { return !m_baseline || m_baseline.LongSide();   }
   bool BaselineATRChannelLong() //{ return !m_baseline || m_baseline.LongSide();   }
   {
       if (!m_baseline)  // not baseline signal set, we are always true to allow backtesting without the baseline
         return true;
       if (!m_baseline.LongSide())
         return false;
       
       double atr_value = GetAtrValue();
       double price=(m_base_price==0.0) ? m_symbol.Ask() : m_base_price;
       double base = m_baseline.GetData(0);
       assert(base != EMPTY_VALUE, "baseline empty value");
       //Print(__FUNCTION__," atr: ", atr_value, " diff: ", (price - base), " price: ", price);
       return (price - base) <= atr_value;
    }


   bool ConfirmSignalShort()     { return m_confirm && m_confirm.ShortSignal();  }
   bool ConfirmSideShort()       { return !m_confirm || m_confirm.ShortSide();    }
   bool Confirm2SideShort()      { return !m_confirm2 || m_confirm2.ShortSide();   }
   bool ContSignalShort()        { return m_continue && m_continue.ShortSignal(); }
   bool ExitSignalShort()        { return m_exit && m_exit.ShortSignal();     }
   bool BaselineSignalShort()    { return m_baseline && m_baseline.ShortSignal(); }
   bool BaselineSideShort()      { return !m_baseline || m_baseline.ShortSide();   }
   bool BaselineATRChannelShort()//{ return !m_baseline ||m_baseline.ShortSide();   }
    {
       if (!m_baseline)  // not baseline signal set, we are always true to allow backtesting without the baseline
         return true;
       if (!m_baseline.ShortSide())
         return false;
         
       double atr_value = GetAtrValue();
       double price=(m_base_price==0.0) ? m_symbol.Ask() : m_base_price;
       double base = m_baseline.GetData(0);
       //Print(__FUNCTION__," atr: ", atr_value, " diff: ", (base - price), " price: ", price);
       return (base - price) <= atr_value;
    }

   CAggSignal *ConfirmSignal()  { return m_confirm; }
   CAggSignal *Confirm2Signal() { return m_confirm2; }
   CAggSignal *ExitSignal()     { return m_exit; }
   CAggSignal *BaselineSignal() { return m_baseline; }
   CAggSignal *VolumeSignal()   { return m_volume; }

   bool Volume() { return !m_volume || m_volume.LongSide(); }
   virtual bool LongSide(void)   ;//{ return m_filters.Total() }
   virtual bool ShortSide(void)  ;//{ return Side()      < 0 ? true : false; } 
   virtual bool LongSignal(void) { return Direction() > 0 ? true : false; }
   virtual bool ShortSignal(void){ return Direction() < 0 ? true : false; }

   // if Side() is not defined, use the direction and scale it up to 100
   virtual int  Side(void) { return(Direction()>0) ? 100 : -100; }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAggSignal::CAggSignal(void) : m_base_price(0.0),
                                     m_general(-1),// no "main" signal
                                     m_weight(1.0),
                                     m_patterns_usage(-1),   // all models are used
                                     m_ignore(0),            // all additional filters are used
                                     m_invert(0),
                                     m_threshold_open(50),
                                     m_threshold_close(100),
                                     m_price_level(0.0),
                                     m_stop_level(0.0),
                                     m_take_level(0.0),
                                     m_expiration(0),
                                     m_direction(EMPTY_VALUE)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAggSignal::~CAggSignal(void)
  {
  }
//+------------------------------------------------------------------+
//| Get flags of used timeseries                                     |
//+------------------------------------------------------------------+
int CAggSignal::UsedSeries(void)
  {
   if(m_other_symbol || m_other_period)
      return(0);
//--- check of the flags of using timeseries in the additional filters
   int total=m_filters.Total();
//--- loop by the additional filters
   for(int i=0;i<total;i++)
     {
      CAggSignal *filter=m_filters.At(i);
      //--- check pointer
      if(filter==NULL)
         return(false);
      m_used_series|=filter.UsedSeries();
     }
   return(m_used_series);
  }
//+------------------------------------------------------------------+
//| Sets magic number for object and its dependent objects           |
//+------------------------------------------------------------------+
void CAggSignal::Magic(ulong value)
  {
   int total=m_filters.Total();
//--- loop by the additional filters
   for(int i=0;i<total;i++)
     {
      CAggSignal *filter=m_filters.At(i);
      //--- check pointer
      if(filter==NULL)
         continue;
      filter.Magic(value);
     }
//---
   CExpertBase::Magic(value);
  }
//+------------------------------------------------------------------+
//| Validation settings protected data                               |
//+------------------------------------------------------------------+
bool CAggSignal::ValidationSettings(void)
  {
   if(!CExpertBase::ValidationSettings())
      return(false);
//--- check of parameters in the additional filters
   int total=m_filters.Total();
//--- loop by the additional filters
   for(int i=0;i<total;i++)
     {
      CAggSignal *filter=m_filters.At(i);
      //--- check pointer
      if(filter==NULL)
         return(false);
      if(!filter.ValidationSettings())
         return(false);
     }

//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators                                                |
//+------------------------------------------------------------------+
bool CAggSignal::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//---
   CAggSignal *filter;
   int            total=m_filters.Total();
//--- gather information about using of timeseries
   for(int i=0;i<total;i++)
     {
      filter=m_filters.At(i);
      m_used_series|=filter.UsedSeries();
     }
//--- create required timeseries
   if(!CExpertBase::InitIndicators(indicators))
      return(false);
//--- initialization of indicators and timeseries in the additional filters
   for(int i=0;i<total;i++)
     {
      filter=m_filters.At(i);
      filter.SetPriceSeries(m_open,m_high,m_low,m_close);
      filter.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
      if(!filter.InitIndicators(indicators))
         return(false);
     }

   // TODO init m_atr
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Setting an additional filter                                     |
//+------------------------------------------------------------------+
bool CAggSignal::AddFilter(CAggSignal *filter)
  {
//--- check pointer
   if(filter==NULL)
      return(false);

   bool already_added=false;
   for(int i=0;i<m_filters.Total();i++)
     {
      if(filter==m_filters.At(i))
        {
         already_added=true;
         break;
        }
     }
   if(!already_added)
     {
//--- add the filter to the array of filters
      if(!m_filters.Add(filter))
         return(false);
      //--- primary initialization of the filter - only on first add
      if(!filter.Init(m_symbol,m_period,m_adjusted_point))
         return(false);
      filter.EveryTick(m_every_tick);
      filter.Magic(m_magic);
     }
//--- succeed
   return(true);
  }

bool CAggSignal::AddAtr(uint atr_period) {
   if(!m_atr.Create(m_symbol.Name(),m_period,atr_period))
      return false;
   
//--- ok
   return true;
}

bool CAggSignal::AddConfirmSignal(CAggSignal *filter){
  if (!AddFilter(filter))
    return false;
  m_confirm = filter;
  return true;
}

bool CAggSignal::AddConfirm2Signal(CAggSignal *filter){
  if (!AddFilter(filter))
    return false;
  m_confirm2 = filter;
  return true;
}

bool CAggSignal::AddBaselineSignal(CAggSignal *filter){
  if (!AddFilter(filter))
    return false;
  m_baseline = filter;
  return true;
}

bool CAggSignal::AddExitSignal(CAggSignal *filter){
  if (!AddFilter(filter))
    return false;
  m_exit = filter;
  return true;
}

bool CAggSignal::AddVolumeSignal(CAggSignal *filter){
  if (!AddFilter(filter))
    return false;
  m_volume = filter;
  return true;
}

//+------------------------------------------------------------------+
//| Generating a buy signal                                          |
//+------------------------------------------------------------------+
bool CAggSignal::CheckOpenLong(double &price,double &sl,double &tp,datetime &expiration)
  {
   bool   result=false;
//--- the "prohibition" signal
   if(m_direction==EMPTY_VALUE)
      return(false);
//--- check of exceeding the threshold value
   if(m_direction>=m_threshold_open)
     {
      printf(__FUNCTION__+": Direction: "+m_direction+" >= "+m_threshold_open);
      //--- there's a signal
      result=true;
      //--- try to get the levels of opening
      if(!OpenLongParams(price,sl,tp,expiration))
         result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Generating a sell signal                                         |
//+------------------------------------------------------------------+
bool CAggSignal::CheckOpenShort(double &price,double &sl,double &tp,datetime &expiration)
  {
   bool   result=false;
//--- the "prohibition" signal
   if(m_direction==EMPTY_VALUE)
      return(false);
//--- check of exceeding the threshold value
   if(-m_direction>=m_threshold_open)
     {
      printf(__FUNCTION__+": Direction: "+m_direction+" > "+m_threshold_open);
      //--- there's a signal
      result=true;
      //--- try to get the levels of opening
      if(!OpenShortParams(price,sl,tp,expiration))
         result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Detecting the levels for buying                                  |
//+------------------------------------------------------------------+
bool CAggSignal::OpenLongParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   CAggSignal *general=(m_general!=-1) ? m_filters.At(m_general) : NULL;
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      double base_price=(m_base_price==0.0) ? m_symbol.Ask() : m_base_price;
      double unit= PriceLevelUnit();
      price      =m_symbol.NormalizePrice(base_price-m_price_level*PriceLevelUnit());
      sl         =(m_stop_level==0.0) ? 0.0 : m_symbol.NormalizePrice(price-m_stop_level*PriceLevelUnit());
      tp         =(m_take_level==0.0) ? 0.0 : m_symbol.NormalizePrice(price+m_take_level*PriceLevelUnit());
      expiration+=m_expiration*PeriodSeconds(m_period);
      return(true);
     }
//---
   return(general.OpenLongParams(price,sl,tp,expiration));
  }
//+------------------------------------------------------------------+
//| Detecting the levels for selling                                 |
//+------------------------------------------------------------------+
bool CAggSignal::OpenShortParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   CAggSignal *general=(m_general!=-1) ? m_filters.At(m_general) : NULL;
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      double base_price=(m_base_price==0.0) ? m_symbol.Bid() : m_base_price;
      price      =m_symbol.NormalizePrice(base_price+m_price_level*PriceLevelUnit());
      sl         =(m_stop_level==0.0) ? 0.0 : m_symbol.NormalizePrice(price+m_stop_level*PriceLevelUnit());
      tp         =(m_take_level==0.0) ? 0.0 : m_symbol.NormalizePrice(price-m_take_level*PriceLevelUnit());
      expiration+=m_expiration*PeriodSeconds(m_period);
      return(true);
     }
//---
   return(general.OpenShortParams(price,sl,tp,expiration));
  }
//+------------------------------------------------------------------+
//| Generating a signal for closing of a long position               |
//+------------------------------------------------------------------+
bool CAggSignal::CheckCloseLong(double &price)
  {
   bool   result=false;
//--- the "prohibition" signal
   if(m_direction==EMPTY_VALUE)
      return(false);


//--- check the entry filters for a closing signal
   double direction=0;
   int number=0;
   for(int i=0;i<m_entry_filters.Total();i++)
     {
      CAggSignal *filter=m_entry_filters.At(i);
      if(filter==NULL)
         continue;

      double dir=filter.ShortCondition()*10;
      if(dir!=0)
        {
         printf(__FUNCTION__+": Entry Signal "+i+" returned "+dir);
        }
      direction+=dir;
      number++;
     }

//--- check the exit filters for a closing signal
   for(int i=0;i<m_exit_filters.Total();i++)
     {
      CAggSignal *filter=m_exit_filters.At(i);
      if(filter==NULL)
         continue;

      int dir= - filter.ShortCondition()*10;
      if(dir!=0)
        {
         printf(__FUNCTION__+": Exit Signal "+i+" returned "+dir);
        }
      direction+=dir; // < 0 ? dir * 10 : 0;
      number++;
     }

   direction+=m_direction;
   printf(__FUNCTION__+": Direction: "+-direction+" th: "+m_threshold_close);

//--- check of exceeding the threshold value
   if(-direction>=m_threshold_close)
     {
      //--- there's a signal
      result=true;
      //--- try to get the level of closing
      if(!CloseLongParams(price))
         result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Generating a signal for closing a short position                 |
//+------------------------------------------------------------------+
bool CAggSignal::CheckCloseShort(double &price)
  {
   bool   result=false;
//--- the "prohibition" signal
   if(m_direction==EMPTY_VALUE)
      return(false);

//--- check the entry filters for a closing signal
   double direction=0;
   int number=0;
   for(int i=0;i<m_entry_filters.Total();i++)
     {
      CAggSignal *filter=m_entry_filters.At(i);
      if(filter==NULL)
         continue;

      double dir=filter.LongCondition()*10;
      if(dir!=0)
        {
         printf(__FUNCTION__+": Entry Signal "+i+" returned "+dir);
        }
      direction+=dir;
      number++;
     }

//--- check the exit filters for a closing signal
   for(int i=0;i<m_exit_filters.Total();i++)
     {
      CAggSignal *filter=m_exit_filters.At(i);
      if(filter==NULL)
         continue;
         
      int dir=filter.LongCondition()*10;
      if(dir!=0)
        {
         printf(__FUNCTION__+": Exit Signal "+i+" returned "+dir);
        }
      direction+=dir; // > 0 ? dir * 10 : 0;
      number++;
     }

   direction+=m_direction;
   printf(__FUNCTION__+": Direction: "+direction+" th: "+m_threshold_close);

//--- check of exceeding the threshold value
   if(direction>=m_threshold_close)
     {
      //--- there's a signal
      result=true;
      //--- try to get the level of closing
      if(!CloseShortParams(price))
         result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Detecting the levels for closing a long position                 |
//+------------------------------------------------------------------+
bool CAggSignal::CloseLongParams(double &price)
  {
   CAggSignal *general=(m_general!=-1) ? m_filters.At(m_general) : NULL;
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      price=(m_base_price==0.0) ? m_symbol.Bid() : m_base_price;
      return(true);
     }
//---
   return(general.CloseLongParams(price));
  }
//+------------------------------------------------------------------+
//| Detecting the levels for closing a short position                |
//+------------------------------------------------------------------+
bool CAggSignal::CloseShortParams(double &price)
  {
   CAggSignal *general=(m_general!=-1) ? m_filters.At(m_general) : NULL;
//---
   if(general==NULL)
     {
      //--- if a base price is not specified explicitly, take the current market price
      price=(m_base_price==0.0)?m_symbol.Ask():m_base_price;
      return(true);
     }
//--- ok
   return(general.CloseShortParams(price));
  }
//+------------------------------------------------------------------+
//| Generating a signal for reversing a long position                |
//+------------------------------------------------------------------+
bool CAggSignal::CheckReverseLong(double &price,double &sl,double &tp,datetime &expiration)
  {
   double c_price;
//--- check the signal of closing a long position
   if(!CheckCloseLong(c_price))
      return(false);
//--- check the signal of opening a short position
   if(!CheckOpenShort(price,sl,tp,expiration))
      return(false);
//--- difference between the close and open prices must not exceed two spreads
   if(c_price!=price)
      return(false);
//--- there's a signal
   return(true);
  }
//+------------------------------------------------------------------+
//| Generating a signal for reversing a short position               |
//+------------------------------------------------------------------+
bool CAggSignal::CheckReverseShort(double &price,double &sl,double &tp,datetime &expiration)
  {
   double c_price;
//--- check the signal of closing a short position
   if(!CheckCloseShort(c_price))
      return(false);
//--- check the signal of opening a long position
   if(!CheckOpenLong(price,sl,tp,expiration))
      return(false);
//--- difference between the close and open prices must not exceed two spreads
   if(c_price!=price)
      return(false);
//--- there's a signal
   return(true);
  }
//+------------------------------------------------------------------+
//| Detecting the "weighted" direction                               |
//+------------------------------------------------------------------+
double CAggSignal::Direction(void)
  {
   long   mask;
   int entry_direction;
   int side;
   double result=m_weight*(LongCondition()-ShortCondition());
   double side_result=0.0;
   int    number=(result==0.0)? 0 : 1;      // number of "voted"
   
   if (GetPointer(m_atr))
      m_atr.Refresh();
//---
//--- loop by filters
   for(int i=0;i<m_entry_filters.Total();i++)
     {
      //--- mask for bit maps
      mask=((long)1)<<i;
      //--- check of the flag of ignoring the signal of filter
      if((m_ignore&mask)!=0)
         continue;
      CAggSignal *filter=m_entry_filters.At(i);
      //--- check pointer
      if(filter==NULL)
         continue;
      entry_direction=filter.Direction();
      //side=filter.Side();
      if(entry_direction!=0)
        {
         //printf(__FUNCTION__+": Signal "+i+" returned "+entry_direction); //+" and side "+side);
        }
      //--- the "prohibition" signal
      if(entry_direction==EMPTY_VALUE)
         return(EMPTY_VALUE);
      //--- check of flag of inverting the signal of filter
      if((m_invert&mask)!=0)
        {
         result-=entry_direction;
         //side_result-=side;
        }
      else
        {
         result+=entry_direction;
         //side_result+=side;
        }
      number++;
     }

//--- normalization
//if(number!=0)
//   result/=number;

//TODO optimize to not calc everything on every tick
/*if(abs(result)>=m_threshold_open))
     {
      return 0.0
     }*/

//--- check for state filters
   int side_number=0;
//--- loop by filters
   for(int i=0;i<m_side_filters.Total();i++)
     {
      CAggSignal *filter=m_side_filters.At(i);
      //--- check pointer
      if(filter==NULL)
         continue;
      side=filter.Side();
      if(side!=0)
        {
         //printf(__FUNCTION__+": Side Signal "+i+" returned "+side);
        }
      side_result+=side;
      number++;
     }

//--- check the exit filters for a side as well
//--- loop by filters
/*   for(int i=0;i<m_exit_filters.Total();i++)
     {
      CAggSignal *filter=m_exit_filters.At(i);
      //--- check pointer
      if(filter==NULL)
         continue;
      side=filter.Side();
      if(side!=0)
        {
         printf(__FUNCTION__+": Exit Signal "+i+" returned side "+side);
        }
      side_result+=side;
      number++;
     }
   */

//--- normalization
   if(m_filters.Total()>0)
     {
      //printf(__FUNCTION__+": confirm result %.1f\tside result %.1f\t=> result: %.2f\t num: %d",
      //       result,side_result,number==0? 0 :(result+side_result)/number,number);
      // get the result by considering the sides of the indicators as well
     }
   if(number!=0)
      result = (result + side_result)/number;

//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+

bool CAggSignal::LongSide(void) {
  if (m_filters.Total() == 0)
    return Side() > 0 ? true : false;
  // if the Signal is not configured it counts as true to give a wildcard for other signals
  return (!m_confirm  || m_confirm.LongSide())
      && (!m_confirm2 || m_confirm2.LongSide()) 
      && (!m_baseline || BaselineATRChannelLong());
}

bool CAggSignal::ShortSide(void){
  if (m_filters.Total() == 0)
    return Side() < 0 ? true : false;
  // if the Signal is not configured it counts as true to give a wildcard for other signals
  return (!m_confirm  || m_confirm.ShortSide())
      && (!m_confirm2 || m_confirm2.ShortSide()) 
      && (!m_baseline || BaselineATRChannelShort());
}
