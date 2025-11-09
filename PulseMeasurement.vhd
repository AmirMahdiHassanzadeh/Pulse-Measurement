library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PulseMeasurement is
  Port (
    iClk          : in STD_LOGIC;
    iNReset       : in STD_LOGIC;
    iPulse        : in STD_LOGIC;
    iEnable       : in STD_LOGIC;
    oHalfDone     : out STD_LOGIC;
    oDone         : out STD_LOGIC;
    oFirstEdge    : out STD_LOGIC;
    oHighDuration : out STD_LOGIC_VECTOR(31 downto 0);
    oLowDuration  : out STD_LOGIC_VECTOR(31 downto 0);
    oPeriod       : out STD_LOGIC_VECTOR(31 downto 0)
  );
end PulseMeasurement;

architecture Behavioral of PulseMeasurement is
 
  signal rHighDuration    : INTEGER := 0;
  signal rLowDuration     : INTEGER := 0;
  signal rPeriod          : INTEGER := 0;
  signal rCounter         : INTEGER := 0;
  signal rEdgeCounter     : INTEGER Range 0 to 2:= 0;
 
  signal rEnable          : STD_LOGIC := '0';
  signal pulse_stable     : STD_LOGIC := '0';
  signal rFirstEdge       : STD_LOGIC := '0';
  signal IsFirstEdge      : STD_LOGIC := '0';
  signal pulse_stableLast : STD_LOGIC := '0';
  signal rMeasureDone     : STD_LOGIC := '0';
  signal rMeasureHalfDone : STD_LOGIC := '0';
  signal rMeasureDone_H   : STD_LOGIC := '0';
  signal rMeasureDone_L   : STD_LOGIC := '0';
--------------------------------------------------
signal pulse_sync1, pulse_sync2 : std_logic := '0';
signal pulse_stable : std_logic := '0';

begin
--------------------------------------------------
  rEnable <= iEnable;
  oFirstEdge <= rFirstEdge;
  oDone <= rMeasureDone;
  oHalfDone <= rMeasureHalfDone;
  oHighDuration <= std_logic_vector(to_unsigned(rHighDuration,32));
  oLowDuration <= std_logic_vector(to_unsigned(rLowDuration,32));
  oPeriod <= std_logic_vector(to_unsigned(rPeriod,32));
  pulse_stable <= pulse_sync2;
---------------------------------------------------------------------
  process(iClk)
  begin
    if rising_edge(iClk) then
      pulse_sync1 <= iPulse;
      pulse_sync2 <= pulse_sync1;
    end if;
  end process;

---------------------------------------------------------------------
  WhatIsEdge:process(iClk, iNReset)
    begin
    if iNReset = '0' then
    
      rFirstEdge <='0';
      IsFirstEdge <='0';
      pulse_stableLast <= pulse_stableLast;
      
    elsif rising_edge(iClk) then
    
      pulse_stableLast <= pulse_stable;
      
      if rEnable = '1' then
        if (pulse_stable = '1') and (pulse_stableLast = '0') then --Rising Edge Pulse
        
          if IsFirstEdge = '0' then
            IsFirstEdge <= '1';
            rFirstEdge <= '1';
           
          end if;
         
        elsif (pulse_stable = '0') and (pulse_stableLast = '1') then --Falling Edge Pulse
         
          if IsFirstEdge = '0' then
            IsFirstEdge <= '1';
            rFirstEdge <= '0';
          end if;
        end if;
        
      else --Enable = '0'
        IsFirstEdge <= '0';
      end if;--Enable = '1'
    end if; --rising_edge(iClk)
  end process;

---------------------------------------------------------------------
  WhatIsDuration:process(iClk, iNReset)
    begin
    if iNReset = '0' then

      rLowDuration <= 0;
      rHighDuration <= 0;
      rCounter <= 1;
      rPeriod <= 0;

      rMeasureDone <='0';
      rMeasureHalfDone <='0';
      rMeasureDone_H <='0';
      rMeasureDone_L <='0';
      rEdgeCounter <= 0;

    elsif rising_edge(iClk) then

      rMeasureHalfDone <= '0';
      rMeasureDone <= '0';

      if rEnable = '1' then
        if (pulse_stable = '1') and (pulse_stableLast = '0') and (IsFirstEdge = '1') then --Rising Edge Pulse
          rCounter <= 1;
          rMeasureDone_H <= '1';
          rLowDuration <= rCounter;
          rEdgeCounter <= rEdgeCounter + 1;

        elsif (pulse_stable = '0') and (pulse_stableLast = '1')and (IsFirstEdge = '1') then --Falling Edge Pulse
          rCounter <= 1;
          rMeasureDone_L <= '1';
          rHighDuration <= rCounter;
          rEdgeCounter <= rEdgeCounter + 1;

        elsif pulse_stable = pulse_stableLast then --Pulse level Duration
          rCounter <= rCounter + 1;
          rMeasureDone_H <= '0';
          rMeasureDone_L <= '0';
        end if;

        if rMeasureDone_L = '1' or rMeasureDone_H = '1' then
            rMeasureHalfDone <= '1';
        end if;

        if rEdgeCounter = 2 then
          rMeasureDone <= '1';
          rPeriod <= rHighDuration + rLowDuration;
          rEdgeCounter <= 0;
        end if;
      else
        rEdgeCounter <= 0;
      end if;--Enable = '1'
    end if; --rising_edge(iClk)
  end process;
---------------------------------------------------------------------
 
end Behavioral;