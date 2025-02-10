다시한번 잡고 가는 용어설명. hart = hardware thread.
그리고 다시금 강조되는 것이지만, 각 모드, 즉 계층별 하드웨어 접근 권한에 대한 보안이 이 Privileged Architecture의 주요 안건 인 것 같다.
hart는 보통 supervisor call이나 timer interrupt같은 트랩이 발생해서 트랩 핸들러로 강제 전환이 이뤄지기 전까지는
U-mode에서 application을 구동한다. which usually runs in a more privileged mode. 

트랩의 종류는 두가지로 나뉜다. privilege level을 높이는 vertical trap; 수직트랩.
같은 privilege level을 유지하는 horizontal trap; 수평트랩.
수평 트랩은 less-privileged mode의 horizontal trap handler에게 제어를 반환하는 수직 트랩으로 구현될 수도 있다.

1.3 디버그 모드.
off-chip 디버깅이나 제조 테스트를 위해서 디버그모드를 구현에 포함시킬 수도 있다. 
Debug mode(D-mode)는 M-mode보다 더 많은 접근권한을 가진 추가적인 privilege mode로 취급될 수 있다.
명시된 각 디버그 스펙들은 디버그 모드에서의 RISC-V hart의 동작을 서술한다.
디버그 모드는 D-mode에서만 접근가능한 몇 CSR 주소들을 reserve하고, 또한 부분적으로 플랫폼의 물리 주소 공간을 reserve할 수도 있다. 

제 2장. 제어 및 상태 레지스터들 (CSRs)
Chapter 2. Control and Status Registers (CSRs)

SYSTEM major opcode는 RISC-V ISA의 모든 privileged 명령어들을 인코딩하기 위해 사용됐다. 
이들은 두 가지의 main classes로 나눠질 수 있다: 
atomic하게 읽고, 변경하고, 쓸 수 있는 제어 및 상태 레지스터들(CSRs), 이것들은 Zicsr extension에서 정의된다. 
그리고  다른 privileged 명령어들.
Privileged 아키텍처는 Zicsr 확장을 필요로 한다; 다른 privileged 명령어들은 privileged 아키텍처 기능 집합에 따라 달라진다.

이 매뉴얼의 Volume I에서 다뤄진 Unprivileged 상태에 추가적으로, 
Volume I에서 묘사된 CSR 명령어들을 사용하여 privilege 레벨의 부분집합으로 접근할 수 있는 CSR들이 구현에 추가적으로 포함될 수 있다. 

이 챕터에서는 CSR의 주소 공간을 map out 해본다. 그 이후에 privilege 레벨에 따른 각 CSR들의 기능을 서술하고, 
일반적으로 특정 privilege 레벨과 밀접하게 연관된 다른 privilege 명령어들도 서술한다. 

표준 CSR들(Standard CSRs)는 읽기에서는 부작용이 없지만, 쓰기에서는 부작용이 있을 수 있다. 

2.1 CSR 주소 매핑 조약.
표준 RISC-V ISA 집합은 최대 4096개의 CSR을 위한 12비트 인코딩 공간(csr[11:0])을 확보한다.
조약에 따라, CSR 주소의 상위 4비트(csr[11:8])은 Table3에 보여진 privilege 레벨에 따른 읽기와 쓰기의 접근성을 인코딩하기 위해 사용된다. 
상위 2비트 (csr[11:10])는 register가 읽기/쓰기인지(00, 01 또는 10) 또는 읽기 전용(11)인지 표시한다. 
다음 2비트 (csr[9:8])은 최저 CSR에 접근할 수 있는 가장 낮은 privilege level을 인코드한다. 

하 그냥 중요내용만 요약 필기 하겠다.

적합한 privilege level 없이 CSR에 접근하려는 시도는 illegal-instruction exceptions 또는 virtual-instruction exception을 일으킨다.
"Attempts to access a CSR without
appropriate privilege level raise illegal-instruction exceptions or, as described in Section 18.6.1, virtualinstruction exceptions"

읽기 전용 레지스터에 쓰기 시도를 하면 illegal-instruction exception을 일으킨다. 
읽기/쓰기 레지스터는 읽기전용인 비트를 포함하고 있을 수 있다. 이 경우, 쓰기를 할 때 해당 읽기전용비트는 무시된다.(그 값이 유지된다는 의미인 듯.)

~2.1. CSR Address Mapping Conventions

Machine-mode standard 읽기-쓰기 CSR들 0x7A0 ~ 0x7BF는 디버깅 시스템의 사용을 위해 reserve 되어있다. 
이 CSR들 중, 0x7A0 ~ 0x7AF는 machine mode에서 접근가능하고, 그 반면 0x7B0 ~ 0x7BF는 디버그 모드에서만 보인다.
구현에는 후자(0x7B0 ~ 0x7BF; 디버그 모드에서만 보이는 CSRs)의 레지스터 세트에 대한 Machine mode 접근에 대하여 illegal-instruction exception을 일으켜야한다. 

---
어우 드디어 나왔다.. CSR Listing.. 

Table 3. RISC-V CSR 주소 범위 할당표. 이건 지금 솔직히 크게 중요하진 않... 아니 중요하네.. 하아...
몇 번 주소부터 몇 번 주소까지는 읽기/쓰기, 몇 번부터 몇 번은 읽기 전용.. 등등 privilege level에 따라 분리되어 서술되어있다. 

