WLRL - Write/Read Only Legal Values
오직 합법적인 값만 써야 하고, 읽을 때도 합법적인 값만 반환
잘못된 값을 쓰면 예외 발생가능.

WARL - Write Any Values, Reads Legal Values
아무 값이나 써도 되지만, 읽을 때는 항상 합법적인 값만 반환
잘못된 값을 써도 자동으로 수정. 

--Machine-level CSRs.--
- Machine Information Registers [Read Only]
mvendorid - 생산자명
RVKC. RISC-KC를 하려고 하였으나 32비트 구조 특성상 4바이트밖에 쓰지 못한다. 때문에 RVKC라는 이름으로 축약하여 인코딩했다.
01010010 01010110 01001011 01000011

marchid - 아키텍처명
bana. banana로 하려고 하였으나, 같은 이유로 bana로 줄였다. RV64에서 banana라는 풀 네이밍으로 진화한다.
01100010 01100001 01101110 01100001

mimpid - 구현이름
I5R1 = risc-v rv32'I' '5'0f. 'R'evision '1'
01001001 00110101 01010010 00110001

mhartid - 논리코어명
BNA0. bana 코어 0, 1, 2 이렇게 되도록 BNA0, BNA1 이런 네이밍으로 간다. BNA1. RV64에서는 BNN1로.
01000010 01001110 01000001 00110000

-----
- Machine Trap Setup
mstatus - hart의 현재 상태를 track하고 control하는 CSR. 
[31] = SD
[30:23] = WPRI
[22] TSR
[21] TW
[20] TVM
[19] MXR
[18] SUM
[17] MPRV
[16:15] XS [1:0]
[14:13] FX[1:0]
[12:11] MPP[1:0]
[10:9] VS[1:0]
[8] SPP
[7] MPIE
[6] UBE
[5] SPIE
[4] WPRI
[3] MIE
[2] WPRI
[1] SIE
[0] WPRI

