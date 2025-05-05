# Data Memory (DM)

[입력신호]
CLK
+ DM_Addr     (from DM_Addr_MUX)
+ WB_Data     (from Write Buffer)
+ WriteEnable (from ~DC_Status)

[출력신호]
DM_RD           (to BE_Logic - DM2RF_RD)
+ DM_WriteDone  (to DataReady_OR)

[Logics]
CLK rising edge에서 작동한다. 
Data Cache에서 출력되는 DC_Status 신호를 통해 쓰기가 제어된다. 
DC_Status가 0으로 Cache Hit이라면 쓰기를 진행하지 않는다. 
DC_Status가 Miss로 캐시 내부 라인의 교체를 위해 Write Back이 일어나야할 때 Data Memory의 Write가 수행된다. 
이 때 쓰여지는 데이터는 WB_Data로 들어오는 쓰여져야할 데이터이다. 이는 곧 캐시의 블럭이 데이터 입력으로 들어오며, DM_Addr에 입력된 주소를 기반으로 offset 연산하여 필요한 word만 쓰기한다. 
읽기는 여전히 비동기식이다.
DM_Addr은 주소 입력으로, 해당 주소를 읽거나 주소에 쓴다.

DM_Addr의 데이터를 읽을 경우, DM_RD 출력 신호로 데이터를 출력한다.

[Note]
... 
DM_Addr로 입력되는 Memory 주소는 SAA시 사용되어야할 기존의 ALUresult값과 C2M(Cache to Memory) 갱신(flush)시 사용되어야할 해당 WriteBack 대상 주소값 WB_Addr 중에 선택된다. 
이 선택은 DM_Addr_MUX에서 Cache의 Hit/Miss 여부에 따라 달라진다. 

ByteMask는 Cache단에서 1차적으로 처리하므로 Data Memory에서는 사라졌다. 


WB_Data     = Write Back Data signal
DM_Addr     = Data Memory input Address
DM_RD       = Data Memory Read Data