Table 4. 현재 할당된 RISC-V Unprivileged CSR 주소들.

Number | Privilege | Name | Description

[Unprivileged Floating-Point CSRs]

0x001 / URW / fflags / Floating-Point Accrued Exceptions
... 스킵.

[Unprivileged Counter/Timers]
싹 URO Privilege다. = Unprivileged Read Only
0xC00 / cycle / RDCYCLE 명령어를 위한 사이클 카운터.
0xC01 / time / RDTIME 명령어를 위한 타이머.
0xC02 / instret / RDINSTRET 명령어를 위한 Instructions-retired 카운터.

- !! Instructions-retired란 무엇인가? 실제로 수행되고 그 결과가 저장된 명령어의 수행 개수를 의미하는 이벤트이다.
 CPU는 기본적으로 꼭 필요한 연산만 진행하지 않고 불필요한 연산을 수행할 때가 있다. (예측 등.) 그들 중 '유효하게' 수행된 명령어의 갯수라고 볼 수 있겠다.
 비슷한 것으로 Instructions decoded라는 이벤트도 있다. RISC-V에서 지원하는지는 모르겠는데 인텔(x86)에서는 있었다. 
 이는 디코딩된 명령어로, 앞서 설명한 retired 명령어들의 수와 비교하여 차이를 볼 수 있다.
 https://community.intel.com/t5/Analyzers/What-does-quot-Instruction-Retired-quot-mean-exactly/td-p/990740
 https://stackoverflow.com/questions/22368835/what-does-intel-mean-by-retired
0xC03 / hpmcounter3 / 성능 모니터링 카운터.
0xC04 / hpmcounter4 / 성능 모니터링 카운터.
.
.
.
0xC1F / hpmcounter31 / 성능 모니터링 카운터.
0xC80 / cycleh / cycle CSR의 상위 32비트들. RV32 전용.
0xC81 / timeh / time CSR의 상위 32비트들. RV32 전용.
0xC82 / instreth / instret CSR의 상위 32비트들. RV32 전용.
0xC83 / hpmcounter3h / hpmcounter3 CSR의 상위 32비트들. RV32 전용.
0xC84 / hpmcounter4h / hpmcounter4 CSR의 상위 32비트들. RV32 전용.
.
.
.
0xC9F / hpmcounter31h / hpmcounter31의 상위 32비트들. RV32 전용.

이거 하나하나 다 보는 것 보다. 하드웨어적으로 로직 구현이 필요한 레지스터와 Privilege 레벨에 따라 읽기전용으로 해야하는지, 
읽기/쓰기 둘다 지원하는 건지만 봐야겠다. 이건 여기에 해석하는 의미가 없을 정도. 따로 엑셀로 만든다면 모를까.

[Supervisor Trap Setup]
별도 표기가 없으면 분류의 앞 단어에 따른 privilege level에 따르며, RW; Read/Write; 읽기쓰기 레지스터이다.
중요한 것만 따로 Name 적는다.
sstatus
sie
stvec
scounteren
아니 다 필요하네. 기계적 업데이트가 필요한 것들만.. 아니 조졌다 그냥 이거 다 하나하나 순서대로 구현하는게 맞다.

일단 Hypervisor단계는 단순 OS만 올릴 지금 시점에서는 필요가 없으니 제외.
총 CSR들의 갯수를 세어보고, 그 중 RV32I50F에서 구현이 필요한 명려어들만 추산해보자.
총 CSR들의 갯수는 Manual 기준 Currently allocated RISC-V CSR addresses를 따른다.

fflages, frm, fcsr, cycle, time, instret, hpmcounter3 ~ hpmcounter31(29), h명령어 cycle부터해서 32개
총 64개 + 3(FP CSRs) = 67개의 Unprivileged CSRs.

sstatus, sie, stvec, scounteren, senvcfg, scountinhibit, sscratch, sepc, scause, stval, sip, scountovf, satp
scontext, sstateen0, sstateen1, sstateen2, sstateen3 
18개의 Supervisor CSRs

mvendorid, marchid, mimpid, mhartid, mconfigptr, mstatus, misa, medeleg, mideleg, mie, mtvec, mcounteren, 
mstatush, medelegh, mscratch, mepc, mcause, mtval, mip, mtinst, mtval2, menvcfg, menvcfgh, mseccfg, mseccfgh,
pmpcfg0,.. PMP?? 아!!! 복선 회수!! Physical Memory Protection이란다..
pmpcfg는15까지.. pmpaddr이 0부터 63까지. mstateen0부터 3, h값 포함.
그럼 총 25개 + 16개 + 64개 + 8개 = 113개
mnscratch, mnepc, mncause, mnstatus, mcycle, minstret, mhpmcounter3~31, h포함 ×2.
mcounthibit, phpmevent3~31, h포함. tselect, tdata1~3, mcontext, dcsr, dpc, dscratch0, 1.
4+62+59+5+4 = 134개..

하이퍼바이저..
7+5+2+1+1+2+8+9 = 35개..

총 367개의 Allocated CSRs.. 그 중 우리가 구현해야할 것들을 추산해보자..

UI