----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2025 08:54:15 PM
-- Design Name: 
-- Module Name: PalseMeasurement_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PulseMeasurement_tb is
--  Port ( );
end PulseMeasurement_tb;

architecture Behavioral of PulseMeasurement_tb is

  signal rHighDuration    : STD_LOGIC_VECTOR(31 downto 0);
  signal rLowDuration     : STD_LOGIC_VECTOR(31 downto 0);
  signal rPeriod          : STD_LOGIC_VECTOR(31 downto 0);

   
  signal rClk             : STD_LOGIC := '0';  
  signal rNReset          : STD_LOGIC := '1';  
  signal rEnable          : STD_LOGIC := '0';  
  signal rPulse           : STD_LOGIC := '0'; 
  signal rFirstEdge       : STD_LOGIC := '0';
  signal IsFirstEdge      : STD_LOGIC := '0';
  signal rPulseLast       : STD_LOGIC := '0';
  signal rMeasureDone     : STD_LOGIC := '0';
  signal rMeasureHalfDone : STD_LOGIC := '0';
begin

PulseMeasurementmodule:entity work.PulseMeasurement(Behavioral) port map
(
  iClk          =>  rClk,
  iNReset       =>  rNReset,
  iPulse        =>  rPulse,
  iEnable       =>  rEnable,
  oHalfDone     =>  rMeasureHalfDone,
  oDone         =>  rMeasureDone,
  oFirstEdge    =>  rFirstEdge,
  oHighDuration =>  rHighDuration, 
  oLowDuration  =>  rLowDuration,  
  oPeriod       =>  rPeriod
);

process
  begin 
    rClk <= '1';
    wait for 10 ns;
    rClk <= '0';
    wait for 10 ns;
  end process;
  
process
  begin 
  
    rNReset <= '0';
    wait for 100 ns;
    rNReset <= '1';
    wait for 40 ns;
    
    rEnable <= '1';
      rPulse <= '0';
    wait for 20 us;    
     rPulse <= '0';
    wait for 20 us;  
     rPulse <= '1';
    wait for 20 us;    
     rPulse <= '0';
    wait for 20 us; 
    rPulse <= '1';
    wait for 100 us;    
     rPulse <= '0';
    wait for 200 us; 
    rPulse <= '1';
    wait for 50 us;    
     rPulse <= '0';
    wait for 100 us; 
      rPulse <= '1';  
      
  wait;    
end process;
   
end Behavioral;