mstatush (62:36 bit field of RV64's mstatus)
[31:6] WPRI
[5] MBE
[4] SBE
[3:0] WPRI

-----
misa [WARL]; 
Machine의 ISA 지원 내용을 다루는 CSR. 각 코드별로 어떤 ISA확장을 지원하는지 나타내는 hart의 상태 레지스터.
근데 왜 Write가 가능하냐? 동작 중 ISA의 지원도가 변경될 수 있기 때문. 만약 RV64IMAFD가 있다고 했을 때, D Extension을 비활성화하면 그 근원인 F Extension도 같이 비활성화되어야 하는 것이 그 사례.
하지만 RV32I50F코어는 단순 RV32I 코어이므로 쓰기 기능을 지원하지 않는 Read Only로 구현하여도 된다.
RV32이기에 MXL 필드는 1로 설정하고, Extensions필드는 매뉴얼에 따라 (The RISC-V Instruction Set Manual: Volume II의 22페이지. 3.1. Machine-Level CSRs; Table 10.)
8번째 비트만 1로 설정한다. 그럼 그 결과값은 다음과 같다. 
01000000 00000000 00000001 00000000 = 0x40000100

+추가적으로, misa의 Extension을 나타내는 비트영역은 수정이 가능하지만 MXL이 담기는 2비트는 ISA의 비트를 나타내는 공간이며 수정되어서는 안된다. 
때문에 이 비트를 쓰려고 하는 경우 Exception을 발생시켜야한다. Illegal Instruction Exception이 좋겠다. 아니면 쓰기 자체를 무시할 수도 있지만 기껏 만들어놓은 Exception Detector 및 Trap Handler이니 응용하도록 하자.

-----

mie [WARL]
Machine interrupt Enable.
mip; Machine interrupt Pending과 함께 사용된다. 
interrupt 발생시 해당 interrupt는 종류에 따라 mip의 특정 비트를 pending시키는데 (0에서 1로.)
해당 pending된 interrupt는 그 특정 비트에 대응되는 mie의 비트의 enable 여부에 따라(0인지 1인지.) 해당 interrupt를 실행할지 여부를 결정하게 된다. 
MXLEN의 길이를 가진다. 
mie의 [15:0] 매핑은 다음과 같다.
[13] LCOFIE
[11] MEIE
[9] SEIE
[7] MTIE
[5] STIE
[3] MSIE
[1] SSIE. 0번 비트를 포함한 나머지 15번 까지의 언급되지 않은 비트는 0이다.
mip도 마찬가지이다. 
[13] LCOFIP
[11] MEIP
[9] SEIP
[7] MTIP
[5] STIP
[3] MSIP
[1] SSIP.

그럼 나머지 [31:16]은 뭐하는 곳일까? 매뉴얼에서 말하길,
Bits 15:0 are allocated to standard interrupt causes only, while bits 16 and above are designated for platform use.
*Interrupts designated for platform use may be designated for custom use at the platform's discretion*
플랫폼에 재량에 따라 알아서 사용할 수 있단다.
mip와 mie에서 각 interrupt 값들을 할당해두었는데, 해당 bit i는 cause는 CSR의 mcause를 따른다. 
RISC-V Manual: Volume II에 Interrupt 처리에 대한 내용이 나와있는 것 같다..
3.1.9. Machine Interrupt Registers (mip and mie) 에 적힌 내용.
An interrupt i will trap to M-mode (causing the privilege mode to change to M-mode) if all of the following are true: 
(a) either the current privilege mode is M and the MIE bit in the mstatus register is set, or the current privilege mode has less privilege than M-mode; 
(b) bit i is set in both mip and mie; and (c) if register mideleg exists, but i is not set in medeleg. 
위에 해당하는 경우에서만 Interrupt가 M-mode로 넘어가 trap처리하게 된다.

현재 모드가 M이면, mstatus.MIE가 1이어야 인터럽트를 처리할 수 있다.
mip[i]와 mie[i]가 모두 1이어야 인터럽트가 발생할 수 있다.
mideleg가 존재하는 경우 해당 인터럽트가 medeleg에서 설정되지 않으면 M-mode로 트랩할 수 있다.

현재 M-mode = X ; mstatus.MIE = 0
M-mode로 트랩되지 않으며, 인터럽트는 다른 모드에서 처리되거나, 무시될 수 있다.

mip[i]와 mie[i] 중 하나라도 0
인터럽트가 발생하더라도 M-mode로 트랩되지 않으며, 인터럽트가 처리되지 않는다.

mideleg에 의해 인터럽트가 델리게이트 되어 있을 경우:
M-mode에서 인터럽트를 처리할 수 없고, S-mode나 다른 모드에서 처리된다.

-----
mtvec [WARL]
[31:2] BASE
[1:0] MODE
mtvec은 Trap 처리를 위한 주소 CSR 이다.
[1:0]의 MODE에 따라 그 동작이 정해진다.
MODE = 0 = Direct. All trap set pc to BASE.
PC값이 BASE 비트 필드 [31:2]에 있는 값이 되도록 한다. 임의의 트랩 핸들러 루틴의 시작 주소로 넘기는 것이다.
BASE 비트 필드 값은 4바이트 단위로 정렬되어 있어야 한다. 만약 미정렬된 경우, 강제로 하위 2비트를 0으로 설정하자. 
MODE = 1 = Vectored. Asynchronous interrupts set pc to BASE + 4 × cause
PC값이 BASE 비트 필드에 있는 값에 interrupt의 원인이 된 값이 있는 mcause 값을 4배 곱하여 더한다. 그리고 그 주소로 분기한다. 
이렇게 하면 각 interrupt나 Trap에 대하여 RISC-V에서 정의한 공간 주소를 사용하여 관리할 수 있다. 
-----

- Machine Trap Handling
mscratch - MRW. MXLEN-bit
M-mode 트랩 핸들러로 진입할 때 유저 레지스터 값을 저장하는 CSR.

RISC-V에서 각 특권 모드(Machine, Supervisor, User 등)마다 Scratch Register가 하나씩 있는데,
서로 컨텍스트 스위칭을하거나 트랩을 처리 할 때 중요한 정보를 저장하거나 교환하려고 사용한다.
M-mode에서 사용되고, M-mode 트랩 핸들러로 진입할 때와 유저 모드에서 M-mode로 컨텍스트 스위칭을 할 때 이 레지스터가 사용된다고 적혀있다.

**"Typically, it is used to hold a pointer to machine-mode hart-local context space and swapped with user register upon entry to an M-mode trap handler."**
hart-local context란, 현재 M-mode에서 실행 중인 프로세서 코어(hart)에 관련된 상태를 의미한다.
그 space를 포인터로 고정한다는건, 주소를 저장한다 볼 수 있고, 정리하여 M-mode에서 사용될 하드웨어 컨텍스트의 시작 주소가 저장된다 볼 수 있다.


mepc - WARL, MRW. MXLEN-bit
mepc[0] = 0 ; RV32일 경우 mepc[1:0] = 0. 항상.


mcause

mtval

mip
위의 mie 설명과 동일하다.