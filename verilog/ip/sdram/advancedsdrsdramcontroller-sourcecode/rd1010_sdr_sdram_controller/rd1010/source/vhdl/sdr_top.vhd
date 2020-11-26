--   ==================================================================
--   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
--   ------------------------------------------------------------------
--   Copyright (c) 2013 by Lattice Semiconductor Corporation
--   ALL RIGHTS RESERVED 
--   ------------------------------------------------------------------
--
--   Permission:
--
--      Lattice SG Pte. Ltd. grants permission to use this code
--      pursuant to the terms of the Lattice Reference Design License Agreement. 
--
--
--   Disclaimer:
--
--      This VHDL or Verilog source code is intended as a design reference
--      which illustrates how these types of functions can be implemented.
--      It is the user's responsibility to verify their design for
--      consistency and functionality through the use of formal
--      verification methods.  Lattice provides no warranty
--      regarding the use or functionality of this code.
--
--   --------------------------------------------------------------------
--
--                  Lattice SG Pte. Ltd.
--                  101 Thomson Road, United Square #07-02 
--                  Singapore 307591
--
--
--                  TEL: 1-800-Lattice (USA and Canada)
--                       +65-6631-2000 (Singapore)
--                       +1-503-268-8001 (other locations)
--
--                  web: http:--www.latticesemi.com/
--                  email: techsupport@latticesemi.com
--
--   --------------------------------------------------------------------
--
-- This is the top level module of the SDR SDRAM controller reference
-- design.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
--	 V4.3 :| Peter						 :| 10/18/09	:| Added VHDL Support 	
-- --------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.sdr_par.all;

entity sdr_top is
	port(
	sys_R_Wn			:in std_logic;
	sys_ADSn			:in std_logic;
	sys_DLY_100US	:in std_logic;
	sys_CLK				:in std_logic;
	sys_RESET			:in std_logic;
	sys_REF_REQ		:in std_logic;
	sys_REF_ACK		:out std_logic;
	sys_A					:in std_logic_vector( 22 downto 0);
	sys_D					:inout std_logic_vector( 15 downto 0);
	sys_D_VALID		:out std_logic;
	sys_CYC_END		:out std_logic;
	sys_INIT_DONE	:out std_logic;

	sdr_DQ				:inout std_logic_vector( 3 downto 0);
	sdr_A					:out std_logic_vector(12-1 downto 0);
	sdr_BA				:out std_logic_vector(2-1 downto 0);
	sdr_CKE				:out std_logic;
	sdr_CSn				:out std_logic;
	sdr_RASn			:out std_logic;
	sdr_CASn			:out std_logic;
	sdr_WEn				:out std_logic;
	sdr_DQM 			:out std_logic
	);
end sdr_top;

architecture behave of sdr_top is
signal iState :std_logic_vector(3 downto 0); --// INIT_FSM state variables
signal cState :std_logic_vector(3 downto 0); --// CMD_FSM state variables
signal clkCNT :std_logic_vector(3 downto 0); --
-----------------------------------------------------------------------
component sdr_ctrl
			port(
			sys_CLK				: in std_logic;
			sys_RESET			: in std_logic;
			sys_R_Wn			: in std_logic;
			sys_ADSn			: in std_logic;
			sys_DLY_100US	: in std_logic;
			sys_REF_REQ		: in std_logic;
			sys_REF_ACK		: out std_logic;
			sys_CYC_END		: out std_logic;
			sys_INIT_DONE	: buffer std_logic;
			iState				: buffer std_logic_vector(3 downto 0);
			cState				: buffer std_logic_vector(3 downto 0);
			clkCNT				: buffer std_logic_vector(3 downto 0)
			);
end component;

component sdr_sig 
		port (            
  	sys_CLK		: in std_logic; 
  	sys_RESET	: in std_logic;
  	sys_A			: in std_logic_vector(RA_MSB downto CA_LSB);   
  	iState		: in std_logic_vector(3 downto 0);  
  	cState		: in std_logic_vector(3 downto 0);  
  	sdr_CKE		: out std_logic; 
  	sdr_CSn		: out std_logic; 
  	sdr_RASn	: out std_logic;
  	sdr_CASn	: out std_logic;
  	sdr_WEn		: out std_logic; 
  	sdr_BA		: out std_logic_vector(SDR_BA_WIDTH-1 downto 0 );  
  	sdr_A			: out std_logic_vector(SDR_A_WIDTH-1 downto 0)   
);                      
end component;

component sdr_data 
	port (                
  sys_CLK			:in std_logic;     
  sys_RESET		:in std_logic;   
  sys_D				:inout std_logic_vector(15 downto 0);      
  sys_D_VALID	:out std_logic; 
  cState			:in std_logic_vector(3 downto 0);      
  clkCNT			:in std_logic_vector(3 downto 0);      
  sdr_DQ			:inout std_logic_vector(3 downto 0)     
);                           
end component;

begin
U0:  sdr_ctrl port map (
		sys_CLK				=> sys_CLK	    ,			
		sys_RESET			=> sys_RESET		,	
		sys_R_Wn			=> sys_R_Wn			,  
		sys_ADSn			=> sys_ADSn			,  
		sys_DLY_100US	=> sys_DLY_100US,	
		sys_REF_REQ		=> sys_REF_REQ	,	
		sys_REF_ACK		=> sys_REF_ACK	,	
		sys_CYC_END		=> sys_CYC_END	,	
		sys_INIT_DONE	=> sys_INIT_DONE,	
		iState				=> iState				,  
		cState				=> cState				,  
		clkCNT				=> clkCNT				  
		);
U1: sdr_sig port map
		(            
  	sys_CLK		=>sys_CLK		,
  	sys_RESET	=>sys_RESET	,
  	sys_A			=>sys_A			,
  	iState		=>iState		,
  	cState		=>cState		,
  	sdr_CKE		=>sdr_CKE		,
  	sdr_CSn		=>sdr_CSn		,
  	sdr_RASn	=>sdr_RASn	,
  	sdr_CASn	=>sdr_CASn	,
  	sdr_WEn		=>sdr_WEn		,
  	sdr_BA		=>sdr_BA		,
  	sdr_A			=>sdr_A			
);
--
U2: sdr_data port map
	 (                                              
  	sys_CLK			=>sys_CLK			 ,  
  	sys_RESET		=>sys_RESET		 ,  
  	sys_D				=>sys_D				 ,  
  	sys_D_VALID	=>sys_D_VALID	 ,  
  	cState			=>cState			 ,  
  	clkCNT			=>clkCNT			 ,  
  	sdr_DQ			=>sdr_DQ			   
		);
--		                                                    
sdr_DQM <= '0' after tDLY ;
end behave;


