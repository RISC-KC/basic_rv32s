# Atomic Unit (AU)

[입력신호]
MemWrite    (from Control Unit)
Invalid     (from Control Unit - Rsv_Invalid)
Atomic      (from Control Unit - DC_Atomic_MUX)
RD1         (from Register File)
RD2         (from Register File)
Data_Addr   (from ALU - ALUresult)
CLK

[출력신호]
Rsv_YN      (to Control Unit)

[Logics]
Atomic Unit 안에는 A 확장의 핵심인 Reservation Set이 Register File로 구현되어있다.
32B 크기를 갖는 블럭의 주소 집합이다. Reservation Register라고 칭한다.
Atomic Unit 안에는 Reservation Register가 있고, 이를 제어하기 위한 제어 로직들이 있다.

Atomic 신호는 아래와 같은 이유로 존재한다.
Atomic Unit은 Atomic 연산임을 알아야한다.
기본적으로 reservation set에 해당하는 주소에 메모리 쓰기가 이뤄지는지를 보기 위해 MemWrite와 ALUresult값을 받는다.
MemWrite가 있을 때 ALUresult와 Reservation set을 비교하는 것이다. 

하지만 SC.W가 나올 때는
MemWrite가 기본적으로 비활성화 되어있다는 전제로, 이 경우 비교를 해야함을 알려주는 식별자가 없다. 
때문에, 이 경우 Atomic임을 알리는 신호를 통해 필연적으로 Reservation Set과 RD2가 비교되게 해야한다. 
이걸 위해, DC_Atomic_MUX를 Atomic이라는 신호로 Atomic Unit에 입력신호로 추가한다. 

----------

LR.W 명령어 실행시,
LR.W : R[rd] <- M[R[rs1]]
Reservation Set <- ( R[rs1]이 포함된 32B 블럭 주소 집합 ) 이 이뤄져야한다.

SC.W : 조건 확인. 
if { ( R[rs2] ∈ Reservation set && Reservation set == valid )
	M[R[rs1]] = R[rs2],
	R[rd] = 0
}

else R[rd] = 1
이 이뤄져야한다.

R[rs1] = RD1이고
R[rs2] = RD2이다. 그래서 해당 두 신호가 모두 필요하다.

SC.W에서 Reservation 검사를 위해 메모리 주솟값 (ALUresult)를 Reservation Set과 비교해야한다. 
위에서 발생한 모순점과 더불어, Store Conditional. 즉, 저장을 위해 데이터가 입력되기 전, reservation의 판단이 이루어져야한다. 
Store을 위한 주소 즉, RD1 값이 (Register File에 5비트 rs1이 입력되는 순간 그 비트를 주솟값으로 하는 레지스터에 쓰여져있는 데이터 출력) 인출되는 순간,
reservation set과 비교되며 조건문을 거쳐 동작의 수행이 이뤄지도록 하는 것이 자연스러우며 구조적으로 기능을 구현하기에 이상적이라 할 수 있다. 

Reservation Set을 등록하기 위한 R[rs1], 즉 Register File 로부터의 RD1 신호.
Reservation Set과 R[rs2], 즉 Register File 로부터의 RD2 신호.
ALUresult, SC외 Reservation set에 해당하는 주소 쓰기 접근이 발생했는지를 알기 위한 메모리의 주소 신호.

받아야하는 데이터 신호는 위 세 가지이다. 
나머지는 제어 신호.

MemWrite : SC 외 Reservation set에 해당하는 주소 쓰기 접근이 발생했는지를 알기 위한 메모리의 쓰기 활성화를 알리는 식별신호.
항상 주솟값인 ALUresult가 입력되고 있을텐데 이 것들까지 다 비교하고 reservation set을 invalidate 하면 안되기 때문이다. 해당 주솟값으로의 쓰기가 발생했을 때에만 일어나야하니 이 MemWrite라는 식별 신호가 필요하다. 

Rsv_Invalid : Control Unit에서 SC.W 명령어의 수행을 식별하면 Reservation Set을 invalidate 시키기 위해 이 신호를 Atomic Unit에 입력시키고, Atomic Unit이 Reservation Set을 Invalidate 한다.

[Note]
자세한 내용은 랑그너일기 3630째 줄, 2024.04.21부터 참조하라.
Zalrsc 명령어 확장, Zaamo, aq, rl 비트 에 대한 구현 내용이 모두 기록되어 있다.

