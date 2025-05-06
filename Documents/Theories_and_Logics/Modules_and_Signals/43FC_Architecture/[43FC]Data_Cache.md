# Data Cache (DC)

[입력신호]
CLK
RST
MemWrite        (from Control Unit)
MemRead         (from Control Unit)
DC_Addr         (from ALU - ALUresult)
DC_WD           (from DC_WD_MUX)
ByteMask        (from BE_Logic)

[출력신호]
WB_Addr         (tp Write_Buffer)
WB_Data         (to Write_Buffer)
DC_WriteDone    (to DataReady_OR)
DC_RD           (to D_RD_MUX)
DC_Status       (to DC_WD_MUX, D_RD_MUX, DM_Addr_MUX, Data Memory - WriteEnable)

[Logics]
43FC_Cache-Memory_Structure.md 참조

[Note]
43FC_Cache-Memory_Structure.md 참조