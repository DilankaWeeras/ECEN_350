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
ExecStep $xv_path/bin/xelab -wto bab04a6225584959ad8fa27937e91c1f -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot SingleCycleProcTest_v_behav xil_defaultlib.SingleCycleProcTest_v xil_defaultlib.glbl -log elaborate.log
