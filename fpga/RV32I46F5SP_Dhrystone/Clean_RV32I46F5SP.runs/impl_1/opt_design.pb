
P
Command: %s
53*	vivadotcl2
opt_design -directive ExploreZ4-113h px� 
R
$Directive used for opt_design is: %s67*	vivadotcl2	
ExploreZ4-136h px� 
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
Implementation2

xc7a200tZ17-347h px� 
p
0Got license for feature '%s' and/or device '%s'
310*common2
Implementation2

xc7a200tZ17-349h px� 
\
,Running DRC as a precondition to command %s
22*	vivadotcl2

opt_designZ4-22h px� 
@

Starting %s Task
103*constraints2
DRCZ18-103h px� 
>
Running DRC with %s threads
24*drc2
2Z23-27h px� 
C
DRC finished with %s
272*project2

0 ErrorsZ1-461h px� 
d
BPlease refer to the DRC report (report_drc) for more information.
274*projectZ1-462h px� 
}

%s
*constraints2]
[Time (s): cpu = 00:00:03 ; elapsed = 00:00:02 . Memory (MB): peak = 786.449 ; gain = 32.891h px� 
O

Starting %s Task
103*constraints2
Logic OptimizationZ18-103h px� 
K

Phase %s%s
101*constraints2
1 2
InitializationZ18-101h px� 
_

Phase %s%s
101*constraints2
1.1 2"
 Core Generation And Design SetupZ18-101h px� 
\
%s*common2C
APhase 1.1 Core Generation And Design Setup | Checksum: 253fcd814
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.024 . Memory (MB): peak = 1161.645 ; gain = 0.000h px� 
a

Phase %s%s
101*constraints2
1.2 2$
"Setup Constraints And Sort NetlistZ18-101h px� 
^
%s*common2E
CPhase 1.2 Setup Constraints And Sort Netlist | Checksum: 253fcd814
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.040 . Memory (MB): peak = 1161.645 ; gain = 0.000h px� 
H
%s*common2/
-Phase 1 Initialization | Checksum: 253fcd814
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.043 . Memory (MB): peak = 1161.645 ; gain = 0.000h px� 
d

Phase %s%s
101*constraints2
2 2)
'Timer Update And Timing Data CollectionZ18-101h px� 
K

Phase %s%s
101*constraints2
2.1 2
Timer UpdateZ18-101h px� 
E
%Done setting XDC timing constraints.
35*timingZ38-35h px� 
H
%s*common2/
-Phase 2.1 Timer Update | Checksum: 253fcd814
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:12 ; elapsed = 00:00:11 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
U

Phase %s%s
101*constraints2
2.2 2
Timing Data CollectionZ18-101h px� 
R
%s*common29
7Phase 2.2 Timing Data Collection | Checksum: 253fcd814
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:12 ; elapsed = 00:00:11 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
a
%s*common2H
FPhase 2 Timer Update And Timing Data Collection | Checksum: 253fcd814
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:12 ; elapsed = 00:00:11 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
E

Phase %s%s
101*constraints2
3 2

RetargetZ18-101h px� 
V
1Number of loadless carry chains removed were: %s
839*opt2
0Z31-1851h px� 
�
XTotal Chains To Be Transformed Were: %s AND Number of Transformed insts Created are: %s
832*opt2
02
0Z31-1834h px� 
d
9Pulled %s inverters resulting in an inversion of %s pins
779*opt2
82
40Z31-1566h px� 
Q
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02
0Z31-138h px� 
9
Retargeted %s cell(s).
49*opt2
0Z31-49h px� 
B
%s*common2)
'Phase 3 Retarget | Checksum: 18d547d8d
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:12 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
4
Retarget | Checksum: 18d547d8d
*commonh px� 
c
.Phase %s created %s cells and removed %s cells267*opt2

Retarget2
02
8Z31-389h px� 
Q

Phase %s%s
101*constraints2
4 2
Constant propagationZ18-101h px� 
Q
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02
0Z31-138h px� 
N
%s*common25
3Phase 4 Constant propagation | Checksum: 2720407b3
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:12 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
@
+Constant propagation | Checksum: 2720407b3
*commonh px� 
o
.Phase %s created %s cells and removed %s cells267*opt2
Constant propagation2
02
0Z31-389h px� 
B

