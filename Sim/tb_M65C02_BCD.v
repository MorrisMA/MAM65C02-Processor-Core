`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Company:         Alpha Beta Technologies, Inc. 
// Engineer:        Michael A. Morris
//
// Create Date:     09:03:19 12/06/2009
// Design Name:     W65C02_BCD
// Module Name:     C:/XProjects/ISE10.1i/MAM6502/tb_W65C02_BCD.v
// Project Name:    MAM6502
// Target Device:   SRAM-based FPGA  
// Tool versions:   Xilinx ISE 10.1i SP3
//
// Verilog Test Fixture created by ISE for module: W65C02_BCD
//
// Dependencies:
// 
// Revision:
// 
//  0.01    09L06   MAM     Initial coding
//
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////////

module tb_W65C02_BCD;

// Inputs

reg D;
reg Sub;

reg [7:0] Q;
reg [7:0] R;
reg Ci;

// Outputs

wire [7:0] Sum;
wire Co;
wire OV;

//  Simulation Variables

integer i, j, k;

reg     [4:0] LSN, MSN;
reg     C3, C7;
reg     [7:0] ALU;
reg     N, V, Z, C;

// Instantiate the Unit Under Test (UUT)

W65C02_BCD  uut (
                .D(D),
                .Sub(Sub), 
                .Q(Q), 
                .R(R), 
                .Ci(Ci), 
                .Co(Co),
                .OV(OV),
                .Sum(Sum)
            );

initial begin
    // Initialize Inputs
    D    = 0;
    Sub  = 0;
    Q    = 0;
    R    = 0;
    Ci   = 0;
    
    i = 0; j = 0; k = 0;
    LSN = 0; MSN = 0; C3 = 0; C7 = 0; ALU = 0; {N,V,Z,C} = 0;

    // Wait 100 ns for global reset to finish
    
    #100;
    
    $display("Begin Adder Tests");

    // BCD Tests
    
    $display("Start Decimal Mode Addition Test");
    
    D = 1; Sub = 0;              // ADC Test

    for(i = 0; i < 100; i = i + 1) begin
        k = (i / 10);
        Q = (k * 16) + (i - (k * 10));
        for(j = 0; j < 100; j = j + 1) begin
            k  = (j / 10);
            R  = (k * 16) + (j - (k * 10));
            Ci = 0;
            #5; 
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Addition Test: Fail");
                $stop;
            end
            #5;
            Ci = 1;
            #5; 
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Addition Test: Fail");
                $stop;
            end
            #5;
        end
    end

    $display("End Decimal Mode Addition Test: Pass");
    
    // SBC Test
    
    $display("Start Decimal Mode Subtraction Test");
    
    D = 1; Sub = 1;         // SBC Test

    for(i = 0; i < 100; i = i + 1) begin
        k = (i / 10);
        Q = (k * 16) + (i - (k * 10));
        for(j = 0; j < 100; j = j + 1) begin
            k  = (j / 10);
            R  = ~((k * 16) + (j - (k * 10)));
            Ci = 1;
            #5; 
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Subtraction Test: Fail");
                $stop;
            end
            #5;
            Ci = 0;
            #5; 
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Subtraction Test: Fail");
                $stop;
            end
            #5;
        end
    end

    $display("End Decimal Mode Subtraction Test: Pass");
    
    // Binary Tests

    $display("Start Binary Mode Addition Test");
    
    D = 0; Sub = 0;         // ADC Test
    
    for(i = 0; i < 256; i = i + 1) begin
        Q = i;
        for(j = 0; j < 256; j = j + 1) begin
            R  = j;
            Ci = 0;
            #5; 
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Binary Mode Addition Test: Fail");
                $stop;
            end
            #5;
            Ci = 1;
            #5; 
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Addition Test: Fail");
                $stop;
            end
            #5;
        end
    end

    $display("End Binary Mode Addition Test: Pass");
    
    //  Binary Mode
    
    $display("Start Binary Mode Subtraction Test");
    
    D = 0; Sub = 1;         // SBC Test

    for(i = 0; i < 256; i = i + 1) begin
        Q = i;
        for(j = 0; j < 256; j = j + 1) begin
            R  = ~j;
            Ci = 1;
            #5; 
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Binary Mode Subtraction Test: Fail");
                $stop;
            end
            #5;
            Ci = 0;
            #5; 
            if((Sum != ALU) || (Co != C) || (OV != V)) begin
                $display("Error: Incorrect Result");
                $display("\tQ: 0x%2h, R: 0x%2h, Ci: %b", Q, R, Ci);
                $display("\t\t{NVZC, ALU}: %b%b%b%b, 0x%2h", N, V, Z, C, ALU);
                $display("\t\t{-V-C, Sum}: -%b-%b, 0x%2h", OV, Co, Sum);
                $display("End Decimal Mode Subtraction Test: Fail");
                $stop;
            end
            #5;
        end
    end
    
    $display("End Binary Mode Subtraction Test: Pass");
    
    $display("End Adder Tests: Pass");

    D = 0; Sub = 0;        // End of Test
    
end

always @(*)
begin
    if(D) begin
        if(Sub) begin
            LSN[4:0] <= {1'b0, Q[3:0]} + {1'b0, R[3:0]} + {4'b0, Ci};
            C3       <= LSN[4] & ~(LSN[3] & (LSN[2] | LSN[1]));
            ALU[3:0] <= ((C3) ? (LSN[3:0] + 0) : (LSN[3:0] + 10));

            MSN[4:0] <= {1'b0, Q[7:4]} + {1'b0, R[7:4]} + {4'b0, C3};
            C7       <= MSN[4] & ~(MSN[3] & (MSN[2] | MSN[1]));
            ALU[7:4] <= ((C7) ? (MSN[3:0] + 0) : (MSN[3:0] + 10));        
        end else begin
            LSN[4:0] <= {1'b0, Q[3:0]} + {1'b0, R[3:0]} + {4'b0, Ci};
            C3       <= LSN[4] | (LSN[3] & (LSN[2] | LSN[1]));
            ALU[3:0] <= ((C3) ? (LSN[3:0] + 6) : (LSN[3:0] + 0));

            MSN[4:0] <= {1'b0, Q[7:4]} + {1'b0, R[7:4]} + {4'b0, C3};
            C7       <= MSN[4] | (MSN[3] & (MSN[2] | MSN[1]));
            ALU[7:4] <= ((C7) ? (MSN[3:0] + 6) : (MSN[3:0] + 0));
        end
        
        N <= 0; V <= ((Sub) ? ~C7 : C7); Z <= ~|ALU; C <=  C7;
    end else begin
        LSN[4:0] <= {1'b0, Q[3:0]} + {1'b0, R[3:0]} + {4'b0, Ci};
        C3       <= LSN[4];
        ALU[3:0] <= LSN[3:0];

        MSN[3:0] <= {1'b0, Q[6:4]} + {1'b0, R[6:4]} + {4'b0, C3};
        MSN[4]   <= (MSN[3] & (Q[7] ^ R[7]) | (Q[7] & R[7]));
        C7       <= MSN[4];
        ALU[7:4] <= {Q[7] ^ R[7] ^ MSN[3], MSN[2:0]};        

        N <= ALU[7]; V <= (MSN[4] ^ MSN[3]); Z <= ~|ALU; C <=  C7;
    end
end
      
endmodule

