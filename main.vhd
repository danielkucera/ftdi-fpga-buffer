----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:18:46 01/06/2020 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- Simple OR gate design
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.Numeric_Std.all;

-- IQs are sampled internally in the SX1301 digital IC on the falling edge of the 32 MHz clock. (clk_in)

-- FT2232H: Data is read or written on the rising edge of the CLKOUT clock. (clk_out)

entity lora_fpga is
port(
	sw2: in std_logic;
	sw3: in std_logic;
	led1: out std_logic;
	led3: out std_logic;

	clk_in: in std_logic;
	clk_in_copy: out std_logic;
	dat_in: in std_logic_vector(7 downto 0);
	wr_out:	out std_logic;
	wr_copy:	out std_logic;
	
	clk_out: in std_logic;
	clk_out_copy: out std_logic;
	txe: in std_logic;
	txe_copy:	out std_logic;
	
	out_rate: out std_logic;
	dat_out: out std_logic_vector(7 downto 0)
);
end lora_fpga;

architecture rtl of lora_fpga is
	constant BUFFER_POW : integer := 16;
	constant BUFFER_LEN : integer := 2**BUFFER_POW;
	constant BUFFER_MAX : integer := BUFFER_LEN - 1;
	
	type t_Memory is array (0 to BUFFER_MAX) of std_logic_vector(7 downto 0);
	signal buf : t_Memory;
  
	signal p_in :integer range 0 to BUFFER_MAX;
	signal buf_in : std_logic_vector(7 downto 0);
	signal buf_in_epoch: std_logic_vector(BUFFER_POW-1 downto 0);

	signal p_out :integer range 0 to BUFFER_MAX;
	signal buf_out : std_logic_vector(7 downto 0);
	signal buf_out_epoch: std_logic_vector(BUFFER_POW-1 downto 0);
	
	signal clk_out_cnt: std_logic_vector(23 downto 0);
	
	signal wr: std_logic;
	
	signal buf_wr :integer range 0 to 1;
	signal buf_rd :integer range 0 to 1;

begin

	led1 <= clk_out_cnt(23);
	led3 <= sw3;

	clk_in_copy <= clk_in;

	clk_out_copy <= clk_out;
	
	wr_copy <= wr;
	wr_out <= wr;
	txe_copy <= txe;
	
	buf_in_epoch <= std_logic_vector(to_unsigned(p_in,BUFFER_POW));
	buf_out_epoch <= std_logic_vector(to_unsigned(p_out,BUFFER_POW));
		
	--out_rate <= clk_out and not wr;
	  
	process(clk_out) is
	begin
		if (falling_edge(clk_out)) then -- setup data for FT on falling edge, will be sampled on rising
			if txe = '0' and not buf_in_epoch(BUFFER_POW-1) = buf_out_epoch(BUFFER_POW-1) then
				p_out <= p_out + 1;
				wr <= '0';
				
				-- potom
				dat_out <= buf(p_out);
			else
				wr <= '1';
			end if;
			
			clk_out_cnt <= clk_out_cnt + '1';
			
		end if;
	end process;
 
 	process(clk_in) is 
	begin
		if (falling_edge(clk_in)) then -- copy data from input to buffer on falling edge
		   p_in <= p_in + 1;
			
			-- potom
			buf(p_in) <= dat_in;			
		end if;
	end process;
 
end rtl;