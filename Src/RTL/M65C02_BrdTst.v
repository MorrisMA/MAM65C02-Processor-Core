`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:00:59 06/17/2013 
// Design Name: 
// Module Name:    M65C02_BrdTst 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module M65C02_BrdTst(
    input   nRst,               // System Reset Input
    output  reg nRstO,          // Internal Reset Output
    input   ClkIn,              // System Clk Input

    output  Phi2O,              // Clock Phase 2 Output
    output  Phi1O,              // Clock Phase 1 Output - complement of Phi2O
    
    output  [ 7:0] DB,
    output  [15:0] A,
    output  [ 3:0] XA,
    output  [ 3:0] nCE,
    
    output  nWait,
    
    output  TxD_A,
    output  TxD_B,
    
    output  [ 2:0] nCS,
    output  SCK,
    output  MOSI
    
);

////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

reg     [3:0] DCM_Rst;          // Stretched DCM Reset (see Table 3-6 UG331)
reg     nRst_IFD;               // Input FF for external Reset signal
reg     [3:0] xRst;             // Stretched external reset (Buf_ClkIn)
wire    Rst_M65C02;             // Combination of DCM_Rst and xRst
reg     [3:0] Rst_Dly;          // Stretched internal reset (Buf_ClkIn)
wire    FE_Rst_Dly;             // Falling edge of Rst_Dly (Clk)
reg     Rst;                    // Internal reset (Clk)

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Implement internal clock generator using DCM and DFS. DCM/DFS multiplies
//  external clock reference by 4.

ClkGen  ClkGen (
            .USER_RST_IN(DCM_Rst[0]),           // DCM Rst generated on FE Lock 

            .CLKIN_IN(ClkIn),                   // ClkIn          = 18.432 MHz
            .CLKIN_IBUFG_OUT(Buf_ClkIn),        // Buffered ClkIn = 18.432 MHz

            .CLKFX_OUT(Clk),                    // DCM ClkFX_Out  = 73.728 MHz 

            .CLK0_OUT(),                        // Clk0_Out unused 
            .CLK2X_OUT(),                       // Clk2x_Out (FB) = 36.864 MHz 
            
            .LOCKED_OUT(DCM_Locked)             // When 1, DCM Locked 
        );
      
//  Detect falling edge of DCM_Locked, and generate DCM reset pulse at least 4
//  ClkIn periods wide if a falling edge is detected. (see Table 3-6 UG331)
        
fedet   FE1 (
            .rst(1'b0),             // No reset required for this circuit 
            .clk(Buf_ClkIn),        // Buffered DCM input Clock
            .din(DCM_Locked),       // DCM Locked signal
            .pls(FE_DCM_Locked)     // Falling Edge of DCM_Locked signal
        );
        
always @(posedge Buf_ClkIn or posedge FE_DCM_Locked)
begin
    if(FE_DCM_Locked)
        DCM_Rst <= #1 ~0;
    else
        DCM_Rst <= #1 {1'b0, DCM_Rst[3:1]};
end

//  Synchronize asynchronous external reset, nRst, to internal clock and
//      stretch (extend) by 16 clock cycles after external reset deasserted
//
//  With Spartan 3A(N) FPGA family use synchronous reset for reset operations
//  per synthesis recommendations. so only these FFs will use asynchronous
//  reset, and the remainder of the design will use synchronous reset.

always @(posedge Buf_ClkIn or negedge DCM_Locked)
begin
    if(~DCM_Locked)
        nRst_IFD <= #1 0;
    else
        nRst_IFD <= #1 nRst;
end

always @(posedge Buf_ClkIn or negedge DCM_Locked)
begin
    if(~DCM_Locked)
        xRst <= #1 ~0;
    else
        xRst <= #1 {~nRst_IFD, xRst[2:1]};
end        

assign Rst_M65C02 = ((|{~nRst_IFD, xRst}) | ~DCM_Locked);

always @(posedge Buf_ClkIn or posedge Rst_M65C02)
begin
    if (Rst_M65C02)
        Rst_Dly <= #1 ~0;
    else
        Rst_Dly <= #1 {1'b0, Rst_Dly[3:1]};
end

//  synchronize Rst to DCM/DFS output clock (if DCM Locked)

fedet   FE2 (
            .rst(Rst_M65C02),       
            .clk(Clk),              // System Clock
            .din(|Rst_Dly),         // System Reset Delay
            .pls(FE_Rst_Dly)        // Falling Edge of Rst_Dly
        );

always @(posedge Clk or posedge Rst_M65C02)
begin
    if(Rst_M65C02)
        Rst <= #1 ~0;
    else if(FE_Rst_Dly)
        Rst <= #1  0;
end

always @(posedge Clk or posedge Rst_M65C02)
begin
    if(Rst_M65C02)
        nRstO <= #1 0;
    else
        nRstO <= #1 ~Rst;
end

////////////////////////////////////////////////////////////////////////////////
//
//  Implement Test Pattern Generator
//

reg     [26:0] TstPtrn = ~0;

always @(posedge Clk)
begin
    if(Rst)
        TstPtrn <= #1 ~0;
    else
        TstPtrn <= #1 TstPtrn + 1;
end

assign Phi1O =  TstPtrn[4];       // 58.9824 MHz / 32
assign Phi2O = ~TstPtrn[4];       // 58.9824 MHz / 32

assign nCE   = 4'b1111;           // Disable External Chip Enables
assign DB    =  TstPtrn[ 7: 0];   // Check Data Bus
assign A     =  TstPtrn[23: 8];   // Check Address Bus
assign XA    = ~TstPtrn[23:20];   // Check Extended Address Bus

assign nCS   =  {TstPtrn[25:24], 1'b1};   // External SPI Device Chip Selects
assign SCK   =  TstPtrn[5];       // 58.9824 MHz / 64
assign MOSI  =  TstPtrn[6];

assign nWait = ~TstPtrn[26];
assign TxD_A =  TstPtrn[23];
assign TxD_B = ~TstPtrn[22];

endmodule
