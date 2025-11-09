architecture Behavioral of PulseMeasurement is

  constant PULSE_WIDTH : integer := 4; -- چند سیکل پالس دیده بشه

  -- شمارنده‌ها و متغیرها
  signal rHighDuration, rLowDuration, rPeriod, rCounter : integer := 0;
  signal rEdgeCounter : integer range 0 to 2 := 0;

  signal pulse_sync1, pulse_sync2, pulse_stable, pulse_last : std_logic := '0';
  signal rFirstEdge, IsFirstEdge : std_logic := '0';

  -- خروجی‌ها
  signal rHalfDone, rDone : std_logic := '0';

  -- شمارنده‌ی کشش پالس‌ها
  signal half_cnt, done_cnt : integer range 0 to PULSE_WIDTH := 0;

begin
  oHalfDone <= rHalfDone;
  oDone     <= rDone;
  oFirstEdge <= rFirstEdge;

  oHighDuration <= std_logic_vector(to_unsigned(rHighDuration, 32));
  oLowDuration  <= std_logic_vector(to_unsigned(rLowDuration, 32));
  oPeriod       <= std_logic_vector(to_unsigned(rPeriod, 32));

  -------------------------------------------------------------------
  process(iClk, iNReset)
  begin
    if iNReset = '0' then
      pulse_sync1 <= '0';
      pulse_sync2 <= '0';
      pulse_stable <= '0';
      pulse_last <= '0';
      rHighDuration <= 0;
      rLowDuration <= 0;
      rCounter <= 0;
      rPeriod <= 0;
      rEdgeCounter <= 0;
      IsFirstEdge <= '0';
      rFirstEdge <= '0';
      rHalfDone <= '0';
      rDone <= '0';
      half_cnt <= 0;
      done_cnt <= 0;

    elsif rising_edge(iClk) then

      -- سینکرون‌سازی
      pulse_sync1 <= iPulse;
      pulse_sync2 <= pulse_sync1;
      pulse_stable <= pulse_sync2;

      -- پیش‌فرض صفر
      if half_cnt = 0 then
        rHalfDone <= '0';
      else
        half_cnt <= half_cnt - 1;
      end if;

      if done_cnt = 0 then
        rDone <= '0';
      else
        done_cnt <= done_cnt - 1;
      end if;

      if iEnable = '1' then
        rCounter <= rCounter + 1;

        -- لبه بالا
        if (pulse_stable = '1') and (pulse_last = '0') then
          if IsFirstEdge = '0' then
            IsFirstEdge <= '1';
            rFirstEdge <= '1';
          end if;

          rLowDuration <= rCounter;
          rCounter <= 0;
          rEdgeCounter <= rEdgeCounter + 1;
          rHalfDone <= '1';
          half_cnt <= PULSE_WIDTH;

        -- لبه پایین
        elsif (pulse_stable = '0') and (pulse_last = '1') then
          if IsFirstEdge = '0' then
            IsFirstEdge <= '1';
            rFirstEdge <= '0';
          end if;

          rHighDuration <= rCounter;
          rCounter <= 0;
          rEdgeCounter <= rEdgeCounter + 1;
          rHalfDone <= '1';
          half_cnt <= PULSE_WIDTH;
        end if;

        if rEdgeCounter = 2 then
          rPeriod <= rHighDuration + rLowDuration;
          rEdgeCounter <= 0;
          rDone <= '1';
          done_cnt <= PULSE_WIDTH;
        end if;

      else
        rCounter <= 0;
        rEdgeCounter <= 0;
        IsFirstEdge <= '0';
        rFirstEdge <= '0';
      end if;

      pulse_last <= pulse_stable;
    end if;
  end process;
end Behavioral;
