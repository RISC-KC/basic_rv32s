본 문서에서는 RV32I50F 코어 구조의 캐시-메모리 구조에 대해서 기술한다. 

RV32I47NF (구 RV32I50F) 프로세서의 메모리 구조는 다음과 같다.
1. Instruction Memory
2. Instruction Cache
3. Data Memory
4. Data Cache

여기서 Instruction Memory와 Cache를 모아 Instruction 메모리 진영이라고 부르고,
Data Memory와 Cache를 모아 Data 메모리 진영이라고 부른다.

추후 Instruction Memory와 Data Memory는 통합 메모리로 병합될 예정이다. 
DDR3 SDRAM을 이식할 것인데, 그 전까지는 FPGA 내의 BRAM으로 합성을 의도하고 있다. 

본 프로세서는 기본적인 Write-Back 캐시 쓰기 정책을 따르며,
추후 서술 될 STAA; Synchronized Total Address Access, 동기식 통합 주소 접근 방식을 읽기 정책으로 사용한다.
(STAA는 현 SAA; Simultanious Address Access로 명칭이 바뀌었다.)

Instruction Memory는 현재 별도의 I/O를 지원하지 않는 프로세서 특성상 ROM으로 구현한다. 
Insturcion Cache는 때문에 비교적 동작방식이 단순하다.

**RV32I43FC 기반 캐시 구조 제원 정의**
# RV32I43FC based Cache Structure Specification (L1$)

## L1 Cache Specification

**2-Way Set Associative**

**32KiB**, respectively for each Instruction & Data Cache (Harvard Structure)
**Total 64KiB of L1$**

**32B Data per Block** ( 8 Word per Block )
64B Data per Set ( 2-Way )

2 Ways, 512 Sets, 1024 Blocks.
──────────────────────────────
## Cache Structure & Policies
Cache Block Replace Mechanism : **LRU** ( Least Recently Used )
Hardware Structure : **Write Buffer**

Original Mechanism : **SAA** ( Simultanious Address Access )

If **Address Port A** = **Address Port B**, WAR(Write after Read) Policy.
Read must be preceded and Write should follow up.
──────────────────────────────
## Cache Design
Block = 메모리 계층 간 최소 단위

[Tag, Index, Offset]
> Tag : Block Search in Set
> Index : Set Search in Way
> Offset : Data Search in Block

32 - 5 (offset, log₂32 = 5) = 27 bits for Tags & Indexs
> log₂512 = **9 bits for Indexs**
> 27 - 9 = **18 bits for Tags**

**32-bit Requested Address : **
> Tag         [31:14]    18-bit
> Index     [13:5]      9-bit
> Offset   [4:2]        5-bit

Tag [31:14], Index [13:5], Offset[4:2]
[1:0] is 00 for 32-bit aligning

# RV32I43FC 기반 메모리 계층 구조 동작
[ **Write Buffer, SAA(Simultaneous Address Access) 채택. **]

## 1. 읽기 (Load)
[**Cache Hit**] (이 경우 Dirty Bit은 상관 없다.)

① 캐시로부터 해당 데이터 반환
[**Cache Miss**] 
① 메모리 접근 
② 해당 Index의 교체할 블럭 판단 (Dirty Bit Check)

    [**if Clean**]
    ***CLK 1***
    ⑴ **SAA** 메모리 데이터 반환
    ⑵ 메모리의 반환 데이터 그대로 캐시에 덮어쓰기.
    ⑶ 덮어쓰여진 캐시 Dirty Bit Set

_if not SAA_
    ***CLK 2***
    ⑷ 캐시의 해당 주소에 갱신된 Clean 블록 데이터 반환
—————
    [**if Dirty**]
    ***CLK 1***
    ⑴ **SAA** 메모리 데이터 반환
    ⑵ 캐시의 Dirty 데이터 블럭을 해당 주솟값과 같이 Write-Buffer에 저장
    ⑶ 캐시 Dirty Bit 해소
    ***CLK 2***
    [ SAA 이후 **요청 주소는 계속 입력되고 있어야 함** ]
    ( 3번 과정을 위해 메모리 블록에서 인출될 데이터의 주솟값이 필요하기 때문 )
    ⑶ Clean된 해당 캐시 블록에 메모리 블록 덮어쓰기
    ⑷ Write Buffer에 저장된 주소와 데이터를 해당 메모리에 쓰기

(혹시나 하지만, Write Buffer에 저장된 주소가 메모리의 갱신 주소랑은 겹칠 수 없음. 겹친다면 애초부터 Cache-Hit여야 함. )

_if not SAA_
    ***CLK 3***
    ⑸ 캐시의 해당 주소에 갱신된 Clean 블록 데이터 반환

## 2. 저장 (Store)

[**Cache Hit**] 
① 캐시에 해당 데이터 쓰기 (Dirty Bit Set)

[**Cache Miss**]
① 메모리 접근 
② 해당 Index 교체할 Block의 Dirty Bit 판단

    [**if Clean**]
    ***CLK 1***
    ⑴ 메모리의 반환 데이터 덮어쓰기
    ***CLK 2***
    ⑴ 덮어쓴(갱신된) 캐시 블럭에 쓰기작업
    ⑵ 해당 블럭 Dirty Bit Set

—————
    [**if Dirty**]
    ***CLK 1***
    ⑴ 캐시의 Dirty 데이터 블록을 주솟값과 함께 Write-Buffer 저장

    ┌ _if not SAA_ ; ***CLK 2***┐
    ⑵ 메모리 반환 데이터 덮어쓰기 ; Clean Block
    
```SAA Hazard 예상 가능. 
메모리 반환 데이터가 덮어씌워질 주소 = Dirty Data Block. 
L1$가 가장 빠르니까 타이밍 상 맞을 수는 있는데, 우려는 충분. 만약 상황 발생 시 고찰 필요. ```

    ***CLK 2***  
    ├_if not SAA_; ***CLK 3***
    ⑴ 갱신된 Clean 캐시에 새 값 쓰기
    ⑵ 새 값 쓰여진 해당 블록 Dirty Bit Set
    ⑶ Write-Buffer에서 메모리로 해당 데이터 출력, 메모리 갱신 (캐시-메모리 동기화)