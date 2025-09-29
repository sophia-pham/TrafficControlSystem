// Name: Sophia Pham
// Assignment: ECE 033 Final Project
// Purpose of program: Implement the proposed design for the traffic control system surrounding two one-way roads.


//main module: implement the traffic control here
module traffic(clk, reset, snow, sys_en, gh, gc, rh, rc, vehicle);
  input clk, reset, snow, sys_en, vehicle; //declare the inputs from the portlist-- the rest are outputs to the lights
  //note that reset and snow are not used in the design
  output gh, gc, rh, rc; //green highway light, green country light, etc.
    
  wire [2:0] q; //present state vals; q[2] = q2, etc.
  wire q2n, q1n, q0n;
  
  wire Q2ns, Q2p1, Q2p2, Q2p3; //three products for Q2 ns
  wire Q1ns, Q1p1, Q1p2, Q1p3, Q1p4; //four products for Q1 ns
  wire Q0ns, Q0p1, Q0p2, Q0p3, Q0p4, Q0p5, Q0p6; //six products for Q0 ns
  
  wire gcp1, gcp2, rcp1, ghp1, ghp2, rhp1, rhp2, rhp3; //products for outputs eqs
  
  //declare not values to use in transition eqs
  wire vehicle_n, sys_en_n;
  not(vehicle_n, vehicle);
  not(sys_en_n, sys_en);
  
  //Q2* = q2q1'en + q2q0'v'en + q2'q1q0ven
  and(Q2p1, q[2], q1n, sys_en);
  and(Q2p2, q[2], q0n, vehicle_n, sys_en);
  and(Q2p3, q2n, q[1], q[0], vehicle, sys_en);
  or(Q2ns, Q2p1, Q2p2, Q2p3);
  
  //Q1* = q1q0'v'en + q2'q1q0'en + q1'q0ven + q2'q1q0v'en
  and(Q1p1, q[1], q0n, vehicle_n, sys_en);
  and(Q1p2, q2n, q[1], q0n, sys_en);
  and(Q1p3, q1n, q[0], vehicle, sys_en);
  and(Q1p4, q2n, q[1], q[0], vehicle_n, sys_en);
  or(Q1ns, Q1p1, Q1p2, Q1p3, Q1p4);
  
  //Q0* = q2q1'q0' + q2'q1'en' + q2'q0'ven + q2'q1'q0'en + q2'q0v'en + q1'q0v'en
  and(Q0p1, q[2], q1n, q0n);
  and(Q0p2, q2n, q1n, sys_en_n);
  and(Q0p3, q2n, q0n, vehicle, sys_en);
  and(Q0p4, q2n, q1n, q0n, sys_en);
  and(Q0p5, q2n, q[0], vehicle_n, sys_en);
  and(Q0p6, q1n, q[0], vehicle_n, sys_en);
  or(Q0ns, Q0p1, Q0p2, Q0p3, Q0p4, Q0p5, Q0p6);
  
  //connect Qs to DFFs
  dff ff2(clk, reset, Q2ns, q[2], q2n);
  dff ff1(clk, reset, Q1ns, q[1], q1n);
  dff ff0(clk, reset, Q0ns, q[0], q0n);
  
  //output equations
  //GC = q2q1q0' + q2q1'q0
  and(gcp1, q[2], q[1], q0n);
  and(gcp2, q[2], q1n, q[0]);
  or(gc, gcp1, gcp2);
  
  //RC = q2' + q1'q0'
  and(rcp1, q1n, q0n);
  or(rc, q2n, rcp1);
  
  //GH = q2'q1 + q2'q0
  and(ghp1, q2n, q[1]);
  and(ghp2, q2n, q[0]);
  or(gh, ghp1, ghp2);
  
  //RH = q1'q0' + q2q0' + q2q1'
  and(rhp1, q1n, q0n);
  and(rhp2, q[2], q0n);
  and(rhp3, q[2], q1n);
  or(rh, rhp1, rhp2, rhp3);
  
endmodule




//implement the DFF to be used throughout the logic
module dff(clk, reset, D, Q, Qn);
  input clk, D, reset; //connect the clock and next state input
  output reg Q, Qn; //output Q and Qn, to be assigned vals
  
  initial
    begin
      Q=0; Qn=1; //set initial vals of Q, Qn
    end
  
  //on clk tick, update Q and Qn with D and !D
  //set Q to 0 when reset is 1 (active high)
  always@ (posedge clk or posedge reset)
    begin
      if(reset == 1)
        begin
          Q <= 0;
          Qn <= 1;
        end
      else
        begin
          Q <= D;
          Qn <= !D;
        end
    end

endmodule
