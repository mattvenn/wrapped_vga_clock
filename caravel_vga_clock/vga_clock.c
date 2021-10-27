/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

#include "verilog/dv/caravel/defs.h"

/*
	IO Test:
		- Configures MPRJ lower 8-IO pins as outputs
		- Observes counter value through the MPRJ lower 8 IO pins (in the testbench)
*/

void main()
{
	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |

	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |

	*/

    /*
    vga_clock vga_clock(
        .clk(wb_clk_i),
        .reset_n(la1_data_in[0]),
        .adj_hrs(io_in[8]),
        .adj_min(io_in[9]),
        .adj_sec(io_in[10]),
        .hsync(buf_io_out[11]),
        .vsync(buf_io_out[12]),
        .rrggbb(buf_io_out[18:13])
        );
    */

    // 3 inputs for buttons
	reg_mprj_io_8  =   GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_9  =   GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_10 =   GPIO_MODE_USER_STD_INPUT_NOPULL;

    // 8 outputs for 6bit colour and hsync/vsync
	reg_mprj_io_11 =   GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_12 =   GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_13 =   GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_14 =   GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_15 =   GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_16 =   GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_17 =   GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_18 =   GPIO_MODE_USER_STD_OUTPUT;

    /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    // activate the project by setting the correct bit of 1st bank of LA - depends on the project ID
    reg_la0_iena = 0; // input enable off
    reg_la0_oenb = 0; // output enable on
    reg_la0_data = 1 << 2;

    // reset the design
    reg_la1_iena = 0;
    reg_la1_oenb = 0;
    reg_la1_data = 1;
    reg_la1_data = 0;
}