Phase %s%s
101*constraints2
5 2
SweepZ18-101h px� 
b
2Building netlist checker database with flags, 0x%s23991*constraints2
8Z18-11670h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2*
(Done building netlist checker database: 2

00:00:002
00:00:00.0062

1694.3712
0.000Z17-268h px� 
?
%s*common2&
$Phase 5 Sweep | Checksum: 22e645374
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:13 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
1
Sweep | Checksum: 22e645374
*commonh px� 
`
.Phase %s created %s cells and removed %s cells267*opt2
Sweep2
02
0Z31-389h px� 
N

Phase %s%s
101*constraints2
6 2
BUFG optimizationZ18-101h px� 
K
%s*common22
0Phase 6 BUFG optimization | Checksum: 22e645374
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:13 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
=
(BUFG optimization | Checksum: 22e645374
*commonh px� 
�
EPhase %s created %s cells of which %s are BUFGs and removed %s cells.395*opt2
BUFG optimization2
02
02
0Z31-662h px� 
X

Phase %s%s
101*constraints2
7 2
Shift Register OptimizationZ18-101h px� 
�
dSRL Remap converted %s SRLs to %s registers and converted %s registers of register chains to %s SRLs546*opt2
02
02
02
0Z31-1064h px� 
U
%s*common2<
:Phase 7 Shift Register Optimization | Checksum: 22e645374
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:13 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
G
2Shift Register Optimization | Checksum: 22e645374
*commonh px� 
v
.Phase %s created %s cells and removed %s cells267*opt2
Shift Register Optimization2
02
0Z31-389h px� 
t
Jcontrol_set_opt supports Versal devices only, and device %s is unsupported769*opt2
7a200tZ31-1555h px� 
T

Phase %s%s
101*constraints2
8 2
Post Processing NetlistZ18-101h px� 
Q
%s*common28
6Phase 8 Post Processing Netlist | Checksum: 22e645374
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:13 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
C
.Post Processing Netlist | Checksum: 22e645374
*commonh px� 
r
.Phase %s created %s cells and removed %s cells267*opt2
Post Processing Netlist2
02
0Z31-389h px� 
I

Phase %s%s
101*constraints2
9 2
FinalizationZ18-101h px� 
j

Phase %s%s
101*constraints2
9.1 2-
+Finalizing Design Cores and Updating ShapesZ18-101h px� 
g
%s*common2N
LPhase 9.1 Finalizing Design Cores and Updating Shapes | Checksum: 1e23340f7
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:14 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
]

Phase %s%s
101*constraints2
9.2 2 
Verifying Netlist ConnectivityZ18-101h px� 
O

Starting %s Task
103*constraints2
Connectivity CheckZ18-103h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.030 . Memory (MB): peak = 1694.371 ; gain = 0.000h px� 
Z
%s*common2A
?Phase 9.2 Verifying Netlist Connectivity | Checksum: 1e23340f7
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:14 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
F
%s*common2-
+Phase 9 Finalization | Checksum: 1e23340f7
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:14 ; elapsed = 00:00:12 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
/
Opt_design Change Summary
*commonh px� 
/
=========================
*commonh px� 


*commonh px� 


*commonh px� 
�
z-------------------------------------------------------------------------------------------------------------------------
*commonh px� 
�
�|  Phase                        |  #Cells created  |  #Cells Removed  |  #Constrained objects preventing optimizations  |
-------------------------------------------------------------------------------------------------------------------------
*commonh px� 
�
�|  Retarget                     |               0  |               8  |                                              0  |
|  Constant propagation         |               0  |               0  |                                              0  |
|  Sweep                        |               0  |               0  |                                              0  |
|  BUFG optimization            |               0  |               0  |                                              0  |
|  Shift Register Optimization  |               0  |               0  |                                              0  |
|  Post Processing Netlist      |               0  |               0  |                                              0  |
-------------------------------------------------------------------------------------------------------------------------
*commonh px� 


*commonh px� 


*commonh px� 
P
%s*common27
5Ending Logic Optimization Task | Checksum: 1e23340f7
h px� 


%s
*constraints2_
]Time (s): cpu = 00:00:14 ; elapsed = 00:00:13 . Memory (MB): peak = 1694.371 ; gain = 532.727h px� 
P

Starting %s Task
103*constraints2
Netlist ObfuscationZ18-103h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.0082

1694.3712
0.000Z17-268h px� 
Q
%s*common28
6Ending Netlist Obfuscation Task | Checksum: 1e23340f7
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.012 . Memory (MB): peak = 1694.371 ; gain = 0.000h px� 
H
Releasing license: %s
83*common2
ImplementationZ17-83h px� 
~
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
292
02
02
0Z4-41h px� 
J
%s completed successfully
29*	vivadotcl2

opt_designZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
opt_design: 2

00:00:212

00:00:192

1694.3712	
940.840Z17-268h px� 
�
Executing command : %s
56330*	planAhead2z
xreport_drc -file RV32I46F5SPSoCTOP_drc_opted.rpt -pb RV32I46F5SPSoCTOP_drc_opted.pb -rpx RV32I46F5SPSoCTOP_drc_opted.rpxZ12-24828h px� 
�
Command: %s
53*	vivadotcl2z
xreport_drc -file RV32I46F5SPSoCTOP_drc_opted.rpt -pb RV32I46F5SPSoCTOP_drc_opted.pb -rpx RV32I46F5SPSoCTOP_drc_opted.rpxZ4-113h px� 
>
Refreshing IP repositories
234*coregenZ19-234h px� 
G
"No user IP repositories specified
1154*coregenZ19-1704h px� 
j
"Loaded Vivado IP repository '%s'.
1332*coregen2!
D:/Xilinx/Vivado/2024.2/data/ipZ19-2313h px� 
>
Running DRC with %s threads
24*drc2
2Z23-27h px� 
�
#The results of DRC are in file %s.
586*	vivadotcl2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.runs/impl_1/RV32I46F5SPSoCTOP_drc_opted.rpt�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.runs/impl_1/RV32I46F5SPSoCTOP_drc_opted.rpt8Z2-168h px� 
J
%s completed successfully
29*	vivadotcl2

report_drcZ4-42h px� 
H
&Writing timing data to binary archive.266*timingZ38-480h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote PlaceDB: 2

00:00:002
00:00:00.0022

1694.3712
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote PulsedLatchDB: 2

00:00:002

00:00:002

1694.3712
0.000Z17-268h px� 
=
Writing XDEF routing.
211*designutilsZ20-211h px� 
J
#Writing XDEF routing logical nets.
209*designutilsZ20-209h px� 
J
#Writing XDEF routing special nets.
210*designutilsZ20-210h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote RouteStorage: 2

00:00:002
00:00:00.0492

1694.3712
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote Netlist Cache: 2

00:00:002

00:00:002

1694.3712
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote Device Cache: 2

00:00:002
00:00:00.0112

1694.3712
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Write Physdb Complete: 2

00:00:002
00:00:00.0722

1694.3712
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Write ShapeDB Complete: 2

00:00:002
00:00:00.0822

1694.3712
0.000Z17-268h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.runs/impl_1/RV32I46F5SPSoCTOP_opt.dcpZ17-1381h px� 


End Record