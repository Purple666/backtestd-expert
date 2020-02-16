﻿//+------------------------------------------------------------------+
//|                                     Copyright 2019, Stefan Lendl |
//+------------------------------------------------------------------+
#include "LevelCrossSignal.mqh"
//+------------------------------------------------------------------+
class CSingleLineLevelCrossSignal : public CLevelCrossSignal
  {
protected:
   virtual bool      InitIndicatorBuffers();
  };

bool CSingleLineLevelCrossSignal::InitIndicatorBuffers()
{
   m_buf_up = m_buf_down = m_indicator.At(m_buf_idx);
   m_last_signal = 0;
   if (m_level_down_enter >= m_level_up_enter)
     m_strict_side = false;

   return true;
}
