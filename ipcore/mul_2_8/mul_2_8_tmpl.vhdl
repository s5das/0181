-- Created by IP Generator (Version 2021.4-SP1.2 build 96435)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT mul_2_8
  PORT (
    a : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    p : OUT STD_LOGIC_VECTOR(25 DOWNTO 0)
  );
END COMPONENT;


the_instance_name : mul_2_8
  PORT MAP (
    a => a,
    b => b,
    clk => clk,
    rst => rst,
    ce => ce,
    p => p
  );
