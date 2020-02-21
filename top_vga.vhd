-- Author: Omar Barazanji
-- Description: Combines components to output data through VGA DAC.
--

library ieee;
use ieee.std_logic_1164.all;

entity top is
  generic (
    h_pulse 	:	INTEGER := 128;    	
    h_bp	  	:	INTEGER := 88;		
    h_pixels	:	INTEGER := 800;		
    h_fp	  	:	INTEGER := 40;		
    h_pol	    :	STD_LOGIC := '1';	
    v_pulse 	:	INTEGER := 4;		
    v_bp	   	:	INTEGER := 23;		
    v_pixels	:	INTEGER := 600;		
    v_fp	  	:	INTEGER := 1;		
    v_pol       :	STD_LOGIC := '1');
  Port (
    CLK      : in std_logic;
    RST      : in std_logic;
    red      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  
    green    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  
    blue     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    h_sync	 :	OUT	STD_LOGIC;	
    v_sync	 :	OUT	STD_LOGIC);	
end top;

architecture HIER of top is

    signal CLK40 : std_logic := '0';
    signal reset_clk : std_logic;
    signal locked : std_logic;
    
    signal disp_ena 	:	 STD_LOGIC;	
    signal column		:	 INTEGER;	
    signal row		    :	 INTEGER;	
    signal n_blank		:	 STD_LOGIC;	
    signal n_sync		:	 STD_LOGIC; 

  component clk_wiz_0 is
    Port (
        clk_out1 : out std_logic;
        reset : in std_logic;
        locked : out std_logic;
        clk_in1 : in std_logic);
  end component;

  component vga_controller is
  	generic (
  		h_pulse 	:	INTEGER := 208;    
  		h_bp	  	:	INTEGER := 336;		
  		h_pixels	:	INTEGER := 1920;	
  		h_fp	  	:	INTEGER := 128;		
  		h_pol	  	:	STD_LOGIC := '0';	
  		v_pulse 	:	INTEGER := 3;		
  		v_bp	   	:	INTEGER := 38;		
  		v_pixels	:	INTEGER := 1200;	
  		v_fp	  	:	INTEGER := 1;		
  		v_pol		  :	STD_LOGIC := '1');	
  	Port (
  		pixel_clk	:	IN STD_LOGIC;	
  		reset_n		:	IN STD_LOGIC;	
  		h_sync		:	OUT	STD_LOGIC;	
  		v_sync		:	OUT	STD_LOGIC;	
  		disp_ena	:	OUT	STD_LOGIC;	
  		column		:	OUT	INTEGER;	
  		row			  :	OUT	INTEGER;	
  		n_blank		:	OUT	STD_LOGIC;	
  		n_sync		:	OUT	STD_LOGIC); 
  end component;

  component hw_image_generator is
    generic (
      pixels_y :  INTEGER := 478;  
      pixels_x :  INTEGER := 600); 
    Port (
      disp_ena :  IN   STD_LOGIC;  
      row      :  IN   INTEGER;    
      column   :  IN   INTEGER;    
      red      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); 
      green    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); 
      blue     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'));
  end component;

  begin

    YUH : clk_wiz_0
       port map ( 
      -- Clock out ports  
       clk_out1 => CLK40,
      -- Status and control signals                
       reset => reset_clk,
       locked => locked,
       -- Clock in ports
       clk_in1 => CLK
     );


      VGA : vga_controller
        generic map (
            h_pulse=>h_pulse,
            h_bp=>h_bp,
            h_pixels=>h_pixels,
            h_fp=>h_fp,
            h_pol=>h_pol,
            v_pulse=>v_pulse,
            v_bp=>v_bp,
            v_pixels=>v_pixels,
            v_fp=>v_fp,
            v_pol=>v_pol)
        port map (
            pixel_clk=>CLK40,
            reset_n=>RST,
            h_sync=>h_sync,
            v_sync=>v_sync,
            disp_ena=>disp_ena,
            column=>column,
            row=>row,
            n_blank=>n_blank,
            n_sync=>n_sync);

      IMG : hw_image_generator
        port map (
            disp_ena=>disp_ena,
            row=>row,
            column=>column,
            red=>red,
            green=>green,
            blue=>blue);

  end HIER;
