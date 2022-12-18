
module ctrl_unit (
    // ngo vao
    input logic [31:0] inst_i,
    input logic br_less_i,
    br_equal_i,
    // ngo ra
    output logic [3:0] ls_op_o,
    output logic [2:0] imm_sel_o,
    output logic br_sel_o,
    output logic br_unsigned_o,
    output logic rd_wren_o,
    output logic op_a_sel_o,
    op_b_sel_o,
    output logic [3:0] alu_op_o,
    output logic mem_wren_o,
    output logic [1:0] wb_sel_o
);

  logic br_unsignedB, br_selB;
  /* verilator lint_off UNUSED */
  logic not_used_bit;
  logic [6:0] opcode_tmp;
  /* verilator lint_on UNUSED */
  assign opcode_tmp = inst_i[6:0];
  always_comb begin
    case (opcode_tmp)
      // TYPE_R	----------------------------------------------------------------------------------
      7'b0110011: begin
        case (inst_i[14:12])
          3'b000:
          alu_op_o = (inst_i[30])? 4'h1 : 4'h0 ; 	// inst_i[30] = 1 --> sub ; inst_i[30] = 0 --> add
          3'b001: alu_op_o = 4'h7;  // sll 
          3'b010: alu_op_o = 4'h2;  // slt  	
          3'b011: alu_op_o = 4'h3;  //sltu  	     
          3'b100: alu_op_o = 4'h4;  // xor  	   
          3'b101:
          alu_op_o = (inst_i[30]) ? 4'h9 : 4'h8;  // inst_i[30]=1 --->sra; inst_i[30]=0 --> srl 
          3'b110: alu_op_o = 4'h5;  //or  	    
          3'b111: alu_op_o = 4'h6;  //and  	   
          default: alu_op_o = 4'h0;
        endcase

        imm_sel_o     = 3'b101;  // don't care 
        rd_wren_o     = 1'b1;  // write to the regfile
        op_a_sel_o    = 1'b0;  // choose rs1_data
        op_b_sel_o    = 1'b0;  // choose rs2_data
        mem_wren_o    = 1'b0;  //don't write LSU
        wb_sel_o      = 2'b00;  // choose alu_data
        br_unsigned_o = (alu_op_o == 4'h3) ? 1'b1 : 1'b0;
        br_sel_o      = 1'b0;  //pc+4
        ls_op_o       = 4'b0000;

      end

      // TYPE_I: addi,..... ----------------------------------------------------------------------
      7'b0010011: begin
        case (inst_i[14:12])
          3'b000: alu_op_o = 4'h0;  // addi
          3'b001: alu_op_o = 4'h7;  // slli 
          3'b010: alu_op_o = 4'h2;  // slti	
          3'b011: alu_op_o = 4'h3;  //sltiu	     
          3'b100: alu_op_o = 4'h4;  // xori	   
          3'b101:
          alu_op_o = (inst_i[30]) ? 4'h9 : 4'h8;  // inst_i[30]=1 --->srai; inst_i[30]=0 --> srli
          3'b110: alu_op_o = 4'h5;  //ori	    
          3'b111: alu_op_o = 4'h6;  //andi	   
          default: alu_op_o = 4'h0;
        endcase

        imm_sel_o     = 3'b000;  // choose imm type_I
        rd_wren_o     = 1'b1;  // write to the regfile
        op_a_sel_o    = 1'b0;  // choose rs1_data
        op_b_sel_o    = 1'b1;  // choose imm
        mem_wren_o    = 1'b0;  // don't write LSU
        wb_sel_o      = 2'b00;  // choose alu_data
        br_unsigned_o = (alu_op_o == 4'h3) ? 1 : 0;
        br_sel_o      = 1'b0;  //pc+4
        ls_op_o       = 4'b0000;
      end

      // l : lw,lh,lb,lbu,lhu -----------------------------------------------------------------
      7'b0000011: begin
        case (inst_i[14:12])
          3'b000:  ls_op_o = 4'b0100;  // lb
          3'b001:  ls_op_o = 4'b0101;  // lh
          3'b010:  ls_op_o = 4'b0110;  // lw
          3'b100:  ls_op_o = 4'b0111;  // lbu
          3'b101:  ls_op_o = 4'b1000;  // lhu
          default: ls_op_o = 4'b0000;
        endcase

        imm_sel_o     = 3'b000;  // have immediate type_I
        rd_wren_o     = 1'b1;  //  read data into regfile
        op_a_sel_o    = 1'b0;  // chọn rs1_data
        op_b_sel_o    = 1'b1;  // chọn imm
        alu_op_o      = 4'h0;  // add
        mem_wren_o    = 1'b0;  // don't write to the LSU	
        wb_sel_o      = 2'b01;  // choose ld_data
        br_sel_o      = 1'b0;  // pc+4  
        br_unsigned_o = 1'b0;  // don't care
      end

      // S : sw ,sh,sb -------------------------------------------------------------------------
      7'b0100011: begin
        case (inst_i[14:12])
          3'b000:  ls_op_o = 4'b0001;  // sb
          3'b001:  ls_op_o = 4'b0010;  // sh
          3'b010:  ls_op_o = 4'b0011;  // sw
          default: ls_op_o = 4'b0000;
        endcase

        br_sel_o      = 1'b0;  // pc+4 
        imm_sel_o     = 3'b001;  // have immediate type_S
        rd_wren_o     = 1'b0;  // don't read data into regfile
        br_unsigned_o = 1'b0;  // don't care
        op_a_sel_o    = 1'b0;  // chọn rs1_data
        op_b_sel_o    = 1'b1;  // chọn imm
        alu_op_o      = 4'h0;  // add
        mem_wren_o    = 1'b1;  // write to the LSU	
        wb_sel_o      = 2'b01;  // don't care 
      end

      // Type_B: beq.bne , blt,bltu,bge,bgeu ----------------------------------------------------
      7'b1100011: begin
        op_a_sel_o    = 1'b1;  // choose pc
        op_b_sel_o    = 1'b1;  // choose imm
        alu_op_o      = 4'h0;  // choose add
        mem_wren_o    = 1'b0;  // don't write to the lsu
        rd_wren_o     = 1'b0;  // don't enable regfile
        imm_sel_o     = 3'b010;  // type B
        wb_sel_o      = 2'b01;  // don't care
        br_unsigned_o = br_unsignedB;
        br_sel_o      = br_selB;
        ls_op_o       = 4'b0000;
      end

      // type_U auipc --------------------------------------------------------------------------
      7'b0010111: begin
        br_sel_o      = 0;  // pc+4 
        imm_sel_o     = 3'b011;  // have immediate type_U
        rd_wren_o     = 1'b1;  //  read data into regfile
        br_unsigned_o = 1'b0;  // don't care
        op_a_sel_o    = 1'b1;  // chọn pc
        op_b_sel_o    = 1'b1;  // chọn imm
        alu_op_o      = 4'h0;  // add
        mem_wren_o    = 1'b0;  //don't write to the LSU	
        wb_sel_o      = 2'b00;  //choose alu_data 
        ls_op_o       = 4'b0000;
      end
      // type_J : JAL--------------------------------------------------------------------------
      7'b1101111: begin
        br_sel_o      = 1'b1;  // alu_data 
        imm_sel_o     = 3'b100;  // have immediate type_J
        rd_wren_o     = 1'b1;  //  read data into regfile
        br_unsigned_o = 1'b0;  // don't care
        op_a_sel_o    = 1'b1;  // chọn pc
        op_b_sel_o    = 1'b1;  // chọn imm
        alu_op_o      = 4'h0;  // add
        mem_wren_o    = 1'b0;  //don't write to the LSU	
        wb_sel_o      = 2'b10;  //choose pc_four 
        ls_op_o       = 4'b0000;
      end
      // JALR ------------------------------------------------------------------------------------
      7'b1100111: begin
        br_sel_o      = 1'b1;  // alu_data 
        imm_sel_o     = 3'b000;  // have immediate type_I
        rd_wren_o     = 1'b1;  //  read data into regfile
        br_unsigned_o = 1'b0;  // don't care	
        op_a_sel_o    = 1'b0;  // chọn rs1_data
        op_b_sel_o    = 1'b1;  // chọn imm
        alu_op_o      = 4'h0;  // add
        mem_wren_o    = 1'b0;  //don't write to the LSU	
        wb_sel_o      = 2'b10;  //choose pc_four
        ls_op_o       = 4'b0000;
      end
      // type_U lui	------------------------------------------------------------------------------------	
      7'b0110111: begin
        br_sel_o      = 0;  // pc+4 
        imm_sel_o     = 3'b011;  // have immediate type_U
        rd_wren_o     = 1'b1;  //  read data into regfile
        br_unsigned_o = 1'b0;  // don't care
        op_a_sel_o    = 1'b0;  // chọn pc
        op_b_sel_o    = 1'b1;  // chọn imm
        alu_op_o      = 4'hA;  // lui
        mem_wren_o    = 1'b0;  //don't write to the LSU	
        wb_sel_o      = 2'b00;  //choose alu_data 
        ls_op_o       = 4'b0000;
      end
      //------------------------------------------------------------------------------------
      default: begin
        br_sel_o      = 1'b0;
        imm_sel_o     = 3'b101;
        rd_wren_o     = 1'b0;
        br_unsigned_o = 1'b0;
        op_a_sel_o    = 1'b0;
        op_b_sel_o    = 1'b0;
        alu_op_o      = 4'h0;
        mem_wren_o    = 1'b0;
        wb_sel_o      = 2'b00;
        ls_op_o       = 4'd0;
      end
    endcase
  end

  //------------------------------------------------------------------------------------

  assign  br_unsignedB  =  ((inst_i  [14:12]  ==   3'b111)  ?  1'b1  :  ((inst_i  [14:12]  ==   3'b110)  ?  1'b1  :   1'b0));
  assign  br_selB  =  
    ((inst_i  [14:12]  ==  3'b000)  ?  (br_equal_i  ?  1'b1  :  1'b0)  : ((inst_i  [14:12]  ==  3'b100)  ? 
	(br_less_i  ?  1'b1  :  1'b0)  :  ((inst_i  [14:12]  ==  3'b110)  ?  (br_less_i  ?  1'b1  :  1'b0)  : 
	((inst_i  [14:12]  ==  3'b001)  ?  (br_equal_i  ?  1'b0  :  1'b1)  :  (br_less_i  ?  1'b0  :  1'b1)))));
  assign not_used_bit = (|inst_i[31]) | (|inst_i[29:15]) | (|inst_i[11:7]);

endmodule









