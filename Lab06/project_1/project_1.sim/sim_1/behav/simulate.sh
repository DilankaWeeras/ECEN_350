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
ExecStep $xv_path/bin/xsim Mux21Test_v_behav -key {Behavioral:sim_1:Functional:Mux21Test_v} -tclbatch Mux21Test_v.tcl -log simulate.log
