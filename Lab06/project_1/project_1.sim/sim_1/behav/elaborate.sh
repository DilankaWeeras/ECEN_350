#!/bin/sh -f
xv_path="/opt/coe/Xilinx/Vivado/2015.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 231d849d141a4f70af83e7716d18f8e0 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot Mux21Test_v_behav xil_defaultlib.Mux21Test_v xil_defaultlib.glbl -log elaborate.log
