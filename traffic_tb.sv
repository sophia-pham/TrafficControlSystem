// Name: Sophia Pham
// Assignment: ECE 033 Final Project TB
// Purpose of program: Apply test cases to the implemented system to see if they match the expected behavior for traffic control.

module traffic_tb;
  
  //delcare regs for inputs in main, wires for outputs in main
  reg clk_tb, reset_tb, snow_tb, sys_en_tb, vehicle_tb;
  wire gh_tb, gc_tb, rh_tb, rc_tb;
  
  //map to dut
  traffic dut(.clk(clk_tb), .reset(reset_tb), .snow(snow_tb), .sys_en(sys_en_tb), .gh(gh_tb), .gc(gc_tb), .rh(rh_tb), .rc(rc_tb),.vehicle(vehicle_tb));
  
  initial
    begin
      sys_en_tb=1; vehicle_tb=0; clk_tb=0; reset_tb=0;
    end
  
  //set up waveforms
  initial
    begin
      $dumpfile("traffic.vcd");
      $dumpvars;
    end
  
  //set up log
  initial
    begin
      $display("sys_en\tvehicle\tclk\treset\t|\tgc\trc\tgh\trh");
      $display("-----------------------------------------------------------------------");
      $monitor("%b\t%b\t%b\t%b\t|\t%b\t%b\t%b\t%b", sys_en_tb, vehicle_tb, clk_tb, reset_tb, gc_tb, rc_tb, gh_tb, rh_tb);
    end
  
  //set up clock cycles, 4 time units each full period
  always
    begin
      #2 clk_tb=!clk_tb;
    end
  
  //test cases
  //reseting the system between each case to avoid interferences
  always
    begin
      //case 1: goes through whole cycle as expected (0-26)
      #2 vehicle_tb = 1; //let one car go through (already at state 1 from instantiation)
      #24 vehicle_tb = 0; reset_tb = 1;
      
      //case 2: green highway is on and one car has passed through (26-42)
      #2 reset_tb = 0; //start
      #2 vehicle_tb = 1; //let one car go through (-> 1 cycle)
      #4 vehicle_tb = 0; //no more cars coming through
      #8 reset_tb = 1; //see state 2, then reset system

      //case 3: three vehicles have come from highway, now transition period (42-62)
      #2 reset_tb = 0;
      #2 vehicle_tb = 1; //start and let three cars through highway and let light start(-> 4 cycles)
      #16 reset_tb = 1; vehicle_tb = 0; //end during the transition period (transition period is always a set length of one clock cycle / 4 ticks)
      
      //case 4: green country is on but no cars are passing through (62-90)
      #2 reset_tb = 0; //start
      #2 vehicle_tb = 1; //let 3 cars go through highway and transition period to complete (-> 4 cycles)
      #16 vehicle_tb = 0;
      #8 reset_tb = 1; //see state 5 then reset system
      
      //case 5: in the transition period before green highway, enable is shut off (90-102)
      #2 reset_tb = 0;
      #2 sys_en_tb = 0; vehicle_tb = 1; //state should not change even though there is a vehicle
      #8 reset_tb = 1; sys_en_tb = 1; vehicle_tb = 0; //see state 1 indefinitely then reset
      
      //case 6: indefinite green highway light is on, enable is turned back on (102-138)
      #2 reset_tb = 0;
      #2 sys_en_tb = 0; vehicle_tb = 1;
      #8 sys_en_tb = 1; //turn en back on after a bit of indefinite highway light
      #24 reset_tb = 1; vehicle_tb = 0; //see behavior, then reset system
      
      //case 7: two vehicles have passed through from the highway and highway green was on, then enable is shut off (138-166)
      #2 reset_tb = 0;
      #2 vehicle_tb = 1; //let 2 cars through (-> 2 cycles)
      #8 vehicle_tb = 0; sys_en_tb = 0; //after 2 cars go through, turn off en
      #16 reset_tb = 1; sys_en_tb = 1; //let eternal green highway light run then reset the system and turn enable back on
      
      //case 8: in the transition period before green country, enable is shut off (166-204)
      #2 reset_tb = 0;
      #2 vehicle_tb = 1;
      #12 vehicle_tb = 0;
      #2 sys_en_tb = 0;
      #12 reset_tb = 1; sys_en_tb = 1;
      
      
    end
  
  initial
    begin
      #210 $finish;
    end
  
endmodule
