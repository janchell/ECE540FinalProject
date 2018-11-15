`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2018 03:30:46 PM
// Design Name: 
// Module Name: mhp_axdl362
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


module mhp_axdl362(
    input clk_50, clk_SPI, reset, MISO,
    output reg MOSI, n_CS,
    output reg [11:0] x_acc_reg, y_acc_reg, z_acc_reg,
    output reg [2:0] counter,
    output reg [2:0] SPI_state
    );
    
    parameter
              //address defines
              CON_REG = 8'h2D,
              X_L_REG = 8'h0E,
              X_H_REG = 8'h0F,
              Y_L_REG = 8'h10,
              Y_H_REG = 8'h11,
              Z_L_REG = 8'h12,
              Z_H_REG = 8'h13,
              //instruction defines
              REGISTER_READ = 8'h0B,
              REGISTER_WRITE = 8'h0A,
              
              //SPI States
              BEGIN = 3'd0,
              INSTRUCTION = 3'd1,
              ADDRESS = 3'd2,
              DATATRANSITION = 3'd3,
              DATAIN = 3'd4,
              DATAOUT = 3'd5,
              END = 3'd6,
              END1 = 3'd7, //extra state after end of read/write cycle to hold CS active
              
              //read/write
              WRITE = 1'b1,
              READ = 1'b0;
              
              
    reg [11:0] x_acc_reg_temp, y_acc_reg_temp, z_acc_reg_temp; //temp regs while reading
    reg rw, roundDone;
    reg [7:0] address; //command for which register to read
    reg [7:0] accel_data; //save the incoming accel SPI data here
    //reg [2:0] counter; //SPI counter
    reg [7:0] instruction_reg;
    
    always@(posedge clk_SPI) begin
        if(!reset) begin
            rw <= WRITE;
            x_acc_reg_temp <= 0;
            y_acc_reg_temp <= 0;
            z_acc_reg_temp <= 0;
            n_CS <= 1;
            SPI_state <= BEGIN;
            instruction_reg <= REGISTER_WRITE;
            address <= CON_REG;
            roundDone <= 0;
            counter <= 7; //counts down to 0
            MOSI <= 0;
            //reset data for initial control write (measurement mode)
            accel_data[7:2] <= 0;
            accel_data[1:0] <= 2'b10; //measurement mode
        end
        else begin
        	if(SPI_state == BEGIN) begin
        	   SPI_state <= INSTRUCTION;
        	   n_CS <= 0;
        	end
        	else if(SPI_state == END) begin
        	   SPI_state <= BEGIN;
        	   n_CS <= 1;
        	   accel_data <= 0;
        	   case(address) //determine next address and if next step is read/write
                   X_L_REG : begin
                       x_acc_reg_temp[7:0] <= accel_data;
                       address <=  X_H_REG;
                   end
                   X_H_REG : begin
                       x_acc_reg_temp[11:8] <= accel_data[3:0];
                       address <=  Y_L_REG;
                   end
                   Y_L_REG : begin
                       y_acc_reg_temp[7:0] <= accel_data;
                       address <=  Y_H_REG;
                   end
                   Y_H_REG : begin
                       y_acc_reg_temp[11:8] <= accel_data[3:0];
                       address <=  Z_L_REG;
                   end
                   Z_L_REG : begin
                       z_acc_reg_temp[7:0] <= accel_data;
                       address <=  Z_H_REG;
                   end
                   Z_H_REG : begin
                       z_acc_reg_temp[11:8] <= accel_data[3:0];
                       roundDone <= 1;
                       address <=  X_L_REG;
                   end
                   CON_REG : begin //done with intial write to control, start measurement reads
                       address <= X_L_REG;
                       rw <= 0;
                       instruction_reg <= REGISTER_READ;
                   end
               endcase
        	end
        	else if(SPI_state == DATAIN) begin //posedge triggers, read data at posedges of clk when valid
        	   accel_data[counter] <= MISO;
        	   if(counter == 0) begin
        	       counter <= 7;
        	       SPI_state <= END1;
        	   end
        	   else counter <= counter - 1;
        	end
        end
     end
     
     always@(negedge clk_SPI) begin //start negedge Logic (instruction and address bytes)
        if(SPI_state == INSTRUCTION || SPI_state == ADDRESS || SPI_state == DATAOUT) begin
            if(SPI_state == INSTRUCTION) MOSI <= instruction_reg[counter];
            else if(SPI_state == ADDRESS) MOSI <= address[counter];
            else MOSI <= accel_data[counter];
            
            if(counter == 0) begin
               counter <= 7;
               if(SPI_state == INSTRUCTION) SPI_state <= ADDRESS;
               else if(SPI_state == ADDRESS && rw) SPI_state <= DATAOUT; //this is a write, don't need to wait an extra clk edge, immediately stwriting
               else if(SPI_state == DATAOUT) SPI_state <= END1; //hold cs for at least 1 clk cycle
               else SPI_state <= DATATRANSITION; //read, wait another neg edge before recieving data, data comes in starting in 2 clock edges
            end
            else counter <= counter - 1;
        end
        else if(SPI_state == DATATRANSITION) SPI_state <= DATAIN;
        else if(SPI_state == END1) SPI_state <= END;
     end
    
    always@(posedge clk_50) begin
        if(!reset) begin
            x_acc_reg <= 0;
            y_acc_reg <= 0;
            z_acc_reg <= 0;
        end
        else begin
            if(roundDone) begin //x,y,z have all been read and stored in temp regs, update accel regs (sync)
               roundDone <= 0;
               x_acc_reg <=  x_acc_reg_temp;
               y_acc_reg <=  y_acc_reg_temp;
               z_acc_reg <=  z_acc_reg_temp;
            end
        end
    end
    
endmodule
