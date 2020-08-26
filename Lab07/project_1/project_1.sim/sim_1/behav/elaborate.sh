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
ExecStep $xv_path/bin/xelab -wto 7d99ca57dff340d1b8eb0f72b1253cd9 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot ImmGeneratorTest_behav xil_defaultlib.ImmGeneratorTest xil_defaultlib.glbl -log elaborate.log
