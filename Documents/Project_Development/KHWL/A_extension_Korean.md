[2025.04.25.]

A확장의 근간은 다수의 RISC-V hart들이 같은 메모리 공간에서 작동할 때 원자적으로 메모리를 읽고-변경하고-쓰고 하는 것을 동기화하기 위함이다. 
두 가지 형태의 atomic instruction이 있고, 하나는 'load-reserved/store-conditional instructions'. 나머지 하나는 'atomic fetch-and-op memory instructions'이다. 
(각각 Zalrsc 확장과 Zaamo 확장으로 이원화된 A확장이 가능하다. )

둘 다 다양한 메모리 일관성 순서를 지원하는데, unordered, acquire, release 그리고 sequentially consistent semantics를 지원한다.
이러한 명령어들은 RISC-V가 RCsc 메모리 일관성 모델을 지원하도록 한다. 
(RCsc : release consistency with special accesses sequentially consistent; Memory consistency and event ordering in scalable shared-memory multiprocessors, Gharachorloo et al., 1990) 

숱한 토론 끝에, RISC-V에서는 rlease consistency를 표준 메모리 일관성 모델로 삼았다. 
그래서 RISC-V의 atomic support는 해당 모델을 기반으로 한다.

기본 RISC-V ISA는 relaxed memory model을 가지고 있고 FENCE 명령어를 통해 추가적인 순서 강제를 부여한다. 
주소 공간은 실행 환경을 통해 메모리와 I/O 영역으로 나뉘어진다. FENCE 명령어는 그 중 하나 또는 두 가지 전체 주소 영역에 대한 접근을 order할 수 있는 options를 제공한다. 

14.1 나머지는 aq, rl 비트에 대한 내용으로 긴급도가 조금 떨어지는 부분이니 이미 이해가 됐다 가정하고 일단 넘어간다.

14.2. "Zalrsc" Extension for Load-Reserved / Store-Conditional Instructions.
복잡한 atomic memory operations..

ㅇ이걸 통번역하라고? 안돼.. reservation이랑 reservation set관련 말이 있는 것만 발췌해야겠다. 

LR.W loads a word from the address in rs1, places the sign-extended value in rd, and registers a **reservation set** 
- a set of bytes that subsumes the bytes in the addressed word.
= LR.W는 rs1의 주소에서 word를 적재하고, 그의 sign-extended 값을 rd 주소에 둔 뒤, reservation set에 등록한다. 
__reservation set은 rs1의 주소에서 적재한 word의 byte를 포함하고 있는 byte의 집합이다.__

SC.W conditionally write a word in rs2 to the address in rs1: the SC.W succeeds only if the **reservation** is still valid and the **reservation set** contains the bytes being written.
= SC.W는 rs2의 word를 조건적으로 rs1에 쓴다. SC.W는 reservation이 여전히 유효하고, reservation set이 rs1에 쓰여질 바이트를 포함하고 있으면 성공한다.

Regardless of success or failure, executing an SC.W instruction invalidates any **reservation** held by this hart.
= 성공과 실패를 떠나서, SC.W 명령어를 수행하는 것으로 해당 hart가 쥐고있는 모든 reservation은 무효화된다. 

Misalinged LR/SC sequences also raise the possibility of accessing multiple **reservation sets** at once, which present definitions do not provide for.
= 미정렬된 LR/SC 시퀀스는 현재의 정의가 제공하지 않는 다수의 reservation set을 한번에 접근하게 되는 확률을 높인다.
(LR/SC 시퀀스는 하나의 쌍으로서 존재하고, 다수의 rerservation set을 현재의 정의가 제공하지 않는다는 것은 reservation set 자체는 한 번의 시퀀스 내에서 쓰일 데이터를 hold하고 있는 데이터 공간으로 보면 될까?)

An implementation can register an arbitrarily large **reservation set** on each LR, provided the **reservation set** includes all bytes of the addressed data word or double word.
= 각 LR에 대해서 임의로 큰 reservation set을 등록할 수 있지만 해당 reservation set은 명령어가 접근한 모든 word 또는 double word 바이트들이 포함되어있어야 한다.

An SC can only pair with the most recent LR in program order. 
= 프로그램 순서상 하나의 SC는 오로지 최근의 LR과만 짝 지을 수 있다. 

An SC may succeed only if no store from another hart to the **reservation set** can be observed to have occurred between the LR and the SC, and if there is no other SC between the LR and ifself in program order. 
= SC는 다른 hart에서 LR과 SC 사이에서 발생한 reservation set으로의 저장 동작이 관측되지 않을 때만, 그리고 프로그램 순서상 LR 사이에 또 다른 SC가 없을 때만 성공할 수 있다. 

An SC may succeed only if no write from a device other than a hart to the bytes accessed by the LR instruction can be observed to have occurred between the LR and SC.
= SC는 

Note this LR might have had a different effective address and data size, but **reserved** the SC's address as part of the **reservation set**

To accommodate legacy devices and buses, writes from devices other than RISC-V harts are only required to invalidate **reservations** when they overlap the bytes accessed by the LR. 
These writes are not required to invalidate the **reservation** when they access other bytes in the **reservation set**

The SC must fail if the address is not within the **reservation set** of the most recent LR in program order. 
The SC must fail if a store to the **reservation set** from another hart can be observed to occur between the LR and SC.
The SC must fail if a write from some other device to the bytes accessed by the LR can be observed to occur between the LR and SC.
(If such a device writes the **reservation set** but does not write the bytes accessed by the LR, the SC may or may not fail.)

The platform should provide a means to determine the size and shape of the **reservation set**.

A platform specification may constrain the size and shape of the **reservation set**.

The invaildation of a hart's **reservation** when it executes an LR or SC imply that a hart can only hold one **reservation** at a time, and that an SC can only pair with the most recent LR, and LR with the next following SC, in program order. 
This restriction to the Atomicity Axiom in Section 17.1 that ensures software runs correctly on expected common implementations that operate in this manner. 

An SC instructions can never be observed by another RISC-V hart before the LR instruction that established the **reservation**.

