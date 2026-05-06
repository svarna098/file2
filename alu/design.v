//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.05.2026 12:53:28
// Design Name: 
// Module Name: design_alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Code your design here
//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.05.2026 10:51:13
// Design Name: 
// Module Name: alu_design
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Eight_bit_ALU_rtl_design #(parameter width=4 ,cmd_width=4,out_width=2*width)
  (
   
   input [(width-1):0] OPA,OPB,
   input CLK,RST,CE,MODE,CIN,
   input [1:0] inp_valid,
   input [(cmd_width-1):0] CMD,
  output reg [(out_width-1):0] RES,
  output reg COUT = 1'b0,
  output reg OFLOW = 1'b0,
  output reg G = 1'b0,
  output reg E = 1'b0,
  output reg L = 1'b0,
  output reg ERR = 1'b0);
  //Temporary register declaration
  reg [(width-1):0] OPA_1, OPB_1;
  reg [(out_width-1):0]temp;
  reg signed [(width-1):0] a;
  reg signed  [(width-1):0] b;
  reg signed[(out_width-1):0] out;
  integer count=1;
  integer count1=1;
  always@(posedge CLK or posedge RST)
          begin
  if(CE)                   // If clock enable is active high then check for other control signals
          begin
  if(RST)                // If reset is active high all output signals are equal to zero
          begin
          RES<={out_width{1'b0}};
          COUT<=1'b0;
         OFLOW<=1'b0;
         G<=1'b0;
          E<=1'b0;
          L<=1'b0;
          ERR<=1'b0;
          end
 
  else if(MODE)          // Reset signal is active low. If MODE signal is high, then this is an Arithmetic Operation
          begin
          RES<={out_width{1'b0}};
         COUT<=1'b0;
         OFLOW<=1'b0;
          G<=1'b0;
          E<=1'b0;
          L<=1'b0;
          ERR<=1'b0;
  case(CMD)             // CMD is the binary code value of the Arithmetic Operation
         4'b0000:             // CMD = 0000: ADD 
   begin
          if(inp_valid==2'b11)
          begin
         temp=OPA+OPB;
         RES<=temp;
          COUT<=RES[width]?1:0; end
          else
          ERR<=1'b1;
          end
          4'b0001:             // CMD = 0001: SUB
          begin
          if(inp_valid==2'b11)
          begin
         temp=OPA-OPB;
        RES<=temp;
          OFLOW<=(OPA<OPB)?1:0;   end
          else
          ERR<=1'b1;
          end
          4'b0010:             // CMD = 0010: ADD_CIN
          begin
          if(inp_valid==2'b11)
          begin
          temp=OPA+OPB+CIN;
          RES<=temp;
          COUT<=RES[width]?1:0;
          end
          else
          ERR<=1'b1;
         end
         4'b0011:             // CMD = 0011: SUB_CIN. Here we set the overflow flag
         begin
         if(inp_valid==2'b11)
        begin
         temp=OPA-OPB-CIN;
        RES<=temp;
COUT<=RES[width]?1:0;
          end
          else
          ERR<=1'b1;
         end
         4'b0100:
         begin
         if(inp_valid==2'b01 ||inp_valid==2'b11)
         begin
         temp=OPA+1;
        RES<=temp;
         end
         else
         ERR<=1'b1;
         end    // CMD = 0100: INC_A
          4'b0101:
           begin
          if(inp_valid==2'b01 ||inp_valid ==2'b11)
          begin
          temp=OPA-1;    // CMD = 0101: DEC_A
        RES<=temp;
          end
         else
         ERR<=1'b1;
         end
         4'b0110:
         begin
         if(inp_valid==2'b10 ||inp_valid==2'b11)
         begin
         temp=OPB+1;    // CMD = 0110: INC_B
        RES<=temp; end
         else
         ERR<=1'b1;
         end
         4'b0111:
         begin
         if(inp_valid==2'b10 ||inp_valid==2'b11) begin
         temp=OPB-1;    // CMD = 0111: DEC_B
        RES<=temp;  end
         else
         ERR<=1'b1;
         end
         4'b1000:              // CMD = 1000: CMP
         begin
         RES<={out_width{1'b0}};
         if(inp_valid==2'b11)
         begin
        
 
 if(OPA==OPB)
         begin
         E<=1'b1;
         G<=1'b0;
         L<=1'b0;
         end
 else if(OPA>OPB)
         begin
         E<=1'b0;
         G<=1'b1;
         L<=1'b0;
         end
         else
         begin
         E<=1'b0;
         G<=1'b0;
         L<=1'b1;
         end
         end
         else
         ERR<=1'b1;
        
         end
       4'b1001:
begin
    if(inp_valid == 2'b11)
    begin
    if(count==2) begin
        temp = (OPA + 1'b1) * (OPB + 1'b1);
        RES={width{1'bx}}; end
    if(count==3) begin
        RES  <= temp;
        ERR  <= 1'b0;
        //count<=1;
        end
    end
    else
    begin
        RES  <= {out_width{1'b0}};
        ERR  <= 1'b1;
    end
end
       4'b1010:
begin
    if(inp_valid == 2'b11)
    begin
    if(count1==2) begin
        temp <= (OPA <<1)*OPB;
           RES={width{1'bx}}; end
    if(count1==3) begin
        RES  <= temp;
        ERR  <= 1'b0;
       // count<=1;
        end
    end
    else
    begin
        RES  <= {out_width{1'b0}};
        ERR  <= 1'b1;
    end
end
 4'b1011 :
         begin
         if(inp_valid==2'b11)
         begin
         a=OPA;
         b=OPB;
         out={a+b};
        RES<=out;
         if(a[width-1]==b[width-1] && RES[width-1]!=a[width-1])
         OFLOW<=1'b1;
         else
         OFLOW<=1'b0;
         end
         else
         ERR<=1'b1;
         if(a==b)
         begin
         E<=1'b1;
         G<=1'b0;
         L<='b0;
         end
 else if(a>b)
         begin
         E<=1'b0;
         G<=1'b1;
         L<=1'b0;
         end
         else
         begin
 E<=1'b0;
         G<=1'b0;
         L<=1'b1;
         end
        end
 
 4'b1100: begin
          if(inp_valid==2'b11)
         begin
         a=OPA;
         b=OPB;
         out={a-b};
        RES<=out;
         if(a[width-1]!=b[width-1] && RES[width-1]!=a[width-1])
         OFLOW<=1'b1;
         else
         OFLOW<=1'b0;
        end
         else
         ERR<=1'b1;
         if(a==b)
         begin
         E<=1'b1;
         G<=1'b0;
         L<='b0;
         end
 else if(a>b)
         begin
         E<=1'b0;
         G<=1'b1;
         L<=1'b0;
         end
         else
         begin
         E<=1'b0;
         G<=1'b0;
         L<=1'b1;
         end
        end
  default:   // For any other case send high impedence value
         begin
         RES<={out_width{1'b0}};
         COUT<=1'b0;
         OFLOW<=1'b0;
         G<=1'b0;
         E<=1'b0;
         L<=1'b0;
         ERR<=1'b0;
         end
         endcase
         end
 
         else
                    // MODE signal is low, then this is a Logical Operation
         begin
        RES<={out_width{1'b0}};
         COUT<=1'b0;
         OFLOW<=1'b0;
         G<=1'b0;
         E<=1'b0;
         L<=1'b0;
         ERR<=1'b0;
 
 case(CMD)
  // CMD is the binary code value of the Logical Operation
 
 4'b0000:begin
 if(inp_valid==2'b11) begin
 temp={1'b0,OPA&OPB};
        RES<=temp; end
 else
 ERR<=1'b1;     // CMD = 0000: AND
 end
 4'b0001:begin
  if(inp_valid==2'b11) begin
  temp={1'b0,~(OPA&OPB)};
        RES<=temp; end
  else
  ERR<=1'b1;
  end  // CMD = 0001: NAND
 4'b0010:begin
  if(inp_valid==2'b11) begin
temp={1'b0,OPA|OPB};     // CMD = 0010: OR
        RES<=temp; end
  else
  ERR<=1'b1;
  end
 4'b0011:begin
  if(inp_valid==2'b11) begin
  temp={1'b0,~(OPA|OPB)};  // CMD = 0011: NOR
        RES<=temp; end
  else
  ERR<=1'b1;
  end
 4'b0100:begin
  if(inp_valid==2'b11) begin
  temp={1'b0,OPA^OPB};     // CMD = 0100: XOR
        RES<=temp;  end
  else
  ERR<=1'b1;
  end
 4'b0101:begin
  if(inp_valid==2'b11) begin
  temp={1'b0,~(OPA^OPB)};  // CMD = 0101: XNOR
        RES<=temp;  end 
  else
  ERR<=1'b1;
  end
 4'b0110:begin
  if(inp_valid==2'b01 ||inp_valid==2'b11)  begin
  temp={1'b0,~OPA};        // CMD = 0110: NOT_A
        RES<=temp; end 
  else
  ERR<=1'b1;
  end
 4'b1000:begin
 if(inp_valid==2'b01 ||inp_valid==2'b11) begin

  temp={1'b0,OPA>>1};      // CMD = 1000: SHR1_A
        RES<=temp; end 
  else
  ERR<=1'b1;
  end
 
 4'b1001:begin
  if(inp_valid==2'b01 ||inp_valid==2'b11) begin
  temp={1'b0,OPA<<1};      // CMD = 1001: SHL1_A
        RES<=temp;  end
        
  else 
  ERR<=1'b1;
  end
 
 
 4'b0111:begin
  if(inp_valid==2'b10 ||inp_valid==2'b11) begin
  temp={1'b0,~OPB};        // CMD = 0111: NOT_B
        RES<=temp;  end
  else
  ERR<=1'b1;
  end
 
 4'b1010:begin
 if(inp_valid==2'b10 ||inp_valid==2'b11) begin
  temp={1'b0,OPB>>1};      // CMD = 1010: SHR1_B
        RES<=temp; end
  else
  ERR<=1'b1;
  end
 4'b1011:begin
  if(inp_valid==2'b10 ||inp_valid==2'b11) begin
  temp={1'b0,OPB<<1};      // CMD = 1011: SHL1_B
        RES<=temp; end
  else
  ERR<=1'b1;
  end
 
 
 /*

 4'b1100:                        // CMD = 1100: ROL_A_B
         begin
 if(OPB[0])
         OPA_1 = {OPA[(width-2):0], OPA[(width-1)]};
 else
 OPA_1 = OPA;
 
 if(OPB[1])
         OPB_1 =  {OPA_1[5:0], OPA_1[(width-1):(width-2)]};
 else
 OPB_1= OPA_1;
 
 if(OPB[2])
         RES =  {OPB_1[3:0], OPB_1[(width-1):(width-4)]} ;
         else
         RES = OPB_1;
 
 if(OPB[4] | OPB[5] | OPB[6] | OPB[7])
         ERR=1'b1;
         end
         */
   /*4'b1100:      begin
   OPB_1=width-(OPB%width);
                     if(inp_valid==2'b11)     // CMD = 1100: ROL_A_B
 begin
         case(OPB)
         
          3'b0:RES={{width{1'b0}},OPA};
          3'b001:RES={{width{1'b0}},OPA[(width-2):0],OPA[width-1]};
          3'b010:RES={{width{1'b0}},OPA[(width-3):0],OPA[(width-1):(width-2)]};
          3'b011:RES={{width{1'b0}},OPA[(width-4):0],OPA[(width-1):(width-3)]};
         // {{width{1'b0}}, 3'b100}:RES={{width{1'b0}},OPA[((width-(OPB%width))-1):0],OPA[(width-1):(width-(OPB%width))]};
          3'b100: begin
                                    if ((OPB_1) == 0)
                                    RES = {{width{1'b0}}, OPA};
                                    else  
                                    
                                     RES = {{width{1'b0}},OPA[((OPB_1)-1):0],OPA[(width-1):(OPB_1)]};
                                    
                                   end
           3'b101:RES={{width{1'b0}},OPA[((OPB_1)-1):0],OPA[(width-1):(OPB_1)]};
           3'b110:RES={{width{1'b0}},OPA[((OPB_1)-1):0],OPA[(width-1):(OPB_1)]};
           3'b111:RES={{width{1'b0}},OPA[((OPB_1))-1):0],OPA[(width-1):(OPB_1)]};      
          endcase
          
          if((OPB[width-1:4])!=0)
          ERR=1'b1;
          else
          ERR=1'b0;
          end
          else
          ERR=1'b1;
          end
        
           */
    4'b1100:      begin
 
    OPB_1 <= OPB % width;
    if (inp_valid == 2'b11) begin   // CMD = 1100: ROL_A_B
        case (OPB[2:0])
            3'b000: begin
                    temp = {{width{1'b0}}, OPA};
                    RES <= temp;
            end
            3'b001: begin
                    temp = {{width{1'b0}}, {OPA[width-2:0], OPA[width-1]}};
                    RES <= temp;
            end
            3'b010: begin
                    if(OPB_1 == 0)
                        temp = {{width{1'b0}}, OPA};
                    else
                        temp = {{width{1'b0}}, ((OPA << OPB_1) | (OPA >> (width - OPB_1)))};
                    RES <= temp;
            end
            3'b011: begin
                    temp = {{width{1'b0}}, ((OPA << OPB_1) | (OPA >> (width - OPB_1)))};
                    RES <= temp;
            end
            default: begin
                    if (OPB_1 == 0)
                        temp = {{width{1'b0}}, OPA};
                    else
                        temp = {{width{1'b0}}, ((OPA << OPB_1) | (OPA >> (width - OPB_1)))};
                    RES <= temp;
            end
        endcase
 
      if (width > 4)
        begin
        if( OPB[width-1:4] != 0)
            ERR <= 1'b1;
        else
            ERR <= 1'b0;
    end
    else begin
        ERR <= 1'b1;
    end
    end
end
 
4'b1101: begin                   // CMD = 1101: ROR_A_B 
    OPB_1 <= OPB % width;
    if (inp_valid == 2'b11) begin
        case (OPB[2:0])
            3'b000: begin
                    temp = {{width{1'b0}}, OPA};
                    RES <= temp;
            end
            3'b001: begin
                    temp = {{width{1'b0}}, {OPA[0], OPA[width-1:1]}};
                    RES <= temp;
            end
            3'b010: begin
                    if(OPB_1 == 0)
                        temp = {{width{1'b0}}, OPA};
                    else
                        temp = {{width{1'b0}}, ((OPA >> OPB_1) | (OPA << (width - OPB_1)))};
                    RES <= temp;
            end
            3'b011: begin
                    temp= {{width{1'b0}}, ((OPA >> OPB_1) | (OPA << (width - OPB_1)))};
                    RES <= temp;
            end
            default: begin
                    if (OPB_1 == 0)
                        temp = {{width{1'b0}}, OPA};
                    else
                        temp = {{width{1'b0}}, ((OPA >> OPB_1) | (OPA << (width - OPB_1)))};
                    RES <= temp;
            end
        endcase

 
      if (width > 4) begin
        if( OPB[width-1:4] != 0)
            ERR <= 1'b1;
        else
            ERR <= 1'b0;

    end
    else begin
        ERR <= 1'b1;
    end
    end
end
 
         default:    // For any other case send high impedence value
         begin
         RES<={out_width{1'b0}};
         COUT<=1'b0;
        OFLOW<=1'b0;
        G<=1'b0;
         E<=1'b0;
         L<=1'b0;
         ERR<=1'b0;
         end
         endcase
         end
      end
      end
 
always@(posedge CLK or posedge RST)
 begin
 if(RST)
        count<=1;
        else
         if(CMD==4'b1001 )
        // count<=1;
         begin
         if(count<=3)
         begin
         count<=count+1;
         end
        
         else
         count<=1;
      end
  end
always@(posedge CLK or posedge RST)
 begin
 if(RST)
        count1<=1;
        else
         if(CMD==4'b1010)
        // count<=1;
         begin
         if(count1<=3)
         begin
         count1<=count1+1;
         end
         else
         count1<=1;
      end
  end

        endmodule
